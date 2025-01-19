variable "name" {
  type = string
}

variable "ec2_key_pair_name" {
  type = string
}

variable "app_security_groups" {
  type = list(string)
}

variable "app_subnet" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "alb_security_groups" {
  type = list(string)
}

variable "acm_certificate_arn" {
  type = string
}
variable "alb_subnets" {
  type = list(string)
}

variable "tags" {
  type = map(string)
  default = {
    Owner : "devops"
    Requestor : "pmo"
    Environment : "pmo"
  }
}
variable "region" {
  type    = string
  default = "us-west-2"
}

variable "disk_layout" {
  default = [
    {
      name : "data",
      size : "50",
      fs : "ext4",
      mount : "/data"
    },
    {
      name : "docker",
      size : "30",
      fs : "xfs",
      mount : "/var/lib/docker"
    },
    {
      name : "logs",
      size : "15",
      fs : "ext4",
      mount : "/logs"
    },
    {
      name : "replicated",
      size : "15",
      fs : "ext4",
      mount : "/var/lib/replicated"
    }
  ]
}