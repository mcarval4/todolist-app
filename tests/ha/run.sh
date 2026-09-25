#!/bin/sh
set -eu

namespace="${NAMESPACE:-todolist}"
deployment="${DEPLOYMENT:-todolist-todolist}"
cluster_name="${CLUSTER_NAME:-todolist-demo}"
health_url="${HEALTH_URL:-http://todolist.localhost/healthz}"
output_dir="evidence/generated/ha-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$output_dir"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  }
}

for command in kubectl curl docker; do
  require_command "$command"
done

probe() {
  while :; do
    status=$(curl --connect-timeout 2 --max-time 5 --silent --output /dev/null --write-out '%{http_code}' "$health_url" || true)
    printf '%s %s\n' "$(date -u +%FT%TZ)" "$status" >>"$output_dir/health.log"
    sleep 1
  done
}

probe &
probe_pid=$!
cleanup() {
  kill "$probe_pid" 2>/dev/null || true
  if [ -n "${stopped_worker:-}" ]; then
    docker start "$stopped_worker" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

kubectl rollout status "deployment/$deployment" -n "$namespace" --timeout=180s

kubectl rollout restart "deployment/$deployment" -n "$namespace"
kubectl rollout status "deployment/$deployment" -n "$namespace" --timeout=180s

pod=$(kubectl get pods -n "$namespace" -l app.kubernetes.io/name=todolist -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod -n "$namespace" "$pod" --wait=false
kubectl rollout status "deployment/$deployment" -n "$namespace" --timeout=180s

worker=$(kubectl get pods -n "$namespace" -l app.kubernetes.io/name=todolist -o jsonpath='{.items[0].spec.nodeName}')
stopped_worker="$cluster_name-${worker#${cluster_name}-}"
docker stop "$stopped_worker" >/dev/null
sleep 10

kubectl get pods -n "$namespace" -o wide >"$output_dir/pods-after-worker-failure.txt"
kubectl get hpa,pdb -n "$namespace" >"$output_dir/availability-controls.txt"
sleep 5

failed=$(awk '$2 != "200" { count++ } END { print count + 0 }' "$output_dir/health.log")
total=$(wc -l <"$output_dir/health.log" | tr -d ' ')
printf 'total=%s failed=%s\n' "$total" "$failed" >"$output_dir/summary.txt"

if [ "$failed" -gt 10 ]; then
  printf 'HA test exceeded the 10-second node-failure error budget.\n' >&2
  exit 1
fi

printf 'HA test passed. Evidence: %s\n' "$output_dir"
