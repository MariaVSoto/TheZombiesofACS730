# Web Server Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  # Allow HTTP from ALB
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Allow SSH from bastion host
  ingress {
    description     = "Allow SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-web-sg"
    }
  )
}

# Private Instance Security Group
resource "aws_security_group" "private_sg" {
  name        = "${var.environment}-private-sg"
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
    {
      Name = "${var.environment}-private-sg"
    }
  )
}

# IAM Role for S3 Access
resource "aws_iam_role" "web_role" {
  name = "${var.team_name}-${var.environment}-web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.team_name}-${var.environment}-web-role"
  })
}

resource "aws_iam_policy" "web_policy" {
  name        = "${var.team_name}-${var.environment}-web-policy"
  description = "Policy for web servers to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "web_role_policy_attachment" {
  policy_arn = aws_iam_policy.web_policy.arn
  role       = aws_iam_role.web_role.name
}

resource "aws_iam_instance_profile" "web_instance_profile" {
  name = "${var.team_name}-${var.environment}-web-profile"
  role = aws_iam_role.web_role.name
}

# Launch Template for ASG Instances (Webserver 1 and 3)
resource "aws_launch_template" "asg_lt" {
  name_prefix   = "${var.environment}-asg-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.web_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.web_instance_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from ASG Instance $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  )

  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-asg-instance"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template for Bastion Host (Webserver 2)
resource "aws_launch_template" "bastion_lt" {
  name_prefix   = "${var.environment}-bastion-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [var.bastion_sg_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Bastion Host</h1>" > /var/www/html/index.html
              EOF
  )

  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-bastion-host"
      }
    )
  }
}

# Launch Template for Webserver 4
resource "aws_launch_template" "webserver4_lt" {
  name_prefix   = "${var.environment}-webserver4-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Webserver 4</h1>" > /var/www/html/index.html
              EOF
  )

  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-webserver4"
      }
    )
  }
}

# Launch Template for Private Instances (VM5 and VM6)
resource "aws_launch_template" "private_lt" {
  name_prefix   = "${var.environment}-private-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.private_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              EOF
  )

  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-private-instance"
      }
    )
  }
}

# ASG for Webserver 1 and 3
resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.environment}-web-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  target_group_arns  = [var.target_group_arn]
  vpc_zone_identifier = [
    var.public_subnet_ids[0],  # Webserver 1 subnet
    var.public_subnet_ids[2]   # Webserver 3 subnet
  ]

  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value              = "${var.environment}-asg-instance"
    propagate_at_launch = true
  }
}

# CloudWatch Alarm for ASG Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.team_name}-${var.environment}-web-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_autoscaling_group.web_asg.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

# Bastion Host (Webserver 2)
resource "aws_instance" "bastion" {
  subnet_id = var.public_subnet_ids[1]  # Public Subnet 2

  launch_template {
    id      = aws_launch_template.bastion_lt.id
    version = "$Latest"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-bastion-host"
    }
  )
}

# Webserver 4
resource "aws_instance" "webserver4" {
  subnet_id = var.public_subnet_ids[3]  # Public Subnet 4

  launch_template {
    id      = aws_launch_template.webserver4_lt.id
    version = "$Latest"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-webserver4"
    }
  )
}

# VM5
resource "aws_instance" "vm5" {
  subnet_id = var.private_subnet_ids[0]  # Private Subnet 1

  launch_template {
    id      = aws_launch_template.private_lt.id
    version = "$Latest"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-vm5"
    }
  )
}

# VM6
resource "aws_instance" "vm6" {
  subnet_id = var.private_subnet_ids[1]  # Private Subnet 2

  launch_template {
    id      = aws_launch_template.private_lt.id
    version = "$Latest"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-vm6"
    }
  )
} 