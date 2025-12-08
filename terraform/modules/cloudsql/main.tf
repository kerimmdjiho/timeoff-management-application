resource "google_sql_database_instance" "timeoff_db_instance" {
  name             = "${var.env}-db-instance"#"timeoff-db-instance"
  database_version = "MYSQL_5_7"
  region           = var.gcp_region
  deletion_protection = false
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }
  depends_on = [var.vpc_connection_ready]
}


resource "google_sql_database" "timeoff_db" {
  name      = var.db_name
  instance  = google_sql_database_instance.timeoff_db_instance.name
  charset   = "UTF8"
  collation = "utf8_general_ci"
  project =  var.gcp_project_id
}

resource "google_secret_manager_secret" "db_pass_secret" {
  secret_id = "${var.env}-db-password"
  project   = var.gcp_project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_pass_secret_version" {
  secret      = google_secret_manager_secret.db_pass_secret.id
  secret_data = var.data
}

resource "google_sql_user" "timeoff_db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.timeoff_db_instance.name
  host     = "%" #da moze sve ip adrese da se povezu
  password = google_secret_manager_secret_version.db_pass_secret_version.secret_data
  depends_on = [ google_secret_manager_secret_version.db_pass_secret_version ]
}
