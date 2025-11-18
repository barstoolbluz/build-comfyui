#!/usr/bin/env bash
# Run ComfyUI with CUDA support
# Usage: flox activate, then run this script

set -euo pipefail

# Create working directories
mkdir -p ~/comfyui-work/{models,output,input,temp}

# Start ComfyUI server
./result-comfyui-cuda/bin/comfyui-cuda \
  --user-directory ~/comfyui-work \
  --output-directory ~/comfyui-work/output \
  --temp-directory ~/comfyui-work/temp \
  --input-directory ~/comfyui-work/input \
  --database-url "sqlite:///$HOME/comfyui-work/comfyui.db" \
  --listen 192.168.0.42 \
  --port 8188
