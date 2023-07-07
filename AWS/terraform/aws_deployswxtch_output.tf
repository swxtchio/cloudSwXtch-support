output "swxtches" {
  value = [for i in range(var.swxtch_count) : {
    ctrl_ip  = aws_instance.swxtch[i].private_ip
    data_ip  = aws_network_interface.swxtch_data[i].private_ip
    username = "ubuntu"
  }]
}
