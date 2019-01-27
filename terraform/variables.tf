variable "aws_region" {
  description = "Region for the VPC"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = "map"

  default = {
    public  = "10.0.1.0/24"
    private = "10.0.0.0/24"
  }
}

variable "ami" {
  description = "Red Hat Enterprise Linux 7.6 (HVM)"
  default     = "ami-036affea69a1101c9"
}

variable "ssh_key" {
  description = "SSH key paths"

  default = {
    public  = "files/ssh_keys/aws.pub"
    private = "files/ssh_keys/aws"
  }
}

variable "user_name" {
  description = "Remote user name"
  default = "ec2-user"
}
