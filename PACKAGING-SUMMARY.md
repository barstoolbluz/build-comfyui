# ComfyUI Package Update - Tools & SD 3.5 Support

## What Was Added

### 1. Model Download Tools

**Files added to both `comfyui-cpu` and `comfyui-cuda` packages:**

- **`comfyui-download`** - Main CLI tool for downloading models
  - Usage: `comfyui-download sd15|sdxl|sd35`
  - Installed to: `$out/bin/comfyui-download`

- **Download scripts** in `$out/share/comfyui-tools/`:
  - `download-sd15.py` - Stable Diffusion 1.5 (4.3GB)
  - `download-sdxl.py` - Stable Diffusion XL (6.9GB)
  - `download-sd35.py` - Stable Diffusion 3.5 Large (27GB)

- **`extra_model_paths.yaml.template`** - Template for configuring custom model paths

### 2. Documentation

**Files added to `$out/share/doc/comfyui/`:**

- **`SD35-GUIDE.md`** - Complete guide for using SD 3.5 with TripleCLIPLoader
- **`README.md`** - General ComfyUI environment documentation

### 3. Example Workflows

**Files added to `$out/share/workflows/`:**

- **`sd35-example.json`** - Pre-configured SD 3.5 workflow with:
  - CheckpointLoaderSimple for MODEL + VAE
  - TripleCLIPLoader for text encoders
  - CLIPTextEncodeSD3 nodes (positive + negative)
  - Recommended settings (28 steps, CFG 4.5, dpmpp_2m)

### 4. Dependencies Added

- **`huggingface-hub`** - Python package for downloading models from HuggingFace

## Build Verification

Both packages built successfully:

```bash
✅ comfyui-cuda-0.3.68 - Built with all tools
✅ comfyui-cpu-0.3.68 - Built with all tools
```

**Verified contents:**
```
$out/
├── bin/
│   ├── comfyui-cuda (or comfyui-cpu)
│   └── comfyui-download ← NEW
├── share/
│   ├── comfyui/ (ComfyUI application)
│   ├── comfyui-tools/ ← NEW
│   │   ├── download-sd15.py
│   │   ├── download-sdxl.py
│   │   ├── download-sd35.py
│   │   └── extra_model_paths.yaml.template
│   ├── doc/comfyui/ ← NEW
│   │   ├── README.md
│   │   └── SD35-GUIDE.md
│   └── workflows/ ← NEW
│       └── sd35-example.json
```

## User Experience After Publishing

### Quick Start (Full Package)

```bash
# Install ComfyUI with tools
flox install barstoolbluz/comfyui-cuda

# Download SD 3.5
HF_TOKEN=hf_xxx comfyui-download sd35

# Run ComfyUI
comfyui-cuda --listen 0.0.0.0 --port 8188

# Load example workflow
# In ComfyUI UI: Load Workflow → Browse to ~/.flox/.../share/workflows/sd35-example.json
```

### What Users Get

1. **One command to download models** instead of manual HuggingFace downloads
2. **Example SD 3.5 workflow** ready to use - no manual node wiring needed
3. **Complete documentation** for SD 3.5 setup
4. **Template for model paths** configuration

## Publishing Steps

### 1. Publish Updated Packages

```bash
cd /home/daedalus/dev/comfyui

# Publish CUDA version
flox publish comfyui-cuda

# Publish CPU version
flox publish comfyui-cpu
```

### 2. Update Environment (Optional)

If you want to update the test environment in `/home/daedalus/dev/testes/comfyui`:

```bash
cd /home/daedalus/dev/testes/comfyui
flox push  # Push updated environment to FloxHub
```

## Changes Made to Build Files

### Modified Files:

1. **`.flox/pkgs/comfyui-cuda.nix`**
   - Added `huggingface-hub` dependency
   - Added installation of download tools
   - Added documentation installation
   - Added example workflow installation
   - Added extra_model_paths.yaml template generation

2. **`.flox/pkgs/comfyui-cpu.nix`**
   - Same changes as comfyui-cuda.nix

### New Files in `.flox/pkgs/`:

- `download-sd15.py`
- `download-sdxl.py`
- `download-sd35.py`
- `comfyui-download`
- `SD35-GUIDE.md`
- `README.md`
- `workflow-sd35-example.json`

## Testing Recommendations

Before publishing, test:

```bash
# Test CUDA package
./result-comfyui-cuda/bin/comfyui-download
./result-comfyui-cuda/bin/comfyui-cuda --help

# Test CPU package
./result-comfyui-cpu/bin/comfyui-download
./result-comfyui-cpu/bin/comfyui-cpu --help

# Test actual download (small model)
HF_TOKEN=xxx ./result-comfyui-cuda/bin/comfyui-download sd15
```

## Backwards Compatibility

✅ **Fully backwards compatible**
- Existing ComfyUI functionality unchanged
- New tools are additions only
- No breaking changes to existing code
- Users who don't use the tools won't notice any difference

## File Locations Reference

When installed via Flox:

```bash
# CLI tool
which comfyui-download
# → ~/.flox/.../bin/comfyui-download

# Documentation
ls ~/.flox/.../share/doc/comfyui/
# → README.md, SD35-GUIDE.md

# Example workflows
ls ~/.flox/.../share/workflows/
# → sd35-example.json

# Model download scripts
ls ~/.flox/.../share/comfyui-tools/
# → download-sd15.py, download-sdxl.py, download-sd35.py, extra_model_paths.yaml.template
```

## Version Bump (Optional)

Consider bumping version to `0.3.69` or `0.4.0` to indicate new features:

```nix
# In comfyui-cuda.nix and comfyui-cpu.nix
version = "0.4.0";  # or "0.3.69"
```

This would indicate to users that this version includes the new download tools.

## Summary

✅ Download tools integrated into both CPU and CUDA packages
✅ SD 3.5 workflow example and documentation included
✅ All builds successful
✅ Backwards compatible
✅ Ready to publish

**Next step:** `flox publish comfyui-cuda && flox publish comfyui-cpu`
