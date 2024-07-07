terragrunt_version_constraint = ">= 0.60"

remote_state {
  backend = "s3"
  config = {
    profile = "nya-solutions"
    role_arn = "arn:aws:iam::156444772887:role/terraform"
    bucket = "vicarious-task-terraform-state"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-lock-table"
  }

  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  profile = "nya-solutions"

  assume_role {
    session_name = "terraform"
    role_arn = "arn:aws:iam::156444772887:role/terraform"
  }
}
EOF
}