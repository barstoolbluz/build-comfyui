# ComfyUI Flox Package Repository

Build and publish reproducible ComfyUI packages with optimized PyTorch backends.

## Overview

This repository packages **ComfyUI** (the most powerful and modular diffusion model GUI) using Flox's Nix expression build system. It provides three variants optimized for different hardware targets:

| Package | PyTorch Backend | Target Hardware | Platform |
|---------|----------------|-----------------|----------|
| `comfyui` | nixpkgs (standard) | General purpose | Linux |
| `comfyui-cpu` | barstoolbluz CPU | AVX-512 CPUs | x86_64-linux |
| `comfyui-cuda` | barstoolbluz CUDA | RTX 40-series (SM 12.0) + AVX-512 | x86_64-linux |

## Architecture

### Environment Composition Pattern

Following FLOX.md §12, these packages use **environment composition** rather than hard Nix dependencies for PyTorch:

```
ComfyUI Package (built with nixpkgs PyTorch)
    ↓
[install] barstoolbluz/pytorch-python313-* (installed in manifest)
    ↓
Runtime: barstoolbluz PyTorch takes precedence
```

This allows:
- **Build-time**: Standard nixpkgs dependencies for reproducible builds
- **Runtime**: Optimized PyTorch from barstoolbluz catalog
- **Flexibility**: Switch PyTorch backends without rebuilding ComfyUI

### Package Structure

```
.flox/pkgs/
├── comfyui.nix                          # Standard variant
├── comfyui-cpu.nix                      # CPU-optimized variant
├── comfyui-cuda.nix                     # CUDA-optimized variant
├── comfyui-frontend-package.nix         # Frontend assets (PyPI)
├── comfyui-workflow-templates.nix       # Workflow templates (PyPI)
├── comfyui-embedded-docs.nix            # Embedded docs (PyPI)
└── spandrel.nix                         # Image upscaling library (PyPI)
```

## Quick Start

### Prerequisites

