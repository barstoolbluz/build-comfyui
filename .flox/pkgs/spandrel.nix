{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "spandrel";
  version = "0.4.0";
  pyproject = true;

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/source/s/spandrel/spandrel-${version}.tar.gz";
    hash = "sha256-9FUmiT+SOhLvN1QsROREsSCJdlk7x8zfpU/QTHw+gMo=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    torch
    torchvision
    numpy
    einops
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
