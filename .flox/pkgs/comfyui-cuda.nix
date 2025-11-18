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
  pname = "comfyui-cuda";
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
    # NOTE: For full CUDA optimization, install these barstoolbluz packages in [install] section:
    #   - barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512
    #   - barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512
    #   - barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512
    # They will override the nixpkgs versions below at runtime via environment composition.
    torchvision  # Overridden by barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512 when installed
    torchaudio   # Overridden by barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512 when installed
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
    huggingface-hub  # For model download tools
  ]);

  nativeBuildInputs = [ makeWrapper ];

  # Skip build phase - ComfyUI runs from source
  dontBuild = true;

  # Don't run tests for now
  doCheck = false;

  # Disable automatic Python wrapping - we'll do it ourselves
  dontWrapPythonPrograms = true;

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/share/comfyui
    mkdir -p $out/share/comfyui-tools
    mkdir -p $out/share/doc/comfyui
    mkdir -p $out/share/workflows
    mkdir -p $out/bin

    # Copy all ComfyUI files to share directory
    cp -r . $out/share/comfyui/

    # Build a Python environment with all dependencies
    pythonEnv="${python3.withPackages (ps: propagatedBuildInputs)}"

    # Install model download tools
    cp ${./download-sd15.py} $out/share/comfyui-tools/download-sd15.py
    cp ${./download-sdxl.py} $out/share/comfyui-tools/download-sdxl.py
    cp ${./download-sd35.py} $out/share/comfyui-tools/download-sd35.py
    chmod +x $out/share/comfyui-tools/*.py

    # Install comfyui-download CLI tool
    cp ${./comfyui-download} $out/bin/comfyui-download
    chmod +x $out/bin/comfyui-download

    # Install documentation
    cp ${./SD35-GUIDE.md} $out/share/doc/comfyui/SD35-GUIDE.md
    cp ${./SD35-IMG2IMG-GUIDE.md} $out/share/doc/comfyui/SD35-IMG2IMG-GUIDE.md
    cp ${./README.md} $out/share/doc/comfyui/README.md

    # Install example workflows
    cp ${./workflow-sd35-example.json} $out/share/workflows/sd35-example.json
    cp ${./workflow-sd35-img2img.json} $out/share/workflows/sd35-img2img.json

    # Create extra_model_paths.yaml template
    cat > $out/share/comfyui-tools/extra_model_paths.yaml.template <<'TEMPLATE'
# ComfyUI Extra Model Paths Configuration
# Copy this to ~/comfyui-work/extra_model_paths.yaml and adjust paths
comfyui:
  base_path: ~/comfyui-work/
  is_default: true
  checkpoints: models/checkpoints/
  clip: models/clip/
  text_encoders: models/clip/
  vae: models/vae/
  loras: models/loras/
  upscale_models: models/upscale_models/
  embeddings: models/embeddings/
  controlnet: models/controlnet/
TEMPLATE

    # Create wrapper script using makeWrapper
    # Use --suffix for dependencies so environment packages (barstoolbluz PyTorch)
    # have priority over built packages (nixpkgs PyTorch)
    # This enables environment composition pattern from FLOX.md §12
    makeWrapper ${python3}/bin/python3 $out/bin/comfyui-cuda \
      --add-flags "$out/share/comfyui/main.py" \
      --suffix PYTHONPATH : "$out/share/comfyui" \
      --suffix PYTHONPATH : "$pythonEnv/${python3.sitePackages}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "ComfyUI with CUDA 12.8 optimized PyTorch (SM 12.0, AVX512)";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];  # CUDA is Linux-only
    mainProgram = "comfyui-cuda";
  };
}
