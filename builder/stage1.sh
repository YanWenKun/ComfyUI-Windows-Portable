
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

# 1) Python standalone (3.12.x comme avant)
curl -sSL \
  https://github.com/astral-sh/python-build-standalone/releases/download/20250814/cpython-3.12.11+20250814-x86_64-pc-windows-msvc-install_only.tar.gz \
  -o python.tar.gz
tar -zxf python.tar.gz
mv python python_standalone

# 2) pip de base
$pip_exe install --upgrade pip wheel setuptools --prefer-binary

# 3) Installation par blocs exactement comme avant
$pip_exe install -r "$workdir/pak2.txt" --prefer-binary
$pip_exe install -r "$workdir/pak3.txt" --prefer-binary
$pip_exe install -r "$workdir/pak4.txt" --prefer-binary

# --- Patch pak5: enlever 'gifski' (n'existe pas sur PyPI) et ajouter 'pygifski' ---
tmp_pak5="$workdir/pak5.effective.txt"
# retire la ligne gifski (peu importe la casse / espaces)
grep -viE '^[[:space:]]*gifski[[:space:]]*$' "$workdir/pak5.txt" > "$tmp_pak5"
# ajoute pygifski (utile si un node importe la lib Python)
echo "pygifski" >> "$tmp_pak5"

$pip_exe install -r "$tmp_pak5" --prefer-binary

# suite des blocs inchangée
$pip_exe install -r "$workdir/pak6.txt" --prefer-binary
$pip_exe install -r "$workdir/pak7.txt" --prefer-binary
$pip_exe install -r "$workdir/pak8.txt" --prefer-binary

# Tweaks identiques
$pip_exe install --upgrade albucore albumentations --prefer-binary

# comfyui requirements selon le dernier tag
latest_tag=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
$pip_exe install -r "https://github.com/comfyanonymous/ComfyUI/raw/refs/tags/${latest_tag}/requirements.txt" --prefer-binary

$pip_exe install -r "$workdir/pakY.txt" --prefer-binary
$pip_exe install -r "$workdir/pakZ.txt" --prefer-binary

$pip_exe list

# Outils externes, inchangés
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip -o ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir/python_standalone/Scripts"
rm ninja-win.zip

curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip -o aria2.zip
unzip -q aria2.zip -d "$workdir/aria2"
mv "$workdir/aria2"/*/aria2c.exe "$workdir/python_standalone/Scripts/"
rm aria2.zip

curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/7.1.1/ffmpeg-7.1.1-full_build.zip -o ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir/ffmpeg"
mv "$workdir/ffmpeg"/*/bin/ffmpeg.exe "$workdir/python_standalone/Scripts/"
rm ffmpeg.zip

# (Optionnel) gifski CLI pour ceux qui shell-out sur l’exécutable
curl -sSL https://github.com/ImageOptim/gifski/releases/download/1.12.0/gifski-1.12.0-win64.zip -o gifski.zip || true
unzip -q -o gifski.zip -d "$workdir/gifski" || true
mv "$workdir/gifski"/*/gifski.exe "$workdir/python_standalone/Scripts/" 2>/dev/null || true
rm -f gifski.zip || true

du -hd1
