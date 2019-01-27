# Define the route table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.qrious.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Route all traffic through IGW"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "default" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}
