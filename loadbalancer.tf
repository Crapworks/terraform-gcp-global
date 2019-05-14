data "null_data_source" "backend_mapping" {
  count = "${length(local.regions)}"
  inputs = {
    group = "${google_compute_region_instance_group_manager.frontend.*.instance_group[count.index]}"
  }
}

resource "google_compute_backend_service" "this" {
  name        = "${var.name}-backend-service"
  port_name   = "echoserver"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend = ["${data.null_data_source.backend_mapping.*.outputs}"]

  health_checks = ["${google_compute_http_health_check.this.self_link}"]
}

resource "google_compute_url_map" "this" {
  name            = "${var.name}-global-map"
  default_service = "${google_compute_backend_service.this.self_link}"
}

resource "google_compute_target_http_proxy" "this" {
  name        = "${var.name}-proxy"
  url_map     = "${google_compute_url_map.this.self_link}"
}

resource "google_compute_global_forwarding_rule" "this" {
  name       = "${var.name}-global-forwarding"
  ip_address = "${google_compute_global_address.this.address}"
  target     = "${google_compute_target_http_proxy.this.self_link}"
  port_range = "80"
}

resource "google_compute_http_health_check" "this" {
  name               = "${var.name}-http-base-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
  port               = 8080
}

resource "google_compute_global_address" "this" {
  name = "${var.name}-frontend-address"
}

