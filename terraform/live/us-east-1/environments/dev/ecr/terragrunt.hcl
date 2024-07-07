terraform {
  source = "tfr:///terraform-aws-modules/ecr/aws?version=2.2.1"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment = local.env_vars.locals.environment
}

inputs = {
  repository_name = "barkuni-app"
  repository_lifecycle_policy = jsonencode({
      rules = [
        {
          rulePriority = 1,
          description  = "Keep last 30 images",
          selection = {
            tagStatus     = "tagged",
            tagPrefixList = ["v"],
            countType     = "imageCountMoreThan",
            countNumber   = 30
          },
          action = {
            type = "expire"
          }
        }
      ]
    })

  tags = local.env_vars.locals.tags
}