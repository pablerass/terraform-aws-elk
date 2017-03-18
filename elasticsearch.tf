resource "aws_instance" "elk_elasticsearch_master" {
  count = "${var.elasticsearch_master_count}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.elasticsearch_master_instance_type}"
  key_name      = "${var.key_pair}"
  subnet_id     = "${var.subnet_id}"

  vpc_security_group_ids = ["${aws_security_group.elk_elasticsearch.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name                     = "elk-elasticsearch-master-${count.index + 1}"
    Module                   = "${var.module}"
    AnsibleRole              = "elasticsearch-master"
    AnsibleUser              = "${var.ubuntu_user}"
    AnsiblePythonInterpreter = "${var.ubuntu_python_bin}"
  }
}

resource "aws_instance" "elk_elasticsearch_data" {
  count = "${var.elasticsearch_data_count}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.elasticsearch_data_instance_type}"
  key_name      = "${var.key_pair}"
  subnet_id     = "${var.subnet_id}"

  vpc_security_group_ids = ["${aws_security_group.elk_elasticsearch.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name                     = "elk-elasticsearch-data-${count.index + 1}"
    Module                   = "${var.module}"
    AnsibleRole              = "elasticsearch-data"
    AnsibleUser              = "${var.ubuntu_user}"
    AnsiblePythonInterpreter = "${var.ubuntu_python_bin}"
  }
}

resource "aws_ebs_volume" "elk_elasticsearch_lib" {
  count = "${var.elasticsearch_data_count}"

  availability_zone = "${element(aws_instance.elk_elasticsearch_data.*.availability_zone, count.index)}"
  type              = "gp2"
  size              = "${var.elasticsearch_data_disk_size}"

  /* Needed to avoid issue https://github.com/hashicorp/terraform/issues/8395 */
  lifecycle {
    ignore_changes = ["availability_zone"]
  }

  tags {
    Name       = "elk-elasticsearch-${count.index + 1}-lib"
    MountPoint = "/var/lib/elasticsearch"
  }
}

resource "aws_volume_attachment" "elk_elasticsearch_lib" {
  count = "${var.elasticsearch_data_count}"

  device_name = "xvdd"
  volume_id   = "${element(aws_ebs_volume.elk_elasticsearch_lib.*.id, count.index)}"
  instance_id = "${element(aws_instance.elk_elasticsearch_data.*.id, count.index)}"

  /* Needed to avoid issue https://github.com/hashicorp/terraform/issues/8395 */
  lifecycle {
    ignore_changes = ["instance_id"]
  }
}

resource "aws_security_group" "elk_elasticsearch" {
  name        = "elk_elasticsearch"
  description = "ELK ElasticSearch instances"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elk_logstash.id}"]
  }

  ingress = {
    from_port       = 9300
    to_port         = 9400
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elk_kibana.id}"]
    self            = true
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
