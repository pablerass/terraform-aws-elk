data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
}

data "aws_vpc" "selected" {
  id = "${data.aws_subnet.selected.vpc_id}"
}

resource "aws_security_group" "elk_admin" {
  name = "${var.name}-admin"
  description = "ELK (${var.name})instances administration"
  vpc_id = "${data.aws_vpc.selected.id}"

  tags = "${merge(var.tags, map("Module", var.module))}"
}
