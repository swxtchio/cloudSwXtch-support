locals {
  product_codes = {
    small  = "ejh6oiwhxalojuo4octwweeqz"
    medium = "61yrdd5np5yre26dg3924t7wr"
    large  = "1towi4nck0h27uy1q1621a3rd"
  }
}

data "aws_ami" "swxtch" {
  most_recent = true

  filter {
    name   = "product-code"
    values = [local.product_codes[var.swxtch_plan]]
  }
}
