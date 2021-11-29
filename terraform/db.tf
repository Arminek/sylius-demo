data "digitalocean_database_cluster" "main" {
    name = var.mysql_cluster_name
}

resource "digitalocean_database_db" "main" {
    depends_on = [data.digitalocean_database_cluster.main]
    cluster_id = data.digitalocean_database_cluster.main.id
    name       = format("%s_%s", var.app_name, var.env)
}

resource "kubernetes_job" "load_fixtures" {
    depends_on = [digitalocean_database_db.main, kubernetes_secret.mysql, kubernetes_namespace.module_namespace]
    metadata {
        name = "fixtures"
        namespace = var.module_namespace
    }
    spec {
        template {
            metadata {}
            spec {
                volume {
                    name = "fixtures-sql"
                    config_map {
                        name = "fixtures-sql"
                        items {
                            key = "fixtures.sql"
                            path = "fixtures.sql"
                        }
                    }
                }
                container {
                    name    = "mysql"
                    image   = "mysql"
                    command = ["bin/bash", "-c", "cat fixtures.sql | mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) -h$(MYSQL_HOST) -P$(MYSQL_PORT) $(MYSQL_DATABASE_NAME)"]
                    volume_mount {
                        mount_path = "/fixtures.sql"
                        name       = "fixtures-sql"
                        sub_path = "fixtures.sql"
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
                restart_policy = "Never"
            }
        }
        backoff_limit = 4
    }
    wait_for_completion = true
}
