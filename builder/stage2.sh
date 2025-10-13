#!/bin/bash
set -eux

# ──────────────────────────────────────────────────────────────────────────────
# 1️⃣ Préparation
# ──────────────────────────────────────────────────────────────────────────────
git config --global core.autocrlf true && git config --global core.longpaths true
workdir=$(pwd)
gcs='git -c core.longpaths=true clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

export PYTHONPYCACHEPREFIX="$workdir/pycache2"
export PATH="$PATH:$workdir/ComfyUI_Windows_portable/python_standalone/Scripts"
export GIT_ASKPASS=echo  # évite les invites d'identification GitHub

ls -lahF

# ──────────────────────────────────────────────────────────────────────────────
# 2️⃣ Prépare les dossiers de cache
# ──────────────────────────────────────────────────────────────────────────────
export HF_HUB_CACHE="$workdir/ComfyUI_Windows_portable/HuggingFaceHub"
export TORCH_HOME="$workdir/ComfyUI_Windows_portable/TorchHome"
mkdir -p "${HF_HUB_CACHE}" "${TORCH_HOME}"

# ──────────────────────────────────────────────────────────────────────────────
# 3️⃣ Déplace le Python standalone dans le package final
# ──────────────────────────────────────────────────────────────────────────────
mv "$workdir/python_standalone" "$workdir/ComfyUI_Windows_portable/python_standalone"

# ──────────────────────────────────────────────────────────────────────────────
# 4️⃣ Ajoute MinGit portable
# ──────────────────────────────────────────────────────────────────────────────
curl -sSL https://github.com/git-for-windows/git/releases/download/v2.50.1.windows.1/MinGit-2.50.1-64-bit.zip -o MinGit.zip
unzip -q MinGit.zip -d "$workdir/ComfyUI_Windows_portable/MinGit"
rm MinGit.zip

# ──────────────────────────────────────────────────────────────────────────────
# 5️⃣ Clone du cœur ComfyUI
# ──────────────────────────────────────────────────────────────────────────────
git clone https://github.com/comfyanonymous/ComfyUI.git "$workdir/ComfyUI_Windows_portable/ComfyUI"
cd "$workdir/ComfyUI_Windows_portable/ComfyUI"
git fetch --tags --force
latest_app_tag=$(git tag -l 'v*' | sort -V | tail -1)
git reset --hard "$latest_app_tag"

# Vide le dossier models (restauré plus tard)
rm -vrf models
mkdir models

# ──────────────────────────────────────────────────────────────────────────────
# 6️⃣ Copie courte pour corriger les problèmes de chemins longs
# ──────────────────────────────────────────────────────────────────────────────
run_tmp="${RUNNER_TEMP:-/d/a}"

if command -v cygpath >/dev/null 2>&1; then
  short_root="$(cygpath -u "$run_tmp")/cwp_phys"
else
  short_root="$run_tmp/cwp_phys"
fi

mkdir -p "$short_root"
rm -rf "$short_root/ComfyUI_Windows_portable" || true
cp -r "$workdir/ComfyUI_Windows_portable" "$short_root/"
port_root="$short_root/ComfyUI_Windows_portable"

# ──────────────────────────────────────────────────────────────────────────────
# 7️⃣ Custom Nodes
# ──────────────────────────────────────────────────────────────────────────────
cd "$port_root/ComfyUI/custom_nodes"

# Workspace
$gcs https://github.com/Comfy-Org/ComfyUI-Manager.git
$gcs https://github.com/crystian/ComfyUI-Crystools.git
$gcs https://github.com/pydn/ComfyUI-to-Python-Extension.git

# General
$gcs https://github.com/akatz-ai/ComfyUI-AKatz-Nodes.git
$gcs https://github.com/Amorano/Jovimetrix.git
$gcs https://github.com/bash-j/mikey_nodes.git
$gcs https://github.com/chrisgoringe/cg-use-everywhere.git
$gcs https://github.com/jags111/efficiency-nodes-comfyui.git
$gcs https://github.com/kijai/ComfyUI-KJNodes.git
$gcs https://github.com/mirabarukaso/ComfyUI_Mira.git
$gcs https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
$gcs https://github.com/rgthree/rgthree-comfy.git
$gcs https://github.com/shiimizu/ComfyUI_smZNodes.git
$gcs https://github.com/ltdrdata/was-node-suite-comfyui.git
$gcs https://github.com/yolain/ComfyUI-Easy-Use.git

# Control
$gcs https://github.com/chflame163/ComfyUI_LayerStyle.git
$gcs https://github.com/Fannovel16/comfyui_controlnet_aux.git
$gcs https://github.com/florestefano1975/comfyui-portrait-master.git
$gcs https://codeberg.org/Gourieff/comfyui-reactor-node.git
$gcs https://github.com/huchenlei/ComfyUI-IC-Light-Native.git
$gcs https://github.com/huchenlei/ComfyUI-layerdiffuse.git
$gcs https://github.com/Jonseed/ComfyUI-Detail-Daemon.git
$gcs https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git
$gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
$gcs https://github.com/mcmonkeyprojects/sd-dynamic-thresholding.git
$gcs https://github.com/twri/sdxl_prompt_styler.git

# Video
$gcs https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git
$gcs https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
$gcs https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
$gcs https://github.com/melMass/comfy_mtb.git

