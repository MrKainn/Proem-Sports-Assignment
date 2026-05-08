variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = var.aws_region
}

variable "instance_type" {
  description = "The size of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Value for the Name tag"
  type        = string
  default     = "App-Server"
}

variable "instance_ami" {
  description = "ami of the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "app_port" {
  description = "The port our Flask app runs on"
  type        = number
  default     = 5000
}