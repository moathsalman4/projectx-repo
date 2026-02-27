variable "project_name" {
  type        = string
  description = "Used for naming/tagging resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (ex: 10.0.0.0/16)"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "azs" {
  type        = list(string)
  description = "List of AZs to place subnets in (3 items)"

  validation {
    condition     = length(var.azs) == 3
    error_message = "azs must contain exactly 3 AZs."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for public subnets (3 items)"

  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "public_subnet_cidrs must contain exactly 3 CIDRs."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for private subnets (3 items)"

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "private_subnet_cidrs must contain exactly 3 CIDRs."
  }
}

variable "environment" {
  type        = string
  description = "Environment for the resources (ex: dev, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name (used for Kubernetes subnet tags)"
}