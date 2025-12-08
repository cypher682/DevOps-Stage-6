variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS SSH key pair name"
  type        = string
  default     = "devops-stage6-key"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "devops-stage6"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "todoapp.mooo.com"
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/cypher682/DevOps-Stage-6.git"
}

variable "ssh_public_key" {
  description = "SSH public key content for EC2 access"
  type        = string
}
