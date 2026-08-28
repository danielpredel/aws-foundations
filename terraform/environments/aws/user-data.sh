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

# Start app
uv run uvicorn src.main:app --host 0.0.0.0 --port 8000
