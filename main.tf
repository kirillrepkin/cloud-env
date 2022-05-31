resource "yandex_compute_instance" "dev01" {

  hostname = "vm-dev01"
  name = "vm-dev01"
  
  metadata = {
    "ssh-keys"  = "${var.vm_username}:${file("~/.ssh/id_rsa.pub")}"
    "user-data"          = <<-EOT
            #cloud-config
            datasource:
             Ec2:
              strict_id: false
            ssh_pwauth: no
            users:
            - name: ${var.vm_username}
              sudo: ALL=(ALL) NOPASSWD:ALL
              shell: /bin/bash
              ssh-authorized-keys:
              - ${file("~/.ssh/id_rsa.pub")}
        EOT
  }
  
  platform_id = "standard-v3"

  boot_disk {
    initialize_params {
      image_id = var.devvm_image_id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat = true
    dns_record {
      fqdn = "dev01.${var.dns_zone}"
    }
  }

  resources {
      core_fraction = 50
      cores = 4
      memory = 8
  }

  scheduling_policy {
      preemptible = true
  }
  
  labels = {
    "project" = "development-environment"
    "environment" = "development"
  }
}