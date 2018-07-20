resource "google_compute_instance" "instance" {
  name         = "${var.instance_name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["${var.instance_name}"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
      size  = "${var.disk_size}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "messer:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "messer"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "../../docker-compose/${var.instance_name}/docker-compose.yml"
    destination = "/home/messer/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "docker-compose up -d",
    ]
  }
}
