# ========================
# Define Common Tags and Variables (assumed defined elsewhere)
# ========================

# Web Server Security Group (used by ASG and Webserver 4)
resource "aws_security_group" "web_sg" {
  name        = "${var.team_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description     = "Allow SSH from within VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.team_name}-web-sg" }
  )
}

# Private Instance Security Group
resource "aws_security_group" "private_sg" {
  name        = "${var.team_name}-private-sg"
  description = "Security group for private instances (VM5 and VM6)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.team_name}-private-sg" }
  )
}

# ========================
# Create Bastion Security Group (Dedicated)
# ========================
resource "aws_security_group" "bastion_sg" {
  name        = "${var.team_name}-bastion-sg"
  description = "Dedicated security group for Bastion Host to allow inbound SSH from external sources"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from anywhere (temporarily for debugging)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.team_name}-bastion-sg" }
  )
}

# ========================
# Launch Template for ASG Instances (Webserver 1 and 3)
# ========================
resource "aws_launch_template" "asg_lt" {
  name_prefix   = "${var.team_name}-asg-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.team_name}-webserver-asg"
    })
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd jq

    # Start and enable Apache
    systemctl start httpd
    systemctl enable httpd
    
    # Get instance metadata using IMDSv2
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
    AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    
    # Get ASG name using AWS CLI with dynamic region
    ASG_NAME=$(aws autoscaling describe-auto-scaling-instances \
      --instance-ids $INSTANCE_ID --region ${var.region} \
      --query 'AutoScalingInstances[0].AutoScalingGroupName' --output text)
    
    # Create custom index.html with enhanced styling
    cat > /var/www/html/index.html <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
        <title>ACS730 Project - Web Server</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                margin: 40px; 
                background-color: #f8f9fa;
            }
            .info { 
                background: white; 
                padding: 20px; 
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }
            .header {
                background: #007bff;
                color: white;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            .metadata {
                background: #e9ecef;
                padding: 15px;
                border-radius: 6px;
                margin-top: 10px;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>Welcome to ACS730 Project</h1>
            <p>Team Zombies Infrastructure Demo</p>
        </div>
        <div class="info">
            <h2>Server Information</h2>
            <p><strong>Team Name:</strong> ${var.team_name}</p>
            <p><strong>Server Type:</strong> Web Server (ASG)</p>
            <div class="metadata">
                <h3>Instance Metadata</h3>
                <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
                <p><strong>Private IP:</strong> $PRIVATE_IP</p>
                <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
                <p><strong>Auto Scaling Group:</strong> $ASG_NAME</p>
            </div>
        </div>
    </body>
    </html>
    HTML

    # Log instance metadata for monitoring
    echo "Instance Metadata:" >> /var/log/user-data.log
    echo "Instance ID: $INSTANCE_ID" >> /var/log/user-data.log
    echo "Private IP: $PRIVATE_IP" >> /var/log/user-data.log
    echo "ASG Name: $ASG_NAME" >> /var/log/user-data.log
    EOF
  )
}

# ========================
# Launch Template for Webserver 2 (Bastion Host)
# ========================
resource "aws_launch_template" "bastion_lt" {
  name_prefix   = "${var.team_name}-bastion-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  # Use dedicated bastion security group instead of web_sg
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.team_name}-webserver2"
    })
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    # Get instance metadata using IMDSv2
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
      -s http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
      -s http://169.254.169.254/latest/meta-data/local-ipv4)
    
    cat > /var/www/html/index.html <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
        <title>ACS730 Project - Bastion Host</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                margin: 40px; 
                background-color: #f8f9fa;
            }
            .info { 
                background: white; 
                padding: 20px; 
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }
            .header {
                background: #28a745;
                color: white;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            .metadata {
                background: #e9ecef;
                padding: 15px;
                border-radius: 6px;
                margin-top: 10px;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>Welcome to ACS730 Project</h1>
            <p>Team Zombies Infrastructure Demo</p>
        </div>
        <div class="info">
            <h2>Server Information</h2>
            <p><strong>Team Name:</strong> ${var.team_name}</p>
            <p><strong>Server Type:</strong> Bastion Host</p>
            <div class="metadata">
                <h3>Instance Metadata</h3>
                <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
                <p><strong>Private IP:</strong> $PRIVATE_IP</p>
            </div>
        </div>
    </body>
    </html>
    HTML
    EOF
  )
}

