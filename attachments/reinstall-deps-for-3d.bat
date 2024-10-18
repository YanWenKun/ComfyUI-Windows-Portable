@echo off
echo ################################################################################
echo In case you have trouble running 3D-Pack workflow, especially get error from
echo diff_gaussian_rasterization, or just unknown CUDA error:
echo This script is a backup resort, it will attempt to download and build several
echo dependencies for 3D-Pack from GitHub, and will perform an overwrite installation
echo after compiling all the wheel files.
echo It will install packages to local python_embeded folder,and will not affect
echo your Windows OS.
echo If the task is interrupted before the compilation is complete, it will not
echo affect the existing python_embeded.
echo Regardless of success or failure, the temporary files will not be deleted.
echo ################################################################################
echo Require environment: C++ Build Tools (Visual Studio 2022), CUDA Toolkit, Git.
echo Recommend to edit TORCH_CUDA_ARCH_LIST in this script to save build time.
echo ################################################################################
echo Press Enter to continue...

pause

@echo on

@REM In order to save your time on compiling, edit this line according to your GPU arch.
@REM Ref: https://github.com/ashawkey/stable-dreamfusion/issues/360#issuecomment-2292510049
@REM Ref: https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
set TORCH_CUDA_ARCH_LIST=5.2+PTX;6.0;6.1+PTX;7.5;8.0;8.6;8.9+PTX

set CMAKE_ARGS=-DBUILD_opencv_world=ON -DWITH_CUDA=ON -DCUDA_FAST_MATH=ON -DWITH_CUBLAS=ON -DWITH_NVCUVID=ON

set PATH=%PATH%;%~dp0\python_embeded\Scripts

if not exist ".\tmp_build" mkdir tmp_build

.\python_embeded\python.exe -s -m pip install numpy==1.26.4

git clone --depth=1 https://github.com/MrForExample/Comfy3D_Pre_Builds.git ^
 .\tmp_build\Comfy3D_Pre_Builds

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 .\tmp_build\Comfy3D_Pre_Builds\_Libs\pointnet2_ops

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 .\tmp_build\Comfy3D_Pre_Builds\_Libs\simple-knn

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://github.com/ashawkey/diff-gaussian-rasterization.git

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://github.com/ashawkey/kiuikit.git

.\python_embeded\python.exe -s -m pip wheel -w tmp_build ^
 git+https://github.com/NVlabs/nvdiffrast.git

echo Build complete, installing...

del .\tmp_build\numpy-2*.whl

for %i in (.\tmp_build\*.whl) do .\python_embeded\python.exe -s -m pip install --force-reinstall "%i"

.\python_embeded\python.exe -s -m pip install numpy==1.26.4
