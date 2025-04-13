# Web Server Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
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

# Launch Template for ASG Instances (Webserver 1 and 3)
resource "aws_launch_template" "asg_lt" {
  name_prefix   = "${var.environment}-asg-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Webserver $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h1>" > /var/www/html/index.html
              EOF
  )

  iam_instance_profile {
    name = "LabProfile"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.environment}-webserver-asg"  # This will be webserver1 and webserver3
    })
  }
}

# Launch Template for Webserver 2 (Bastion Host)
resource "aws_launch_template" "bastion_lt" {
  name_prefix   = "${var.environment}-bastion-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Webserver 2 (Bastion Host)</h1>" > /var/www/html/index.html
              EOF
  )

  iam_instance_profile {
    name = "LabProfile"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.environment}-webserver2"  # This is webserver2
    })
  }
}

# Launch Template for Webserver 4
resource "aws_launch_template" "webserver4_lt" {
  name_prefix   = "${var.environment}-webserver4-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Webserver 4</h1>" > /var/www/html/index.html
              EOF
  )

  iam_instance_profile {
    name = "LabProfile"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.environment}-webserver4"
    })
  }
}

# Launch Template for Webserver 5 and 6
resource "aws_launch_template" "private_lt" {
  name_prefix   = "${var.environment}-private-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = "LabProfile"
  }

  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.environment}-webserver-private"  # This will be webserver5 and webserver6
    })
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
    value              = "${var.environment}-webserver-asg"
    propagate_at_launch = true
  }
}

# Bastion Host (Webserver 2)
resource "aws_instance" "bastion" {
  launch_template {
    id      = aws_launch_template.bastion_lt.id
    version = "$Latest"
  }
  subnet_id = var.public_subnet_ids[var.bastion_subnet_index]

  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.environment}-webserver2"
  })
}

# Webserver 4
resource "aws_instance" "webserver4" {
  launch_template {
    id      = aws_launch_template.webserver4_lt.id
    version = "$Latest"
  }
  subnet_id = var.public_subnet_ids[var.web4_subnet_index]

  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.environment}-webserver4"
  })
}

# VM5
resource "aws_instance" "vm5" {
  launch_template {
    id      = aws_launch_template.private_lt.id
    version = "$Latest"
  }
  subnet_id = var.private_subnet_ids[var.web5_subnet_index]

  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.environment}-webserver-private"
  })
}

# VM6
resource "aws_instance" "vm6" {
  launch_template {
    id      = aws_launch_template.private_lt.id
    version = "$Latest"
  }
  subnet_id = var.private_subnet_ids[var.vm6_subnet_index]

  tags = merge(var.common_tags, var.additional_tags, {
    Name = "${var.environment}-webserver-private"
  })
}