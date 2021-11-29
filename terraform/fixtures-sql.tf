resource "kubernetes_config_map" "fixtures_sql" {
    depends_on = [kubernetes_namespace.module_namespace]
    metadata {
        name = "fixtures-sql"
        namespace = var.module_namespace
    }

    data = {
        "fixtures.sql" = "${file("${path.module}/../docker/mysql/fixtures.sql")}"
    }
}
