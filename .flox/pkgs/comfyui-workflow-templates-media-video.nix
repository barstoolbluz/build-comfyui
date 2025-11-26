{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-workflow-templates-media-video";
  version = "0.3.12";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_workflow_templates_media_video/comfyui_workflow_templates_media_video-${version}-py3-none-any.whl";
    hash = "sha256-aplXdlGrRb6ePuRbz9ncVTULPKqWeGSEaVhgIVcNKxU=";
  };

  propagatedBuildInputs = [ ];

  dontBuild = true;
  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates media video";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
