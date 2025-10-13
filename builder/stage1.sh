#!/bin/bash
set -eux

# ──────────────────────────────────────────────────────────────────────────────
# Setup de base
# ──────────────────────────────────────────────────────────────────────────────
workdir=$(pwd)
pip_exe="${workdir}/python_standalone/python.exe -s -m pip"

export PYTHONPYCACHEPREFIX="${workdir}/pycache1"
export PIP_NO_WARN_SCRIPT_LOCATION=0
# Évite toute demande interactive en CI (git/pip)
export GIT_TERMINAL_PROMPT=0
export PIP_NO_INPUT=1

ls -lahF

# ──────────────────────────────────────────────────────────────────────────────
# Python Standalone
# ──────────────────────────────────────────────────────────────────────────────
curl -sSL \
  https://github.com/astral-sh/python-build-standalone/releases/download/20250814/cpython-3.12.11+20250814-x86_64-pc-windows-msvc-install_only.tar.gz \
  -o python.tar.gz
tar -zxf python.tar.gz
mv python python_standalone

# Outils pip à jour
$pip_exe install --upgrade pip wheel setuptools

# ──────────────────────────────────────────────────────────────────────────────
# Empêcher les prompts Git (cozy-comfyui & co en CI)
# ──────────────────────────────────────────────────────────────────────────────
git config --global credential.helper ""

# ──────────────────────────────────────────────────────────────────────────────
# Forcer ONNX Runtime GPU (et éviter que la version CPU prenne la main)
# ──────────────────────────────────────────────────────────────────────────────
# On installe d’abord la version GPU sans dépendances (idempotent)
$pip_exe install --no-deps onnxruntime-gpu==1.19.2 || true

# ──────────────────────────────────────────────────────────────────────────────
# Install des paquets par lots
# ──────────────────────────────────────────────────────────────────────────────
$pip_exe install -r "$workdir/pak2.txt"
$pip_exe install -r "$workdir/pak3.txt"
$pip_exe install -r "$workdir/pak4.txt"
$pip_exe install -r "$workdir/pak5.txt"

# pak6 inclut désormais cozy-comfyui via ZIP + wheels binaires (pas de prompt git)
$pip_exe install -r "$workdir/pak6.txt"

# Si un paquet a tiré 'onnxruntime' CPU, on le retire et on réassure la version GPU
$pip_exe uninstall -y onnxruntime || true
$pip_exe install --no-deps onnxruntime-gpu==1.19.2 || true

$pip_exe install -r "$workdir/pak7.txt"
$pip_exe install -r "$workdir/pak8.txt"

# ──────────────────────────────────────────────────────────────────────────────
# Tweaks spécifiques
# ──────────────────────────────────────────────────────────────────────────────
# transparent-background a déplacé ses deps – on s’assure d’avoir les bonnes versions
$pip_exe install --upgrade albucore albumentations

# Requirements frontend alignés sur le dernier tag ComfyUI
latest_tag=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
$pip_exe install -r "https://github.com/comfyanonymous/ComfyUI/raw/refs/tags/${latest_tag}/requirements.txt"

# Paquets additionnels
$pip_exe install -r "$workdir/pakY.txt"
$pip_exe install -r "$workdir/pakZ.txt"

# Log des versions installées (utile pour diagnostiquer)
$pip_exe list

cd "$workdir"

# ──────────────────────────────────────────────────────────────────────────────
# Binaries annexes (ninja, aria2, ffmpeg) pour un portable complet
# ──────────────────────────────────────────────────────────────────────────────
# Ninja (remplace le binaire pip si présent)
curl -sSL "https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip" -o ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir/python_standalone/Scripts"
rm -f ninja-win.zip

# aria2 (téléchargements robustes)
curl -sSL "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" -o aria2.zip
unzip -q aria2.zip -d "$workdir/aria2"
mv "$workdir/aria2"/*/aria2c.exe "$workdir/python_standalone/Scripts/" || true
rm -rf aria2.zip "$workdir/aria2"

# FFmpeg (pour WAS Node Suite et autres)
curl -sSL "https://github.com/GyanD/codexffmpeg/releases/download/7.1.1/ffmpeg-7.1.1-full_build.zip" -o ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir/ffmpeg"
mv "$workdir/ffmpeg"/*/bin/ffmpeg.exe "$workdir/python_standalone/Scripts/" || true
rm -rf ffmpeg.zip "$workdir/ffmpeg"

cd "$workdir"
du -hd1
