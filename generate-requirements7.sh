#!/bin/bash
set -eu

cat > requirements7.txt << EOF
facexlib
fvcore
image-reward
EOF

array=(
https://github.com/chflame163/ComfyUI_LayerStyle/raw/refs/heads/main/requirements.txt
https://github.com/pydn/ComfyUI-to-Python-Extension/raw/refs/heads/main/requirements.txt
https://github.com/XLabs-AI/x-flux-comfyui/raw/refs/heads/main/requirements.txt
https://github.com/yolain/ComfyUI-Easy-Use/raw/refs/heads/main/requirements.txt
https://github.com/city96/ComfyUI-GGUF/raw/refs/heads/main/requirements.txt
)

for line in "${array[@]}";
    do curl -w "\n" -sSL "${line}" >> requirements7.txt
done

sed -i '/^#/d' requirements7.txt
sed -i 's/[[:space:]]*$//' requirements7.txt
sed -i 's/>=.*$//' requirements7.txt
sed -i 's/_/-/g' requirements7.txt

# Remove duplicate items, compare to requirements4.txt and requirements5.txt
grep -Fxv -f requirements4.txt requirements7.txt > temp.txt && mv temp.txt requirements7.txt
grep -Fxv -f requirements5.txt requirements7.txt > temp.txt && mv temp.txt requirements7.txt

sort -uo requirements7.txt requirements7.txt

echo "<requirements7.txt> generated. Check before use."
