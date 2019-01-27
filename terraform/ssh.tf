# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name   = "terraform"
  public_key = "${file("${path.cwd}/${var.ssh_key["public"]}")}"
}
