resource "kubernetes_namespace" "todolist" {
  metadata {
    name = "todolist"
    labels = {
      "pod-security.kubernetes.io/enforce" = "restricted"
    }
  }
}

resource "random_password" "database" {
  length  = 32
  special = false
}

resource "random_password" "session" {
  length  = 48
  special = false
}

resource "random_password" "cleanup" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "todolist" {
  metadata {
    name      = "todolist-secrets"
    namespace = kubernetes_namespace.todolist.metadata[0].name
  }

  data = {
    DB_USER        = "todolist"
    DB_PASSWORD    = random_password.database.result
    SESSION_KEY    = random_password.session.result
    ADMIN_USER     = "admin"
    ADMIN_PASSWORD = "admin"
    CLEANUP_TOKEN  = random_password.cleanup.result
  }
}

resource "kubernetes_secret" "database" {
  metadata {
    name      = "todolist-db-credentials"
    namespace = kubernetes_namespace.todolist.metadata[0].name
  }

  data = {
    username = "todolist"
    password = random_password.database.result
  }
}

resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.16.5"
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [file("${path.module}/values/cilium.yaml")]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.12"
  create_namespace = true
  wait             = true
  timeout          = 600

  values     = [file("${path.module}/values/argocd.yaml")]
  depends_on = [helm_release.cilium]
}

resource "helm_release" "kyverno" {
  name             = "kyverno"
  namespace        = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  version          = "3.3.6"
  create_namespace = true
  wait             = true
  timeout          = 600

  values     = [file("${path.module}/values/kyverno.yaml")]
  depends_on = [helm_release.cilium]
}

resource "helm_release" "cnpg" {
  name             = "cloudnative-pg"
  namespace        = "cnpg-system"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  version          = "0.22.1"
  create_namespace = true
  wait             = true
  timeout          = 600

  depends_on = [helm_release.cilium]
}

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = "3.12.2"
  create_namespace = false
  wait             = true
  timeout          = 600

  values     = [file("${path.module}/values/metrics-server.yaml")]
  depends_on = [helm_release.cilium]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  version          = "25.27.0"
  create_namespace = true
  wait             = true
  timeout          = 600

  values     = [file("${path.module}/values/prometheus.yaml")]
  depends_on = [helm_release.cilium]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  namespace        = "monitoring"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = "8.8.2"
  create_namespace = true
  wait             = true
  timeout          = 600

  values     = [file("${path.module}/values/grafana.yaml")]
  depends_on = [helm_release.prometheus]
}

resource "local_file" "argocd_application" {
  filename = "${path.module}/application.generated.yaml"
  content = templatefile("${path.module}/../../platform/argocd/application.yaml.tftpl", {
    git_repository_url = var.git_repository_url
  })
}

resource "local_file" "kyverno_policy" {
  filename = "${path.module}/kyverno.generated.yaml"
  content = templatefile("${path.module}/../../platform/policies/kyverno.yaml.tftpl", {
    repository_identity = trimsuffix(var.git_repository_url, ".git")
  })
}

resource "null_resource" "application_resources" {
  triggers = {
    application = local_file.argocd_application.content_sha256
    kyverno     = local_file.kyverno_policy.content_sha256
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -eu
      kubectl apply -f ${path.module}/../../platform/database/cluster.yaml
      kubectl apply -f ${local_file.kyverno_policy.filename}
      kubectl apply -f ${local_file.argocd_application.filename}
    EOT
  }

  depends_on = [
    helm_release.argocd,
    helm_release.kyverno,
    helm_release.cnpg,
    kubernetes_secret.database,
  ]
}

resource "null_resource" "platform_cleanup" {
  triggers = {
    cluster_name = "todolist-db"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl delete application/todolist -n argocd --ignore-not-found
      kubectl delete cluster/todolist-db -n todolist --ignore-not-found --wait=true --timeout=300s
      kubectl delete clusterpolicy/todolist-workload-baseline --ignore-not-found
    EOT
  }

  depends_on = [null_resource.application_resources]
}
