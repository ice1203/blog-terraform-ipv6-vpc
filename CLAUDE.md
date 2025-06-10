# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This Terraform project creates an IPv6-enabled AWS VPC infrastructure with dual-stack networking capabilities. The architecture follows a modular approach:

- **Environment-based structure**: Configurations are organized under `envs/` (currently `dev/`)
- **Reusable modules**: Infrastructure components are modularized under `modules/` (currently `ec2/`)
- **IPv6-first design**: Private subnets are IPv6-only (`ipv6_native = true`), public subnets are dual-stack
- **Security-focused**: Uses IMDSv2, encrypted EBS volumes, and minimal security group rules

## Key Components

- **VPC Module**: Uses `terraform-aws-modules/vpc/aws` with IPv6 CIDR blocks, dual availability zones (ap-northeast-1a, ap-northeast-1c)
- **EC2 Module**: Custom module that creates IPv6-enabled instances in private subnets with SSM access
- **Security Groups**: Configured for IPv6-only outbound traffic (HTTPS, DNS, NTP)

## Common Commands

### Development Tools
Tool versions are managed via aqua (see `aqua.yaml`):
```bash
# Install tools
aqua install

# Available tools:
# - Terraform v1.11.4
# - git-secrets v1.3.0
```

### Terraform Operations
```bash
# Navigate to environment
cd envs/dev

# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes  
terraform apply

# Destroy infrastructure
terraform destroy
```

### Validation
```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Check for security issues
git secrets --scan
```

## Module Dependencies

The EC2 module depends on:
- VPC ID from the main VPC module
- Subnet ID from VPC's private subnets
- EC2 key pair name (must be provided as variable)

## Important Notes

- Private subnets are IPv6-only - ensure any resources deployed there support IPv6
- EC2 instances use Amazon Linux 2023 AMI via SSM parameter lookup
- IAM role includes SSM managed instance core policy for session manager access
- All resources are tagged with Terraform, Environment, and System identifiers