resource "aws_instance" "elk_logstash" {
  count = "${var.logstash_count}"

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.kibana_instance_type}"
  key_name               = "${var.key_pair}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.elk_logstash.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name                     = "elk-logstash-${count.index + 1}"
    AnsibleRole              = "logstash"
    AnsibleUser              = "${var.ubuntu_user}"
    AnsiblePythonInterpreter = "${var.ubuntu_python_bin}"
  }
}

resource "aws_security_group" "elk_logstash" {
  name        = "elk_logstash"
  description = "ELK Logstash instances"
  vpc_id      = "${var.vpc_id}"

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
    security_groups = ["${aws_security_group.elk_admin.id}"]
    cidr_blocks     = "${var.admin_cidrs}"
  }

  tags {
    Module = "${var.module}"
  }
}

resource "aws_security_group" "elk_beat" {
  name = "elk_beat"

  description = "ELK Beat instances"

  vpc_id = "${var.vpc_id}"

  tags {
    Module = "${var.module}"
  }
}
