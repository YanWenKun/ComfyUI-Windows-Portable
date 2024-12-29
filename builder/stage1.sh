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
unzip python_embeded.zip -d "$workdir"/python_embeded

# Setup PIP
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

# Setup Python embeded, part 3/3
cd "$workdir"/python_embeded
sed -i '1i../ComfyUI' ./python312._pth

$pip_exe list

cd "$workdir"

du -hd1
