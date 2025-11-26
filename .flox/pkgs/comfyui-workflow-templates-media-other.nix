{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-workflow-templates-media-other";
  version = "0.3.9";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_workflow_templates_media_other/comfyui_workflow_templates_media_other-${version}-py3-none-any.whl";
    hash = "sha256-CmVPt3UwVldumIOsMu6K7TnX+Ht0NZ02ht1SO7czr5c=";
  };

  propagatedBuildInputs = [ ];

  dontBuild = true;
  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates media other";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
