resource "aws_instance" "elk_logstash" {
  count = "${var.logstash_count}"

  ami                    = "${var.ami}"
  instance_type          = "${var.kibana_instance_type}"
  key_name               = "${var.key_pair}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.elk_logstash.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags = "${merge(var.tags, var.tags_instances, map("Module", var.module), map("Name", concat(var.name, "-logstash-", count.index + 1), map("Role", "logstash"))}"
}

resource "aws_security_group" "elk_logstash" {
  name        = "${var.name}-logstash"
  description = "ELK (${var.name}) Logstash instances"
  vpc_id      = "${data.aws_vpc.selected.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port       = 5044
    to_port         = 5044
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elk_beat.id}"]
  }

  ingress = {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = "${concat(list(aws_security_group.elk_admin.id), var.admin_sg_ids)}"
    cidr_blocks     = "${var.admin_cidrs}"
  }

  tags = "${merge(var.tags, map("Module", var.module))}"
}

resource "aws_security_group" "elk_beat" {
  name = "${var.name}-beat"
  description = "ELK (${var.name}) Beat instances"
  vpc_id      = "${data.aws_vpc.selected.id}"

  tags = "${merge(var.tags, map("Module", var.module))}"
}
