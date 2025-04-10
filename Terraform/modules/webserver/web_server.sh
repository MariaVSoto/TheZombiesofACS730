#!/bin/bash
# Install Apache
apt-get update
apt-get install -y apache2 awscli

# Configure Apache to serve from /var/www/html
cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Download content from S3 (assuming bucket is configured for EC2 instance access)
aws s3 sync s3://${s3_bucket_name} /var/www/html --no-sign-request

# Start Apache
systemctl start apache2
systemctl enable apache2