locals {
  product_codes = {
    multicast = "ejh6oiwhxalojuo4octwweeqz"
    byol      = "2qr1ymskv9a1lfnwqe6gfncx1"
  }
}

data "aws_ami" "swxtch" {
  most_recent = true

  filter {
    name   = "product-code"
    values = [local.product_codes[var.swxtch_plan]]
  }
}
