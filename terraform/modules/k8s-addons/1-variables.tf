variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
}

variable "oidc_provider_arn" {
  description = "IAM Openid Connect Provider ARN"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with your cluster."
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API server."
  type        = string
}

variable "helm_releases" {
  description = "Helm releases information."
  type = map(any)

  default = {}
}

