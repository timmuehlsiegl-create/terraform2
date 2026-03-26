terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
   backend "s3" {
    bucket = "s3-pirelli-test"
    key    = "app/terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
}
# 🔐 Security Group (wird korrekt definiert)
resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # nur zum Testen!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🖥 EC2 Instance
resource "aws_instance" "demo" {
  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t2.micro"
  key_name      = "der_schlussel"

  # ✅ KORREKTE Referenz (mit _ statt -)
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "test-server-iac"
  }
}

output "instance_id" {
  value = aws_instance.demo.id
}
output "public_ip" {
  value = aws_instance.demo.public_ip
}