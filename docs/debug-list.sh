#!/bin/bash
set -eu

echo '#' > debug-list.txt

array=(
https://github.com/comfyanonymous/ComfyUI/raw/refs/heads/master/requirements.txt
https://github.com/crystian/ComfyUI-Crystools/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/ComfyUI_essentials/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/ComfyUI_FaceAnalysis/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/ComfyUI_InstantID/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/PuLID_ComfyUI/raw/refs/heads/main/requirements.txt
https://github.com/Fannovel16/comfyui_controlnet_aux/raw/refs/heads/main/requirements.txt
https://github.com/Fannovel16/ComfyUI-Frame-Interpolation/raw/refs/heads/main/requirements-no-cupy.txt
https://github.com/FizzleDorf/ComfyUI_FizzNodes/raw/refs/heads/main/requirements.txt
https://github.com/Gourieff/ComfyUI-ReActor/raw/refs/heads/main/requirements.txt
https://github.com/huchenlei/ComfyUI-layerdiffuse/raw/refs/heads/main/requirements.txt
https://github.com/jags111/efficiency-nodes-comfyui/raw/refs/heads/main/requirements.txt
https://github.com/kijai/ComfyUI-KJNodes/raw/refs/heads/main/requirements.txt
https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Impact-Pack/raw/refs/heads/Main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Impact-Subpack/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Inspire-Pack/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Manager/raw/refs/heads/main/requirements.txt
https://github.com/melMass/comfy_mtb/raw/refs/heads/main/requirements.txt
https://github.com/WASasquatch/was-node-suite-comfyui/raw/refs/heads/main/requirements.txt
https://github.com/akatz-ai/ComfyUI-AKatz-Nodes/raw/refs/heads/main/requirements.txt
https://github.com/akatz-ai/ComfyUI-DepthCrafter-Nodes/raw/refs/heads/main/requirements.txt
https://github.com/Amorano/Jovimetrix/raw/refs/heads/main/requirements.txt
https://github.com/chflame163/ComfyUI_LayerStyle/raw/refs/heads/main/repair_dependency_list.txt
https://github.com/chflame163/ComfyUI_LayerStyle/raw/refs/heads/main/requirements.txt
https://github.com/city96/ComfyUI-GGUF/raw/refs/heads/main/requirements.txt
https://github.com/digitaljohn/comfyui-propost/raw/refs/heads/master/requirements.txt
https://github.com/Jonseed/ComfyUI-Detail-Daemon/raw/refs/heads/main/requirements.txt
https://github.com/kijai/ComfyUI-DepthAnythingV2/raw/refs/heads/main/requirements.txt
https://github.com/kijai/ComfyUI-Florence2/raw/refs/heads/main/requirements.txt
https://github.com/neverbiasu/ComfyUI-SAM2/raw/refs/heads/main/requirements.txt
https://github.com/pydn/ComfyUI-to-Python-Extension/raw/refs/heads/main/requirements.txt
https://github.com/yolain/ComfyUI-Easy-Use/raw/refs/heads/main/requirements.txt
https://github.com/deepseek-ai/Janus/raw/refs/heads/main/requirements.txt
)

for line in "${array[@]}"; do
    printf '\n# %s\n' "${line}" >> debug-list.txt
    curl -w "\n" -sSL "${line}" >> debug-list.txt
done
