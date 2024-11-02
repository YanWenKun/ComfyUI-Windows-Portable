@REM 依照下表，修改为你的 GPU 对应架构，以节约运行时编译 PyTorch C++ 扩展的时间：
@REM 'Pascal', '6.0;6.1+PTX'
@REM 'Volta+Tegra', '7.2'
@REM 'Volta', '7.0+PTX'
@REM 'Turing', '7.5+PTX'
@REM 'Ampere+Tegra', '8.7'
@REM 'Ampere', '8.0;8.6+PTX'
@REM 'Ada', '8.9+PTX'
@REM 'Hopper', '9.0+PTX'
set TORCH_CUDA_ARCH_LIST=5.2+PTX;6.0;6.1+PTX;7.5;8.0;8.6;8.9+PTX

@REM 如需配置代理，取消注释（移除行首的 'rem '）并编辑下两行环境变量。
rem set HTTP_PROXY=http://localhost:1081
rem set HTTPS_PROXY=http://localhost:1081

@REM 如需配置 HuggingFace Access Token（访问令牌），取消注释并编辑。
@REM 管理令牌： https://huggingface.co/settings/tokens
rem set HF_TOKEN=

@REM 该环境变量启用 HF Hub 实验性高速传输，
@REM 如果下载遇到卡死问题，将该行删除。
@REM https://huggingface.co/docs/huggingface_hub/hf_transfer
set HF_HUB_ENABLE_HF_TRANSFER=1

@REM 该环境变量配置 PIP 使用国内镜像站点。
set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

@REM 该环境变量配置 HuggingFace Hub 使用国内镜像站点。
set HF_ENDPOINT=https://hf-mirror.com

@REM 该环境变量指示 HuggingFace Hub 下载模型到"本目录\HuggingFaceHub"，而不是"用户\.cache"目录。
set HF_HUB_CACHE=%~dp0\HuggingFaceHub

@REM 该命令配置 PATH 环境变量。
set PATH=%PATH%;%~dp0\python_embeded\Scripts

@REM 该环境变量使 .pyc 缓存文件集中保存在一个文件夹下，而不是随 .py 文件分布。
set PYTHONPYCACHEPREFIX=%~dp0\pycache

@REM 该命令会复制 u2net.onnx 到用户主目录下，以免启动时还需下载。
IF NOT EXIST "%USERPROFILE%\.u2net\u2net.onnx" (
    IF EXIST ".\extras\u2net.onnx" (
        mkdir "%USERPROFILE%\.u2net" 2>nul
        copy ".\extras\u2net.onnx" "%USERPROFILE%\.u2net\u2net.onnx"
    )
)

@REM 如不希望 ComfyUI 启动后自动打开浏览器，添加 --disable-auto-launch 到下行末尾（注意空格）。
@REM 如在用 40 系显卡，可添加 --fast 开启实验性高性能模式。
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build

pause
