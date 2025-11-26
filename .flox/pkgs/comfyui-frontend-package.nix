{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-frontend-package";
  version = "1.30.6";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_frontend_package/comfyui_frontend_package-${version}-py3-none-any.whl";
    hash = "sha256-NTTaulqHFwBbwHHmIVpa6BPfBpe/FdAO6EkyZQYkkM8=";
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
