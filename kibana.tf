resource "aws_instance" "elk_kibana" {
  count = "${var.kibana_count}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.kibana_instance_type}"
  key_name      = "${var.key_pair}"
  subnet_id     = "${var.subnet_id}"

  vpc_security_group_ids = ["${aws_security_group.elk_kibana.id}",
    "${aws_security_group.elk_elasticsearch.id}",
  ]

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name                     = "elk-kibana-${count.index + 1}"
    Module                   = "${var.module}"
    AnsibleRole              = "kibana"
    AnsibleUser              = "${var.ubuntu_user}"
    AnsiblePythonInterpreter = "${var.ubuntu_python_bin}"
  }
}

resource "aws_security_group" "elk_kibana" {
  name        = "elk_kibana"
  description = "ELK Kibana instances"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
