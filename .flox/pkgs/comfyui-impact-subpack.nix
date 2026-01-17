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

  inherit (nixpkgs_pinned) lib stdenv fetchFromGitHub bash python313 python313Packages;

  # Python dependencies for Impact Subpack
  pythonWithDeps = python313.withPackages (ps: with ps; [
    matplotlib
    ultralytics
    numpy
    opencv4  # opencv-python-headless
    dill
  ]);
in

stdenv.mkDerivation rec {
  pname = "comfyui-impact-subpack";
  version = "1.3.5";  # Latest version

  src = fetchFromGitHub {
    owner = "ltdrdata";
    repo = "ComfyUI-Impact-Subpack";
    rev = "50c7b71a6a224734cc9b21963c6d1926816a97f1";  # Latest as of Jan 2025
    hash = "sha256-+qYmGdHjrWYfJ+uqGURWk1y8kVR0pBc+ObjUyM0A7UA=";
  };

  # No build needed - it's pure Python
  dontBuild = true;

  nativeBuildInputs = [ pythonWithDeps ];

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/share/comfyui/custom_nodes/ComfyUI-Impact-Subpack
    mkdir -p $out/bin

    # Copy all files
    cp -r . $out/share/comfyui/custom_nodes/ComfyUI-Impact-Subpack/

    # Create activation script that links Subpack into ComfyUI
    cat > $out/bin/comfyui-activate-impact-subpack << 'EOF'
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
      echo "  comfyui-activate-impact-subpack /path/to/comfyui"
      exit 1
    fi

    echo "Activating ComfyUI Impact Subpack in: $COMFYUI_DIR"

    # Create custom_nodes directory if it doesn't exist
    mkdir -p "$COMFYUI_DIR/custom_nodes"

    # Link the Subpack
    subpack_source="${placeholder "out"}/share/comfyui/custom_nodes/ComfyUI-Impact-Subpack"
    subpack_target="$COMFYUI_DIR/custom_nodes/ComfyUI-Impact-Subpack"

    if [ -e "$subpack_target" ]; then
      echo "  ⚠️  ComfyUI-Impact-Subpack already exists"
      read -p "  Replace with Flox version? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$subpack_target"
        ln -sf "$subpack_source" "$subpack_target"
        echo "  ✅ Activated ComfyUI-Impact-Subpack (replaced existing)"
      else
        echo "  Skipping activation"
      fi
    else
      ln -sf "$subpack_source" "$subpack_target"
      echo "  ✅ Activated ComfyUI-Impact-Subpack"
    fi

    echo ""
    echo "Impact Subpack activated! Restart ComfyUI to use it."
    echo ""
    echo "Impact Subpack provides:"
    echo "  • UltralyticsDetectorProvider for object detection"
    echo "  • Additional nodes that complement Impact Pack"
    echo ""
    echo "Note: Python dependencies (matplotlib, ultralytics, etc.) are"
    echo "      included with this Flox package."
    EOF
    chmod +x $out/bin/comfyui-activate-impact-subpack

    runHook postInstall
  '';

  meta = with lib; {
    description = "ComfyUI Impact Subpack - Additional nodes for Impact Pack";
    longDescription = ''
      ComfyUI Impact Subpack provides additional nodes that complement
      the Impact Pack, including:
      - UltralyticsDetectorProvider for YOLO-based object detection
      - Additional utility nodes

      All Python dependencies are included with this package.
    '';
    homepage = "https://github.com/ltdrdata/ComfyUI-Impact-Subpack";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}