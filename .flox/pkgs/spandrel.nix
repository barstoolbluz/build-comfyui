{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonPackage rec {
  pname = "spandrel";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "";  # Will be filled after first build attempt
  };

  propagatedBuildInputs = with python3.pkgs; [
    torch
    numpy
    pillow
    safetensors
  ];

  doCheck = false;

  meta = with lib; {
    description = "Spandrel is a library for loading and running pre-trained PyTorch models";
    homepage = "https://github.com/chaiNNer-org/spandrel";
    license = licenses.mit;
  };
}
