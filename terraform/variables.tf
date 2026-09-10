variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
  default     = "ap-south-1a"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "ap-south-1b"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "devsecops-demo-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "devsecops-demo"
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "devsecops-demo"
}
