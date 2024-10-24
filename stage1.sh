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

# Setup Python embeded, part 2/3
cd "$workdir"/python_embeded
echo 'import site' >> ./python312._pth
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
./python.exe get-pip.py

# PIP install
./python.exe -s -m pip install \
    --upgrade pip wheel setuptools Cython cmake

./python.exe -s -m pip install \
    xformers torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu124 \
    --extra-index-url https://pypi.org/simple

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

# Fix broken dep for mediapipe
./python.exe -s -m pip install \
    mediapipe

# Setup Python embeded, part 3/3
sed -i '1i../ComfyUI' ./python312._pth

./python.exe -s -m pip list

cd "$workdir"

du -hd1
