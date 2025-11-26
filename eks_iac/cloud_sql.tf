resource "google_sql_database_instance" "timeoff_db_instance_gke" {
  name             = "timeoff-db-instance-gke"
  database_version = "MYSQL_5_7"
  region           = var.gcp_region
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks {
        name            = "office-ip"
        value           = "192.222.40.114/32"
        expiration_time = "3021-11-15T16:19:00.094Z"
      }
      ipv4_enabled    = false
      private_network = data.google_compute_network.default_network.id
    }
  }
  depends_on = [google_service_networking_connection.private_vpc_connection_gke]
}


resource "google_sql_database" "timeoff_db" {
  name      = var.db_name
  instance  = google_sql_database_instance.timeoff_db_instance_gke.name
  charset   = "UTF8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "timeoff_db_user" {
  name     = kubernetes_secret.timeoff_secrets.data["db_user"]
  instance = google_sql_database_instance.timeoff_db_instance_gke.name
  host     = "%" #da moze sve ip adrese da se povezu
  password = kubernetes_secret.timeoff_secrets.data["db_password"]
}

