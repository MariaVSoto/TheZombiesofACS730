# Web Server Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.team_name}-${var.environment}-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  # Allow HTTP from internet
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from internet
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

  tags = merge(var.common_tags, {
    Name        = "${var.team_name}-${var.environment}-web-sg"
    Environment = var.environment
    Team        = var.team_name
    Project     = "ACS730"
    Terraform   = "true"
  })
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

# Launch Configuration
resource "aws_launch_configuration" "launch_config" {
  name_prefix          = "${var.team_name}-${var.environment}-web-"
  image_id             = var.ami_id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.web_sg.id]
  iam_instance_profile = aws_iam_instance_profile.web_instance_profile.name
  key_name            = var.key_name
  user_data           = templatefile("${path.module}/setup_webserver.sh", {
    WEBSERVER_ID = "${var.team_name}-${var.environment}"
    ENVIRONMENT  = var.environment
    S3_BUCKET    = var.s3_bucket
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                = "${var.team_name}-${var.environment}-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [var.target_group_arn]
  vpc_zone_identifier = var.public_subnet_ids

  launch_configuration = aws_launch_configuration.launch_config.name

  tag {
    key                 = "Name"
    value              = "${var.team_name}-${var.environment}-web"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value              = tag.value
      propagate_at_launch = true
    }
  }
} 