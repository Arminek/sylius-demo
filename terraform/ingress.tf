resource "kubernetes_ingress" "main" {
    depends_on             = [kubernetes_namespace.module_namespace]
    wait_for_load_balancer = true
    metadata {
        name        = "ingress"
        namespace   = var.module_namespace
        annotations = {
            "cert-manager.io/cluster-issuer" : "letsencrypt"
            "kubernetes.io/ingress.class" : "nginx"
        }
    }

    spec {
        rule {
            host = format("%s.%s", var.sub_domain, var.main_domain)
            http {
                path {
                    backend {
                        service_name = var.app_name
                        service_port = 80
                    }
                    path = "/"
                }
            }
        }

        tls {
            hosts       = [format("%s.%s", var.sub_domain, var.main_domain)]
            secret_name = format("secret-tls-%s", var.app_name)
        }
    }
}
