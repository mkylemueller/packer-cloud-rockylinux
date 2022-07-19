#Set Local Env Vars 
#export AWS_ACCESS_KEY_ID=
#export AWS_SECRET_ACCESS_KEY=
#The first run will require accepting EULA via AWS Console

# Required Provider 
# https://github.com/hashicorp/packer-plugin-amazon
packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "rocky" {
  # AWS EC2 parameters
  ami_name      = "rockybuild-${regex_replace(timestamp(), "[- TZ:]", "")}"
  instance_type = "t2.micro"
  region        = "us-east-1"

  # AWS AMI data source lookup 
  source_ami_filter {
    filters = {
      name = "Rocky-8-ec2*x86_64*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    # Rocky Linux Owner ID
    owners      = ["679593333241"]
  }

  # provisioning connection parameters
  communicator         = "ssh"
  ssh_username         = "rocky"

  #Tag examples - https://www.packer.io/plugins/builders/amazon/ebs#tag-example
  tags = {
    Name            = "rockybuild-${regex_replace(timestamp(), "[- TZ:]", "")}"
    PackerBuilt     = "true"
    PackerTimestamp = regex_replace(timestamp(), "[- TZ:]", "")
  }
}

build {
  sources = [
    "source.amazon-ebs.rocky"
  ]
}
