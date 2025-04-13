# ACS730 Project - Infrastructure as Code

## Two-Tier Web Application Automation with Terraform, Ansible, and GitHub Actions

This project implements a two-tier web application infrastructure on AWS using Infrastructure as Code (IaC) principles. The infrastructure is provisioned using Terraform, configured using Ansible, and automated using GitHub Actions.

## Team Information

**Team**: Zombies

**Members**:
- Zhihuai Wang (`kevinhust`)
- Shruti Amit Vasanwala (`Shrutii-30`)
- Maria Victoria Soto Ortiz (`MariaVSoto`)

## Infrastructure Overview

The infrastructure consists of:
- VPC with CIDR `10.1.0.0/16`
- 4 Public Subnets (10.1.1.0/24 to 10.1.4.0/24)
- 2 Private Subnets (10.1.5.0/24 and 10.1.6.0/24)
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- NAT Gateway
- 6 EC2 instances:
  - Webserver 1 & 3: In ASG, public subnets
  - Webserver 2: Bastion host, public subnet
  - Webserver 4: Static webserver, public subnet
  - Webserver 5: Private subnet webserver
  - VM 6: Private subnet for SSH testing

## Prerequisites

1. AWS CLI installed and configured
2. Terraform v0.14 or later
3. S3 bucket for Terraform state: `zombies-acs730`
4. DynamoDB table for state locking: `terraform-state-lock`
5. SSH key pair: `zombies-key` (created in AWS)

## Directory Structure

```
Terraform/
├── config.tf           # Provider and backend configuration
├── main.tf            # Root module configuration
├── variables.tf       # Variable definitions
├── outputs.tf         # Output definitions
├── terraform.tfvars   # Variable values
└── modules/
    ├── network/       # VPC, subnets, gateways
    ├── webserver/     # EC2 instances and security groups
    ├── ALB/           # Load balancer and ASG
    └── security_groups/ # Shared security group definitions
```

## Deployment Steps

1. **Initialize Terraform**:
   ```bash
   cd Terraform
   terraform init
   ```

2. **Review the deployment plan**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Access the web servers**:
   - Public access via ALB DNS (output after deployment)
   - Private instances accessible through Bastion host

## SSH Access to Private Instances

1. Connect to Bastion host (Webserver 2):
   ```bash
   ssh -i ~/.ssh/zombies-key.pem ec2-user@<bastion-ip>
   ```

2. From Bastion, connect to private instances:
   ```bash
   ssh -i ~/.ssh/zombies-key.pem ec2-user@<private-instance-ip>
   ```

## Security Notes

1. Web servers are only accessible through the ALB on port 80
2. SSH access to private instances is only available through the Bastion host
3. Security groups are configured for minimal required access
4. IMDSv2 is enabled for enhanced security
5. State files are encrypted in S3
6. DynamoDB table is used for state locking

## Infrastructure Features

1. **High Availability**:
   - ALB distributes traffic across multiple availability zones
   - ASG maintains desired capacity and handles instance failures
   - NAT Gateway provides internet access for private instances

2. **Security**:
   - Bastion host for secure SSH access
   - Security groups with principle of least privilege
   - Private subnets for sensitive resources

3. **Monitoring and Scaling**:
   - ASG scales based on CPU utilization
   - Health checks via ALB
   - Instance metadata and logs for troubleshooting

## Clean-up Instructions

To avoid unnecessary AWS charges, destroy all resources when not needed:

1. **Destroy infrastructure**:
   ```bash
   terraform destroy
   ```

2. **Manual clean-up**:
   - Delete S3 bucket contents
   - Delete DynamoDB table
   - Remove SSH key pair if no longer needed

## Team Contributions

- **Zhihuai Wang** (`kevinhust`):
  - Webserver module implementation
  - EC2 instance configurations
  - User data scripting

- **Shruti Amit Vasanwala** (`Shrutii-30`):
  - ALB module development
  - Load balancing optimization
  - Failover mechanisms

- **Maria Victoria Soto Ortiz** (`MariaVSoto`):
  - Network module design
  - VPC and subnet configurations
  - NAT Gateway setup

## Automation and CI/CD

The project includes GitHub Actions workflows for:
1. Infrastructure deployment via Terraform
2. Security scanning using tfsec and tflint
3. Automated testing of infrastructure changes

## Known Issues and Limitations

1. Manual creation of S3 bucket and DynamoDB table required
2. SSH key pair must be created manually in AWS
3. Region is currently fixed to us-east-1

For more information or troubleshooting, please contact the team members.