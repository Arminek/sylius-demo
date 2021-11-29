resource "kubernetes_persistent_volume_claim" "persistent_volume_claim" {
    depends_on = [kubernetes_namespace.module_namespace]
    metadata {
        name = "swibeco-demo"
        namespace = var.module_namespace
    }
    spec {
        access_modes = ["ReadWriteMany"]
        storage_class_name = "nfs"
        resources {
            requests = {
                storage = "2Gi"
            }
        }
    }
}
