data "digitalocean_kubernetes_cluster" "main" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
  token                  = data.digitalocean_kubernetes_cluster.main.kube_config[0].token
}

provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
    token                  = data.digitalocean_kubernetes_cluster.main.kube_config[0].token
  }
}

provider "digitalocean" {
  token = var.digital_ocean_access_token
}
