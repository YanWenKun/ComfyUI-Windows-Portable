#!/bin/bash
set -eux

# Chores
workdir=$(pwd)
pip_exe="${workdir}/python_standalone/python.exe -s -m pip"

export PYTHONPYCACHEPREFIX="${workdir}/pycache1"
export PIP_NO_WARN_SCRIPT_LOCATION=0

ls -lahF

# Download Python Standalone
curl -sSL \
https://github.com/astral-sh/python-build-standalone/releases/download/20251028/cpython-3.12.12+20251028-x86_64-pc-windows-msvc-install_only.tar.gz \
    -o python.tar.gz
tar -zxf python.tar.gz
mv python python_standalone

# PIP installs
$pip_exe install --upgrade pip wheel setuptools

$pip_exe install -r "$workdir"/pak2.txt
$pip_exe install -r "$workdir"/pak3.txt

# temp-fix, TODO: remove after version chaos resolved
$pip_exe install transformers

$pip_exe install -r "$workdir"/pak4.txt
$pip_exe install -r "$workdir"/pak5.txt
$pip_exe install -r "$workdir"/pak6.txt
$pip_exe install -r "$workdir"/pak7.txt
$pip_exe install -r "$workdir"/pak8.txt

# Install comfyui-frontend-package, version determined by ComfyUI release version.
latest_tag=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags | jq -r '.[0].name')
$pip_exe install -r "https://github.com/comfyanonymous/ComfyUI/raw/refs/tags/${latest_tag}/requirements.txt"

$pip_exe install -r "$workdir"/pakY.txt
$pip_exe install -r "$workdir"/pakZ.txt

$pip_exe list

cd "$workdir"

# Add Ninja binary (replacing PIP Ninja if exists)
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip \
    -o ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir"/python_standalone/Scripts
rm ninja-win.zip

# Add aria2 binary
curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip \
    -o aria2.zip
unzip -q aria2.zip -d "$workdir"/aria2
mv "$workdir"/aria2/*/aria2c.exe  "$workdir"/python_standalone/Scripts/
rm aria2.zip

# Add FFmpeg binary
curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/8.0/ffmpeg-8.0-full_build.zip \
    -o ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir"/ffmpeg
mv "$workdir"/ffmpeg/*/bin/ffmpeg.exe  "$workdir"/python_standalone/Scripts/
rm ffmpeg.zip

cd "$workdir"
du -hd1
