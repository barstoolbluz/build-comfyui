# Package Inventory

Complete list of all packages defined in this repository.

## ComfyUI Variants

### `comfyui` (Standard)
- **File**: `.flox/pkgs/comfyui.nix`
- **Version**: 0.3.68
- **Description**: ComfyUI with standard nixpkgs PyTorch
- **Platform**: `x86_64-linux`
- **PyTorch**: From nixpkgs
- **Executable**: `comfyui`
- **Use Case**: General purpose, maximum compatibility

### `comfyui-cpu` (CPU-Optimized)
- **File**: `.flox/pkgs/comfyui-cpu.nix`
- **Version**: 0.3.68
- **Description**: ComfyUI with AVX-512 optimized PyTorch
- **Platform**: `x86_64-linux`
- **PyTorch**: Requires `barstoolbluz/pytorch-python313-cpu-avx512`
- **Executable**: `comfyui-cpu`
- **Use Case**: AVX-512 CPUs, CPU inference workloads

### `comfyui-cuda` (CUDA-Optimized)
- **File**: `.flox/pkgs/comfyui-cuda.nix`
- **Version**: 0.3.68
- **Description**: ComfyUI with CUDA 12.8 + SM 12.0 + AVX-512 optimized PyTorch
- **Platform**: `x86_64-linux`
- **PyTorch**: Requires `barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512`
- **Executable**: `comfyui-cuda`
- **Use Case**: RTX 40-series GPUs with AVX-512 CPUs

## PyPI Dependencies

### `comfyui-frontend-package`
- **File**: `.flox/pkgs/comfyui-frontend-package.nix`
- **Version**: 1.28.8
- **Type**: Wheel (py3-none-any)
- **Source**: PyPI (fetchurl)
- **Hash**: `sha256-vnbb+arbg2tnLmkWFFYpTWXzIE8VYuwfeK4SxpNHqOA=`
- **Description**: ComfyUI frontend assets and web interface
- **Dependencies**: None
- **License**: GPL-3.0

### `comfyui-workflow-templates`
- **File**: `.flox/pkgs/comfyui-workflow-templates.nix`
- **Version**: 0.2.11
- **Type**: Wheel (py3-none-any)
- **Source**: PyPI (fetchurl)
- **Hash**: `sha256-gPOJUxO3/NpLZiPZCt5Yt+V3V0WG+fYTmdUTt/PpvMs=`
- **Description**: Workflow templates for ComfyUI
- **Dependencies**: None
- **License**: GPL-3.0

### `comfyui-embedded-docs`
- **File**: `.flox/pkgs/comfyui-embedded-docs.nix`
- **Version**: 0.3.1
- **Type**: Wheel (py3-none-any)
- **Source**: PyPI (fetchurl)
- **Hash**: `sha256-+7sO+Z6r2Hh8Zl7+I1ZlsztivV+bxNlA6yBV02g0yRw=`
- **Description**: Embedded documentation for ComfyUI
- **Dependencies**: None
- **License**: GPL-3.0

### `spandrel`
- **File**: `.flox/pkgs/spandrel.nix`
- **Version**: 0.4.0
- **Type**: Source tarball (setuptools)
- **Source**: PyPI (fetchurl)
- **Hash**: `sha256-9FUmiT+SOhLvN1QsROREsSCJdlk7x8zfpU/QTHw+gMo=`
- **Description**: Library for loading and running pre-trained PyTorch image upscaling models
- **Dependencies**: torch, torchvision, numpy, einops, pillow, safetensors
- **License**: MIT
- **Homepage**: https://github.com/chaiNNer-org/spandrel

## Dependency Tree

### Common to All Variants

```
ComfyUI (any variant)
├── comfyui-frontend-package (1.28.8)
├── comfyui-workflow-templates (0.2.11)
├── comfyui-embedded-docs (0.3.1)
├── spandrel (0.4.0)
│   ├── torch
│   ├── torchvision
│   ├── numpy
│   ├── einops
│   ├── pillow
│   └── safetensors
├── PyTorch Ecosystem
│   ├── torch (variant-specific)
│   ├── torchvision
│   ├── torchaudio
│   └── torchsde
├── ML/AI Libraries
│   ├── transformers (>=4.37.2)
│   ├── tokenizers (>=0.13.3)
│   ├── sentencepiece
│   ├── safetensors (>=0.4.2)
│   └── kornia (>=0.7.1)
├── Scientific Computing
│   ├── numpy (>=1.25.0)
│   ├── scipy
│   ├── pillow
│   └── einops
├── Web & Async
│   ├── aiohttp (>=3.11.8)
│   └── yarl (>=1.18.0)
├── Data & Config
│   ├── pyyaml
│   ├── pydantic (~=2.0)
│   └── pydantic-settings (~=2.0)
├── Database
│   ├── alembic
│   └── sqlalchemy
├── Media
│   └── av (>=14.2.0)
└── Utilities
    ├── tqdm
    └── psutil
```

### Variant-Specific PyTorch

