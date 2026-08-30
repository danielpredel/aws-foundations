#!/usr/bin/env bash
set -euxo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

cd /home/ec2-user

# Install dependencies
dnf update -y
dnf install -y git tar curl --allowerasing

# Clone app
git clone https://github.com/danielpredel/aws-foundations.git tmp-repo
mv tmp-repo/app .
rm -rf tmp-repo

# Install uv for ec2-user
sudo -u ec2-user bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'

# Move into app
cd /home/ec2-user/app

# Define bucket name
echo "${bucket_name}" > ./src/.bucket_name

# Change owner of the app
chown -R ec2-user:ec2-user /home/ec2-user/app

# Install app dependencies as ec2-user
sudo -u ec2-user /home/ec2-user/.local/bin/uv sync

# Create systemd service
cat > /etc/systemd/system/aws-foundations.service <<EOF
[Unit]
Description=AWS Foundations FastAPI App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/home/ec2-user/.local/bin/uv run uvicorn src.main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable --now aws-foundations.service
