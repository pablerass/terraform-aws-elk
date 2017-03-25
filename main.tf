data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
}

data "aws_vpc" "selected" {
  id = "${data.aws_subnet.selected.vpc_id}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

variable "ubuntu_python_bin" {
  default = "/usr/bin/python3"
}

variable "ubuntu_user" {
  default = "ubuntu"
}

resource "aws_security_group" "elk_admin" {
  name = "${var.name}-admin"

  description = "ELK instances administration"

  vpc_id = "${data.aws_vpc.selected.id}"

  tags = "${merge(var.tags, map("Module", var.module))}"
}