# More
$gcs https://github.com/akatz-ai/ComfyUI-DepthCrafter-Nodes.git
$gcs https://github.com/city96/ComfyUI-GGUF.git
$gcs https://github.com/digitaljohn/comfyui-propost.git
$gcs https://github.com/kijai/ComfyUI-DepthAnythingV2.git
$gcs https://github.com/kijai/ComfyUI-Florence2.git
$gcs https://github.com/neverbiasu/ComfyUI-SAM2.git
$gcs https://github.com/pythongosssss/ComfyUI-WD14-Tagger.git
$gcs https://github.com/SLAPaper/ComfyUI-Image-Selector.git
$gcs https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
$gcs https://github.com/nunchaku-tech/ComfyUI-nunchaku.git
$gcs https://github.com/balazik/ComfyUI-PuLID-Flux.git        # PulidFlux suite (ModelLoader, EvaClip, InsightFace, ApplyPulidFlux)
$gcs https://github.com/jamesWalker55/comfyui-various.git      # JW nodes (ex: JWImageResizeByLongerSide)
$gcs https://github.com/Causan/ComfyMath.git                   # CM_ math and logic nodes (IntToFloat, BoolOps, etc.)

# Legacy (dépréciés)
$gcs https://github.com/cubiq/ComfyUI_essentials.git
$gcs https://github.com/cubiq/ComfyUI_InstantID.git
$gcs https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
$gcs https://github.com/cubiq/PuLID_ComfyUI.git
$gcs https://github.com/cubiq/ComfyUI_FaceAnalysis.git
$gcs https://github.com/CY-CHENYUE/ComfyUI-Janus-Pro.git
$gcs https://github.com/FizzleDorf/ComfyUI_FizzNodes.git
$gcs https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

# ──────────────────────────────────────────────────────────────────────────────
# 8️⃣ Restaure dans le dossier principal
# ──────────────────────────────────────────────────────────────────────────────
rm -rf "$workdir/ComfyUI_Windows_portable"
cp -r "$port_root" "$workdir/"
rm -rf "$(dirname "$port_root")"

# ──────────────────────────────────────────────────────────────────────────────
# 9️⃣ Copie des fichiers de démarrage / scripts
# ──────────────────────────────────────────────────────────────────────────────
cp -rf "$workdir/attachments/." "$workdir/ComfyUI_Windows_portable/"
du -hd2 "$workdir/ComfyUI_Windows_portable"

# ──────────────────────────────────────────────────────────────────────────────
# 🔟 Téléchargements de modèles
# ──────────────────────────────────────────────────────────────────────────────
cd "$workdir"
$gcs https://github.com/madebyollin/taesd.git
mkdir -p "$workdir/ComfyUI_Windows_portable/ComfyUI/models/vae_approx"
cp taesd/*_decoder.pth "$workdir/ComfyUI_Windows_portable/ComfyUI/models/vae_approx/"
rm -rf taesd

# AnimateDiff-Evolved : motion model par défaut
ad_file="mm_sd_v14.ckpt"
ad_url="https://huggingface.co/guoyww/animatediff/resolve/main/models/motion_module/mm_sd_v14.ckpt"
ad_dir_node="$workdir/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-AnimateDiff-Evolved/models"
ad_dir_global="$workdir/ComfyUI_Windows_portable/ComfyUI/models/animatediff_models"
mkdir -p "$ad_dir_node" "$ad_dir_global"

echo "[AnimateDiff] Téléchargement du motion model: $ad_file"
curl -L --fail --retry 3 --retry-all-errors --connect-timeout 20 -o "$ad_dir_node/$ad_file" "$ad_url" || true
if [ -f "$ad_dir_node/$ad_file" ]; then
  cp -f "$ad_dir_node/$ad_file" "$ad_dir_global/$ad_file" || true
else
  echo "[AnimateDiff] ATTENTION: téléchargement du motion model non effectué (réseau ?)."
fi

# ReActor models
cd "$workdir/ComfyUI_Windows_portable/ComfyUI/models"
curl -sSL https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth --create-dirs -o facerestore_models/codeformer-v0.1.0.pth
curl -sSL https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth   --create-dirs -o facerestore_models/GFPGANv1.4.pth
curl -sSL https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128_fp16.onnx --create-dirs -o insightface/inswapper_128_fp16.onnx

# Impact-Pack / Subpack
cd "$workdir/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Impact-Pack"
"$workdir/ComfyUI_Windows_portable/python_standalone/python.exe" -s -B install.py
cd "$workdir/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Impact-Subpack"
"$workdir/ComfyUI_Windows_portable/python_standalone/python.exe" -s -B install.py

# ──────────────────────────────────────────────────────────────────────────────
# 11️⃣ Test CPU
# ──────────────────────────────────────────────────────────────────────────────
cd "$workdir/ComfyUI_Windows_portable"
./python_standalone/python.exe -s -B ComfyUI/main.py --quick-test-for-ci --cpu

# ──────────────────────────────────────────────────────────────────────────────
# 12️⃣ Nettoyage final
# ──────────────────────────────────────────────────────────────────────────────
rm -vf "$workdir/ComfyUI_Windows_portable/"*.log
rm -vf "$workdir/ComfyUI_Windows_portable/ComfyUI/user/"*.log
rm -vrf "$workdir/ComfyUI_Windows_portable/ComfyUI/user/default/ComfyUI-Manager"

cd "$workdir/ComfyUI_Windows_portable/ComfyUI/custom_nodes"
rm -vf ./ComfyUI-Custom-Scripts/pysssss.json
rm -vf ./ComfyUI-Easy-Use/config.yaml
rm -vf ./ComfyUI-Impact-Pack/impact-pack.ini
rm -vf ./Jovimetrix/web/config.json
rm -vf ./was-node-suite-comfyui/was_suite_config.json

cd "$workdir/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Manager"
git reset --hard
git clean -fxd

cd "$workdir"
