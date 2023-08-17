output "swxtches" {
  value = [for i in range(var.swxtch_count) : {
    ctrl_ip  = aws_instance.swxtch[i].private_ip
    data_ip  = aws_network_interface.swxtch_data[i].private_ip
    username = "ubuntu"
  }]
}

output "xnic_instances" {
  value = [for i in range(var.xnic_instance_count) : {
    ctrl_ip  = aws_instance.xnic_instance[i].private_ip
    data_ip  = aws_network_interface.xnic_data[i].private_ip
    username = "ubuntu"
  }]
}
