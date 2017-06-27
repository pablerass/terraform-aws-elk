variable "module" {
  description = "Terraform module"

  default = "tf_aws_elk"
}

variable "kibana_count" {
  description = "Count of Kibana instances"
  default     = 1
}

variable "elasticsearch_master_count" {
  description = "Count of ElasticSearch master instances"
  default     = 1
}

variable "elasticsearch_data_count" {
  description = "Count of ElasticSearch data instances"
  default     = 1
}

variable "logstash_count" {
  description = "Count of Logstash instances"
  default     = 1
}

variable "name" {
  description = "ELK stack name"
  default     = "elk"
}

variable "tags" {
  description = "Resources tags"
  default     = {}
}

variable "instance_tags" {
  description = "Instance tags"
  default     = {}
}

variable "admin_cidrs" {
  description = "Adminitration CIDRs for remote access"
  default     = []
}

variable "admin_sg_ids" {
  description = "Adminitration Security Group ids for remote access"
  default     = []
}
