@REM 如需配置代理，编辑下两行命令，并取消注释（移除行首的 'rem '）。
rem set HTTP_PROXY=http://localhost:1081
rem set HTTPS_PROXY=http://localhost:1081

@REM 如需配置 PIP 与 HuggingFace Hub 镜像，编辑下两行。
set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
set HF_ENDPOINT=https://hf-mirror.com

@REM 该命令启用 HF Hub 实验性高速传输，
@REM 如果下载遇到卡死问题，将该行删除。
@REM https://huggingface.co/docs/huggingface_hub/hf_transfer
set HF_HUB_ENABLE_HF_TRANSFER=1

@REM 依照下表，修改为你的 GPU 对应架构，以节约 JIT 编译 PyTorch C++ 扩展的时间：
@REM 'Pascal', '6.0;6.1+PTX'
@REM 'Volta+Tegra', '7.2'
@REM 'Volta', '7.0+PTX'
@REM 'Turing', '7.5+PTX'
@REM 'Ampere+Tegra', '8.7'
@REM 'Ampere', '8.0;8.6+PTX'
@REM 'Ada', '8.9+PTX'
@REM 'Hopper', '9.0+PTX'
set TORCH_CUDA_ARCH_LIST=5.2+PTX;6.0;6.1+PTX;7.5;8.0;8.6;8.9+PTX

@REM 该行命令会配置 PATH 环境变量。
set PATH=%PATH%;%~dp0\python_embeded\Scripts

@REM 该行命令会使 .pyc 文件集中保存在一处。
set PYTHONPYCACHEPREFIX=%~dp0\pycache

@REM 该命令会复制 u2net.onnx 到用户主目录下，以免启动时还需下载。
IF NOT EXIST "%USERPROFILE%\.u2net\u2net.onnx" (
    IF EXIST ".\extras\u2net.onnx" (
        mkdir "%USERPROFILE%\.u2net" 2>nul
        copy ".\extras\u2net.onnx" "%USERPROFILE%\.u2net\u2net.onnx"
    )
)

@REM 如果不想要 ComfyUI 启动后自动打开浏览器，添加" --disable-auto-launch"（不含引号）到下行末尾。
@REM 如果用 40 系显卡，可添加" --fast"
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build

pause
