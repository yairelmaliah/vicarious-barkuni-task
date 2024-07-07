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