resource "kubernetes_secret" "timeoff_secrets" {
  metadata {
    name = "timeoff-secrets"
  }

  type = "Opaque"

  data = {
    db_user = var.db_user
    db_password = var.db_password
       
  }
}
