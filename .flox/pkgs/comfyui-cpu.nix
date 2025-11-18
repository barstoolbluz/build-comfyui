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

  # Disable automatic Python wrapping - we'll do it ourselves
  dontWrapPythonPrograms = true;

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/share/comfyui
    mkdir -p $out/bin

    # Copy all ComfyUI files to share directory
    cp -r . $out/share/comfyui/

    # Build a Python environment with all dependencies
    pythonEnv="${python3.withPackages (ps: propagatedBuildInputs)}"

    # Create wrapper script using makeWrapper
    # Use --suffix for dependencies so environment packages (barstoolbluz PyTorch)
    # have priority over built packages (nixpkgs PyTorch)
    # This enables environment composition pattern from FLOX.md §12
    makeWrapper ${python3}/bin/python3 $out/bin/comfyui-cpu \
      --add-flags "$out/share/comfyui/main.py" \
      --suffix PYTHONPATH : "$out/share/comfyui" \
      --suffix PYTHONPATH : "$pythonEnv/${python3.sitePackages}"

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
