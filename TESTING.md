# Testing ComfyUI Builds

## Quick Test

The fastest way to verify your build works:

```bash
# Test the executable
./result-comfyui-cuda/bin/comfyui-cuda --help

# Should show usage information
```

## Automated Tests

### Basic Test (No GPU Required)

```bash
chmod +x test-comfyui-simple.sh
./test-comfyui-simple.sh comfyui-cuda
```

This tests:
- ✅ Executable exists and runs
- ✅ Help output works
- ✅ Python imports work
- ✅ Basic startup

### Full Test (GPU Required for CUDA)

```bash
chmod +x test-comfyui.sh
./test-comfyui.sh comfyui-cuda
```

This tests everything including GPU detection.

## Manual Testing

### Step 1: Test in Flox Environment

```bash
# Activate environment
flox activate

# Install barstoolbluz CUDA packages (for full optimization)
flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512

# Test executable
./result-comfyui-cuda/bin/comfyui-cuda --help
```

### Step 2: Verify PyTorch and CUDA

```bash
# In activated environment
python3 << 'EOF'
import torch
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA version: {torch.version.cuda if torch.cuda.is_available() else 'N/A'}")
print(f"GPU count: {torch.cuda.device_count() if torch.cuda.is_available() else 0}")

if torch.cuda.is_available():
    for i in range(torch.cuda.device_count()):
        print(f"GPU {i}: {torch.cuda.get_device_name(i)}")

    # Test CUDA computation
    x = torch.rand(5, 3).cuda()
    print(f"\n✅ CUDA computation works!")
    print(f"Test tensor on {x.device}: {x.shape}")
EOF
```

**Expected output with barstoolbluz packages:**
```
PyTorch version: 2.8.0
CUDA available: True
CUDA version: 12.8
GPU count: 1
GPU 0: NVIDIA GeForce RTX 4090

✅ CUDA computation works!
Test tensor on cuda:0: torch.Size([5, 3])
```

### Step 3: Check Package Sources

Verify you're using barstoolbluz packages:

```bash
python3 << 'EOF'
import torch
import torchvision
import torchaudio

print("Package locations:")
print(f"torch:       {torch.__file__}")
print(f"torchvision: {torchvision.__file__}")
print(f"torchaudio:  {torchaudio.__file__}")

# Should contain "pytorch-python313-cuda12_8-sm120-avx512" if barstoolbluz is active
if "pytorch-python313-cuda12_8" in torch.__file__:
    print("\n✅ Using barstoolbluz optimized PyTorch!")
else:
    print("\n⚠️  Using nixpkgs PyTorch (install barstoolbluz packages for optimization)")
EOF
```

### Step 4: Test Dependencies

```bash
python3 << 'EOF'
# Test all ComfyUI dependencies
deps = {
    'torch': 'PyTorch',
    'torchvision': 'TorchVision',
    'torchaudio': 'TorchAudio',
    'torchsde': 'TorchSDE',
    'transformers': 'Transformers',
    'tokenizers': 'Tokenizers',
    'safetensors': 'SafeTensors',
    'aiohttp': 'aiohttp',
    'PIL': 'Pillow',
    'numpy': 'NumPy',
    'scipy': 'SciPy',
    'einops': 'einops',
    'pydantic': 'Pydantic',
    'sqlalchemy': 'SQLAlchemy',
}

print("Testing dependencies...")
missing = []
for module, name in deps.items():
    try:
        mod = __import__(module)
        version = getattr(mod, '__version__', 'unknown')
        print(f"✓ {name:20s} {version}")
    except ImportError as e:
        missing.append(name)
        print(f"✗ {name:20s} MISSING")

if missing:
    print(f"\n❌ Missing: {', '.join(missing)}")
else:
    print(f"\n✅ All {len(deps)} dependencies available!")
EOF
```

### Step 5: Start ComfyUI Server

```bash
# Start server (Ctrl+C to stop)
./result-comfyui-cuda/bin/comfyui-cuda --listen 127.0.0.1 --port 8188

# Or with CUDA device selection
./result-comfyui-cuda/bin/comfyui-cuda --listen 127.0.0.1 --port 8188 --cuda-device 0
```

**Expected output:**
```
Total VRAM 24564 MB, total RAM 65536 MB
pytorch version: 2.8.0
Set vram state to: NORMAL_VRAM
Device: cuda:0 NVIDIA GeForce RTX 4090 : cudaMallocAsync

Starting server
To see the GUI go to: http://127.0.0.1:8188
```

### Step 6: Test in Browser

1. Open browser to `http://127.0.0.1:8188`
2. You should see the ComfyUI interface
3. Try loading a default workflow
4. Check that models can be loaded

