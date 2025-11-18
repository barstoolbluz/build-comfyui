#!/usr/bin/env bash
# Quick test script for comfyui-cuda

set -euo pipefail

echo "========================================="
echo "Testing comfyui-cuda with CUDA support"
echo "========================================="
echo

# Test 1: Verify CUDA is available
echo "[Test 1] Checking CUDA availability..."
flox activate -- python3 << 'PYEOF'
import torch
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"CUDA version: {torch.version.cuda}")
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    print(f"✅ CUDA is working!")
else:
    print(f"❌ CUDA not available")
    exit(1)
PYEOF
echo

# Test 2: Start ComfyUI server
echo "[Test 2] Starting ComfyUI server..."
echo "Creating working directory in /tmp/comfyui-work..."
mkdir -p /tmp/comfyui-work/{models,output,input,temp}

echo
echo "Starting server (will run for 10 seconds)..."
echo "Watch for these lines:"
echo "  - 'Total VRAM'"
echo "  - 'Device: cuda:0'"
echo "  - 'Starting server'"
echo

timeout 10s flox activate -- ./result-comfyui-cuda/bin/comfyui-cuda \
  --user-directory /tmp/comfyui-work \
  --output-directory /tmp/comfyui-work/output \
  --temp-directory /tmp/comfyui-work/temp \
  --input-directory /tmp/comfyui-work/input \
  --listen 127.0.0.1 \
  --port 8188 \
  2>&1 || true

echo
echo "========================================="
echo "✅ Test complete!"
echo "========================================="
echo
echo "To run ComfyUI manually:"
echo "  mkdir -p ~/comfyui-work/{models,output,input,temp}"
echo "  flox activate -- ./result-comfyui-cuda/bin/comfyui-cuda \\"
echo "    --user-directory ~/comfyui-work \\"
echo "    --output-directory ~/comfyui-work/output \\"
echo "    --temp-directory ~/comfyui-work/temp \\"
echo "    --input-directory ~/comfyui-work/input \\"
echo "    --listen 127.0.0.1 \\"
echo "    --port 8188"
echo
echo "Then visit: http://127.0.0.1:8188"
echo
