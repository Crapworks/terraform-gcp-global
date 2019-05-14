resource "google_compute_network" "this" {
  name                    = "${var.name}-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "this" {
  count                    = "${length(local.regions)}"
  name                     = "${var.name}-subnetwork-${local.regions[count.index]}"
  ip_cidr_range            = "${cidrsubnet(var.subnet, 8, count.index)}"
  region                   = "${local.regions[count.index]}"
  network                  = "${google_compute_network.this.self_link}"
  private_ip_google_access = true
}

resource "google_compute_firewall" "this" {
  name    = "${var.name}-firewall"
  network = "${google_compute_network.this.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}

data "google_dns_managed_zone" "this" {
  name    = "ceichelmann"
  project = "${var.dns_project}"
}

resource "google_dns_record_set" "this" {
  name    = "${var.name}.${data.google_dns_managed_zone.this.dns_name}"
  project = "${var.dns_project}"
  type    = "A"
  ttl     = 300

  managed_zone = "${data.google_dns_managed_zone.this.name}"

  rrdatas = ["${google_compute_global_address.this.address}"]
}
