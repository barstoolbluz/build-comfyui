{ lib
, python3
, fetchurl
, pytorch-python313-cuda12_8-sm120-avx512
}:

python3.pkgs.buildPythonPackage rec {
  pname = "spandrel-cuda";
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
    pytorch-python313-cuda12_8-sm120-avx512
  ] ++ (with python3.pkgs; [
    # TODO: Replace with barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512 when available
    torchvision
    numpy
    einops
    pillow
    safetensors
  ]);

  doCheck = false;

  meta = with lib; {
    description = "Spandrel with CUDA 12.8 optimized PyTorch (SM 12.0, AVX512)";
    homepage = "https://github.com/chaiNNer-org/spandrel";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];  # CUDA is Linux-only
  };
}
