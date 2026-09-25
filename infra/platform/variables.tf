variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "git_repository_url" {
  type        = string
  description = "HTTPS URL of this repository, used by Argo CD."
}
