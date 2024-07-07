terraform {
  source = "${get_path_to_repo_root()}/terraform/modules/argocd-bootstrap-apps"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    cluster_name = "dev-eks-cluster"
    oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E55B018D5B6D6D6D6"
    cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJTys3R2FBMXNadFl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBM01EWXhPVFUxTVRkYUZ3MHpOREEzTURReU1EQXdNVGRhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNZd1duSVpGRDNWeGFpNFZtY21NR2NzYzFjZW12bzdOZFg4dFVWVmdmNWRHZE96dUNxSlJTN1RpWUQKQm5vUHk4U2xsTkZwRzE5SUlWZVdHd1o5d2s2TmdxZWxiTmxxWk9NU0lWdUR2RitVTTB4ZHJRRmJsN2M5NVVtMgpyUEhUUXA4b3BaMWlHNHh2Q3dndXV3V2xwOTIzMHlKNHFML2puL1h2R0FhQTJFMkdpajNZOGp4QnZacEkyaXp4CjRTaGtFc0R0eGE5eVpWT1dFV2lvL3F6eThGSDkvaHM2VWd1bmwraVRvMzBxTFlidk9JNHI5OXcrWDdLZC9ZL1cKQnFUVmxMUmlkVUIwMzBiOFFHK05DbFBqZElOcXBJaDBFZzBvaHJqYWNMYVI1NnI2WkVZL3o3bWFQVEJPeW00YwpKSVc4ZVN4WTRCVm5uVjAvQVF2OWFWVkRUamoxQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJScEpYYlQxbjBDbUExc2lQYUV5VTBkZFdUQ0VqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQkNrZUxSWXUwWApYNTVUUzVNVkwwNnhnVFN0RGpVOVptVGJRUnNQdy9xNTd2SFlLV21yc3JLcnZzNG1zSUt3VUFtWVB3SE84Z0FPCkU2YWRENXNMMGZoNlBFUU9hNHpKajBPOFBmTThCenpZeFpmclRwYzdEQW9hRmlJWGxidGhKZUtrUThkNktrOS8KQVd4QVhHbitucndnR0JzcG5KUWt5TkpGRlBmbW9VWXZHMXZOQ2RaKzk2eW5TeHlNOXhtOUVBMXprS3gxWi9FSQo1WXRjVVlvL1dPVDMxZFpKZ2ZaaWJHL0FUcW9NeGNJWUhrU3Brd2lSdWZaQUpnMjBueUM5MmxlTW9JcjVrc3liCkt4MmpXUGV5b3pmMnZIRUFjNjdDMDhCSlJmR2lpdlNWTXA5aUI4MUFpbFplbTRtcEY1WDA5Z1hiU1pKOGVhYlMKRUVNaGF6d2p1ZlpZCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
    cluster_endpoint = "https://abcd.us-east-1.eks.amazonaws.com"
  }
}

dependencies {
  paths = ["../k8s-addons"]
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment = local.env_vars.locals.environment
}

inputs = {
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_endpoint = dependency.eks.outputs.cluster_endpoint
  cluster_name = dependency.eks.outputs.cluster_name

  create_infra_application = true
  create_chart_application = true
}

generate "k8s-provider" {
  path      = "k8s-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
EOF
}