#!/bin/bash
set -eux

# Chores
workdir=$(pwd)
pip_exe="${workdir}/python_embeded/python.exe -s -m pip"

export PYTHONPYCACHEPREFIX="${workdir}/pycache1"
export PIP_NO_WARN_SCRIPT_LOCATION=0

ls -lahF

# Download Python embeded
curl -sSL https://www.python.org/ftp/python/3.12.8/python-3.12.8-embed-amd64.zip \
    -o python_embeded.zip
unzip -q python_embeded.zip -d "$workdir"/python_embeded

# Special fix for 'triton' on Windows, used by X-Portrait
cd "$workdir"/python_embeded
curl -sSL https://github.com/woct0rdho/triton-windows/releases/download/v3.0.0-windows.post1/python_3.12.7_include_libs.zip \
    -o temp.zip
unzip -q temp.zip
rm temp.zip

# Setup PIP
cd "$workdir"/python_embeded
sed -i 's/^#import site/import site/' ./python312._pth
curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
./python.exe get-pip.py

# PIP installs
$pip_exe install --upgrade pip wheel setuptools

$pip_exe install -r "$workdir"/pak2.txt
$pip_exe install -r "$workdir"/pak3.txt
$pip_exe install -r "$workdir"/pak4.txt
$pip_exe install -r "$workdir"/pak5.txt
$pip_exe install -r "$workdir"/pak6.txt
$pip_exe install -r "$workdir"/pak7.txt
$pip_exe install -r "$workdir"/pak8.txt
$pip_exe install -r "$workdir"/pak9.txt

# Setup Python embeded, part 3/3
cd "$workdir"/python_embeded
sed -i '1i../ComfyUI' ./python312._pth

$pip_exe list

cd "$workdir"

du -hd1
