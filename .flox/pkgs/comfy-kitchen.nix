{ lib, python3Packages, fetchPypi }:

python3Packages.buildPythonPackage rec {
  pname = "comfy-kitchen";
  version = "0.2.6";
  format = "wheel";

  src = fetchPypi {
    pname = "comfy_kitchen";
    version = version;
    dist = "py3";
    python = "py3";
    format = "wheel";
    hash = "sha256-1d9sd8daasm3gi50wh6l207q2xxdkfyhv1512h7h4d6s2b2yscrp";
  };

  pythonImportsCheck = [ "comfy_kitchen" ];

  meta = with lib; {
    description = "ComfyUI kitchen utilities for FP8/FP4 support";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
    maintainers = [ ];
  };
}