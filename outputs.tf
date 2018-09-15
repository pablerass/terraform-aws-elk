output "sg_beat" {
  value = {
    id   = "${aws_security_group.elk_beat.id}"
    name = "${aws_security_group.elk_beat.name}"
  }
}
