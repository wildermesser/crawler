output "db_external_ip" {
  value = "${google_compute_instance.jenkins.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "ns_servers" {
  value = "${google_dns_managed_zone.ocrawler.name_servers}"
}
