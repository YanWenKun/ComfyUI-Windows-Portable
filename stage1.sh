#!/bin/bash
set -eux

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

workdir=$(pwd)

export PYTHONPYCACHEPREFIX="$workdir"/pycache

ls -lahF

# Setup Python embeded, part 1/3
curl https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip \
    -o python_embeded.zip
unzip python_embeded.zip -d "$workdir"/python_embeded

# ComfyUI-3D-Pack, part 1/2
$gcs https://github.com/MrForExample/Comfy3D_Pre_Builds.git \
    "$workdir"/Comfy3D_Pre_Builds

mv \
    "$workdir"/Comfy3D_Pre_Builds/_Python_Source_cpp/py311/include \
    "$workdir"/python_embeded/include

mv \
    "$workdir"/Comfy3D_Pre_Builds/_Python_Source_cpp/py311/libs \
    "$workdir"/python_embeded/libs

# Setup Python embeded, part 2/3
cd "$workdir"/python_embeded
echo 'import site' >> ./python311._pth
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
./python.exe get-pip.py

# PIP install
./python.exe -s -m pip install \
    --upgrade pip wheel setuptools Cython cmake

./python.exe -s -m pip install \
    xformers torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121 \
    --extra-index-url https://pypi.org/simple

./python.exe -s -m pip install \
    -r "$workdir"/requirements.txt

./python.exe -s -m pip install \
    -r "$workdir"/requirements2.txt

./python.exe -s -m pip uninstall --yes \
    onnxruntime-gpu \
&& ./python.exe -s -m pip --no-cache-dir install \
    onnxruntime-gpu \
    --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/ \
    --extra-index-url https://pypi.org/simple \
&& ./python.exe -s -m pip install \
    mediapipe

# ComfyUI-3D-Pack, part 2/2
./python.exe -s -m pip install \
    "$workdir"/Comfy3D_Pre_Builds/_Build_Wheels/_Wheels_win_py311_cu121/*.whl

# From: https://github.com/rusty1s/pytorch_scatter?tab=readme-ov-file#binaries
./python.exe -s -m pip install \
    torch-scatter -f https://data.pyg.org/whl/torch-2.3.0+cu121.html

rm -rf "$workdir"/Comfy3D_Pre_Builds

# Add Ninja binary (replacing PIP one)
curl -L https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip \
    -o ninja-win.zip
unzip -o ninja-win.zip -d "$workdir"/python_embeded/Scripts
rm ninja-win.zip

# Setup Python embeded, part 3/3
sed -i '1i../ComfyUI' ./python311._pth

./python.exe -s -m pip list

cd "$workdir"

du -hd1
