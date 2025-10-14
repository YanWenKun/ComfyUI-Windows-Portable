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

# ──────────────────────────────────────────────────────────────
# 1) Python standalone (3.12.x stable) + vérification archive
# ──────────────────────────────────────────────────────────────
echo "[Stage1] Téléchargement du Python standalone 3.12.x …"
PY_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20250814/cpython-3.12.11+20250814-x86_64-pc-windows-msvc-install_only.tar.gz"

curl -fSL -o python.tar.gz "${PY_URL}"
# Valide l’archive avant extraction (évite le 'not in gzip format')
tar -tzf python.tar.gz >/dev/null
tar -zxf python.tar.gz
mv python python_standalone

# ──────────────────────────────────────────────────────────────
# 2) Mise à jour pip, wheel, setuptools
# ──────────────────────────────────────────────────────────────
$pip_exe install --upgrade pip wheel setuptools --prefer-binary

# ──────────────────────────────────────────────────────────────
# 3) Installation par blocs (pak2 → pak8)
#    ⚠️ PAK3: torch/vision/audio d’abord, xformers ensuite (wheel only)
# ──────────────────────────────────────────────────────────────
$pip_exe install -r "$workdir/pak2.txt" --prefer-binary

# --- Bloc PAK3 : d’abord torch/vision/audio (depuis ton pak3 en gardant les index) ---
tmp_pak3="${workdir}/pak3.no_xformers.txt"
# copie pak3 en retirant uniquement les lignes xformers (on garde les index-url)
grep -viE '^[[:space:]]*xformers([[:space:]]|$)' "$workdir/pak3.txt" > "$tmp_pak3"
$pip_exe install -r "$tmp_pak3" --prefer-binary

# --- Puis xformers en wheel uniquement, sans deps (évite toute compilation) ---
# plage compatible avec torch 2.8/2.9 ; adapte si besoin
set +e
$pip_exe install --only-binary=:all: --no-deps "xformers>=0.0.31.post1,<0.0.33"
rc=$?
if [ $rc -ne 0 ]; then
  echo "[WARN] échec plage xformers, tentative fallback à 0.0.32.post1…"
  $pip_exe install --only-binary=:all: --no-deps xformers==0.0.32.post1
fi
set -e

# Reste des paquets (inchangé)
$pip_exe install -r "$workdir/pak4.txt" --prefer-binary
$pip_exe install -r "$workdir/pak5.txt" --prefer-binary
$pip_exe install -r "$workdir/pak6.txt" --prefer-binary
$pip_exe install -r "$workdir/pak7.txt" --prefer-binary
$pip_exe install -r "$workdir/pak8.txt" --prefer-binary

# ──────────────────────────────────────────────────────────────
# 4) Tweaks et requirements ComfyUI
# ──────────────────────────────────────────────────────────────
$pip_exe install --upgrade albucore albumentations --prefer-binary

latest_tag=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags \
  | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
$pip_exe install -r "https://github.com/comfyanonymous/ComfyUI/raw/refs/tags/${latest_tag}/requirements.txt" --prefer-binary

$pip_exe install -r "$workdir/pakY.txt" --prefer-binary
$pip_exe install -r "$workdir/pakZ.txt" --prefer-binary

# Sanity check versions clés
"$workdir/python_standalone/python.exe" - <<'PY'
import sys
def show(mod):
    try:
        m = __import__(mod)
        print(f"{mod.upper():9s}", getattr(m, "__version__", "?"))
    except Exception as e:
        print(f"{mod.upper():9s} IMPORT FAIL -> {e}", file=sys.stderr); sys.exit(1)
for m in ("torch","torchvision","torchaudio","xformers"):
    show(m)
PY

$pip_exe list

# ──────────────────────────────────────────────────────────────
# 5) Outils externes (ninja, aria2, ffmpeg)
# ──────────────────────────────────────────────────────────────
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip -o ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir/python_standalone/Scripts"
rm ninja-win.zip

curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip -o aria2.zip
unzip -q aria2.zip -d "$workdir/aria2"
mv "$workdir/aria2"/*/aria2c.exe "$workdir/python_standalone/Scripts/" || true
rm aria2.zip

curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/7.1.1/ffmpeg-7.1.1-full_build.zip -o ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir/ffmpeg"
mv "$workdir/ffmpeg"/*/bin/ffmpeg.exe "$workdir/python_standalone/Scripts/" || true
rm ffmpeg.zip

du -hd1
