{ lib
, python3
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "comfyui-workflow-templates-media-image";
  version = "0.3.15";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/c/comfyui_workflow_templates_media_image/comfyui_workflow_templates_media_image-${version}-py3-none-any.whl";
    hash = "sha256-qkIJ4Fli9CMc8EPmFTX36bV90HFP+T3u1Licw65EMx8=";
  };

  propagatedBuildInputs = [ ];

  dontBuild = true;
  doCheck = false;

  meta = with lib; {
    description = "ComfyUI workflow templates media image";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
  };
}
