variable "cluster_name" {
  description = "Name of the cluster."
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

variable "create_infra_application" {
  description = "Create the application."
  type        = bool
}

variable "create_chart_application" {
  description = "Create the application."
  type        = bool
}