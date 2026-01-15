{ lib, python3Packages, fetchPypi }:

python3Packages.buildPythonPackage rec {
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

  # No dependencies listed
  propagatedBuildInputs = [ ];

  pythonImportsCheck = [ "comfy_kitchen" ];

  meta = with lib; {
    description = "ComfyUI kitchen utilities for FP8/FP4 support";
    homepage = "https://pypi.org/project/comfy-kitchen/";
    license = licenses.gpl3Only;
    maintainers = [ ];
  };
}