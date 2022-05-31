resource "yandex_dns_zone" "dns_zone_public" {
  name = "remote-development-dns-zone"
  zone = var.dns_zone
  public = true
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