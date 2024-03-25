#!/bin/bash
set -eu

git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules \
    https://github.com/MrForExample/ComfyUI-3D-Pack.git

python -m pip wheel --no-cache-dir \
    ./ComfyUI-3D-Pack/_Pre_Builds/_Wheels_win_py311_cu121/*.whl \
        -w ./temp_wheel_dir

# Put everything together to resolve compatible versions
python -m pip wheel --no-cache-dir \
    xformers torchvision torchaudio \
    -r requirements.txt \
    onnxruntime-gpu \
        --index-url https://download.pytorch.org/whl/cu121 \
        --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/ \
        --extra-index-url https://pypi.org/simple \
        -w ./temp_wheel_dir

mv temp_wheel_dir cp311_cu121_deps

tar cf cp311_cu121_deps.tar cp311_cu121_deps

ls -lahF cp311_cu121_deps
