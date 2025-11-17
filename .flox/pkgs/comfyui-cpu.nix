{ lib
, python3
, fetchFromGitHub
, makeWrapper
, comfyui-frontend-package
, comfyui-workflow-templates
, comfyui-embedded-docs
, spandrel-cpu
, pytorch-python313-cpu-avx512  # barstoolbluz/pytorch-python313-cpu-avx512
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

    # Custom PyTorch build (CPU-optimized)
    pytorch-python313-cpu-avx512
    # NOTE: You'll need to publish these too:
    # - barstoolbluz/torchvision-python313-cpu-avx512
    # - barstoolbluz/torchaudio-python313-cpu-avx512

    # Spandrel (CPU variant)
    spandrel-cpu
  ] ++ (with python3.pkgs; [
    # PyTorch ecosystem (using nixpkgs versions for now)
    # TODO: Replace with barstoolbluz variants when available
    torchvision
    torchaudio
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

    # Create wrapper script for main executable
    makeWrapper ${python3}/bin/python3 $out/bin/comfyui-cpu \
      --add-flags "$out/share/comfyui/main.py" \
      --prefix PYTHONPATH : "$out/share/comfyui:$PYTHONPATH"

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
