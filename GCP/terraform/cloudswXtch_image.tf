data "google_compute_image" "cloudswxtch" {
  project     = "mpi-swxtchio-public"
  name        = var.swxtch_image_id
  most_recent = true
}
