{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "spandrel";
  version = "0.4.0";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/source/s/spandrel/spandrel-${version}.tar.gz";
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
