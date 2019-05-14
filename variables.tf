variable "name" {
  default = "terraform"
}

variable "instances_per_zone" {
  default = "1"
}

variable "subnet" {
  default = "10.0.0.0/16"
}

variable "dns_project" {
  default = "premium-cloud-support-dns"
}
