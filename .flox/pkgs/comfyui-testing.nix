{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) lib python3 fetchFromGitHub makeWrapper;

  # Build a Python environment with all required packages
  pythonEnv = python3.withPackages (ps: with ps; [
    # Core ML/AI
    torch
    torchvision
    torchaudio
    torchsde
    numpy
    scipy
    pillow
    einops

    # Transformers and related
    transformers
    tokenizers
    sentencepiece
    safetensors

    # Web framework
    aiohttp
    yarl

    # Config and data
    pyyaml
    pydantic
    pydantic-settings

    # Database
    alembic
    sqlalchemy

    # Media processing
    av
    opencv-python

    # Utilities
    tqdm
    psutil
    packaging
    huggingface-hub
    typing-extensions
  ]);
in

python3.pkgs.buildPythonApplication rec {
  pname = "comfyui-testing";
  version = "0.9.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "v${version}";
    hash = "sha256-tAbXhLoN3tuML3R1AdJ18stleFv4w0nZcUoySP6W9+0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  doCheck = false;
  dontWrapPythonPrograms = true;

  installPhase = ''
    runHook preInstall

    # Create output directories
    mkdir -p $out/share/comfyui
    mkdir -p $out/bin

    # Copy all ComfyUI source files
    cp -r . $out/share/comfyui/

    # Create wrapper script
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/comfyui \
      --add-flags "$out/share/comfyui/main.py"

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