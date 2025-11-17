{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-frontend-package";
  version = "1.28.8";
  format = "wheel";

  src = fetchPypi {
    inherit pname version;
    format = "wheel";
    python = "py3";
    abi = "none";
    platform = "any";
    hash = "";  # Will be filled after first build attempt
  };

  # No dependencies - this is a frontend package
  propagatedBuildInputs = [ ];

  # Skip tests
  doCheck = false;

  meta = with lib; {
    description = "ComfyUI frontend package";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
