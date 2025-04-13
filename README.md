# TheZombiesofACS730

AWS Infrastructure as Code for ACS730 Project

## Project Structure

```
.
├── Terraform/
│   ├── modules/
│   │   ├── ALB/            # Application Load Balancer module
│   │   ├── network/        # Network infrastructure module
│   │   └── webserver/      # Web server module
│   ├── main.tf            # Main configuration file
│   └── config.tf          # Provider configuration
```

## Features

- VPC and Subnet Configuration
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Web Servers
- IAM Role and Permission Management

## Getting Started

1. Ensure Terraform is installed (version >= 0.14)
2. Configure AWS credentials
3. Initialize Terraform:
   ```bash
   cd Terraform
   terraform init
   ```
4. Review the changes:
   ```bash
   terraform plan
   ```
5. Apply the changes:
   ```bash
   terraform apply
   ```

## Security

- IAM role management using LabRole
- Security group-based access control
- Public/Private subnet architecture

## Infrastructure Components

- VPC with public and private subnets
- Application Load Balancer for traffic distribution
- Auto Scaling Group for web servers
- Bastion host for secure access
- Private instances in isolated subnets

## Prerequisites

- AWS Account
- Terraform >= 0.14
- AWS CLI configured
- SSH key pair for EC2 instances

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Note

Please ensure you have appropriate AWS permissions and understand the costs associated with creating these resources.