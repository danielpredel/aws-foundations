#!/usr/bin/env bash
set -euxo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# Move to ec2-user's home
cd /home/ec2-user

# Install git
dnf update -y
dnf install -y git tar --allowerasing

# Clone app
git clone https://github.com/danielpredel/aws-foundations.git tmp-repo
mv tmp-repo/app .
rm -rf tmp-repo

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source /root/.local/bin/env

# Move into app's dir
cd app

# Define bucket's name
echo "${bucket_name}" > ./src/.bucket_name

# Download app's dependencies
uv sync

# Create systemd service
cat > /etc/systemd/system/awsapp.service <<EOF
[Unit]
Description=AWS Foundations App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/root/.local/bin/uv run uvicorn src.main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable awsapp
systemctl start awsapp
