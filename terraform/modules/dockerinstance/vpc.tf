resource "google_compute_firewall" "instance_tcp" {
  name    = "allow-default-${var.instance_name}-tcp"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = "${var.tcp_ports}"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.instance_name}"]
}

resource "google_dns_record_set" "instance_dns_name" {
  name = "${var.instance_name}.${var.dns_zone_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${var.managed_zone_name}"

  rrdatas = ["${google_compute_instance.instance.network_interface.0.access_config.0.assigned_nat_ip}"]
}
