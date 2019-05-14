output "frontend_ip" {
    value       = "http://${google_compute_global_address.this.address}"
}

output "frontend_dns" {
    value       = "http://${google_dns_record_set.this.name}"
}
