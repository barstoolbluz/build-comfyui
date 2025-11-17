{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-embedded-docs";
  version = "0.3.1";
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
    description = "ComfyUI embedded documentation";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
