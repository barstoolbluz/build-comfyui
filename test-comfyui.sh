#!/usr/bin/env bash
# Test script for ComfyUI builds
# Usage: ./test-comfyui.sh [comfyui|comfyui-cpu|comfyui-cuda]

set -euo pipefail

VARIANT="${1:-comfyui-cuda}"
RESULT_DIR="./result-${VARIANT}"
EXECUTABLE="${RESULT_DIR}/bin/${VARIANT}"

echo "========================================="
echo "Testing ${VARIANT}"
echo "========================================="
echo

# Test 1: Executable exists and runs
echo "[1/5] Testing executable..."
if [ ! -f "$EXECUTABLE" ]; then
    echo "❌ FAIL: Executable not found at $EXECUTABLE"
    echo "   Run: flox build ${VARIANT}"
    exit 1
fi

if ! "$EXECUTABLE" --help > /dev/null 2>&1; then
    echo "❌ FAIL: Executable failed to run"
    exit 1
fi
echo "✅ PASS: Executable runs"
echo

# Test 2: Check PyTorch
echo "[2/5] Testing PyTorch import and version..."
TORCH_TEST=$(cat << 'EOF'
import torch
import sys

print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")

if torch.cuda.is_available():
    print(f"CUDA version: {torch.version.cuda}")
    print(f"cuDNN version: {torch.backends.cudnn.version()}")
    print(f"GPU count: {torch.cuda.device_count()}")
    for i in range(torch.cuda.device_count()):
        print(f"GPU {i}: {torch.cuda.get_device_name(i)}")
else:
    print("Running on CPU")

# Check if we're using optimized build
if hasattr(torch, '__file__'):
    print(f"PyTorch path: {torch.__file__}")
EOF
)

if ! python3 -c "$TORCH_TEST"; then
    echo "❌ FAIL: PyTorch test failed"
    exit 1
fi
echo "✅ PASS: PyTorch loaded successfully"
echo

# Test 3: Check key dependencies
echo "[3/5] Testing ComfyUI dependencies..."
DEPS_TEST=$(cat << 'EOF'
import sys

deps = [
    'torch',
    'torchvision',
    'torchaudio',
    'transformers',
    'safetensors',
    'aiohttp',
    'PIL',
    'numpy',
    'scipy',
]

missing = []
for dep in deps:
    try:
        __import__(dep)
        print(f"✓ {dep}")
    except ImportError as e:
        missing.append(dep)
        print(f"✗ {dep}: {e}")

if missing:
    print(f"\n❌ Missing dependencies: {', '.join(missing)}")
    sys.exit(1)
else:
    print("\n✅ All dependencies available")
EOF
)

if ! python3 -c "$DEPS_TEST"; then
    echo "❌ FAIL: Dependency check failed"
    exit 1
fi
echo "✅ PASS: All dependencies loaded"
echo

# Test 4: Check ComfyUI modules
echo "[4/5] Testing ComfyUI modules..."
COMFY_TEST=$(cat << 'EOF'
import sys
sys.path.insert(0, 'RESULT_PATH/share/comfyui')

try:
    import comfy
    print(f"✓ comfy module loaded")
    import comfy_api
    print(f"✓ comfy_api module loaded")
    import folder_paths
    print(f"✓ folder_paths module loaded")
    print("\n✅ ComfyUI modules loaded successfully")
except Exception as e:
    print(f"❌ FAIL: {e}")
    sys.exit(1)
EOF
)

COMFY_TEST_UPDATED=$(echo "$COMFY_TEST" | sed "s|RESULT_PATH|${RESULT_DIR}|")

if ! python3 -c "$COMFY_TEST_UPDATED"; then
    echo "❌ FAIL: ComfyUI module check failed"
    exit 1
fi
echo "✅ PASS: ComfyUI modules loaded"
echo

# Test 5: Check command-line arguments
echo "[5/5] Testing command-line interface..."
if ! "$EXECUTABLE" --help 2>&1 | grep -q "usage: main.py"; then
    echo "❌ FAIL: Help output incorrect"
    exit 1
fi
echo "✅ PASS: Command-line interface works"
echo

# Summary
echo "========================================="
echo "✅ ALL TESTS PASSED"
echo "========================================="
echo
echo "Next steps:"
echo "  • Test with actual workflow:"
echo "    $EXECUTABLE --listen 127.0.0.1 --port 8188"
echo
echo "  • Access at: http://127.0.0.1:8188"
echo
if [ "$VARIANT" = "comfyui-cuda" ]; then
    echo "  • CUDA-specific test:"
    echo "    $EXECUTABLE --cuda-device 0"
    echo
fi
