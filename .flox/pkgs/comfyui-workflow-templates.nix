{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "comfyui-workflow-templates";
  version = "0.2.11";
  format = "wheel";

  src = fetchPypi {
    inherit pname version;
    format = "wheel";
    python = "py3";
    abi = "none";
    platform = "any";
    hash = "";  # Will be filled after first build attempt
  };

  propagatedBuildInputs = [ ];

  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
