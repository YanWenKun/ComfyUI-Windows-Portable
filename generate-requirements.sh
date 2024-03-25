#!/bin/bash
set -eu

cat > requirements.txt << EOF
compel
lark
torchdiffeq
fairscale
cupy-cuda12x
python-ffmpeg
pygit2
EOF

{
curl -w "\n" https://raw.githubusercontent.com/comfyanonymous/ComfyUI/master/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/crystian/ComfyUI-Crystools/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/cubiq/ComfyUI_essentials/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/cubiq/ComfyUI_FaceAnalysis/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/Fannovel16/comfyui_controlnet_aux/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/Fannovel16/ComfyUI-Frame-Interpolation/main/requirements-no-cupy.txt
curl -w "\n" https://raw.githubusercontent.com/FizzleDorf/ComfyUI_FizzNodes/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/jags111/efficiency-nodes-comfyui/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/kijai/ComfyUI-KJNodes/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/ltdrdata/ComfyUI-Impact-Pack/Main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/ltdrdata/ComfyUI-Impact-Subpack/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/ltdrdata/ComfyUI-Inspire-Pack/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/MrForExample/ComfyUI-3D-Pack/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/storyicon/comfyui_segment_anything/main/requirements.txt
curl -w "\n" https://raw.githubusercontent.com/ZHO-ZHO-ZHO/ComfyUI-InstantID/main/requirements.txt
}  >> requirements.txt

sort -u requirements.txt > tmpfile && mv tmpfile requirements.txt

sed -i '/^#/d' requirements.txt

echo "<requirements.txt> generated. Check before use."
