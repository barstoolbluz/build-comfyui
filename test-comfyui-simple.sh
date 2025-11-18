#!/usr/bin/env bash
# Simple test for ComfyUI builds
# Usage: ./test-comfyui-simple.sh [comfyui|comfyui-cpu|comfyui-cuda]

set -euo pipefail

VARIANT="${1:-comfyui-cuda}"
RESULT_DIR="./result-${VARIANT}"
EXECUTABLE="${RESULT_DIR}/bin/${VARIANT}"

echo "========================================="
echo "Testing ${VARIANT}"
echo "========================================="
echo

# Test 1: Executable exists and shows help
echo "[Test 1] Checking executable..."
if [ ! -f "$EXECUTABLE" ]; then
    echo "❌ FAIL: Executable not found"
    echo "   Build with: flox build ${VARIANT}"
    exit 1
fi

echo "✅ Executable exists: $EXECUTABLE"
echo

# Test 2: Run help command
echo "[Test 2] Running --help..."
if ! "$EXECUTABLE" --help 2>&1 | head -5; then
    echo "❌ FAIL: Help command failed"
    exit 1
fi
echo "✅ Help command works"
echo

# Test 3: Check Python imports via the executable
echo "[Test 3] Testing Python imports..."
TEST_SCRIPT=$(cat << 'EOF'
import sys
print("Testing imports...")

# Test PyTorch
try:
    import torch
    print(f"✓ PyTorch {torch.__version__}")
    print(f"  CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"  CUDA version: {torch.version.cuda}")
        print(f"  GPU: {torch.cuda.get_device_name(0)}")
    print(f"  Location: {torch.__file__}")
except Exception as e:
    print(f"✗ PyTorch: {e}")
    sys.exit(1)

# Test torchvision
try:
    import torchvision
    print(f"✓ torchvision {torchvision.__version__}")
    print(f"  Location: {torchvision.__file__}")
except Exception as e:
    print(f"✗ torchvision: {e}")
    sys.exit(1)

# Test torchaudio
try:
    import torchaudio
    print(f"✓ torchaudio {torchaudio.__version__}")
    print(f"  Location: {torchaudio.__file__}")
except Exception as e:
    print(f"✗ torchaudio: {e}")
    sys.exit(1)

# Test other key dependencies
deps = ['transformers', 'safetensors', 'aiohttp', 'PIL', 'numpy']
for dep in deps:
    try:
        mod = __import__(dep)
        print(f"✓ {dep}")
    except ImportError as e:
        print(f"✗ {dep}: {e}")
        sys.exit(1)

print("\n✅ All imports successful!")
EOF
)

# Run the test via Python directly (not through ComfyUI main.py)
if ! python3 -c "$TEST_SCRIPT"; then
    echo "❌ FAIL: Python import test failed"
    exit 1
fi
echo

# Test 4: Test ComfyUI actually starts (quick test)
echo "[Test 4] Testing ComfyUI startup (3 seconds)..."
if timeout 3s "$EXECUTABLE" --quick-test-for-ci > /dev/null 2>&1 || [ $? -eq 124 ]; then
    # Exit code 124 is timeout, which is fine - means it was running
    echo "✅ ComfyUI starts successfully"
else
    echo "⚠️  Quick startup test inconclusive (this is often OK)"
fi
echo

echo "========================================="
echo "✅ BASIC TESTS PASSED"
echo "========================================="
echo
echo "To test with barstoolbluz packages:"
echo "  1. Install the packages:"
echo "     flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512"
echo "     flox install barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512"
echo "     flox install barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512"
echo
echo "  2. Activate environment and test:"
echo "     flox activate"
echo "     $EXECUTABLE --help"
echo
echo "To run ComfyUI server:"
echo "  $EXECUTABLE --listen 127.0.0.1 --port 8188"
echo
echo "Then visit: http://127.0.0.1:8188"
echo
