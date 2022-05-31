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

variable "devvm_image_id" {
    type = string
    description = "VM ID (packer build)" 
}