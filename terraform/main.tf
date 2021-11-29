data "kubernetes_service" "ingress_controller" {
  metadata {
    namespace = var.nginx_namespace
    name = var.nginx_controller_name
  }
}

resource "kubernetes_namespace" "module_namespace" {
  metadata {
    name = var.module_namespace
  }
}

resource "digitalocean_record" "module_subdomain" {
  domain   = var.main_domain
  type     = "A"
  name = var.sub_domain
  value = data.kubernetes_service.ingress_controller.status[0].load_balancer[0].ingress[0].ip
}
