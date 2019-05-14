provider "google" {
  credentials = "${file("./credentials.json")}"
  project     = "ceichelmann-swisscom"
  version     = "v2.3.0"
}
