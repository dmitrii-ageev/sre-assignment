# Define webserver inside the public subnet
resource "aws_instance" "web" {
  # ami = "${lookup(var.amis, var.region)}"
  ami                         = "${var.ami}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.default.id}"
  subnet_id                   = "${aws_subnet.public.id}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "webserver"
  }

  provisioner "remote-exec" {
    inline = ["sudo yum install -y python libselinux-python"]

    connection {
      type        = "ssh"
      user        = "${var.user_name}"
      private_key = "${file("${path.cwd}/${var.ssh_key["private"]}")}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.user_name} -i inventory -e 'ansible_host=${self.public_ip}' --private-key ${path.cwd}/${var.ssh_key["private"]} provision.yml && echo Server address is: ${self.public_ip}"
  }
}
