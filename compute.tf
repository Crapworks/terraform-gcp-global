locals {
    regions = "${data.google_compute_regions.available.names}"
}

data "google_compute_regions" "available" {}

data "google_compute_zones" "available" {
  count  = "${length(local.regions)}"
  region = "${local.regions[count.index]}"
}

data "google_compute_image" "cos" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_compute_instance_template" "frontend" {
  count        = "${length(local.regions)}"
  name         = "${var.name}-template-${local.regions[count.index]}"
  machine_type = "n1-standard-1"

  disk {
    source_image = "${data.google_compute_image.cos.self_link}"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.this.*.self_link[count.index]}"
  }

  metadata {
    gce-container-declaration = <<-EOF
      spec:
        containers:
          - name: echoserver-template
            image: 'k8s.gcr.io/echoserver:1.10'
      EOF
  }

  labels {
    container-vm = "${data.google_compute_image.cos.name}"
  }

  service_account {
    scopes = ["compute-ro", "storage-ro"]
  }
}

resource "google_compute_region_instance_group_manager" "frontend" {
  count = "${length(local.regions)}"
  name  = "${var.name}-mig-${local.regions[count.index]}"

  region                     = "${local.regions[count.index]}"
  base_instance_name         = "${var.name}-mig-${local.regions[count.index]}"
  instance_template          = "${google_compute_instance_template.frontend.*.self_link[count.index]}"
  distribution_policy_zones  = ["${data.google_compute_zones.available.*.names[count.index]}"]

  target_size  = "${length(data.google_compute_zones.available.*.names[count.index]) * var.instances_per_zone}"

  named_port {
    name = "echoserver"
    port = 8080
  }
}
