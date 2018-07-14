provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
  version = "1.16"
}

resource "google_compute_instance" "jenkins" {
  name         = "jenkins"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["jenkins"]

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

  provisioner "remote-exec" {
    script = "../files/install_docker.sh"
  }
}
