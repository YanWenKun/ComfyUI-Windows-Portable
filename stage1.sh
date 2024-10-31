#!/bin/bash
set -eux

git config --global core.autocrlf true

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

workdir=$(pwd)

export PYTHONPYCACHEPREFIX="$workdir"/pycache

ls -lahF

# Setup Python embeded, part 1/3
curl https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip \
    -o python_embeded.zip
unzip python_embeded.zip -d "$workdir"/python_embeded

# ComfyUI-3D-Pack, part 1/2
# Do this firstly (in a clean python_embeded folder)
$gcs https://github.com/MrForExample/Comfy3D_Pre_Builds.git \
    "$workdir"/Comfy3D_Pre_Builds

mv \
    "$workdir"/Comfy3D_Pre_Builds/_Python_Source_cpp/py312/* \
    "$workdir"/python_embeded/

rm -rf "$workdir"/Comfy3D_Pre_Builds

# Add missing header for StableFast3D
curl -L https://raw.githubusercontent.com/martinus/unordered_dense/refs/heads/main/include/ankerl/unordered_dense.h \
    --create-dirs -o "$workdir"/python_embeded/include/ankerl/unordered_dense.h

$gcs https://github.com/shader-slang/slang.git \
    "$workdir"/slang

mv \
    "$workdir"/slang/include/*.h \
    "$workdir"/python_embeded/include/

rm -rf "$workdir"/slang

# Setup Python embeded, part 2/3
cd "$workdir"/python_embeded
echo 'import site' >> ./python312._pth
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
./python.exe get-pip.py

# PIP install PyTorch
./python.exe -s -m pip install \
    --upgrade pip wheel setuptools Cython cmake

./python.exe -s -m pip install \
    xformers==0.0.28.post3 torch==2.5.1 torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu124 \
    --extra-index-url https://pypi.org/simple

# PIP install
# 1. requirements.txt
# 2. onnxruntime-gpu
# 3. requirements2.txt
./python.exe -s -m pip install \
    -r "$workdir"/requirements.txt

./python.exe -s -m pip uninstall --yes \
    onnxruntime-gpu \
&& ./python.exe -s -m pip --no-cache-dir install \
    onnxruntime-gpu \
    --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/ \
    --extra-index-url https://pypi.org/simple \

./python.exe -s -m pip install \
    -r "$workdir"/requirements2.txt

# ComfyUI-3D-Pack, part 2/2
./python.exe -s -m pip install \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/pointnet2_ops-3.0.0-cp312-cp312-win_amd64.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/simple_knn-0.0.0-cp312-cp312-win_amd64.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/diff_gaussian_rasterization-0.0.0-cp312-cp312-win_amd64.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/kiui-0.2.14-py3-none-any.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/nvdiffrast-0.3.3-py3-none-any.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/torch_scatter-2.1.2-cp312-cp312-win_amd64.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/pytorch3d-0.7.8-cp312-cp312-win_amd64.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/texture_baker-0.0.1-cp312-cp312-win_amd64.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/uv_unwrapper-0.0.1-cp312-cp312-win_amd64.whl \
https://github.com/YanWenKun/ComfyUI-Windows-Portable/releases/download/v6.2-wheels/pynim-0.0.3-cp312-abi3-win_amd64.whl

# Fix broken dep for mediapipe
./python.exe -s -m pip install \
    mediapipe

# Add Ninja binary (replacing PIP one)
curl -L https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip \
    -o ninja-win.zip
unzip -o ninja-win.zip -d "$workdir"/python_embeded/Scripts
rm ninja-win.zip

# Setup Python embeded, part 3/3
sed -i '1i../ComfyUI' ./python312._pth

./python.exe -s -m pip list

cd "$workdir"

du -hd1
