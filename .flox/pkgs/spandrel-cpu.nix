{ lib
, python3
, fetchurl
, pytorch-python313-cpu-avx512
}:

python3.pkgs.buildPythonPackage rec {
  pname = "spandrel-cpu";
  version = "0.4.0";
  pyproject = true;

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/source/s/spandrel/spandrel-${version}.tar.gz";
    hash = "sha256-9FUmiT+SOhLvN1QsROREsSCJdlk7x8zfpU/QTHw+gMo=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = [
    pytorch-python313-cpu-avx512
  ] ++ (with python3.pkgs; [
    # TODO: Replace with barstoolbluz/torchvision-python313-cpu-avx512 when available
    torchvision
    numpy
    einops
    pillow
    safetensors
  ]);

  doCheck = false;

  meta = with lib; {
    description = "Spandrel with CPU-optimized PyTorch (AVX512)";
    homepage = "https://github.com/chaiNNer-org/spandrel";
    license = licenses.mit;
  };
}
