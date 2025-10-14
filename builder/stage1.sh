#!/bin/bash
set -eux

workdir=$(pwd)
pip_exe="${workdir}/python_standalone/python.exe -s -m pip"

# Evite toute invite interactive de git/pip en CI
export GIT_ASKPASS=echo
export PIP_DEFAULT_TIMEOUT=120
export PIP_NO_INPUT=1
export PYTHONPYCACHEPREFIX="${workdir}/pycache1"
export PIP_NO_WARN_SCRIPT_LOCATION=0

ls -lahF

# ──────────────────────────────────────────────────────────────
# 1️⃣ Python standalone
# ──────────────────────────────────────────────────────────────
curl -sSL \
#  https://github.com/astral-sh/python-build-standalone/releases/download/20250814/cpython-3.12.11+20250814-x86_64-pc-windows-msvc-install_only.tar.gz \
   https://github.com/astral-sh/python-build-standalone/releases/download/20250205/cpython-3.10.15+20250205-x86_64-pc-windows-msvc-install_only.tar.gz
  -o python.tar.gz
tar -zxf python.tar.gz
mv python python_standalone

# ──────────────────────────────────────────────────────────────
# 2️⃣ Mise à jour pip, wheel, setuptools
# ──────────────────────────────────────────────────────────────
$pip_exe install --upgrade pip wheel setuptools --prefer-binary

# ──────────────────────────────────────────────────────────────
# 3️⃣ Installation par blocs
# ──────────────────────────────────────────────────────────────
$pip_exe install -r "$workdir/pak2.txt" --prefer-binary

echo "[Stage1] Installation torch/vision/audio (CUDA 12.9) ..."
# On installe le trio en lisant pak3 mais on EXCLUT xformers ici
$pip_exe install --prefer-binary torch==2.8.0+cu129 torchaudio==2.8.0+cu129 torchvision==0.23.0

echo "[Stage1] Installation xformers (wheel only, no build) ..."
# Empêche toute tentative de compilation locale
set -o pipefail
$pip_exe install --only-binary=:all: xformers==0.0.32.post2 \
  || $pip_exe install --only-binary=:all: xformers==0.0.31.post0

# (optionnel mais utile) EVA-CLIP et repos Xet + cache HF plus rapides
$pip_exe install -q hf_xet huggingface-hub

# Reste des paquets
$pip_exe install -r "$workdir/pak4.txt" --prefer-binary
$pip_exe install -r "$workdir/pak5.txt" --prefer-binary
$pip_exe install -r "$workdir/pak6.txt" --prefer-binary
$pip_exe install -r "$workdir/pak7.txt" --prefer-binary
$pip_exe install -r "$workdir/pak8.txt" --prefer-binary

# Tweaks additionnels
$pip_exe install --upgrade albucore albumentations --prefer-binary

# comfyui requirements selon le dernier tag
latest_tag=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
$pip_exe install -r "https://github.com/comfyanonymous/ComfyUI/raw/refs/tags/${latest_tag}/requirements.txt" --prefer-binary

# Sanity check versions (échoue tôt si pb)
"$workdir/python_standalone/python.exe" - <<'PY'
import torch, torchvision, torchaudio, sys
print("TORCH    :", torch.__version__)
print("VISION   :", torchvision.__version__)
print("AUDIO    :", torchaudio.__version__)
try:
    import xformers
    print("XFORMERS :", xformers.__version__)
except Exception as e:
    print("XFORMERS : import FAILED ->", e, file=sys.stderr); sys.exit(1)
PY

# ──────────────────────────────────────────────────────────────
# 4️⃣ Tweaks et dépendances additionnelles
# ──────────────────────────────────────────────────────────────
$pip_exe install --upgrade albucore albumentations --prefer-binary

# comfyui-frontend en fonction du tag ComfyUI
latest_tag=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
$pip_exe install -r "https://github.com/comfyanonymous/ComfyUI/raw/refs/tags/${latest_tag}/requirements.txt" --prefer-binary

$pip_exe install -r "$workdir/pakY.txt" --prefer-binary
$pip_exe install -r "$workdir/pakZ.txt" --prefer-binary

$pip_exe list

# ──────────────────────────────────────────────────────────────
# 5️⃣ Outils externes (ninja, aria2, ffmpeg)
# ──────────────────────────────────────────────────────────────
# Ninja
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip -o ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir/python_standalone/Scripts"
rm ninja-win.zip

# aria2
curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip -o aria2.zip
unzip -q aria2.zip -d "$workdir/aria2"
mv "$workdir/aria2"/*/aria2c.exe "$workdir/python_standalone/Scripts/"
rm aria2.zip

# ffmpeg
curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/7.1.1/ffmpeg-7.1.1-full_build.zip -o ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir/ffmpeg"
mv "$workdir/ffmpeg"/*/bin/ffmpeg.exe "$workdir/python_standalone/Scripts/"
rm ffmpeg.zip

du -hd1
