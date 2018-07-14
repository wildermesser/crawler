resource "google_compute_firewall" "jenkins_ssh" {
  name    = "allow-jenkins-default-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins"]
}

resource "google_dns_record_set" "jenkins" {
  name = "jenkins.${google_dns_managed_zone.ocrawler.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.ocrawler.name}"

  rrdatas = ["${google_compute_instance.jenkins.network_interface.0.access_config.0.assigned_nat_ip}"]
}

resource "google_dns_managed_zone" "ocrawler" {
  name     = "ocrawler"
  dns_name = "ocrawler.tk."
}
