{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-workflow-templates";
  version = "0.7.20";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_workflow_templates/comfyui_workflow_templates-${version}-py3-none-any.whl";
    hash = "sha256-tPF2mr3BrqXKNAxlzx9cI1OJfH3gyzKc8IrtN8co8qM=";
  };

  propagatedBuildInputs = [ ];

  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