- [Flox installed](https://flox.dev)
- Flox account: `flox auth login`
- Git repository with remote configured

### Build Standard Variant

```bash
flox build comfyui
./result-comfyui/bin/comfyui --help
```

### Build CPU-Optimized Variant

```bash
# Install optimized PyTorch
flox install barstoolbluz/pytorch-python313-cpu-avx512

# Build ComfyUI
flox build comfyui-cpu
./result-comfyui-cpu/bin/comfyui-cpu --help
```

### Build CUDA-Optimized Variant

```bash
# Install CUDA PyTorch
flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512

# Build ComfyUI
flox build comfyui-cuda
./result-comfyui-cuda/bin/comfyui-cuda --help
```

## Publishing

### Prerequisites for Publishing

Per FLOX.md §11, you need:
- ✅ Package defined in `.flox/pkgs/` (done)
- ✅ Git repository with configured remote
- ✅ Clean working tree (all changes committed)
- ✅ Current commit pushed to remote
- ✅ All build files tracked by Git
- ✅ At least one package installed in `[install]`

### Publishing Workflow

```bash
# 1. Ensure git remote is configured
git remote add origin <your-repo-url>
git push -u origin master

# 2. Install a package (if not already done)
flox install barstoolbluz/pytorch-python313-cpu-avx512

# 3. Publish packages
flox publish comfyui
flox publish comfyui-cpu
flox publish comfyui-cuda

# Or publish to specific catalog
flox publish -o <your-username> comfyui
flox publish -o <your-org> comfyui-cpu
```

### After Publishing

Packages become available as:
```bash
flox install <catalog>/comfyui
flox install <catalog>/comfyui-cpu
flox install <catalog>/comfyui-cuda
```

## Dependencies

### Core Dependencies

All variants include:
- Python 3.13
- NumPy, SciPy, Pillow, einops
- Transformers, tokenizers, sentencepiece, safetensors
- aiohttp, yarl, pyyaml, pydantic
- SQLAlchemy, alembic (database)
- tqdm, psutil (utilities)

### PyTorch Ecosystem

#### Standard Variant (`comfyui`)
- torch, torchvision, torchaudio, torchsde (from nixpkgs)

#### CPU Variant (`comfyui-cpu`)
- **Requires**: `barstoolbluz/pytorch-python313-cpu-avx512`
- Currently using nixpkgs for: torchvision, torchaudio, torchsde
- **TODO**: Replace with barstoolbluz variants when available

#### CUDA Variant (`comfyui-cuda`)
- **Requires**: `barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512`
- Currently using nixpkgs for: torchvision, torchaudio, torchsde
- **TODO**: Replace with barstoolbluz variants when available

### ComfyUI-Specific Packages (PyPI)

Built using fixed-output derivations with `fetchurl`:
- `comfyui-frontend-package` (1.28.8) - Frontend assets
- `comfyui-workflow-templates` (0.2.11) - Workflow templates
- `comfyui-embedded-docs` (0.3.1) - Embedded documentation
- `spandrel` (0.4.0) - Image upscaling library

## Updating for New ComfyUI Releases

When ComfyUI releases a new version:

### 1. Update Version and Hash

Edit all three variant files (`.flox/pkgs/comfyui*.nix`):

```nix
python3.pkgs.buildPythonApplication rec {
  pname = "comfyui";
  version = "0.3.68";  # Update this

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "v${version}";
    hash = "";  # Clear hash to get new one
  };
```

### 2. Build to Get New Hash

```bash
flox build comfyui 2>&1 | grep "got:"
# Copy the hash from error message
```

### 3. Update Hash

```nix
hash = "sha256-NEW_HASH_HERE";
```

### 4. Verify Build

```bash
flox build comfyui
flox build comfyui-cpu
flox build comfyui-cuda
```

### 5. Commit and Publish

```bash
git add .flox/pkgs/
git commit -m "Update ComfyUI to v0.x.x"
git push
flox publish comfyui
flox publish comfyui-cpu
flox publish comfyui-cuda
```

## Fixed-Output Derivations (PyPI Packages)

The ComfyUI-specific packages use **fetchurl** with direct PyPI URLs, which are allowed network access in Nix sandbox because they're content-addressed:

```nix
src = fetchurl {
  url = "https://files.pythonhosted.org/packages/py3/c/comfyui_frontend_package/comfyui_frontend_package-${version}-py3-none-any.whl";
  hash = "sha256-vnbb+arbg2tnLmkWFFYpTWXzIE8VYuwfeK4SxpNHqOA=";
};
```

This pattern (from FLOX.md §10) allows:
- Network access during fetch phase (before sandbox)
- Reproducible builds (hash verification)
- No need for packages to exist in nixpkgs
- Works in pure sandbox mode

## Usage Examples

### Running ComfyUI

```bash
# Standard variant
flox activate
comfyui --listen 0.0.0.0 --port 8188

# CPU-optimized variant
flox activate
comfyui-cpu --listen 0.0.0.0 --port 8188

# CUDA-optimized variant
flox activate
comfyui-cuda --listen 0.0.0.0 --port 8188 --cuda-device 0
```

### With Custom Directories

```bash
comfyui \
  --output-directory /path/to/outputs \
  --input-directory /path/to/inputs \
  --extra-model-paths-config /path/to/config.yaml
```

### In CI/CD

```yaml
# GitHub Actions example
- uses: flox/install-flox-action@v2
- uses: flox/activate-action@v1
  with:
    command: |
      flox build comfyui
      flox publish -o myorg comfyui
```

## Hardware Requirements

### CPU Variant
- **Required**: AVX-512 support (Intel Skylake-X or newer, AMD Zen 4 or newer)
- **Recommended**: 16GB+ RAM
- For inference only (no training)

### CUDA Variant
- **Required**: NVIDIA RTX 40-series GPU (Ada Lovelace, SM 12.0)
- **Required**: AVX-512 CPU support
- **Required**: CUDA 12.8 compatible driver
- **Recommended**: 8GB+ VRAM, 32GB+ system RAM

### Standard Variant
- Any x86_64 Linux system
- No special CPU instructions required
- Can use CUDA if available

## Known Limitations

### Missing barstoolbluz Packages

The CPU and CUDA variants currently use **nixpkgs versions** for:
- `torchvision`
- `torchaudio`
- `torchsde`

For full optimization, these should be replaced with barstoolbluz variants:
- `barstoolbluz/torchvision-python313-cpu-avx512`
- `barstoolbluz/torchaudio-python313-cpu-avx512`
- `barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512`
- `barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512`

### Platform Support

- **CPU/CUDA variants**: Linux only (`x86_64-linux`)
- **Standard variant**: Linux (could be extended to macOS)

## Troubleshooting

### Build Failures

**Hash mismatch errors**:
```bash
# Clear the hash and rebuild to get correct value
hash = "";
flox build <package> 2>&1 | grep "got:"
```

**Missing dependencies**:
```bash
# Check what's available
flox list
flox search <package>
```

### Runtime Issues

**PyTorch not found**:
```bash
# Verify barstoolbluz PyTorch is installed
flox list | grep pytorch

# Install if missing
flox install barstoolbluz/pytorch-python313-cpu-avx512
```

**CUDA errors**:
```bash
# Check CUDA availability
nvidia-smi
python3 -c "import torch; print(torch.cuda.is_available())"
```

## Development

### Repository Structure

```
.
├── .flox/
│   ├── pkgs/           # Nix expression builds
│   └── env/
│       └── manifest.toml  # Environment configuration
├── FLOX.md            # Flox reference documentation
└── README.md          # This file
```

### Adding New Dependencies

For nixpkgs packages:
```nix
propagatedBuildInputs = [
  # ... existing packages
] ++ (with python3.pkgs; [
  new-package-name
]);
```

For PyPI packages not in nixpkgs:
1. Create `.flox/pkgs/new-package.nix`
2. Use `fetchurl` with PyPI URL
3. Add to variant's propagatedBuildInputs

### Testing Builds Locally

```bash
# Build without publishing
flox build <package>

# Test executable
./result-<package>/bin/<package> --help

# Check dependencies
nix-store -q --references ./result-<package>
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes, test builds
4. Commit with descriptive messages
5. Push and create pull request

## References

- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [Flox Documentation](https://flox.dev/docs)
- [barstoolbluz/build-pytorch](https://github.com/barstoolbluz/build-pytorch)
- FLOX.md in this repository

## License

ComfyUI is licensed under GPL-3.0. This packaging repository follows the same license.
