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

# Start app
# /root/.local/bin/uv run uvicorn src.main:app --host 0.0.0.0 --port 8000

# Create systemd service
cat > /etc/systemd/system/aws-foundations.service <<EOF
[Unit]
Description=AWS Foundations FastAPI App
After=network.target

[Service]
Environment="AWS_ENDPOINT_URL=${aws_endpoint_url}"
Environment="AWS_EC2_METADATA_SERVICE_ENDPOINT=http://172.17.0.2:9169"
Environment="AWS_DEFAULT_REGION=us-east-1"
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
