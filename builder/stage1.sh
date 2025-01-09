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

# Tweak for transparent-background. TODO: remove if upstream updated.
# https://github.com/plemeri/transparent-background/blob/f54975ce489af549dcfc4dc0a2d39e8f69a204fd/setup.py#L45
$pip_exe install --upgrade albucore albumentations

$pip_exe install -r "$workdir"/pakZ.txt

# Config Python Embedded
cd "$workdir"/python_embeded
sed -i '1i../ComfyUI' ./python312._pth

$pip_exe list

cd "$workdir"

# Add Ninja binary (replacing PIP Ninja if exists)
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip \
    -o ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir"/python_embeded/Scripts
rm ninja-win.zip

# Add aria2 binary
curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip \
    -o aria2.zip
unzip -q aria2.zip -d "$workdir"/aria2
mv "$workdir"/aria2/*/aria2c.exe  "$workdir"/python_embeded/Scripts/
rm aria2.zip

# Add FFmpeg binary
curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/7.1/ffmpeg-7.1-full_build.zip \
    -o ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir"/ffmpeg
mv "$workdir"/ffmpeg/*/bin/ffmpeg.exe  "$workdir"/python_embeded/Scripts/
rm ffmpeg.zip

cd "$workdir"
du -hd1
