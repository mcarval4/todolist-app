provider "kind" {}

resource "kind_cluster" "todolist" {
  name            = var.cluster_name
  node_image      = var.node_image
  wait_for_ready  = true
  kubeconfig_path = pathexpand("~/.kube/config")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      disable_default_cni = true
    }

    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 30080
        host_port      = 80
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 30443
        host_port      = 443
        protocol       = "TCP"
      }
    }

    node { role = "worker" }
    node { role = "worker" }
    node { role = "worker" }
  }
}
