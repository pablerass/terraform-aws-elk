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

  tags = "${merge(var.tags, map("Module", var.module), map("Name", concat(var.name, "-kibana-", count.index + 1), map("Role", "kibana"), map("AnsibleUser", var.ubuntu_user), map("AnsiblePythonInterpreter", var.ubuntu_python_bin))}"
}

resource "aws_security_group" "elk_kibana" {
  name        = "${var.name}-kibana"
  description = "ELK Kibana instances"
  vpc_id      = "${data.aws_vpc.selected.id}"

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
    security_groups = "${concat(list(aws_security_group.elk_admin.id), var.admin_sg_ids)}"
    cidr_blocks     = "${var.admin_cidrs}"
  }

  tags = "${merge(var.tags, map("Module", var.module))}"
}
