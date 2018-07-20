variable "instance_name" {
  description = "Name of instance"
}

variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable private_key_path {
  description = "Path to the private key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable disk_image {
  description = "Disk image for reddit db"
  default     = "ubuntu-minimal-18.04-lts"
}

variable disk_size {
  description = "Disk size"
  default     = "20"
}

variable machine_type {
  description = "Machine type for instance"
  default     = "g1-small"
}

variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable "dns_zone_name" {
  description = "Dns managed zone name"
}

variable "tcp_ports" {
  description = "List of opened instance's tcp ports"
}
