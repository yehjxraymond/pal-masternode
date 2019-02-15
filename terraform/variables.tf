variable "aws_region" {}
variable "key_name" {}
variable "public_key_path" {}
variable "private_key_path" {}
variable "localip" {}
variable "vpc_cidr" {}
variable "dev_instance_type" {}
variable "dev_ami" {}
variable "ebs_size" {}

variable "cidrs" {
  type = "map"
}
