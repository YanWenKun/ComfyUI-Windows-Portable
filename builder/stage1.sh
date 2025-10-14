#!/bin/bash
set -eux

workdir=$(pwd)
pip_exe="${workdir}/python_standalone/python.exe -s -m pip"

# ──────────────────────────────────────────────────────────────
# Environnement CI propre
# ──────────────────────────────────────────────────────────────
export GIT_ASKPASS=echo
export PIP_DEFAULT_TIMEOUT=120
export PIP_NO_INPUT=1
export PYTHONPYCACHEPREFIX="${workdir}/pycache1"
export PIP_NO_WARN_SCRIPT_LOCATION=0

ls -lahF

# ──────────────────────────────────────────────
# 1️⃣ Python standalone (CPython 3.10.13, assets Astral)
# ──────────────────────────────────────────────
echo "[Stage1] Téléchargement du Python standalone 3.10.13 …"
PY_VER=3.10.13
PY_TAG=20240715
BASE_URL="https://github.com/astral-sh/python-build-standalone/releases/download/${PY_TAG}"
CANDIDATES=(
  "cpython-${PY_VER}+${PY_TAG}-x86_64-pc-windows-msvc-install_only.zip"
  "cpython-${PY_VER}+${PY_TAG}-x86_64-pc-windows-msvc-shared-install_only.zip"
  "cpython-${PY_VER}+${PY_TAG}-x86_64-pc-windows-msvc-install_only.tar.zst"
  "cpython-${PY_VER}+${PY_TAG}-x86_64-pc-windows-msvc-shared-install_only.tar.zst"
)

rm -f python.pkg
rm -rf python
ok=""
for f in "${CANDIDATES[@]}"; do
  url="${BASE_URL}/${f}"
  echo "→ try ${f}"
  if curl -fsSL -o python.pkg "$url"; then
    case "$f" in
      *.zip)
        if unzip -tqq python.pkg; then
          echo "[OK] archive ZIP valide"
          mkdir -p python
          unzip -q -o python.pkg -d python
          ok="zip"
          rm -f python.pkg
          break
        fi
        ;;
      *.tar.zst)
        if tar --zstd -tf python.pkg >/dev/null 2>&1; then
          echo "[OK] archive TAR.ZST valide"
          mkdir -p python
          tar --zstd -xf python.pkg -C python
          ok="zst"
          rm -f python.pkg
          break
        fi
        ;;
    esac
  fi
done

if [ -z "$ok" ]; then
  echo "[ERREUR] Aucune archive Python valide trouvée pour ${PY_VER} (${PY_TAG})."
  echo "Vérifie manuellement les assets de la release ${PY_TAG}."
  exit 1
fi

mv python python_standalone
test -x "$workdir/python_standalone/python.exe" || { echo "[ERR] python.exe manquant"; ls -R python_standalone || true; exit 1; }

# ──────────────────────────────────────────────────────────────
# 2️⃣ Mise à jour pip, wheel, setuptools
# ──────────────────────────────────────────────────────────────
$pip_exe install --upgrade pip wheel setuptools --prefer-binary

# ──────────────────────────────────────────────────────────────
# 3️⃣ Installation par blocs
# ──────────────────────────────────────────────────────────────
$pip_exe install -r "$workdir/pak2.txt" --prefer-binary

echo "[Stage1] Installation torch/vision/audio (CUDA 12.9) ..."
$pip_exe install --prefer-binary \
  torch==2.8.0+cu129 torchaudio==2.8.0+cu129 torchvision==0.23.0+cu129 \
  --index-url https://download.pytorch.org/whl/cu129 \
  --extra-index-url https://pypi.org/simple

echo "[Stage1] Installation xformers (wheel only, no build) ..."
set -o pipefail
$pip_exe install --only-binary=:all: xformers==0.0.32.post2 \
  || $pip_exe install --only-binary=:all: xformers==0.0.31.post0

# EVA-CLIP et utilitaires HF
$pip_exe install -q hf_xet huggingface-hub --prefer-binary

# Reste des paquets
$pip_exe install -r "$workdir/pak4.txt" --prefer-binary
$pip_exe install -r "$workdir/pak5.txt" --prefer-binary
$pip_exe install -r "$workdir/pak6.txt" --prefer-binary
$pip_exe install -r "$workdir/pak7.txt" --prefer-binary
$pip_exe install -r "$workdir/pak8.txt" --prefer-binary

# ──────────────────────────────────────────────────────────────
# 4️⃣ Vérification torch/xformers
# ──────────────────────────────────────────────────────────────
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

# Tweaks additionnels
$pip_exe install --upgrade albucore albumentations --prefer-binary

# comfyui requirements selon le dernier tag
latest_tag=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
$pip_exe install -r "https://github.com/comfyanonymous/ComfyUI/raw/refs/tags/${latest_tag}/requirements.txt" --prefer-binary

$pip_exe install -r "$workdir/pakY.txt" --prefer-binary
$pip_exe install -r "$workdir/pakZ.txt" --prefer-binary

$pip_exe list

# ──────────────────────────────────────────────────────────────
# 5️⃣ Outils externes (ninja, aria2, ffmpeg)
# ──────────────────────────────────────────────────────────────
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip -o ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir/python_standalone/Scripts"
rm -f ninja-win.zip

curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip -o aria2.zip
unzip -q aria2.zip -d "$workdir/aria2"
mv "$workdir/aria2"/*/aria2c.exe "$workdir/python_standalone/Scripts/" || true
rm -f aria2.zip

curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/7.1.1/ffmpeg-7.1.1-full_build.zip -o ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir/ffmpeg"
mv "$workdir/ffmpeg"/*/bin/ffmpeg.exe "$workdir/python_standalone/Scripts/" || true
rm -f ffmpeg.zip

du -hd1
