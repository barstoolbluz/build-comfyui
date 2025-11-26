{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-embedded-docs";
  version = "0.3.1";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_embedded_docs/comfyui_embedded_docs-${version}-py3-none-any.whl";
    hash = "sha256-+7sO+Z6r2Hh8Zl7+I1ZlsztivV+bxNlA6yBV02g0yRw=";
  };

  propagatedBuildInputs = [ ];

  doCheck = false;

  meta = with lib; {
    description = "ComfyUI embedded documentation";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
