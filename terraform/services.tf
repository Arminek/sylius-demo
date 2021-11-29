resource "kubernetes_service" "main" {
    depends_on = [kubernetes_namespace.module_namespace]
    metadata {
        name      = var.app_name
        namespace = var.module_namespace
        labels    = {
            env = var.env
            app = var.app_name
        }
    }
    spec {
        selector = {
            app = var.app_name
            env = var.env
        }
        port {
            port        = 80
            protocol    = "TCP"
            target_port = 80
        }

        type = "NodePort"
    }
}
