resource "helm_release" "argocd" {
  count = try(var.helm_releases["argocd"]["enabled"], false) ? 1 : 0

  name = try(var.helm_releases["argocd"]["name"], "argocd")
  repository = try(var.helm_releases["argocd"]["repository"], "https://argoproj.github.io/argo-helm")
  chart = try(var.helm_releases["argocd"]["chart"], "argo-cd")
  version = try(var.helm_releases["argocd"]["version"], "7.3.4")
  namespace = try(var.helm_releases["argocd"]["namespace"], "argocd")
  create_namespace = true

  values = [ 
    file("values/argocd.yaml")
  ]
}
