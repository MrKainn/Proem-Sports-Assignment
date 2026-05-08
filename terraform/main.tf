provider "aws" {
  region     = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "s3-terraform-state"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true 
  }
}

resource "aws_instance" "app" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  tags = {
    Name = var.instance_name
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow restricted traffic"

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
