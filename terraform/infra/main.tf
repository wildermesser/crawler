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
  source        = "github.com/wildermesser/dockerinstance"
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

  remote_commands = [
    "cd ~",
    "sudo docker run -p 8080:8080 -d -u root -v /var/run/docker.sock:/var/run/docker.sock --restart always -v jenkins-data-1:/var/jenkins_home  jenkinsci/blueocean:latest",
  ]
}

module "production" {
  source        = "github.com/wildermesser/dockerinstance"
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

  remote_commands = [
    "cd ~",
    "sudo chgrp -R ubuntu /var/lib/docker/containers",
    "sudo chmod -R g+rx /var/lib/docker/containers",
    "sudo chown ubuntu filebeat.conf",
    "sudo docker-compose up -d",
  ]
}

module "monitoring" {
  source        = "github.com/wildermesser/dockerinstance"
  instance_name = "monitoring"

  public_key_path   = "${var.public_key_path}"
  private_key_path  = "${var.private_key_path}"
  zone              = "${var.zone}"
  disk_image        = "${var.disk_image}"
  disk_size         = "10"
  machine_type      = "${var.machine_type}"
  dns_zone_name     = "ocrawler.tk."
  managed_zone_name = "ocrawler"
  tcp_ports         = ["22", "80", "8086"]

  remote_commands = [
    "cd ~",
    "sudo docker-compose up -d",
  ]
}

module "logging" {
  source        = "github.com/wildermesser/dockerinstance"
  instance_name = "logging"

  public_key_path   = "${var.public_key_path}"
  private_key_path  = "${var.private_key_path}"
  zone              = "${var.zone}"
  disk_image        = "${var.disk_image}"
  disk_size         = "10"
  machine_type      = "n1-standard-1"
  dns_zone_name     = "ocrawler.tk."
  managed_zone_name = "ocrawler"
  tcp_ports         = ["22", "80", "9200"]

  remote_commands = [
    "cd ~",
    "sudo sysctl -w vm.max_map_count=262144",
    "sudo docker-compose up -d",
  ]
}
