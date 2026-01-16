# ComfyUI Packages

## Core Packages

### comfyui.nix
Main ComfyUI application with Python dependencies.
- **Added dependencies**: gitpython, pygithub, rich, typer, toml, chardet (for Manager)
- **Added tools**: uv package manager in PATH for runtime installations
- **OpenCV**: Standardized to opencv4

### comfyui-manager.nix
Runtime package manager for custom nodes.
- **Activation**: `comfyui-activate-manager` symlinks to userland
- **Features**: Web UI for node installation, doesn't write to nix store
- **Dependencies**: Requires uv/pip for runtime package operations
- **Nix patch**: Automatically adds `--system` flag to uv commands for compatibility

### comfyui-ultralytics.nix
YOLO detection support for UltralyticsDetectorProvider node.
- **Type**: Python package (no activation script needed)
- **Note**: Required for Impact-Subpack workflows
- **OpenCV**: Uses opencv4

## Supporting Packages

### comfyui-plugins.nix
Impact Pack and other custom nodes.
- **Impact-Pack**: Face enhancement, detection nodes
- **Impact-Subpack**: Contains UltralyticsDetectorProvider

### Other Dependencies
- spandrel.nix - Model loading library
- nunchaku.nix - FLUX optimization
- controlnet-aux.nix - Advanced preprocessors
- gguf.nix - Quantized model support
- accelerate.nix - Model loading optimization

## Activation Pattern

All custom node packages use symlink pattern:
1. Package installs to nix store
2. Activation script creates symlink from store → userland
3. ComfyUI loads from userland directory

Example:
```bash
comfyui-activate-manager    # Links Manager to ~/comfyui-work/custom_nodes/
comfyui-activate-plugins    # Links Impact Pack to ~/comfyui-work/custom_nodes/
```

## Branch Availability

- **main** (0.6.0): Core ComfyUI only
- **nightly** (0.9.1): All packages including Manager and Ultralytics
- **historical** (0.6.0): Core ComfyUI only

## Branch Migration

When nightly becomes main:
1. Copy comfyui-manager.nix and comfyui-ultralytics.nix to main branch
2. Update versions in these packages to match main's ComfyUI version
3. Test activation scripts still work with older ComfyUI

## Build & Integration

### How they're built
- Manager: stdenv.mkDerivation (pure file copy with activation script)
- Ultralytics: buildPythonPackage (wraps ultralytics Python package)
- Both are separate Flox packages (`flox build comfyui-manager`)
- They don't depend on comfyui.nix but require it at runtime

### Integration with comfyui
- comfyui.nix has Manager's Python dependencies (rich, gitpython, etc.)
- comfyui.nix adds uv to PATH for Manager's runtime installs
- Activation scripts symlink from nix store to ComfyUI's custom_nodes/

### Maintenance
- Update Manager: Change rev/hash in comfyui-manager.nix
- Update Ultralytics: Change version/hash in comfyui-ultralytics.nix
- Keep versions aligned with ComfyUI version on each branch