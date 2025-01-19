#!/bin/bash
set -eux

# Chores
git config --global core.autocrlf true
workdir=$(pwd)
gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'
export PYTHONPYCACHEPREFIX="$workdir/pycache2"
export PATH="$PATH:$workdir/ComfyUI_Windows_portable/python_standalone/Scripts"

ls -lahF

# Redirect HuggingFace-Hub model folder
export HF_HUB_CACHE="$workdir/ComfyUI_Windows_portable/HuggingFaceHub"
mkdir -p "${HF_HUB_CACHE}"
# Redirect Pytorch Hub model folder
export TORCH_HOME="$workdir/ComfyUI_Windows_portable/TorchHome"
mkdir -p "${TORCH_HOME}"

# Relocate python_standalone
# This move is intentional. It will fast-fail if this breaks anything.
mv  "$workdir"/python_standalone  "$workdir"/ComfyUI_Windows_portable/python_standalone

################################################################################
# ComfyUI main app
git clone https://github.com/comfyanonymous/ComfyUI.git \
    "$workdir"/ComfyUI_Windows_portable/ComfyUI
# Use latest stable version (has a release tag)
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI
git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"
# Clear models folder (will restore in the next stage)
rm -vrf models
mkdir models

# Custom Nodes
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes
$gcs https://github.com/ltdrdata/ComfyUI-Manager.git

# Workspace
$gcs https://github.com/crystian/ComfyUI-Crystools.git
$gcs https://github.com/pydn/ComfyUI-to-Python-Extension.git

# General
$gcs https://github.com/akatz-ai/ComfyUI-AKatz-Nodes.git
$gcs https://github.com/Amorano/Jovimetrix.git
$gcs https://github.com/bash-j/mikey_nodes.git
$gcs https://github.com/chrisgoringe/cg-use-everywhere.git
$gcs https://github.com/cubiq/ComfyUI_essentials.git
$gcs https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git
$gcs https://github.com/jags111/efficiency-nodes-comfyui.git
$gcs https://github.com/kijai/ComfyUI-KJNodes.git
$gcs https://github.com/mirabarukaso/ComfyUI_Mira.git
$gcs https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
$gcs https://github.com/rgthree/rgthree-comfy.git
$gcs https://github.com/shiimizu/ComfyUI_smZNodes.git
$gcs https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
$gcs https://github.com/WASasquatch/was-node-suite-comfyui.git
$gcs https://github.com/yolain/ComfyUI-Easy-Use.git

# Control
$gcs https://github.com/chflame163/ComfyUI_LayerStyle.git
$gcs https://github.com/cubiq/ComfyUI_InstantID.git
$gcs https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
$gcs https://github.com/cubiq/PuLID_ComfyUI.git
$gcs https://github.com/Fannovel16/comfyui_controlnet_aux.git
$gcs https://github.com/florestefano1975/comfyui-portrait-master.git
$gcs https://github.com/Gourieff/ComfyUI-ReActor.git
$gcs https://github.com/huchenlei/ComfyUI-IC-Light-Native.git
$gcs https://github.com/huchenlei/ComfyUI-layerdiffuse.git
$gcs https://github.com/Jonseed/ComfyUI-Detail-Daemon.git
$gcs https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git
$gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
$gcs https://github.com/mcmonkeyprojects/sd-dynamic-thresholding.git
$gcs https://github.com/twri/sdxl_prompt_styler.git

# Video
$gcs https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git
$gcs https://github.com/FizzleDorf/ComfyUI_FizzNodes.git
$gcs https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
$gcs https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
$gcs https://github.com/melMass/comfy_mtb.git

# More
$gcs https://github.com/akatz-ai/ComfyUI-DepthCrafter-Nodes.git
$gcs https://github.com/city96/ComfyUI-GGUF.git
$gcs https://github.com/cubiq/ComfyUI_FaceAnalysis.git
$gcs https://github.com/digitaljohn/comfyui-propost.git
$gcs https://github.com/kijai/ComfyUI-DepthAnythingV2.git
$gcs https://github.com/kijai/ComfyUI-Florence2.git
$gcs https://github.com/neverbiasu/ComfyUI-SAM2.git
$gcs https://github.com/pythongosssss/ComfyUI-WD14-Tagger.git
$gcs https://github.com/SLAPaper/ComfyUI-Image-Selector.git
$gcs https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git

################################################################################
# Copy attachments files (incl. start scripts)
cp -rf "$workdir"/attachments/. \
    "$workdir"/ComfyUI_Windows_portable/

du -hd2 "$workdir"/ComfyUI_Windows_portable

################################################################################
# TAESD model for image on-the-fly preview
cd "$workdir"
$gcs https://github.com/madebyollin/taesd.git
mkdir -p "$workdir"/ComfyUI_Windows_portable/ComfyUI/models/vae_approx
cp taesd/*_decoder.pth \
    "$workdir"/ComfyUI_Windows_portable/ComfyUI/models/vae_approx/
rm -rf taesd

# Download models for ReActor
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/models
curl -sSL https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth \
    --create-dirs -o facerestore_models/codeformer-v0.1.0.pth
curl -sSL https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth \
    --create-dirs -o facerestore_models/GFPGANv1.4.pth
curl -sSL https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128_fp16.onnx \
    --create-dirs -o insightface/inswapper_128_fp16.onnx
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/config.json \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/config.json
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/confusion_matrix.png \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/confusion_matrix.png
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/model.safetensors \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/model.safetensors
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/preprocessor_config.json \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/preprocessor_config.json

# Download models for Impact-Pack & Impact-Subpack
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Impact-Pack
"$workdir"/ComfyUI_Windows_portable/python_standalone/python.exe -s -B install.py
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Impact-Subpack
"$workdir"/ComfyUI_Windows_portable/python_standalone/python.exe -s -B install.py

################################################################################
# Run the test (CPU only), also let custom nodes download some models
cd "$workdir"/ComfyUI_Windows_portable
./python_standalone/python.exe -s -B ComfyUI/main.py --quick-test-for-ci --cpu

################################################################################
# Clean up
# DO NOT clean pymatting cache, they are nbi/nbc files for Numba, and won't be regenerated.
#rm -rf "$workdir"/ComfyUI_Windows_portable/python_standalone/Lib/site-packages/pymatting
rm -vf "$workdir"/ComfyUI_Windows_portable/*.log
rm -vrf "$workdir"/ComfyUI_Windows_portable/ComfyUI/user/default/ComfyUI-Manager

cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes
rm -vf ./ComfyUI-Custom-Scripts/pysssss.json
rm -vf ./ComfyUI-Easy-Use/config.yaml
rm -vf ./ComfyUI-Impact-Pack/impact-pack.ini
rm -vf ./Jovimetrix/web/config.json
rm -vf ./was-node-suite-comfyui/was_suite_config.json

cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Manager
git reset --hard
git clean -fxd

cd "$workdir"