# ========================
# Launch Template for Webserver 4
# ========================
resource "aws_ltaunch_templae" "webserver4_lt" {
  name_prefix   = "${var.team_name}-webserver4-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.team_name}-webserver4"
    })
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd jq
    systemctl start httpd
    systemctl enable httpd
    
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
      -s http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
      -s http://169.254.169.254/latest/meta-data/local-ipv4)
    AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
      -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    
    cat > /var/www/html/index.html <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
        <title>ACS730 Project - Web Server 4</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                margin: 40px; 
                background-color: #f8f9fa;
            }
            .info { 
                background: white; 
                padding: 20px; 
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }
            .header {
                background: #28a745;
                color: white;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            .metadata {
                background: #e9ecef;
                padding: 15px;
                border-radius: 6px;
                margin-top: 10px;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>Welcome to ACS730 Project</h1>
            <p>Team Zombies Infrastructure Demo</p>
        </div>
        <div class="info">
            <h2>Server Information</h2>
            <p><strong>Team Name:</strong> ${var.team_name}</p>
            <p><strong>Server Type:</strong> Web Server 4 (Static)</p>
            <div class="metadata">
                <h3>Instance Metadata</h3>
                <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
                <p><strong>Private IP:</strong> $PRIVATE_IP</p>
                <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
            </div>
        </div>
    </body>
    </html>
    HTML
    echo "Instance Metadata:" >> /var/log/user-data.log
    echo "Instance ID: $INSTANCE_ID" >> /var/log/user-data.log
    echo "Private IP: $PRIVATE_IP" >> /var/log/user-data.log
    EOF
  )
}

# ========================
# Launch Template for Webserver 5 and 6 (Private Instances)
# ========================
resource "aws_launch_template" "private_lt" {
  name_prefix   = "${var.team_name}-private-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.team_name}-webserver-private"
    })
  }
}

# ========================
# ASG for Webserver 1 and 3
# ========================
resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.team_name}-web-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [var.target_group_arn]
  vpc_zone_identifier = [
    var.public_subnet_ids[0],  # Webserver 1 subnet
    var.public_subnet_ids[2]   # Webserver 3 subnet
  ]

  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  metadata_options {
    http_tokens = "optional"  # allows IMDSv1
}

  tag {
    key                 = "Name"
    value               = "${var.team_name}-webserver-asg"
    propagate_at_launch = true
  }
}

# ========================
# Bastion Host (Webserver 2)
# ========================
resource "aws_instance" "bastion" {
  launch_template {
    id      = aws_launch_template.bastion_lt.id
    version = "$Latest"
  }
  subnet_id = var.public_subnet_ids[var.bastion_subnet_index]

  metadata_options {
    http_tokens = "optional"  # allows IMDSv1
}

  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.team_name}-webserver2"
  })
}

# ========================
# Webserver 4
# ========================
resource "aws_instance" "webserver4" {
  launch_template {
    id      = aws_launch_template.webserver4_lt.id
    version = "$Latest"
  }
  subnet_id = var.public_subnet_ids[var.web4_subnet_index]

  metadata_options {
    http_tokens = "optional"  # allows IMDSv1
}
  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.team_name}-webserver4"
  })
}

# ========================
# VM5
# ========================
resource "aws_instance" "vm5" {
  launch_template {
    id      = aws_launch_template.private_lt.id
    version = "$Latest"
  }
  subnet_id = var.private_subnet_ids[var.web5_subnet_index]

  metadata_options {
    http_tokens = "optional"  # allows IMDSv1
}
  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.team_name}-webserver-private5"
  })
}

# ========================
# VM6
# ========================
resource "aws_instance" "vm6" {
  launch_template {
    id      = aws_launch_template.private_lt.id
    version = "$Latest"
  }
  subnet_id = var.private_subnet_ids[var.vm6_subnet_index]

  metadata_options {
    http_tokens = "optional"  # allows IMDSv1
}

  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.team_name}-webserver-private6"
  })
}

# ========================
# Key Pair Resource
# ========================
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}
