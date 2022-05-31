variable "token" {
  type = string
  description = "yandex cloud token"
}

variable "cloud_id" {
  type = string
  description = "yandex cloud_id"
}

variable "folder_id" {
  type = string
  description = "yandex cloud folder_id"
}

variable "dns_zone" {
  type = string
  description = "environment dns zone"
}

variable "subnet_id" {
  type = string
  description = "yandex cloud subnet_id"
}

variable "vm_username" {
  type = string
  description = "yandex cloud ssh username"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    key = "terraform/state/main.tfstate"
    region = "ru-central1"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-b"
}

resource "yandex_dns_zone" "dns_zone_public" {
  name = "remote-development-dns-zone"
  zone = var.dns_zone
  public = true
  labels = {
    "project" = "development-environment"
    "environment" = "development"
  }
}

resource "yandex_compute_instance" "dev01" {
  hostname = "vm-dev01"
  
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
      image_id = "fd84uu6t8d9c96589gvr"
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

resource "yandex_dns_recordset" "dev01_dns01" {
  zone_id = yandex_dns_zone.dns_zone_public.id
  name = "dev01"
  type = "A"
  ttl = 600
  data = [yandex_compute_instance.dev01.network_interface.0.nat_ip_address]
}