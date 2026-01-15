{ lib, python3Packages, fetchPypi }:

python3Packages.buildPythonPackage rec {
  pname = "comfy-kitchen";
  version = "0.2.6";
  format = "setuptools";

  src = fetchPypi {
    pname = "comfy_kitchen";
    inherit version;
    hash = "sha256-sPx5+K6x7sE9MNKDBzSmD6CcKBsJmwtq+qDu9h0vNBs=";
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