# CLAUDE.md

## Project Overview

ComfyUI build packages for Flox with custom node support and runtime package management.

## Key Packages

- **comfyui.nix**: Core application with Manager dependencies and uv
- **comfyui-manager.nix**: Runtime package manager for custom nodes
- **comfyui-ultralytics.nix**: YOLO detection for Impact-Subpack

## Critical Patterns

### OpenCV Standardization
All packages use `opencv4` to prevent "recursion detected" errors.

### Activation Scripts
Manager and plugins use symlink pattern:
```bash
comfyui-activate-manager  # Links Manager from nix store to ~/comfyui-work/custom_nodes/
comfyui-activate-plugins  # Links Impact Pack from nix store to ~/comfyui-work/custom_nodes/
```
Note: Ultralytics is a Python package, no activation needed.

### Manager Dependencies
Added to comfyui.nix: gitpython, pygithub, rich, typer, toml, chardet, uv

## Branch Strategy
- **main**: v0.6.0 stable
- **nightly**: v0.9.1 with Manager and Ultralytics
- **historical**: v0.6.0 compatibility

## Common Issues

1. **"No module named 'rich'"**: Manager dependencies missing from comfyui.nix
2. **"Neither pip nor uv available"**: uv not in PATH via makeWrapper
3. **UltralyticsDetectorProvider missing**: Need comfyui-ultralytics package
4. **"No virtual environment found; run uv venv"**: FIXED - Manager now patches uv commands with `--system` flag automatically

## Testing Commands

```bash
flox build comfyui
flox build comfyui-manager
flox build comfyui-ultralytics
```

## Branch Migration Checklist

When nightly → main:
- [ ] Copy comfyui-manager.nix to main branch
- [ ] Copy comfyui-ultralytics.nix to main branch
- [ ] Update package versions to match main's ComfyUI
- [ ] Verify Manager dependencies in comfyui.nix
- [ ] Test Manager activation script works