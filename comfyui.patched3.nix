{ pkgs ? import <nixpkgs> {} }:

let
  # Import nixpkgs at a specific revision where PyTorch 2.8.0 is compatible with ComfyUI dependencies
  # This ensures compatibility with custom PyTorch/TorchVision/TorchAudio builds
  nixpkgs_pinned = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/fe5e41d7ffc0421f0913e8472ce6238ed0daf8e3.tar.gz";
  }) {
    config = {
      allowUnfree = true;  # Required for CUDA packages
      cudaSupport = true;
    };
  };

  inherit (nixpkgs_pinned) lib python3 fetchFromGitHub makeWrapper uv bash;

  # Import ComfyUI dependencies using the same pinned nixpkgs
  # Need to resolve dependencies between packages
  comfyui-frontend-package = nixpkgs_pinned.callPackage ./comfyui-frontend-package.nix {};
  comfyui-workflow-templates-core = nixpkgs_pinned.callPackage ./comfyui-workflow-templates-core.nix {};
  comfyui-workflow-templates-media-api = nixpkgs_pinned.callPackage ./comfyui-workflow-templates-media-api.nix {};
  comfyui-workflow-templates-media-video = nixpkgs_pinned.callPackage ./comfyui-workflow-templates-media-video.nix {};
  comfyui-workflow-templates-media-image = nixpkgs_pinned.callPackage ./comfyui-workflow-templates-media-image.nix {};
  comfyui-workflow-templates-media-other = nixpkgs_pinned.callPackage ./comfyui-workflow-templates-media-other.nix {};
  comfyui-workflow-templates = nixpkgs_pinned.callPackage ./comfyui-workflow-templates.nix {
    inherit comfyui-workflow-templates-core
            comfyui-workflow-templates-media-api
            comfyui-workflow-templates-media-video
            comfyui-workflow-templates-media-image
            comfyui-workflow-templates-media-other;
  };
  comfyui-embedded-docs = nixpkgs_pinned.callPackage ./comfyui-embedded-docs.nix {};
  spandrel = nixpkgs_pinned.callPackage ./spandrel.nix {};
  nunchaku = nixpkgs_pinned.callPackage ./nunchaku.nix {};
  controlnet-aux = nixpkgs_pinned.callPackage ./controlnet-aux.nix {};
  gguf = nixpkgs_pinned.callPackage ./gguf.nix {};
  accelerate = nixpkgs_pinned.callPackage ./accelerate.nix {};
  comfy-kitchen = nixpkgs_pinned.callPackage ./comfy-kitchen.nix {};

  # Override av to 14.2+ for API nodes support (pinned nixpkgs has 14.1.0)
  av = nixpkgs_pinned.python3Packages.av.overrideAttrs (oldAttrs: rec {
    version = "14.2.0";
    src = nixpkgs_pinned.fetchPypi {
      pname = "av";
      inherit version;
      hash = "sha256-EytdUsomK5ewNW6PSMu+VNCsIyEHpyKrjMjAwZ6voXs=";
    };
  });
in

python3.pkgs.buildPythonApplication rec {
  pname = "comfyui";
  version = "0.9.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "v${version}";
    hash = "sha256-tAbXhLoN3tuML3R1AdJ18stleFv4w0nZcUoySP6W9+0=";
  };

  # Python dependencies for ComfyUI
  # PyTorch, numpy, scipy can be overridden in Flox environments with optimized versions:
  #   - python313Packages.pytorchWithCuda (nixpkgs CUDA version)
  #   - flox/pytorch-python313-cuda12_8-sm86-avx2 (pre-built optimized)
  #   - Custom builds published to your catalog
  propagatedBuildInputs = [
    # ComfyUI-specific packages
    comfyui-frontend-package
    comfyui-workflow-templates
    comfyui-embedded-docs
    spandrel

    # Workflow optimization packages
    nunchaku          # FLUX inference optimization
    controlnet-aux    # Advanced ControlNet preprocessors

    # Custom overridden packages (with Darwin fixes)
    gguf              # GGUF quantized model support (critical for FLUX) - custom override for Darwin
    accelerate        # Model loading optimization - custom override for Darwin
    comfy-kitchen     # FP8/FP4 support for optimized inference (v0.9.1+)
    av                # Media library - overridden to 14.2.0 for API nodes support
  ] ++ (with python3.pkgs; [
    # PyTorch stack - Override with CUDA-optimized if needed
    torch
    torchvision
    torchaudio
    torchsde

    # Scientific computing - Override with CUDA-optimized if needed
    numpy
    scipy
    pillow
    einops

    # ML/AI libraries
    transformers
    tokenizers
    sentencepiece
    safetensors
  ]) ++ lib.optionals false (with python3.pkgs; [
    # kornia - temporarily disabled due to kornia-rs version incompatibility with pinned nixpkgs
    # The pinned nixpkgs (for PyTorch 2.8.0) has kornia-rs 0.1.2 but kornia 0.8.1 requires >=0.1.9
    # This is not critical for ComfyUI functionality
    kornia
  ]) ++ (with python3.pkgs; [
    # Web and async
    aiohttp
    yarl

    # Data and config
    pyyaml
    pydantic
    pydantic-settings

    # Database
    alembic
    sqlalchemy

    # Media - removed, using custom override below

    # Utilities
    tqdm
    psutil
    packaging         # Required for comfy_api.latest (audio nodes)
    huggingface-hub   # Model downloads
    typing-extensions # Required for API nodes (gemini, moonvalley, etc.)

    # ComfyUI-Manager dependencies
    gitpython         # Git operations for Manager
    pygithub          # GitHub API for Manager
    rich              # Terminal formatting for Manager
    typer             # CLI framework for Manager
    toml              # Config file parsing for Manager
    chardet           # Encoding detection for Manager

    # Impact Subpack dependencies
    dill              # Serialization for Impact Subpack

    # Workflow support dependencies
    opencv4           # ControlNet preprocessors (Canny, HED, etc.) - using opencv4 to avoid conflicts

    # Additional dependencies for workflow optimization
    timm              # PyTorch Image Models (for controlnet-aux)
    scikit-image      # Image processing (for controlnet-aux)
    matplotlib        # Plotting library (for nunchaku)
    pandas            # Data analysis (for nunchaku)
  ]);

  nativeBuildInputs = [ makeWrapper uv ];

  # Skip build phase - ComfyUI runs from source
  dontBuild = true;

  # Don't run tests
  doCheck = false;

  # Disable automatic Python wrapping - we'll do it ourselves
  dontWrapPythonPrograms = true;

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/share/comfyui
    mkdir -p $out/share/comfyui-tools
    mkdir -p $out/bin

    # Copy all ComfyUI files to share directory
    cp -r . $out/share/comfyui/

    # Build Python environment with all dependencies
    pythonEnv="${python3.withPackages (ps: propagatedBuildInputs)}"

    # Install enhanced model download tools (as library scripts)
    cp ${../../assets/download-sd15-enhanced.py} $out/share/comfyui-tools/download-sd15.py
    cp ${../../assets/download-sdxl-enhanced.py} $out/share/comfyui-tools/download-sdxl.py
    cp ${../../assets/download-sd35-enhanced.py} $out/share/comfyui-tools/download-sd35.py
    cp ${../../assets/download-flux-enhanced.py} $out/share/comfyui-tools/download-flux.py

    # Create wrapped Python executables for download scripts
    for script in download-sd15 download-sdxl download-sd35 download-flux; do
      makeWrapper $pythonEnv/bin/python3 $out/share/comfyui-tools/''${script}-wrapped \
        --add-flags "$out/share/comfyui-tools/''${script}.py"
      chmod +x $out/share/comfyui-tools/''${script}-wrapped
    done

    # Install comfyui-download CLI tool (wrapper script)
    cp ${../../assets/comfyui-download-enhanced} $out/bin/comfyui-download
    chmod +x $out/bin/comfyui-download

    # Create launch script for ComfyUI.
    #
    # ComfyUI-Manager installs Python deps at runtime via `uv pip install`. In a Nix/Flox setup,
    # writing into the Nix store is not possible, and `uv ... --system` forces installs into the
    # system Python. We provide a per-user virtualenv (with system-site-packages) and run ComfyUI
    # from that interpreter, so runtime installs land in a writable location.

