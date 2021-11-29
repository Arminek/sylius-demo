resource "kubernetes_config_map" "nginx" {
    depends_on = [kubernetes_namespace.module_namespace]
    metadata {
        name = "nginx"
        namespace = var.module_namespace
    }

    data = {
        "default.conf" = "${file("${path.module}/../docker/nginx/k8s.conf")}"
    }
}
