{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) lib python3 fetchFromGitHub makeWrapper fetchPypi uv;

  # Build comfyui-frontend-package
  comfyui-frontend-package = python3.pkgs.buildPythonPackage rec {
    pname = "comfyui-frontend-package";
    version = "1.34.9";
    format = "wheel";
    src = fetchPypi {
      pname = "comfyui_frontend_package";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-g2ypUoTVcFc5RjJAw8SCanqKdycpJlanfL8LQaOa7HY=";
    };
    propagatedBuildInputs = [ ];
    doCheck = false;
  };

  # Build comfy-kitchen
  comfy-kitchen = python3.pkgs.buildPythonPackage rec {
    pname = "comfy-kitchen";
    version = "0.2.6";
    format = "wheel";
    src = fetchPypi {
      pname = "comfy_kitchen";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-8rNDVgFVgMwQ5h3f9tHXp3TE/5yn4oAyylGk9EbuJi4=";
    };
    propagatedBuildInputs = with python3.pkgs; [ torch ];
    doCheck = false;
    dontBuild = true;
  };

  # Build workflow-templates
  comfyui-workflow-templates = python3.pkgs.buildPythonPackage rec {
    pname = "comfyui-workflow-templates";
    version = "0.7.63";
    format = "wheel";
    src = fetchPypi {
      pname = "comfyui_workflow_templates";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-yVUeZ3nNJZwKslkhI8fURm15MTYIBFevWaHVr5VPN8o=";
    };
    propagatedBuildInputs = [ ];
    doCheck = false;
    dontBuild = true;
  };

  # Build embedded-docs
  comfyui-embedded-docs = python3.pkgs.buildPythonPackage rec {
    pname = "comfyui-embedded-docs";
    version = "0.3.1";
    format = "wheel";
    src = fetchPypi {
      pname = "comfyui_embedded_docs";
      inherit version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-+7sO+Z6r2Hh8Zl7+I1ZlsztivV+bxNlA6yBV02g0yRw=";
    };
    propagatedBuildInputs = [ ];
    doCheck = false;
    dontBuild = true;
  };

  # Build spandrel - wheel format to avoid build issues
  spandrel = python3.pkgs.buildPythonPackage rec {
    pname = "spandrel";
    version = "0.4.0";
    format = "wheel";
    src = fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-gZ8/Ff6UT+WJ9DujMVBFigDQ7QwujvHu8BmGFTIBJ7E=";
    };
    propagatedBuildInputs = with python3.pkgs; [
      torch torchvision numpy einops pillow safetensors
    ];
    doCheck = false;
    dontBuild = true;
  };

in

python3.pkgs.buildPythonApplication rec {
  pname = "comfyui-testing";
  version = "0.9.1-r2";  # Revision 2: Fix dependency inclusion
  format = "other";

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "v0.9.1";  # Use the actual upstream version
    hash = "sha256-tAbXhLoN3tuML3R1AdJ18stleFv4w0nZcUoySP6W9+0=";
  };

  nativeBuildInputs = [ makeWrapper uv ];

  propagatedBuildInputs = [
    # ComfyUI-specific packages built in let block
    comfyui-frontend-package
    comfy-kitchen
    comfyui-workflow-templates
    comfyui-embedded-docs
    spandrel
  ] ++ (with python3.pkgs; [
    # Core ML/AI
    torch
    torchvision
    torchaudio
    torchsde
    numpy
    scipy
    pillow
    einops
    kornia  # For Canny edge detection and morphology

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

    # Additional workflow/impact pack dependencies
    scikit-image  # Required by Impact Pack
  ]);

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

    # Build Python environment with all dependencies from propagatedBuildInputs
    pythonEnv="${python3.withPackages (ps: propagatedBuildInputs)}"

    # Create wrapper script with proper PYTHONPATH and uv in PATH
    makeWrapper $pythonEnv/bin/python3 $out/bin/comfyui \
      --add-flags "$out/share/comfyui/main.py" \
      --suffix PYTHONPATH : "$out/share/comfyui" \
      --suffix PYTHONPATH : "$pythonEnv/${python3.sitePackages}" \
      --prefix PATH : "${uv}/bin"

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