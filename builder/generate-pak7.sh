#!/bin/bash
set -eu

cat > pak7.txt << EOF
facexlib
fvcore
gpytoolbox
EOF

array=(
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
https://github.com/mirabarukaso/ComfyUI_Mira/raw/refs/heads/main/requirements.txt
https://github.com/neverbiasu/ComfyUI-SAM2/raw/refs/heads/main/requirements.txt
https://github.com/pydn/ComfyUI-to-Python-Extension/raw/refs/heads/main/requirements.txt
https://github.com/yolain/ComfyUI-Easy-Use/raw/refs/heads/main/requirements.txt
)

for line in "${array[@]}";
    do curl -w "\n" -sSL "${line}" >> pak7.txt
done

sed -i '/^#/d' pak7.txt
sed -i 's/[[:space:]]*$//' pak7.txt
sed -i 's/>=.*$//' pak7.txt
sed -i 's/_/-/g' pak7.txt
sed -i 's/; platform-system=="Windows"//' pak7.txt

sort -ufo pak7.txt pak7.txt

# Remove duplicate items, compare to pak4.txt and pak5.txt
grep -Fixv -f pak4.txt pak7.txt > temp.txt && mv temp.txt pak7.txt
grep -Fixv -f pak5.txt pak7.txt > temp.txt && mv temp.txt pak7.txt

echo "<pak7.txt> generated. Check before use."
