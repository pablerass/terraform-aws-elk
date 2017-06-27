variable "key_pair" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "ami" {
  type = "string"
}

variable "logstash_instance_type" {
  type = "string"
}

variable "kibana_instance_type" {
  type = "string"
}

variable "elasticsearch_master_instance_type" {
  type = "string"
}

variable "elasticsearch_data_instance_type" {
  type = "string"
}

variable "elasticsearch_data_disk_size" {
  type = "string"
}
