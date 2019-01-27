# Define the public subnet
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.qrious.id}"
  cidr_block        = "${var.subnet_cidr["public"]}"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "Qrious VPC public subnet"
  }
}
