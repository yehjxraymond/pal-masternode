provider "aws" {
  region = "${var.aws_region}"
}

data "aws_availability_zones" "available" {}

# SSH Key Pair
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# VPC
resource "aws_vpc" "pal_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "pal_vpc"
  }
}

# Subnet
resource "aws_subnet" "pal_public_subnet" {
  vpc_id                  = "${aws_vpc.pal_vpc.id}"
  cidr_block              = "${var.cidrs["public"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "pal_public"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "pal_internet_gateway" {
  vpc_id = "${aws_vpc.pal_vpc.id}"

  tags {
    Name = "pal_igw"
  }
}

# Route Table
resource "aws_route_table" "pal_public_rt" {
  vpc_id = "${aws_vpc.pal_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.pal_internet_gateway.id}"
  }

  tags {
    Name = "pal_public"
  }
}

# Security Group
resource "aws_security_group" "pal_node_sg" {
  name        = "pal_node_sg"
  description = "Used for access to the dev instance"
  vpc_id      = "${aws_vpc.pal_vpc.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #RPC(TCP):8545
  ingress {
    from_port   = 8545
    to_port     = 8545
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #WS-RPC(TCP):8546
  ingress {
    from_port   = 8546
    to_port     = 8546
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Listener(TCP)/Discovery(UDP):30303
  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EBS
resource "aws_ebs_volume" "pal_ebs" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  size              = "${var.ebs_size}"
}

# EC2
resource "aws_instance" "pal_node" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"

  tags {
    Name = "pal_node"
  }

  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.pal_node_sg.id}"]
  subnet_id              = "${aws_subnet.pal_public_subnet.id}"

  connection {
    type        = "ssh"
    agent       = "false"
    private_key = "${file(var.private_key_path)}"
    user        = "ubuntu"
  }

  provisioner "remote-exec" {
    script = "./init.sh"
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts 
[dev] 
${aws_instance.pal_node.public_ip}
EOF
EOD
  }
}

# EBS Attachment
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.pal_ebs.id}"
  instance_id = "${aws_instance.pal_node.id}"
}

# Route table assocation
resource "aws_route_table_association" "pal_public_assoc" {
  subnet_id      = "${aws_subnet.pal_public_subnet.id}"
  route_table_id = "${aws_route_table.pal_public_rt.id}"
}
