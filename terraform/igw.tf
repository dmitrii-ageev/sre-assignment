# Define the Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.qrious.id}"

  tags {
    Name = "Qrious VPC Internet gateway"
  }
}
