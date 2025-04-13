# Launch Template for ASG Instances (Webserver 1 and 3)
resource "aws_launch_template" "asg_lt" {
  name_prefix   = "${var.team_name}-asg-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd jq

              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd
              
              # Get instance metadata
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
              PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
              AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              
              # Get ASG name using AWS CLI
              ASG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids $INSTANCE_ID --region us-east-1 --query 'AutoScalingInstances[0].AutoScalingGroupName' --output text)
              
              # Create custom index.html
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

              # Add instance metadata to logs
              echo "Instance Metadata:" >> /var/log/user-data.log
              echo "Instance ID: $INSTANCE_ID" >> /var/log/user-data.log
              echo "Private IP: $PRIVATE_IP" >> /var/log/user-data.log
              echo "ASG Name: $ASG_NAME" >> /var/log/user-data.log
              EOF
  )

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.team_name}-webserver-asg"
    })
  }
}

# Launch Template for Webserver 4
resource "aws_launch_template" "webserver4_lt" {
  name_prefix   = "${var.team_name}-webserver4-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd jq

              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd
              
              # Get instance metadata
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
              PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
              AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              
              # Create custom index.html
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

              # Add instance metadata to logs
              echo "Instance Metadata:" >> /var/log/user-data.log
              echo "Instance ID: $INSTANCE_ID" >> /var/log/user-data.log
              echo "Private IP: $PRIVATE_IP" >> /var/log/user-data.log
              EOF
  )

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, var.additional_tags, {
      Name = "${var.team_name}-webserver4"
    })
  }
}