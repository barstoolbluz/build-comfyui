{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-workflow-templates";
  version = "0.2.11";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_workflow_templates/comfyui_workflow_templates-${version}-py3-none-any.whl";
    hash = "sha256-gPOJUxO3/NpLZiPZCt5Yt+V3V0WG+fYTmdUTt/PpvMs=";
  };

  propagatedBuildInputs = [ ];

  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
