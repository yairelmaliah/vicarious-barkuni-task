resource "kubernetes_manifest" "argo_infra_application" {
  count = var.create_infra_application ? 1 : 0
  
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "argo-infra"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/yairelmaliah/vicarious-barkuni-task.git"
        targetRevision = "HEAD"
        path           = "k8s/infra/"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
      }
      syncPolicy = {
        automated = {
          selfHeal = true
          prune     = true
        }
      }
    }
  }
}

resource "kubernetes_manifest" "argo_chart_application" {
  count = var.create_chart_application ? 1 : 0
  
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "argo-chart"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/yairelmaliah/vicarious-barkuni-task.git"
        targetRevision = "HEAD"
        path           = "k8s/barkuni-chart/"
        helm = {
          parameters = [
            {
              name  = "global.serviceAccount.name"
              value = aws_eks_pod_identity_association.barkuni-app-sa.service_account
            },
          ]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          selfHeal = true
          prune     = true
        }
      }
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "pod-identity-role" {
  name               = "${var.cluster_name}-pod-identity-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2-full-access-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.pod-identity-role.name
}

resource "aws_eks_pod_identity_association" "barkuni-app-sa" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "barkuni-app-sa"
  role_arn        = aws_iam_role.pod-identity-role.arn
}