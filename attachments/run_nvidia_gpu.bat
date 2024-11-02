@REM To set proxy, edit and uncomment the two lines below (remove 'rem ' in the beginning of line).
rem set HTTP_PROXY=http://localhost:1081
rem set HTTPS_PROXY=http://localhost:1081

@REM To set mirror site for PIP & HuggingFace Hub, uncomment and edit the two lines below.
rem set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
rem set HF_ENDPOINT=https://hf-mirror.com

@REM In order to save your time on compiling PyTorch JIT CPP extensions, edit this line according to your GPU arch.
@REM Ref: https://github.com/ashawkey/stable-dreamfusion/issues/360#issuecomment-2292510049
set TORCH_CUDA_ARCH_LIST=5.2+PTX;6.0;6.1+PTX;7.5;8.0;8.6;8.9+PTX

@REM This command enables experimental HF Hub high-speed file transfers.
@REM Remove this line if you encounter errors or freezing during the download.
@REM https://huggingface.co/docs/huggingface_hub/hf_transfer
set HF_HUB_ENABLE_HF_TRANSFER=1

@REM This command will set PATH environment variable.
set PATH=%PATH%;%~dp0\python_embeded\Scripts

@REM This command will let the .pyc files to be stored in one place.
set PYTHONPYCACHEPREFIX=%~dp0\pycache

@REM This command will copy u2net.onnx to user's home path, to skip download at first start.
IF NOT EXIST "%USERPROFILE%\.u2net\u2net.onnx" (
    IF EXIST ".\extras\u2net.onnx" (
        mkdir "%USERPROFILE%\.u2net" 2>nul
        copy ".\extras\u2net.onnx" "%USERPROFILE%\.u2net\u2net.onnx"
    )
)

@REM If you don't want the browser to open automatically, add " --disable-auto-launch" (without quotation marks) to the end of the line below.
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build

pause
