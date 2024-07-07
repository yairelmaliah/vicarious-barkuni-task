locals {
  environment = "dev"
  cluster_name = "${local.environment}-barkuni"

  domain_name = "barkuni.nya-solutions.com"
  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}