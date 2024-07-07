# Vicarious Task

## Overview

This project establishes a complete infrastructure using Terraform and Terragrunt to deploy an Amazon EKS cluster within a dedicated VPC. The setup includes ArgoCD for continuous deployment, orchestrating updates and management of Kubernetes resources automatically through GitOps principles.
Additionally, the project hosts the Barkuni API, a Flask-based RESTful service, which is containerized with Docker and managed via Kubernetes/helm. Also there is a CI-CD workflows to automate build test and deploy new versions of the app using github actions

## Tools and Technologies

- **Python & Flask**: For building the RESTful API.
- **Terragrunt**: For infrastructure provisioning on AWS.
- **Docker**: For application containerization.
- **Kubernetes & Helm**: For orchestrating and managing the containerized application.
- **GitHub Actions**: For CI/CD workflows.
- **AWS EKS**: As the Kubernetes environment.
- **AWS ECR**: For Docker image storage.

## File Structure

```plaintext
/
├── .github/workflows   # CI/CD pipeline configurations
├── api                 # Flask application code
│   ├── app
│   └── tests
├── k8s                 # Kubernetes resources
│   ├── barkuni-chart   # Barkuni helm chart
│   └── infra           # Other infra related resources (ingress, metrics-server)
└── terraform           # Terraform configurations
    ├── live            # Terragrunt live configurations
    └── modules         # Reusable Terraform modules
```

## Getting Started

### Prerequisites
- AWS CLI configured with Administrator access
- Docker installed and running
- Helm and kubectl installed and configured
- Terraform and Terragrunt installed

## Initial Setup

### Create IAM Role for Terraform

Create an IAM role named `terraform` with Administrator access and attach the policy to your user to allow to assume terraform role:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": ["sts:AssumeRole"],
            "Resource": ["arn:aws:iam::12345678910:role/terraform"]
        }
    ]
}
```

### Configure Terragrunt
Update the root terragrunt.hcl to include the IAM role:

```hcl
assume_role {
  session_name = "terraform"
  role_arn = "arn:aws:iam::12345678910:role/terraform"
}
```

### Deployment
1. Navigate to the Terraform Directory:

    `cd terraform/live`.

2. Run Terragrunt:
    Initialize and apply the configuration:
    ```bash
    terragrunt run-all plan
    terragrunt run-all apply
    ```

## Continuous Integration and Deployment
The project uses GitHub Actions for CI/CD. It automatically builds the Docker image, pushes it to AWS ECR, and updates barkuni chart upon commits to the master branch.

after new Image tag was commits into the barkuni chart, ArgoCD detect the new image and automatically update the application. 

## Additional Notes
**Domain** : http://barkuni.nya-solutions.com/
