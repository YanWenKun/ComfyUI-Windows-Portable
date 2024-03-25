#!/bin/bash
set -eu

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

workdir=$(pwd)
echo "pwd=$workdir"

tar xf cp311_cu121_deps.tar
ls
rm cp311_cu121_deps.tar

$gcs https://github.com/comfyanonymous/ComfyUI.git
cp -r ComfyUI ComfyUI_copy

curl https://www.python.org/ftp/python/3.11.8/python-3.11.8-embed-amd64.zip \
    -o python_embeded.zip
unzip python_embeded.zip -d "$workdir"/python_embeded

cd "$workdir"/python_embeded
echo 'import site' >> ./python311._pth
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
./python.exe get-pip.py
./python.exe -s -m pip install "$workdir"/cp311_cu121_deps/*
sed -i '1i../ComfyUI' ./python311._pth
cd "$workdir"
rm -rf "$workdir"/cp311_cu121_deps

$gcs https://github.com/madebyollin/taesd
cp taesd/*.pth ./ComfyUI_copy/models/vae_approx/
rm -rf taesd

cd "$workdir"/ComfyUI_copy/custom_nodes
$gcs https://github.com/MrForExample/ComfyUI-3D-Pack.git
cd ComfyUI-3D-Pack
cp -rf _Pre_Builds/_Python311_cpp/include "$workdir"/python_embeded/include
cp -rf _Pre_Builds/_Python311_cpp/libs "$workdir"/python_embeded/libs


cd "$workdir"/ComfyUI_copy/custom_nodes
$gcs https://github.com/ltdrdata/ComfyUI-Manager.git
$gcs https://github.com/bash-j/mikey_nodes.git
$gcs https://github.com/chrisgoringe/cg-use-everywhere.git
$gcs https://github.com/crystian/ComfyUI-Crystools.git
$gcs https://github.com/cubiq/ComfyUI_essentials.git
$gcs https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
$gcs https://github.com/Fannovel16/comfyui_controlnet_aux.git
$gcs https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git
$gcs https://github.com/FizzleDorf/ComfyUI_FizzNodes.git
$gcs https://github.com/jags111/efficiency-nodes-comfyui.git
$gcs https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
$gcs https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
$gcs https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
$gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
$gcs https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
$gcs https://github.com/pythongosssss/ComfyUI-WD14-Tagger.git
$gcs https://github.com/rgthree/rgthree-comfy.git
$gcs https://github.com/shiimizu/ComfyUI_smZNodes.git
$gcs https://github.com/SLAPaper/ComfyUI-Image-Selector.git
$gcs https://github.com/twri/sdxl_prompt_styler.git
$gcs https://github.com/ZHO-ZHO-ZHO/ComfyUI-InstantID.git
cd "$workdir"

mkdir ComfyUI_Windows_portable
mv python_embeded ComfyUI_Windows_portable
mv ComfyUI_copy ComfyUI_Windows_portable/ComfyUI

cd ComfyUI_Windows_portable
mkdir update
cp -r ComfyUI/.ci/update_windows/* ./update/
cp -r ComfyUI/.ci/windows_base_files/* ./

cd "$workdir"
"C:\Program Files\7-Zip\7z.exe" a -t7z -m0=lzma -mx=8 -mfb=64 -md=32m -ms=on -mf=BCJ2 ComfyUI_Windows_portable.7z ComfyUI_Windows_portable

cd ComfyUI_Windows_portable
python_embeded/python.exe -s ComfyUI/main.py --quick-test-for-ci --cpu

cd "$workdir"
du -hd1
