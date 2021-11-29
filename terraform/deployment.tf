resource "kubernetes_deployment" "main" {
    depends_on = [kubernetes_secret.mysql, digitalocean_database_db.main, kubernetes_namespace.module_namespace]
    wait_for_rollout = false
    metadata {
        name      = var.app_name
        namespace = var.module_namespace
        labels    = {
            env = var.env
            app = var.app_name
        }
    }

    spec {
        replicas = 1

        selector {
            match_labels = {
                env = var.env
                app = var.app_name
            }
        }

        template {
            metadata {
                labels = {
                    env = var.env
                    app = var.app_name
                }
            }

            spec {
                volume {
                    name = "shared-data"
                    persistent_volume_claim {
                        claim_name = "swibeco-demo"
                        read_only = false
                    }
                }
                volume {
                    name = "cache"
                    empty_dir {}
                }
                volume {
                    name = "nginx"
                    config_map {
                        name = "nginx"
                        items {
                            key = "default.conf"
                            path = "default.conf"
                        }
                    }
                }
                init_container {
                    image_pull_policy = "Always"
                    name = "copy-public"
                    image = lower(var.app_docker_image)
                    volume_mount {
                        mount_path = "/public"
                        name       = "shared-data"
                    }
                    command = ["cp", "-a", "/app/public", "/public"]
                }
                init_container {
                    image_pull_policy = "Always"
                    name = "cache-clear"
                    image = lower(var.app_docker_image)
                    volume_mount {
                        mount_path = "/app/var/cache"
                        name       = "cache"
                    }
                    command = ["/bin/bash", "-c", "php bin/console cache:clear && php bin/console cache:warmup"]
                }
                container {
                    image_pull_policy = "Always"
                    image = "nginx:stable-alpine"
                    name  = "nginx"
                    port {
                        container_port = 80
                    }
                    volume_mount {
                        mount_path = "/app/public"
                        name       = "shared-data"
                        sub_path = "public"
                    }
                    volume_mount {
                        mount_path = "/etc/nginx/conf.d/default.conf"
                        name       = "nginx"
                        sub_path = "default.conf"
                    }
                    resources {
                        limits   = {
                            cpu    = "0.5"
                            memory = "128Mi"
                        }
                        requests = {
                            cpu    = "0.2"
                            memory = "50Mi"
                        }
                    }
                    liveness_probe {
                        http_get {
                            path = "/"
                            port = 80
                        }

                        initial_delay_seconds = 3
                        period_seconds        = 3
                    }
                }
                container {
                    image_pull_policy = "Always"
                    image = lower(var.app_docker_image)
                    name = "php"
                    port {
                        container_port = 9000
                    }
                    volume_mount {
                        mount_path = "/app/public"
                        name       = "shared-data"
                        sub_path = "public"
                    }
                    volume_mount {
                        mount_path = "/app/config/jwt"
                        name       = "shared-data"
                        sub_path = "jwt"
                    }
                    volume_mount {
                        mount_path = "/app/var/cache"
                        name       = "cache"
                    }
                    volume_mount {
                        mount_path = "/app/var/sessions"
                        name       = "shared-data"
                        sub_path = "sessions"
                    }
                    resources {
                        limits   = {
                            cpu    = "1.5"
                            memory = "1024Mi"
                        }
                        requests = {
                            cpu    = "0.5"
                            memory = "256Mi"
                        }
                    }
                    env {
                        name = "MYSQL_USER"
                        value_from {
                            secret_key_ref {
                                name = "mysql-cluster"
                                key = "username"
                            }
                        }
                    }
                    env {
                        name = "MYSQL_PASSWORD"
                        value_from {
                            secret_key_ref {
                                name = "mysql-cluster"
                                key = "password"
                            }
                        }
                    }
                    env {
                        name = "MYSQL_HOST"
                        value_from {
                            secret_key_ref {
                                name = "mysql-cluster"
                                key = "host"
                            }
                        }
                    }
                    env {
                        name = "MYSQL_PORT"
                        value_from {
                            secret_key_ref {
                                name = "mysql-cluster"
                                key = "port"
                            }
                        }
                    }
                    env {
                        name = "MYSQL_DATABASE_NAME"
                        value_from {
                            secret_key_ref {
                                name = "mysql-cluster"
                                key = "database_name"
                            }
                        }
                    }
                }
                image_pull_secrets {
                    name = "github-registry"
                }
            }
        }
    }
}