cat > $out/bin/comfyui << EOF
#!${bash}/bin/bash
set -euo pipefail

WORK_DIR="\${COMFYUI_WORK_DIR:-\$HOME/comfyui-work}"
VENV_DIR="\${WORK_DIR}/.venv"
BASE_PY="${pythonEnv}/bin/python3"

# ComfyUI v0.9.x stores state (including a sqlite DB) under a `user/` directory.
# When ComfyUI is launched from /nix/store, its default paths can resolve into a
# read-only location, which makes DB init fail and leaves `Session` as None.
# (In ComfyUI's db.py, Session is only set inside init_db(), and create_session()
# simply calls Session().)

mkdir -p "\${WORK_DIR}/user"

if [ ! -x "\${VENV_DIR}/bin/python" ]; then
mkdir -p "\${WORK_DIR}"
"\${BASE_PY}" -m venv --system-site-packages "\${VENV_DIR}"
fi

# Make Nix-provided Python packages visible to the venv interpreter without relying
# on PYTHONPATH. This writes a .pth file in the venv site-packages.
PTH_DIR="\${VENV_DIR}/lib/python${python3.pythonVersion}/site-packages"
mkdir -p "\${PTH_DIR}"
cat > "\${PTH_DIR}/nix-site-packages.pth" <<'PTH'
${pythonEnv}/${python3.sitePackages}
$out/share/comfyui
PTH

export VIRTUAL_ENV="\${VENV_DIR}"
export PATH="\${VENV_DIR}/bin:$out/bin:${uv}/bin:\${PATH}"

# Use a writable working directory so relative paths resolve under WORK_DIR.
cd "\${WORK_DIR}"

# If the caller did not specify database/user directories, default them into WORK_DIR.
have_db=0
have_userdir=0
for a in "\$@"; do
case "\$a" in
--database-url|--database_url) have_db=1 ;;
--user-directory|--user_directory) have_userdir=1 ;;
esac
done

extra_args=()
if [ "\${have_db}" -eq 0 ]; then
extra_args+=(--database-url "sqlite:////\${WORK_DIR}/user/comfyui.db")
fi
if [ "\${have_userdir}" -eq 0 ]; then
extra_args+=(--user-directory "\${WORK_DIR}/user")
fi

exec "\${VENV_DIR}/bin/python" "$out/share/comfyui/main.py" "\${extra_args[@]}" "\$@"
EOF
chmod +x $out/bin/comfyui

# Provide a uv shim that strips `--system` so ComfyUI-Manager installs into the venv.
cat > $out/bin/uv << EOF
#!${bash}/bin/bash
set -euo pipefail
real_uv="${uv}/bin/uv"

if [ "\${1:-}" = "pip" ] && [ -n "\${VIRTUAL_ENV:-}" ]; then
args=()
for a in "\$@"; do
if [ "\$a" = "--system" ]; then
continue
fi
args+=("\$a")
done
exec "\$real_uv" "\${args[@]}"
fi

exec "\$real_uv" "\$@"
EOF
chmod +x $out/bin/uv

    runHook postInstall
  '';

  meta = with lib; {
    description = "The most powerful and modular diffusion model GUI and backend";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "comfyui";
  };
}
