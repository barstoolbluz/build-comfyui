{ pkgs ? import <nixpkgs> {} }:

let
  # Import nixpkgs at a specific revision for compatibility
  nixpkgs_pinned = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/fe5e41d7ffc0421f0913e8472ce6238ed0daf8e3.tar.gz";
  }) {
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };

  inherit (nixpkgs_pinned) lib stdenv fetchFromGitHub bash;
in

stdenv.mkDerivation rec {
  pname = "comfyui-manager";
  version = "0.9.1";  # Match ComfyUI version

  src = fetchFromGitHub {
    owner = "ltdrdata";
    repo = "ComfyUI-Manager";
    # Latest version as of Jan 2025
    rev = "e8e0e884f29bbf02caa48e397b84c2fc2c536a62";
    hash = "sha256-Y9QHpt8DDgNAPJtL7hYBkRmQWGmrWcvoL/uo4BN3Oj0=";
  };

  # No build needed - it's pure Python
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/share/comfyui/custom_nodes/ComfyUI-Manager
    mkdir -p $out/bin

    # Copy all files
    cp -r . $out/share/comfyui/custom_nodes/ComfyUI-Manager/

    # Fix manager_util.py for Nix/Flox environments
    # First remove any incorrect patches that put --system in wrong place
    sed -i "s/\['-m', 'uv', 'pip', '--system'\]/['-m', 'uv', 'pip']/g" \
      $out/share/comfyui/custom_nodes/ComfyUI-Manager/glob/manager_util.py
    sed -i "s/\['uv', 'pip', '--system'\]/['uv', 'pip']/g" \
      $out/share/comfyui/custom_nodes/ComfyUI-Manager/glob/manager_util.py


    # Create activation script that links Manager into ComfyUI
cat > $out/bin/comfyui-activate-manager << 'EOF'
#!${bash}/bin/bash
set -e

# Determine ComfyUI directory
if [ -n "$1" ]; then
COMFYUI_DIR="$1"
else
COMFYUI_DIR="''${COMFYUI_WORK_DIR:-$HOME/comfyui-work}"
fi

if [ ! -d "$COMFYUI_DIR" ]; then
echo "Error: ComfyUI directory not found: $COMFYUI_DIR"
echo "Please run ComfyUI at least once or specify the directory:"
echo "  comfyui-activate-manager /path/to/comfyui"
exit 1
fi

echo "Activating ComfyUI Manager in: $COMFYUI_DIR"

# Create custom_nodes directory if it doesn't exist
mkdir -p "$COMFYUI_DIR/custom_nodes"

# Link the Manager
manager_source="${placeholder "out"}/share/comfyui/custom_nodes/ComfyUI-Manager"
manager_target="$COMFYUI_DIR/custom_nodes/ComfyUI-Manager"

if [ -e "$manager_target" ]; then
echo "  ⚠️  ComfyUI-Manager already exists, skipping"
else
ln -sf "$manager_source" "$manager_target"
echo "  ✅ Activated ComfyUI-Manager"
fi

echo ""
echo "Manager activated! Restart ComfyUI to use it."
echo ""
echo "ComfyUI Manager provides:"
echo "  • Web UI for installing custom nodes"
echo "  • Automatic model downloads"
echo "  • Python dependency management"
echo "  • Node version updates"
echo ""
echo "Access it through the Manager button in ComfyUI's web interface."
EOF
chmod +x $out/bin/comfyui-activate-manager

    # Note: The Manager will:
    # - Install custom nodes to user's $COMFYUI_WORK_DIR/custom_nodes/
    # - Use pip to install Python deps to user's environment
    # - Download models to user's models directory
    # - NOT write to the Nix store

    runHook postInstall
  '';

  meta = with lib; {
    description = "ComfyUI Manager - Package manager for ComfyUI custom nodes";
    longDescription = ''
      ComfyUI-Manager provides a web UI and CLI for managing ComfyUI:
      - Install/update/remove custom nodes
      - Install Python dependencies
      - Download models
      - Manage node versions

      All installations happen in the user's environment ($HOME/comfyui-work/),
      not in the Nix store. This allows runtime management while maintaining
      Nix packaging benefits for the Manager itself.
    '';
    homepage = "https://github.com/ltdrdata/ComfyUI-Manager";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}