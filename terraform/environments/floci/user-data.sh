#!/usr/bin/env bash

# Move to root's home
cd $HOME

# Install git
dnf update -y
dnf install git tar -y

# Clone app
git clone https://github.com/danielpredel/aws-foundations.git tmp-repo
mv tmp-repo/app .
rm -rf tmp-repo

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
echo 'source $HOME/.local/bin/env' >> /home/root/.bashrc

# Move into app's dir
cd app

# Define bucket's name
echo "${bucket_name}" > ./src/.bucket_name

# Download app's dependencies
uv sync

# Start app
uv run uvicorn src.main:app --host 0.0.0.0 --port 8000
