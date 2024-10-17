chcp 65001

@echo off

echo ################################################################################
echo "如果遇到 3D-Pack 疑难问题（执行工作流时 C++ 报错、CUDA 报错等，"
echo "尤其是 diff_gaussian_rasterization 抛出异常），可以尝试本脚本。"
echo "本脚本会从 GitHub 下载 3D-Pack 的若干依赖项，"
echo "并全部编译完后，再使用 wheel 文件进行覆盖安装。"
echo ################################################################################
echo "运行需要环境： C++ 编译套件 (VS 2022), CUDA 工具包, Git。"
echo "建议修改脚本中的 TORCH_CUDA_ARCH_LIST 以大幅节约编译时间。"
echo ################################################################################
echo "安装不会影响你的 Windows 系统，只影响 python_embeded 目录。"
echo "如在编译期间中断任务，不会影响 python_embeded 。"
echo "无论执行成功与否，临时文件均会被保留。"
echo ################################################################################
echo "按回车继续……"

pause

@echo on

@REM 如需配置代理，编辑下两行命令，并取消注释（移除行首的 'rem '）。
rem set HTTP_PROXY=http://localhost:1081
rem set HTTPS_PROXY=http://localhost:1081

@REM 配置 PIP 与 HuggingFace Hub 镜像
set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
set HF_ENDPOINT=https://hf-mirror.com

@REM 依照下表，修改为你的 GPU 对应架构，以节约编译时间：
@REM https://github.com/ashawkey/stable-dreamfusion/issues/360#issuecomment-2292510049
@REM https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
set TORCH_CUDA_ARCH_LIST=5.2+PTX;6.0;6.1+PTX;7.5;8.0;8.6;8.9+PTX

set CMAKE_ARGS=-DBUILD_opencv_world=ON -DWITH_CUDA=ON -DCUDA_FAST_MATH=ON -DWITH_CUBLAS=ON -DCUDA_ARCH_PTX=8.9 -DWITH_NVCUVID=ON

set PATH=%PATH%;%~dp0\python_embeded\Scripts

if not exist ".\tmp_build" mkdir tmp_build

git clone --depth=1 https://ghp.ci/https://github.com/MrForExample/Comfy3D_Pre_Builds.git ^
 .\tmp_build\Comfy3D_Pre_Builds

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 .\tmp_build\Comfy3D_Pre_Builds\_Libs\pointnet2_ops

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 .\tmp_build\Comfy3D_Pre_Builds\_Libs\simple-knn

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://ghp.ci/https://github.com/ashawkey/diff-gaussian-rasterization.git

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://ghp.ci/https://github.com/NVlabs/nvdiffrast.git

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://ghp.ci/https://github.com/facebookresearch/pytorch3d.git

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://ghp.ci/https://github.com/ashawkey/kiuikit.git

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://ghp.ci/https://github.com/rusty1s/pytorch_scatter.git

echo "编译完成，开始安装……"

del .\tmp_build\numpy-2*.whl

for %i in (.\tmp_build\*.whl) do .\python_embeded\python.exe -s -m pip install --force-reinstall "%i"
