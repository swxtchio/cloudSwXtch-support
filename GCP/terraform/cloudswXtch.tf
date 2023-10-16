provider "google" {
  project = var.project_id
  zone    = var.zone
}

locals {
  ssh_key_metadata = var.ssh_public_key != "" && var.ssh_user != "" ? "${var.ssh_user}:${var.ssh_public_key}" : ""
}

data "cloudinit_config" "swxtch_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"

    content = <<EOF
#!/bin/bash
set -ex

function wait_for_url() {
  local __url=$1

  local curl_attempt_counter=0
  local curl_max_attempts=60

  until $(curl --output /dev/null --silent --fail $__url); do
      if [ $curl_attempt_counter -eq $curl_max_attempts ];then
        echo "Max attempts reached"
        return 255
      fi

      printf '.'
      curl_attempt_counter=$(($curl_attempt_counter+1))
      sleep 10
  done
  return 0
}

wait_for_url "http://localhost:80/swxtch/debug/v1/version"
/swxtch/swx update -i localhost -v "${var.swxtch_version}"

EOF
  }
}

resource "google_compute_instance" "swxtch" {
  count = var.swxtch_count

  name = "${var.name}-${count.index}"

  machine_type = var.swxtch_machine_type

  min_cpu_platform = "Intel Ice Lake"

  metadata = {
    user-data = data.cloudinit_config.swxtch_config.rendered
    ssh-keys  = local.ssh_key_metadata
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cloudswxtch.id
    }
  }

  network_interface {
    subnetwork = var.ctrl_subnet_id
  }

  network_interface {
    subnetwork = var.data_subnet_id
    nic_type   = "VIRTIO_NET"
  }
}
