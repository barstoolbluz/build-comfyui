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

  inherit (nixpkgs_pinned) lib python3 stdenv;

  # Build ultralytics package with specific version for ComfyUI v0.9.1
  ultralytics = python3.pkgs.buildPythonPackage rec {
    pname = "ultralytics";
    version = "8.3.55";  # Version compatible with ComfyUI v0.9.1
    format = "wheel";

    src = python3.pkgs.fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      hash = "sha256-2jXVueQjC3Hyt2IsGzNrEI3q0Tj8b08hmXTwrwG03gU=";
    };

    propagatedBuildInputs = with python3.pkgs; [
      # Core dependencies
      numpy
      opencv4  # Use opencv4 instead of opencv-python to avoid conflicts
      pillow
      pyyaml
      requests
      scipy
      torch
      torchvision
      tqdm
      pandas
      seaborn
      psutil
      matplotlib
      
      # Additional dependencies that might be needed
      typing-extensions
      importlib-metadata
    ];

    # Skip import check as it requires specific setup
    doCheck = false;
    dontBuild = true;  # It's a wheel, no build needed
    pythonImportsCheck = [ ];

    meta = with lib; {
      description = "Ultralytics YOLO for object detection in ComfyUI Impact Pack";
      homepage = "https://github.com/ultralytics/ultralytics";
      license = licenses.agpl3Plus;
    };
  };

in
# Meta package that provides ultralytics for ComfyUI
python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-ultralytics";
  version = "0.9.1";  # Match ComfyUI version
  format = "other";

  dontUnpack = true;
  dontBuild = true;
  doCheck = false;

  propagatedBuildInputs = [
    ultralytics
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Ultralytics YOLO support for ComfyUI Impact Pack";
    longDescription = ''
      Provides the ultralytics package (YOLO models) for ComfyUI Impact Pack.
      This enables the UltralyticsDetectorProvider node for object detection.
      
      Install this package if you need YOLO-based detection in ComfyUI workflows.
    '';
    license = licenses.agpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
