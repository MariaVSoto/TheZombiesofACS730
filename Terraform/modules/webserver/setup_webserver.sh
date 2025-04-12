#!/bin/bash

# Parameters
WEBSERVER_ID=$1
GROUP_NAME=$2
S3_BUCKET=$3

# Update system packages
sudo yum update -y

# Install Apache and awscli
sudo yum install -y httpd awscli

# Start and enable Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Get instance metadata
HOSTNAME=$(hostname)
IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Check if instance is part of an Auto Scaling group
ASG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids $INSTANCE_ID --region us-east-1 --query 'AutoScalingInstances[0].AutoScalingGroupName' --output text)

# Download appropriate image based on ASG status
if [ "$ASG_NAME" != "None" ] && [ ! -z "$ASG_NAME" ]; then
    # Instance is part of ASG
    aws s3 cp s3://${S3_BUCKET}/webserver/ASG.jpg /var/www/html/server.jpg
    DISPLAY_NAME="ASG Instance: $ASG_NAME"
else
    # Standalone instance
    aws s3 cp s3://${S3_BUCKET}/webserver/webserver${WEBSERVER_ID}.jpg /var/www/html/server.jpg
    DISPLAY_NAME="Webserver ${WEBSERVER_ID}"
fi

# Create index.html with hostname, IP, creation method, and image
cat <<EOT | sudo tee /var/www/html/index.html
<h1>Hello from ${DISPLAY_NAME}</h1>
<p>Team: ${GROUP_NAME}</p>
<p>Hostname: $HOSTNAME</p>
<p>IP Address: $IP</p>
<p>Created by Terraform</p>
<img src="/server.jpg" alt="Server Image">
EOT