## Performance Testing

### CPU vs CUDA Performance

Test inference speed:

```python
import torch
import time

# Test tensor size
size = (1000, 1000)

# CPU test
x_cpu = torch.rand(size)
start = time.time()
for _ in range(100):
    y = x_cpu @ x_cpu.T
cpu_time = time.time() - start

print(f"CPU: {cpu_time:.2f}s")

# CUDA test (if available)
if torch.cuda.is_available():
    x_cuda = torch.rand(size).cuda()
    torch.cuda.synchronize()
    start = time.time()
    for _ in range(100):
        y = x_cuda @ x_cuda.T
    torch.cuda.synchronize()
    cuda_time = time.time() - start

    print(f"CUDA: {cuda_time:.2f}s")
    print(f"Speedup: {cpu_time/cuda_time:.1f}x")
```

### Memory Test

```python
import torch

if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    print(f"Total VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")
    print(f"Allocated: {torch.cuda.memory_allocated() / 1e9:.1f} GB")
    print(f"Cached: {torch.cuda.memory_reserved() / 1e9:.1f} GB")

    # Allocate some memory
    x = torch.rand(10000, 10000).cuda()
    print(f"\nAfter allocation:")
    print(f"Allocated: {torch.cuda.memory_allocated() / 1e9:.1f} GB")
```

## Comparing Variants

### Test All Three Variants

```bash
# Build all variants
flox build comfyui comfyui-cpu comfyui-cuda

# Test standard
./result-comfyui/bin/comfyui --help

# Test CPU-optimized (requires AVX-512)
./result-comfyui-cpu/bin/comfyui-cpu --help

# Test CUDA-optimized (requires GPU)
./result-comfyui-cuda/bin/comfyui-cuda --help
```

### Benchmark Script

```bash
# Create benchmark script
cat > benchmark.py << 'EOF'
import torch
import time
import sys

def benchmark(device='cpu', iterations=100):
    size = (2000, 2000)
    x = torch.rand(size, device=device)

    # Warmup
    for _ in range(10):
        y = x @ x.T

    if device == 'cuda':
        torch.cuda.synchronize()

    start = time.time()
    for _ in range(iterations):
        y = x @ x.T

    if device == 'cuda':
        torch.cuda.synchronize()

    elapsed = time.time() - start
    print(f"{device.upper()}: {elapsed:.2f}s ({iterations} iterations)")
    return elapsed

print(f"PyTorch version: {torch.__version__}")
cpu_time = benchmark('cpu')

if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    cuda_time = benchmark('cuda')
    print(f"Speedup: {cpu_time/cuda_time:.1f}x")
EOF

# Run benchmark
python3 benchmark.py
```

## Troubleshooting

### "No module named 'torch'"

**Problem**: Testing outside of Flox environment.

**Solution**:
```bash
flox activate
# Then run tests
```

### "CUDA not available"

**Problem**: GPU drivers not installed or wrong version.

**Solution**:
```bash
# Check GPU
nvidia-smi

# Check driver supports CUDA 12.8
# Driver version should be >= 525.60.13

# Verify CUDA libraries
ls -l /usr/local/cuda*/lib64/libcudart.so*
```

### "Wrong PyTorch version"

**Problem**: Not using barstoolbluz packages.

**Solution**:
```bash
flox list | grep pytorch

# If not installed:
flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512
```

### "Out of memory"

**Problem**: Model too large for GPU VRAM.

**Solution**: Use `--lowvram` or `--normalvram` flags:
```bash
./result-comfyui-cuda/bin/comfyui-cuda --lowvram
```

## Success Criteria

Your build is working correctly if:

- ✅ Executable runs without errors
- ✅ `--help` shows usage information
- ✅ PyTorch imports successfully
- ✅ `torch.cuda.is_available()` returns `True` (for CUDA variant)
- ✅ All dependencies import without errors
- ✅ Server starts on port 8188
- ✅ Web interface loads in browser
- ✅ Can load and run workflows

## Next Steps

Once testing passes:

1. **Commit final changes**: `git commit -am "Verified CUDA build"`
2. **Push to remote**: `git push`
3. **Publish**: `flox publish comfyui-cuda`

## CI/CD Testing

For automated testing in CI:

```bash
# Quick validation (no GPU)
./result-comfyui-cuda/bin/comfyui-cuda --quick-test-for-ci

# Exit code 0 = success
```

Or use the test scripts in GitHub Actions:

```yaml
- name: Test ComfyUI build
  run: |
    chmod +x test-comfyui-simple.sh
    ./test-comfyui-simple.sh comfyui-cuda
```
