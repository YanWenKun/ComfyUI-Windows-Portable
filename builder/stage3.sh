#!/usr/bin/env bash
set -Eeuo pipefail

log()  { printf '\n\033[1;34m[stage3]\033[0m %s\n' "$*"; }
warn() { printf '\n\033[1;33m[warn]\033[0m %s\n' "$*"; }
die()  { printf '\n\033[1;31m[error]\033[0m %s\n' "$*"; exit 1; }

WORKDIR="$(pwd)"
PORTABLE_DIR="${WORKDIR}/ComfyUI_Windows_portable"
PY="${PORTABLE_DIR}/python_standalone/python.exe"

# 7-Zip (chemin Windows, fallback binaire '7z' dans le PATH)
SEVENZIP="${SEVENZIP:-C:/Program Files/7-Zip/7z.exe}"
if [[ ! -x "$SEVENZIP" ]]; then
  if command -v 7z >/dev/null 2>&1; then
    SEVENZIP="$(command -v 7z)"
  else
    die "7-Zip introuvable (ni '$SEVENZIP' ni '7z' dans le PATH)"
  fi
fi

# Taille de volume (GitHub limite ~2.15GB)
VOL_SIZE="${VOL_SIZE:-2140000000b}"
LEVEL="${LEVEL:-7}"               # -mx (0..9)
MAIN_FMT="${MAIN_FMT:-7z}"        # 7z par défaut pour meilleur ratio
MODELS_FMT="${MODELS_FMT:-zip}"   # zip pour compat universelle

log "Inventaire initial…"
ls -lahF
du -hd2 "${PORTABLE_DIR}" || true

# Détection suffixe CUDA
CUDA_TAG="$("$PY" - <<'PY'
import torch, sys
v = getattr(torch.version, "cuda", None) or ""
print(f"cu{v.replace('.', '')}" if v else "cpu")
PY
)"
[[ -n "$CUDA_TAG" ]] || CUDA_TAG="cuXX"

# Emplacements de sortie (fichiers définitifs)
OUT_MAIN="${WORKDIR}/ComfyUI_Windows_portable_${CUDA_TAG}.${MAIN_FMT}"
OUT_MODELS="${WORKDIR}/models.${MODELS_FMT}"

# 1) Séparer les modèles
log "Séparation des modèles…"
MODELS_DIR="${PORTABLE_DIR}/ComfyUI/models"
[[ -d "$MODELS_DIR" ]] || mkdir -p "$MODELS_DIR"
mkdir -p "${WORKDIR}/m_folder/ComfyUI_Windows_portable/ComfyUI"

if [[ -d "$MODELS_DIR" && "$(ls -A "$MODELS_DIR")" ]]; then
  mv "${MODELS_DIR}" "${WORKDIR}/m_folder/ComfyUI_Windows_portable/ComfyUI/" || die "mv models -> m_folder échoué"
  # Restaurer un dossier models vide côté repo (au cas où Git suit le répertoire)
  git -C "${PORTABLE_DIR}/ComfyUI" checkout -- models || true
  mkdir -p "${PORTABLE_DIR}/ComfyUI/models"
else
  warn "Pas de modèles à déplacer (dossier vide)."
fi

# 2) Compression du package principal (sans models)
log "Compression principal: ${OUT_MAIN} (format=${MAIN_FMT}, vol=${VOL_SIZE}, lvl=${LEVEL})"
"$SEVENZIP" a -t"${MAIN_FMT}" -mx="${LEVEL}" -m0=lzma2 -mfb=64 -md=128m -ms=on -mf=BCJ2 -v"${VOL_SIZE}" \
  "${OUT_MAIN}" "ComfyUI_Windows_portable" >/dev/null

# 3) Compression des modèles (dans m_folder)
if [[ -d "${WORKDIR}/m_folder/ComfyUI_Windows_portable/ComfyUI/models" ]]; then
  log "Compression modèles: ${OUT_MODELS} (format=${MODELS_FMT}, vol=${VOL_SIZE}, lvl=${LEVEL})"
  pushd "${WORKDIR}/m_folder" >/dev/null
  "$SEVENZIP" a -t"${MODELS_FMT}" -mx="${LEVEL}" -v"${VOL_SIZE}" \
    "${OUT_MODELS}" "ComfyUI_Windows_portable" >/dev/null
  popd >/dev/null
else
  warn "Dossier modèles absent dans m_folder — aucune archive modèles créée."
fi

# 4) Listing & tailles
log "Résultats:"
ls -lahF "${WORKDIR}" | sed -n '1,200p'
log "Terminé."
