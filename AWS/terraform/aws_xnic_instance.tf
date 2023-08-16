data "aws_ami" "ubuntu2004" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical
}

# This will connect all xNIC instances to the first swXtch.
data "cloudinit_config" "xnic_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"

    content = <<EOT
#!/bin/bash

function wait_for_url() {
  local __url=$1

  local curl_max_attempts=$${2:-5}

  local curl_attempt_counter=0
  until $(curl --output /dev/null --silent --fail $__url); do
      if [ $curl_attempt_counter -eq $curl_max_attempts ];then
        echo "Max attempts reached"
        return 255
      fi

      printf '.'
      curl_attempt_counter=$(($curl_attempt_counter+1))
      sleep 5
  done
  return 0
}

# Wait for the cloudSwxtch to respond and be ready
wait_for_url "http://${aws_network_interface.swxtch_ctrl[0].private_ip}/swxtch/debug/v1/version" 20
if [[ $? -ne 0 ]] ; then
  exit 1
fi

# Install the xNIC
curl --fail http://${aws_network_interface.swxtch_ctrl[0].private_ip}/services/install/swxtch-xnic-install.sh | bash -s -- -k -v "${var.xnic_version}"
if [[ $? -ne 0 ]] ; then
  exit 1
fi
EOT
  }
}

resource "aws_instance" "xnic_instance" {
  count = var.xnic_instance_count

  ami           = data.aws_ami.ubuntu2004.id
  instance_type = var.instance_type
  key_name      = var.aws_ssh_key_name
  tags = {
    Name = "${var.swxtch_name}-0${count.index}"
  }

  user_data                   = data.cloudinit_config.xnic_config.rendered
  user_data_replace_on_change = true

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xnic_ctrl[count.index].id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.xnic_data[count.index].id
  }
}

resource "aws_network_interface" "xnic_data" {
  count           = var.xnic_instance_count
  subnet_id       = var.data_subnet_id
  security_groups = [aws_security_group.swxtch_traffic.id]

  tags = {
    Name = "xnic_${count.index}_data"
  }
}

resource "aws_network_interface" "xnic_ctrl" {
  count           = var.swxtch_count
  subnet_id       = var.control_subnet_id
  security_groups = [aws_security_group.swxtch_traffic.id]

  tags = {
    Name = "xnic_${count.index}_ctrl"
  }
}
