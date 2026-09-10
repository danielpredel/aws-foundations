#!/usr/bin/env bash

# Enable strict error handling
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# Move to root directory
cd /root

# Install dependencies
apt update -y
apt install git tar -y

# Clone app
git clone https://github.com/danielpredel/aws-foundations.git tmp-repo
mv tmp-repo/app .
rm -rf tmp-repo

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Move into app
cd app

# Define bucket's name
echo "${bucket_name}" > ./src/.bucket_name

# Download app's dependencies
/root/.local/bin/uv sync

# Create systemd service for the app
cat > /etc/systemd/system/aws-foundations.service <<EOF
[Unit]
Description=AWS Foundations FastAPI App
After=network.target

[Service]
Environment="AWS_ENDPOINT_URL=${aws_endpoint_url}"
Environment="AWS_EC2_METADATA_SERVICE_ENDPOINT=${aws_ec2_metadata_service_endpoint}"
Environment="AWS_DEFAULT_REGION=${region}"
User=root
WorkingDirectory=/root/app
ExecStart=/root/.local/bin/uv run uvicorn src.main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable --now aws-foundations.service

# Install CloudWatch Agent
cd /tmp
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E amazon-cloudwatch-agent.deb

# Create CloudWatch Configuration File
cat > /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-agent.json <<EOF
{
    "agent": {
        "region": "${region}"
    },
    "logs": {
        "endpoint_override": "${aws_endpoint_url}",
        "logs_collected": {
            "journald": {
                "collect_list": [
                    {
                        "units": [
                        "aws-foundations.service"
                        ],
                        "log_group_name": "/aws/ec2/aws-foundations",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    }
}
EOF

# Add Floci endpoints to CloudWatch Agent systemd service configuration 
sudo mkdir -p /etc/systemd/system/amazon-cloudwatch-agent.service.d

sudo tee /etc/systemd/system/amazon-cloudwatch-agent.service.d/floci.conf > /dev/null <<EOF
[Service]
Environment="AWS_ENDPOINT_URL=${aws_endpoint_url}"
Environment="AWS_EC2_METADATA_SERVICE_ENDPOINT=${aws_ec2_metadata_service_endpoint}"
EOF

sudo systemctl daemon-reload

# Start the agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-agent.json
