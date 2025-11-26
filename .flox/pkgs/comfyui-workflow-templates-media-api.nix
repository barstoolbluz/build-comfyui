{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-workflow-templates-media-api";
  version = "0.3.14";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_workflow_templates_media_api/comfyui_workflow_templates_media_api-${version}-py3-none-any.whl";
    hash = "sha256-hILMXVdAguE3bDJwWaJuorwBaGWkFbZWKGjIJy0DQc0=";
  };

  propagatedBuildInputs = [ ];

  dontBuild = true;
  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates media API";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
