packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

data "amazon-ami" "linux" {
  most_recent = true
  region      = "us-west-2"
  owners      = ["{ACCOUNT_OWNER_ID}"]

  filters = {
    name                = "official-amz2-base-1-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
}

source "amazon-ebs" "linux" {
  ami_name        = "linux-main-builder-${local.timestamp}"
  ami_description = "Main Jenkins Linux agent"
  ami_users       = ["{ACCOUNT_ID_THAT_CAN_USE_AMI_bycoma}"]
  instance_type   = "t3.micro"
  region          = "us-west-2"
  source_ami        = "${data.amazon-ami.linux.id}"
  vpc_id          = "vpc-0a1b2c3d4e5f67890" #This is random generated. Insert your VPC
  subnet_id       = "subnet-0d7e4f9a2b3c6a8d1" #This is random generated. Insert your Subnet
  ssh_username = "ec2-user"
  aws_polling {
    delay_seconds = 60
    max_attempts  = 300
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name     = "linux-main-builder-${local.timestamp}"
    Project  = "Jenkins Packer for AMI"
    Owner    = "devops"
  }
}

build {
  name    = "jenkins-linux-agent-packer"
  sources = ["source.amazon-ebs.linux"]

  provisioner "shell" {
    expect_disconnect = true
    pause_before = "10s"
    script = "./install_main.sh"
    pause_after  = "15s"
  }
  provisioner "shell" {
    pause_before = "10s"
    expect_disconnect = true
    script = "./install_second.sh"
  }

  post-processor "manifest" {
      output = "manifest.json"
      strip_path = true
  }

}