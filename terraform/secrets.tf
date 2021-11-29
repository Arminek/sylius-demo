resource "kubernetes_secret" "mysql" {
    depends_on = [data.digitalocean_database_cluster.main, kubernetes_namespace.module_namespace]
    metadata {
        name = "mysql-cluster"
        namespace = var.module_namespace
    }

    data = {
        username = data.digitalocean_database_cluster.main.user
        password = data.digitalocean_database_cluster.main.password
        uri = data.digitalocean_database_cluster.main.uri
        port = data.digitalocean_database_cluster.main.port
        host = data.digitalocean_database_cluster.main.host
        database_name = format("%s_%s", var.app_name, var.env)
    }
}

resource "kubernetes_secret" "github_registry" {
  depends_on = [kubernetes_namespace.module_namespace]
  metadata {
    name = "github-registry"
    namespace = var.module_namespace
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.ghcr_username
          password = var.ghcr_password
          email = var.ghcr_email
          auth = var.ghcr_auth
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}
