packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "conan_u" {
  type = string
}

variable "conan_p" {
  type = string
}

# Cr of tooling-cloud-hsm
variable "hsm_u" {
  type = string
}

variable "hsm_p" {
  type = string
}

data "amazon-ami" "windows" {
  most_recent = true
  region      = "us-west-2"
  owners      = ["ACCOUNT_ID"]

  filters = {
    name                = "official-windows2022-base-1-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
}

source "amazon-ebs" "windows" {
  access_key        = var.aws_access_key
  secret_key        = var.aws_secret_key
  ami_users         = ["SHARED_ACCOUNTS"]
  vpc_id            = "vpc-0a1b2c3d4e5f67890" //Randomly generated
  subnet_id         = "subnet-0d7e4f9a2b3c6a8d1" //Randomly generated
  region            = "us-west-2"
  source_ami        = "${data.amazon-ami.windows.id}"
  winrm_use_ssl     = false
  winrm_insecure    = true
  instance_type     = "t2.xlarge"
  communicator      = "winrm"
  winrm_username    = "Administrator"
  winrm_timeout     = "6h"
  user_data_file    = "./bootstrap.txt"
  ami_name          = "windows-builder-${local.timestamp}"
  security_group_id = "sg-0a1b2c3d4e5f67890" //Randomly generated
  winrm_password    = "password"
  aws_polling {
    delay_seconds = 60
    max_attempts  = 300
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    encrypted             = false
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 250
  }

  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    encrypted             = false
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 400
  }

  tags = {
    Name     = "windows-builder-${local.timestamp}"
    Project  = "Windows Packer for AMI"
    Owner    = "devops"
  }
}

build {
  sources = [
    "source.amazon-ebs.windows"
  ]

  provisioner "powershell" {
    inline = [
      # Extend the volume
      "Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data'",

      # Resize the file system
      "Resize-Partition -DriveLetter D -Size 199.88GB", # Replace 'D' with the correct drive letter
    ]
  }

  provisioner "file" {
    source      = "./Autologon.exe"
    destination = "C:\\Downloads\\"
  }

  provisioner "file" {
    source      = "./vs2022/vs_Professional.exe"
    destination = "C:\\Downloads\\"
  }

  provisioner "file" {
    source      = "./vs2022/vs_Professional_latest.exe"
    destination = "C:\\Downloads\\"
  }

  provisioner "file" {
    source      = "./vs2022/vs2022.vsconfig"
    destination = "C:\\Downloads\\"
  }

    provisioner "file" {
    source      = "./vs2017/vs_Professional.exe"
    destination = "C:\\Downloads\\vs17\\"
  }
  provisioner "file" {
    source      = "./vs2017/vs2017.vsconfig"
    destination = "C:\\Downloads\\vs17\\"
  }

  provisioner "file" {
    source      = "./certs/customerCA.crt"
    destination = "C:\\ProgramData\\Amazon\\CloudHSM\\"
  }

  provisioner "file" {
    source      = "./certs/root.crt"
    destination = "C:\\ProgramData\\Amazon\\CloudHSM\\"
  }

  provisioner "file" {
    source      = "./certs/codesign.crt"
    destination = "C:\\ProgramData\\Amazon\\CloudHSM\\"
  }

  provisioner "file" {
    source      = "./certs/Root_CA_G2.crt"
    destination = "C:\\Downloads\\"
  }

  provisioner "file" {
    source      = "./Buildcert/oldone.pfx"
    destination = "D:\\Buildcert\\"
  }

  #   provisioner "file" {
  #   source      = "./somefolder/"
  #   destination = "D:\\somefolder\\"
  # }

  provisioner "file" {
    source      = "./Buildcert/certif.pfx"
    destination = "D:\\Buildcert\\"
  }

  provisioner "file" {
    source      = "./Buildcert/cert.pfx"
    destination = "D:\\Buildcert\\"
  }

  provisioner "file" {
    source      = "./Buildcert/Inc.pfx"
    destination = "D:\\Buildcert\\"
  }

  provisioner "file" {
    source      = "./conan/conan.conf"
    destination = "C:\\Users\\Administrator\\.conan\\"
  }

  provisioner "file" {
    source      = "./conan/remotes.json"
    destination = "C:\\Users\\Administrator\\.conan\\"
  }

  provisioner "file" {
    source      = "./conan/registry.txt"
    destination = "C:\\Users\\Administrator\\.conan\\"
  }

  provisioner "file" {
    source      = "./it/settings.json"
    destination = "C:\\ProgramData\\data\\"
  }

  provisioner "file" {
    source      = "./itp/RTH/settings.json"
    destination = "C:\\ProgramData\\Cadent\\RTH\\data\\"
  }

  provisioner "file" {
    source      = "./InstallShield/server.ini"
    destination = "C:\\Program Files (x86)\\InstallShield\\2020 SAB\\System\\"
  }


  provisioner "file" {
      source      = "./nuget/NuGet.Config"
      destination = "C:\\Users\\Administrator\\AppData\\Roaming\\NuGet\\"
  }

  provisioner "file" {
    source      = "./aws/somefile"
    destination = "C:\\Users\\Administrator\\.aws\\"
  }

  provisioner "file" {
    source      = "./ssh/known_hosts"
    destination = "C:\\Users\\Administrator\\.ssh\\"
  }

  provisioner "file" {
    source      = "./ssh/id_rsa"
    destination = "C:\\Users\\Administrator\\.ssh\\"
  }

  provisioner "file" {
    source      = "./nircmd/nircmd.exe"
    destination = "C:\\Windows\\System32\\"
  }

  provisioner "file" {
    source      = "./certs/devtrust.ps1"
    destination = "C:\\Downloads\\"
  }

  provisioner "file" {
    source      = "./swarm/run_swarm.ps1"
    destination = "C:\\Prod\\Jenkins\\"
  }

  provisioner "powershell" {
    environment_vars = [
      "HSM_U=${var.hsm_u}",
      "HSM_P=${var.hsm_p}",
      "HSM_UP=${var.hsm_u}${var.hsm_p}",
      "CONAN_USER=${var.conan_u}",
      "CONAN_PASSWORD=${var.conan_p}",
    ]
    script = "./install_main.ps1"
  }

  provisioner "powershell" {
    environment_vars = [
      "CONAN_USER=${var.conan_u}",
      "CONAN_PASSWORD=${var.conan_p}",
    ]
    script = "./InstallShield.ps1"
  }

  provisioner "powershell" {
    script = "./qt/qt.ps1"
  }

  provisioner "powershell" {
    script = "./swarm/swarm-tsc.ps1"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}    