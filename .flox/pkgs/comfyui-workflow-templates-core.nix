{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-workflow-templates-core";
  version = "0.3.10";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_workflow_templates_core/comfyui_workflow_templates_core-${version}-py3-none-any.whl";
    hash = "sha256-g6lxGRp7LlpRKRahaReEPPK9Yfdw2MLGu6GyRoRjT9c=";
  };

  propagatedBuildInputs = [ ];

  dontBuild = true;
  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates core";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
