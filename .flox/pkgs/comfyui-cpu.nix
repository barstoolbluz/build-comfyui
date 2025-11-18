{ lib
, python3
, fetchFromGitHub
, makeWrapper
, comfyui-frontend-package
, comfyui-workflow-templates
, comfyui-embedded-docs
, spandrel
}:

python3.pkgs.buildPythonApplication rec {
  pname = "comfyui-cpu";
  version = "0.3.68";
  format = "other";

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "v${version}";
    hash = "sha256-aSkRaNBBLIVNab7GgGHwiRqc7YoZi73igxCURUHEVLM=";
  };

  propagatedBuildInputs = [
    # ComfyUI-specific packages
    comfyui-frontend-package
    comfyui-workflow-templates
    comfyui-embedded-docs
    spandrel
  ] ++ (with python3.pkgs; [
    # PyTorch ecosystem
    # NOTE: For full CPU optimization, install these barstoolbluz packages in [install] section:
    #   - barstoolbluz/pytorch-python313-cpu-avx512
    #   - barstoolbluz/torchvision-python313-cpu-avx512 (when available)
    #   - barstoolbluz/torchaudio-python313-cpu-avx512 (when available)
    # They will override the nixpkgs versions below at runtime via environment composition.
    torchvision  # Will be overridden by barstoolbluz/torchvision-python313-cpu-avx512 when available
    torchaudio   # Will be overridden by barstoolbluz/torchaudio-python313-cpu-avx512 when available
    torchsde

    # Scientific computing
    numpy
    scipy
    pillow
    einops

    # ML/AI libraries
    transformers
    tokenizers
    sentencepiece
    safetensors
    kornia

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

    # Media
    av

    # Utilities
    tqdm
    psutil
  ]);

  nativeBuildInputs = [ makeWrapper ];

  # Skip build phase - ComfyUI runs from source
  dontBuild = true;

  # Don't run tests for now
  doCheck = false;

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/share/comfyui
    mkdir -p $out/bin

    # Copy all ComfyUI files to share directory
    cp -r . $out/share/comfyui/

    # Create wrapper script that uses environment Python
    # This allows barstoolbluz PyTorch to override nixpkgs version at runtime
    cat > $out/bin/comfyui-cpu << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Wrapper for ComfyUI CPU variant
# Uses Python from PATH to allow runtime PyTorch override via Flox composition

SCRIPT_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"
COMFYUI_DIR="$SCRIPT_DIR/../share/comfyui"

# Add ComfyUI to PYTHONPATH so imports work
export PYTHONPATH="$COMFYUI_DIR:''${PYTHONPATH:-}"

# Use Python from environment (not hardcoded build-time Python)
# This allows barstoolbluz PyTorch to take precedence
exec python3 "$COMFYUI_DIR/main.py" "$@"
WRAPPER_EOF

    chmod +x $out/bin/comfyui-cpu

    runHook postInstall
  '';

  meta = with lib; {
    description = "ComfyUI with CPU-optimized PyTorch (AVX512)";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "comfyui-cpu";
  };
}
