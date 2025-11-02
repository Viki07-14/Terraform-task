terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

# -------------------
# Providers (Two Regions)
# -------------------
provider "aws" {
  alias   = "mumbai"
  region  = "ap-south-1"
  profile = "default"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "default"
}

# -------------------
# Get latest Ubuntu AMIs
# -------------------
data "aws_ami" "ubuntu_mumbai" {
  provider    = aws.mumbai
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "ubuntu_virginia" {
  provider    = aws.virginia
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# -------------------
# EC2 in Mumbai
# -------------------
resource "aws_instance" "ec2_mumbai" {
  provider      = aws.mumbai
  ami           = data.aws_ami.ubuntu_mumbai.id
  instance_type = var.instance_type
  user_data     = file("${path.module}/scripts/userdata.sh")

  tags = {
    Name = "ec2-mumbai"
  }
}

# -------------------
# EC2 in US East
# -------------------
resource "aws_instance" "ec2_virginia" {
  provider      = aws.virginia
  ami           = data.aws_ami.ubuntu_virginia.id
  instance_type = var.instance_type
  user_data     = file("${path.module}/scripts/userdata.sh")

  tags = {
    Name = "ec2-virginia"
  }
}

# -------------------
# Outputs
# -------------------
output "mumbai_instance_public_ip" {
  value = aws_instance.ec2_mumbai.public_ip
}

output "virginia_instance_public_ip" {
  value = aws_instance.ec2_virginia.public_ip
}
