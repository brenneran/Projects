# Define an IAM policy document specifying the permissions for assuming the role
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create an IAM role using the defined assume role policy
resource "aws_iam_role" "instance" {
  name               = local.name
  path               = "/jama/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  tags = merge(local.tags, {
    Role = "jama/infra"
  })
}

# Attach the AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.instance.name
}

# Create an IAM instance profile associated with the IAM role
resource "aws_iam_instance_profile" "server" {
  name = local.name
  role = aws_iam_role.instance.name
}

# Fetch the latest Amazon Linux AMI ID
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

# Define local variables for disk names and configurations
locals {
  disk_names = zipmap([for i in range(length(var.disk_layout)) : format("/dev/sd%s", substr("hijklmnopqrstuvwxyz", i, 1))], var.disk_layout)
  disks      = [for k, v in local.disk_names : merge(v, { device : k })]
}

# Create an EC2 instance
resource "aws_instance" "jama" {
  ami           = data.aws_ami.amazon_linux.image_id
  instance_type = "m5a.2xlarge"
  key_name      = var.ec2_key_pair_name
  root_block_device {
    volume_size = 50
  }

  user_data = templatefile("${path.module}/init.sh.tftemplate", { disks = local.disks })

  subnet_id              = var.app_subnet
  vpc_security_group_ids = concat(var.app_security_groups, [aws_security_group.jama.id])
  iam_instance_profile   = aws_iam_instance_profile.server.id

  tags = merge(local.tags, {
    Name        : local.name,
    Role        : "jama/compute",
    DailyBackup : "Yes",
  })

  # Ignore changes to AMI and user data during lifecycle events
  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# Create EBS volumes for each specified disk
resource "aws_ebs_volume" "volume" {
  count             = length(local.disks)
  availability_zone = data.aws_subnet.app_subnet.availability_zone
  size              = element(local.disks, count.index).size
  type              = "gp2"

  tags = merge(local.tags, {
    Name = "${local.name}-${element(local.disks, count.index).name}",
    Role = "jama/storage",
  })
}

# Attach EBS volumes to the EC2 instance
resource "aws_volume_attachment" "volume" {
  count       = length(local.disks)
  device_name = element(local.disks, count.index).device
  instance_id = aws_instance.jama.id
  volume_id   = aws_ebs_volume.volume[count.index].id
}
