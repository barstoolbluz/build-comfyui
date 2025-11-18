# ComfyUI Flox Packaging - Quick Start

## TL;DR

```bash
# Clone this repo
git clone <this-repo>
cd comfyui

# Build standard variant
flox build comfyui

# Or build CPU-optimized variant
flox install barstoolbluz/pytorch-python313-cpu-avx512
flox build comfyui-cpu

# Or build CUDA-optimized variant (full stack available!)
flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512
flox build comfyui-cuda
```

## Variants at a Glance

| Variant | Command | PyTorch Source | Best For |
|---------|---------|----------------|----------|
| Standard | `comfyui` | nixpkgs | General use, testing |
| CPU | `comfyui-cpu` | barstoolbluz | AVX-512 CPUs, inference |
| CUDA | `comfyui-cuda` | barstoolbluz | RTX 40-series GPUs |

## Common Tasks

### Build Locally

```bash
flox build comfyui
./result-comfyui/bin/comfyui --help
```

### Publish to Catalog

```bash
# Setup (one time)
git remote add origin <your-repo>
git push -u origin master
flox auth login

# Publish
flox publish comfyui
flox publish -o <catalog> comfyui-cpu
flox publish -o <catalog> comfyui-cuda
```

### Update for New ComfyUI Release

```bash
# 1. Edit .flox/pkgs/comfyui*.nix
version = "0.3.69"  # New version
hash = ""           # Clear hash

# 2. Get new hash
flox build comfyui 2>&1 | grep "got:"

# 3. Update hash in .nix file
hash = "sha256-NEW_HASH"

# 4. Build & publish
flox build comfyui comfyui-cpu comfyui-cuda
git add -A && git commit -m "Update to v0.3.69"
git push
flox publish comfyui comfyui-cpu comfyui-cuda
```

### Test PyTorch Backend

```bash
# In activated environment
python3 << 'EOF'
import torch
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"CUDA version: {torch.version.cuda}")
    print(f"GPU: {torch.cuda.get_device_name(0)}")
EOF
```

## Package Contents

Each variant includes:

### Python Dependencies
- ✅ PyTorch, torchvision, torchaudio, torchsde
- ✅ Transformers, tokenizers, safetensors
- ✅ NumPy, SciPy, Pillow, einops
- ✅ aiohttp, pyyaml, pydantic
- ✅ SQLAlchemy, alembic

### ComfyUI Components (from PyPI)
- ✅ Frontend assets (1.28.8)
- ✅ Workflow templates (0.2.11)
- ✅ Embedded docs (0.3.1)
- ✅ Spandrel upscaler (0.4.0)

## When to Use Each Variant

### Use `comfyui` (standard) when:
- You want maximum compatibility
- You're testing or developing
- You don't have AVX-512 or RTX 40-series
- You're on a non-x86_64-linux platform

### Use `comfyui-cpu` when:
- You have an AVX-512 capable CPU
- You're doing inference only (no training)
- You don't have a GPU
- You want fastest CPU performance

### Use `comfyui-cuda` when:
- You have an RTX 40-series GPU (4090, 4080, etc.)
- You have an AVX-512 CPU
- You want maximum performance
- You have CUDA 12.8 drivers

## File Locations

```
.flox/pkgs/
├── comfyui.nix                    # Standard variant
├── comfyui-cpu.nix                # CPU variant
├── comfyui-cuda.nix               # CUDA variant
├── comfyui-frontend-package.nix   # PyPI: Frontend
├── comfyui-workflow-templates.nix # PyPI: Templates
├── comfyui-embedded-docs.nix      # PyPI: Docs
└── spandrel.nix                   # PyPI: Upscaler
```

## Common Issues

### "required argument pytorch-python313-*"
**Solution**: The barstoolbluz PyTorch packages are installed via `[install]`, not Nix dependencies. Just build without them - they're not needed at build time.

### Hash mismatch
**Solution**: Clear hash (`hash = ""`), rebuild, copy hash from error.

### CUDA not available at runtime
**Solution**:
1. Check: `nvidia-smi`
2. Install CUDA PyTorch: `flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512`
3. Verify in Python: `import torch; torch.cuda.is_available()`

### Conflicts between PyTorch packages
**Solution**: Don't install both CPU and CUDA PyTorch in same environment. Use separate environments or use priority values (see FLOX.md §5).

## Next Steps

1. **Read full docs**: See [README.md](./README.md)
2. **Build variants**: Try all three variants
3. **Publish**: Share to your Flox catalog
4. **Stay updated**: Watch ComfyUI releases, update version/hash

## Quick Reference

```bash
# Build
flox build <package>

# Publish
flox publish <package>
flox publish -o <catalog> <package>

# Test
./result-<package>/bin/<package> --help

# List builds
ls -l result-*

# Check dependencies
flox list
```

## Links

- [Full Documentation](./README.md)
- [Flox Reference](./FLOX.md)
- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [barstoolbluz PyTorch](https://github.com/barstoolbluz/build-pytorch)
