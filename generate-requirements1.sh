#!/bin/bash
set -eu

cat > requirements1.txt << EOF
compel
cupy-cuda12x
fairscale
joblib
lark
pilgram
pygit2
python-ffmpeg
regex
torchdiffeq
torchmetrics
scikit_build_core
nanobind
git+https://github.com/rodjjo/filterpy.git
huggingface_hub[hf_transfer]
https://raw.githubusercontent.com/chflame163/ComfyUI_LayerStyle/refs/heads/main/whl/docopt-0.6.2-py2.py3-none-any.whl
https://raw.githubusercontent.com/chflame163/ComfyUI_LayerStyle/refs/heads/main/whl/hydra_core-1.3.2-py3-none-any.whl
EOF

array=(
https://raw.githubusercontent.com/chflame163/ComfyUI_LayerStyle/refs/heads/main/requirements.txt
https://raw.githubusercontent.com/comfyanonymous/ComfyUI/master/requirements.txt
https://raw.githubusercontent.com/crystian/ComfyUI-Crystools/main/requirements.txt
https://raw.githubusercontent.com/cubiq/ComfyUI_essentials/main/requirements.txt
https://raw.githubusercontent.com/cubiq/ComfyUI_FaceAnalysis/main/requirements.txt
https://raw.githubusercontent.com/cubiq/ComfyUI_InstantID/main/requirements.txt
https://raw.githubusercontent.com/cubiq/PuLID_ComfyUI/refs/heads/main/requirements.txt
https://raw.githubusercontent.com/Fannovel16/comfyui_controlnet_aux/main/requirements.txt
https://raw.githubusercontent.com/Fannovel16/ComfyUI-Frame-Interpolation/main/requirements-no-cupy.txt
https://raw.githubusercontent.com/FizzleDorf/ComfyUI_FizzNodes/main/requirements.txt
https://raw.githubusercontent.com/Gourieff/comfyui-reactor-node/refs/heads/main/requirements.txt
https://raw.githubusercontent.com/huchenlei/ComfyUI-layerdiffuse/refs/heads/main/requirements.txt
https://raw.githubusercontent.com/jags111/efficiency-nodes-comfyui/main/requirements.txt
https://raw.githubusercontent.com/kijai/ComfyUI-KJNodes/main/requirements.txt
https://raw.githubusercontent.com/Kosinkadink/ComfyUI-VideoHelperSuite/main/requirements.txt
https://raw.githubusercontent.com/ltdrdata/ComfyUI-Impact-Pack/Main/requirements.txt
https://raw.githubusercontent.com/ltdrdata/ComfyUI-Impact-Subpack/main/requirements.txt
https://raw.githubusercontent.com/ltdrdata/ComfyUI-Inspire-Pack/main/requirements.txt
https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/requirements.txt
https://raw.githubusercontent.com/melMass/comfy_mtb/main/requirements.txt
https://raw.githubusercontent.com/MrForExample/ComfyUI-3D-Pack/main/requirements.txt
https://raw.githubusercontent.com/MrForExample/ComfyUI-AnimateAnyone-Evolved/refs/heads/main/requirements.txt
https://raw.githubusercontent.com/storyicon/comfyui_segment_anything/main/requirements.txt
https://raw.githubusercontent.com/WASasquatch/was-node-suite-comfyui/refs/heads/main/requirements.txt
)

for line in "${array[@]}";
    do curl -w "\n" -sSL "${line}" >> requirements1.txt
done

sed -i '/^#/d' requirements1.txt
sed -i 's/[[:space:]]*$//' requirements1.txt
sed -i 's/>=.*$//' requirements1.txt
sed -i 's/_/-/g' requirements1.txt

sort -uo requirements1.txt requirements1.txt


echo "<requirements1.txt> generated. Check before use."
