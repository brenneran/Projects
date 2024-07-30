provider "aws" {
  region = var.region
}

locals {
  name    = var.name
  tags    = var.tags
  sg_name = "${var.name}-internal"
}

data "aws_subnet" "app_subnet" {
  id = var.app_subnet
}

resource "aws_security_group" "jama" {
  name        = local.sg_name
  vpc_id      = data.aws_subnet.app_subnet.vpc_id
  description = "Allows any traffic inside this security group"
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/8"] # Use your CIDR Blocks
    self        = false
    description = "Allow port 80 for forwarding"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/8"] # Use your CIDR Blocks
    self        = false
    description = "Allow port 22 for SSH"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/8"] # Use your CIDR Blocks
    self        = false
    description = "Allow HTTPS protocol"
  }
  ingress {
    from_port   = 480
    to_port     = 499
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/8"] # Use your CIDR Blocks
    self        = false
    description = "Allow port range by request of Jama"
  }
  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/8"] # Use your CIDR Blocks
    self        = false
    description = "Allow 8800 for Replicated Console"
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  tags = merge(local.tags, {
    Role = "jama/infra",
    Name = local.sg_name
  })
}
