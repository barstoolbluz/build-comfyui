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
  pname = "comfyui";
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
    # Core PyTorch stack
    torch
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
    # Use --suffix for dependencies so environment packages
    # have priority over built packages
    # This enables environment composition pattern from FLOX.md §12
    makeWrapper ${python3}/bin/python3 $out/bin/comfyui \
      --add-flags "$out/share/comfyui/main.py" \
      --suffix PYTHONPATH : "$out/share/comfyui" \
      --suffix PYTHONPATH : "$pythonEnv/${python3.sitePackages}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "The most powerful and modular diffusion model GUI and backend";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "comfyui";
  };
}