#### Standard (`comfyui`)
```
torch (from nixpkgs)
├── CPU support only
└── Standard optimizations
```

#### CPU-Optimized (`comfyui-cpu`)
```
barstoolbluz/pytorch-python313-cpu-avx512
├── AVX-512 optimized
├── OpenBLAS backend
├── MKLDNN enabled
└── No CUDA
```

#### CUDA-Optimized (`comfyui-cuda`)
```
barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512
├── CUDA 12.8
├── SM 12.0 (RTX 40-series)
├── AVX-512 CPU optimizations
└── cuDNN enabled
```

## External Dependencies (Required at Runtime)

### For `comfyui-cpu`
- `barstoolbluz/pytorch-python313-cpu-avx512` (install via `flox install`)

### For `comfyui-cuda`
- `barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512` (install via `flox install`)
- NVIDIA GPU drivers (CUDA 12.8 compatible)
- CUDA runtime libraries

### barstoolbluz Package Availability

#### CPU Ecosystem
- [x] `barstoolbluz/pytorch-python313-cpu-avx512` ✅ Available
- [ ] `barstoolbluz/torchvision-python313-cpu-avx512` ⏳ Pending
- [ ] `barstoolbluz/torchaudio-python313-cpu-avx512` ⏳ Pending

#### CUDA Ecosystem (Complete Stack Available!)
- [x] `barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512` ✅ Available
- [x] `barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512` ✅ Available
- [x] `barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512` ✅ Available

**Usage**: Install these packages alongside `comfyui-cuda` for full optimization:
```bash
flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512
```

## Build Order

Packages build in this order (dependencies first):

1. **PyPI Packages** (independent)
   - `comfyui-frontend-package`
   - `comfyui-workflow-templates`
   - `comfyui-embedded-docs`

2. **Spandrel** (depends on PyTorch from nixpkgs for build)
   - `spandrel`

3. **ComfyUI Variants** (depend on all above)
   - `comfyui`
   - `comfyui-cpu`
   - `comfyui-cuda`

## Version Matrix

| Package | Current Version | Upstream Latest | Update Frequency |
|---------|----------------|-----------------|------------------|
| comfyui* | 0.3.68 | Check [GitHub](https://github.com/comfyanonymous/ComfyUI/releases) | Weekly releases |
| comfyui-frontend-package | 1.28.8 | Check [PyPI](https://pypi.org/project/comfyui-frontend-package/) | With ComfyUI |
| comfyui-workflow-templates | 0.2.11 | Check [PyPI](https://pypi.org/project/comfyui-workflow-templates/) | With ComfyUI |
| comfyui-embedded-docs | 0.3.1 | Check [PyPI](https://pypi.org/project/comfyui-embedded-docs/) | With ComfyUI |
| spandrel | 0.4.0 | Check [PyPI](https://pypi.org/project/spandrel/) | Periodic |

## Size Estimates

| Package | Approximate Size | Notes |
|---------|-----------------|-------|
| comfyui-frontend-package | ~10 MB | Web assets |
| comfyui-workflow-templates | ~200 KB | JSON templates |
| comfyui-embedded-docs | ~1 MB | Documentation |
| spandrel | ~500 KB | Source |
| comfyui (all variants) | ~100 MB | With all dependencies |

**Note**: PyTorch adds significant size:
- nixpkgs PyTorch: ~500 MB
- barstoolbluz PyTorch (CPU): ~450 MB
- barstoolbluz PyTorch (CUDA): ~3 GB (includes CUDA libraries)

## Testing Matrix

### Minimum Testing Requirements

Before publishing, test each variant:

| Variant | Test Command | Expected Result |
|---------|--------------|-----------------|
| comfyui | `./result-comfyui/bin/comfyui --help` | Help output, no errors |
| comfyui-cpu | `./result-comfyui-cpu/bin/comfyui-cpu --help` | Help output, no errors |
| comfyui-cuda | `./result-comfyui-cuda/bin/comfyui-cuda --help` | Help output, no errors |

### Extended Testing

```bash
# Test PyTorch import
python3 -c "import torch; print(torch.__version__)"

# Test CUDA (cuda variant only)
python3 -c "import torch; print(torch.cuda.is_available())"

# Test ComfyUI modules
python3 -c "import comfy; import comfy_api"

# Test dependencies
python3 -c "import spandrel; import transformers; import safetensors"
```

## Maintenance Checklist

### Weekly
- [ ] Check for new ComfyUI releases
- [ ] Update version if changed
- [ ] Build all variants
- [ ] Test executables

### Monthly
- [ ] Check PyPI dependencies for updates
- [ ] Review dependency tree
- [ ] Test on clean system

### Quarterly
- [ ] Review barstoolbluz PyTorch updates
- [ ] Consider new optimization targets
- [ ] Update documentation

## Publishing Status

| Package | Published | Catalog | Date |
|---------|-----------|---------|------|
| comfyui | ❌ | - | - |
| comfyui-cpu | ❌ | - | - |
| comfyui-cuda | ❌ | - | - |

Update this table after publishing.
