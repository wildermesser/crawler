provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
  version = "1.16"
}

resource "google_dns_managed_zone" "ocrawler" {
  name     = "ocrawler"
  dns_name = "ocrawler.tk."
}

module "jenkins" {
  source        = "../modules/dockerinstance"
  instance_name = "jenkins"

  public_key_path   = "${var.public_key_path}"
  private_key_path  = "${var.private_key_path}"
  zone              = "${var.zone}"
  disk_image        = "${var.disk_image}"
  disk_size         = "10"
  machine_type      = "${var.machine_type}"
  dns_zone_name     = "ocrawler.tk."
  managed_zone_name = "ocrawler"
  tcp_ports         = ["22", "8080"]
}

module "production" {
  source        = "../modules/dockerinstance"
  instance_name = "production"

  public_key_path   = "${var.public_key_path}"
  private_key_path  = "${var.private_key_path}"
  zone              = "${var.zone}"
  disk_image        = "${var.disk_image}"
  disk_size         = "10"
  machine_type      = "${var.machine_type}"
  dns_zone_name     = "ocrawler.tk."
  managed_zone_name = "ocrawler"
  tcp_ports         = ["22", "8000"]
}
