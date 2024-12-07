#!/bin/bash
set -eux

git config --global core.autocrlf true

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

workdir=$(pwd)

pip_exe="${workdir}/python_embeded/python.exe -s -m pip"

export PYTHONPYCACHEPREFIX="${workdir}/pycache"

ls -lahF

# Setup Python embeded, part 1/3
curl -sSL https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip \
    -o python_embeded.zip
unzip python_embeded.zip -d "$workdir"/python_embeded

# Header files for ComfyUI-3D-Pack
# Do this firstly (in a clean python_embeded folder)
$gcs https://github.com/MrForExample/Comfy3D_Pre_Builds.git \
    "$workdir"/Comfy3D_Pre_Builds

mv \
    "$workdir"/Comfy3D_Pre_Builds/_Python_Source_cpp/py312/* \
    "$workdir"/python_embeded/

rm -rf "$workdir"/Comfy3D_Pre_Builds

# Setup Python embeded, part 2/3
cd "$workdir"/python_embeded
sed -i 's/^#import site/import site/' ./python312._pth
curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
./python.exe get-pip.py

# PIP installs
$pip_exe install --upgrade pip wheel setuptools

$pip_exe install -r "$workdir"/requirements2.txt
$pip_exe install -r "$workdir"/requirements3.txt
$pip_exe install -r "$workdir"/requirements4.txt
$pip_exe install -r "$workdir"/requirements5.txt
$pip_exe install -r "$workdir"/requirements6.txt
$pip_exe install -r "$workdir"/requirements7.txt
$pip_exe install -r "$workdir"/requirements8.txt
$pip_exe install -r "$workdir"/requirements9.txt

# Add Ninja binary (replacing PIP Ninja)
## The 'python_embeded\Scripts\ninja.exe' is not working,
## because most .exe files in 'python_embeded\Scripts' are wrappers 
## that looking for 'C:\Absolute\Path\python.exe', which is not portable.
## So here we use the actual binary of Ninja.
## Whatsmore, if the end-user re-install/upgrade the PIP Ninja,
## the path problem will be fixed automatically.
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip \
    -o ninja-win.zip
unzip -o ninja-win.zip -d "$workdir"/python_embeded/Scripts
rm ninja-win.zip

# Setup Python embeded, part 3/3
sed -i '1i../ComfyUI' ./python312._pth

$pip_exe list

cd "$workdir"

du -hd1
