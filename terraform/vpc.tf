# Define our VPC
resource "aws_vpc" "qrious" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "Qrious VPC"
  }
}
