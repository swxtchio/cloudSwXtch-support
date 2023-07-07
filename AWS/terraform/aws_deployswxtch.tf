# Security group provided as an example. Modify to suit your needs.
resource "aws_security_group" "swxtch_traffic" {
  name        = "swxtch_traffic_${var.swxtch_name}_sg"
  description = "Allow traffic for swXtch processing"

  vpc_id = var.vpc_id

  tags = {
    "Name" = "swxtch_traffic_${var.swxtch_name}_sg"
  }

  ingress {
    description = "Allow ssh traffic from all addresses"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow All Traffic from this security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "swxtch_data" {
  count           = var.swxtch_count
  subnet_id       = var.data_subnet_id
  security_groups = [aws_security_group.swxtch_traffic.id]

  tags = {
    Name = "${var.swxtch_name}_${count.index}_data"
  }
}

resource "aws_network_interface" "swxtch_ctrl" {
  count           = var.swxtch_count
  subnet_id       = var.control_subnet_id
  security_groups = [aws_security_group.swxtch_traffic.id]

  tags = {
    Name = "${var.swxtch_name}_${count.index}_ctrl"
  }
}

# If you wish to update the cloudswXtch version during cloud-init, include this block
# and pass it to the user_data section of the aws_instance
data "cloudinit_config" "swxtch-config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"

    content = <<EOT
#!/bin/bash
/swxtch/swx update -i localhost -v "${var.swxtch_version}"
EOT
  }
}

resource "aws_instance" "swxtch" {
  count         = var.swxtch_count
  ami           = data.aws_ami.swxtch.id
  instance_type = var.instance_type
  key_name      = var.aws_ssh_key_name
  tags = {
    Name = "${var.swxtch_name}-0${count.index}"
  }

  user_data = data.cloudinit_config.swxtch-config.rendered

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.swxtch_ctrl[count.index].id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.swxtch_data[count.index].id
  }
}
