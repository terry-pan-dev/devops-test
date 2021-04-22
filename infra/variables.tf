variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "vpc default cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "The availability zone"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "public_subnets" {
  description = "public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "private subnets"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
}

variable "container_image" {
  description = "the name of the container image"
  type        = string
}


