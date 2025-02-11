@echo off
setlocal

@REM To set proxy, edit and uncomment the two lines below (remove 'rem ' in the beginning of line).
rem set HTTP_PROXY=http://localhost:1080
rem set HTTPS_PROXY=http://localhost:1080

@REM To enable HuggingFace Hub's experimental high-speed file transfer, uncomment the line below.
@REM https://huggingface.co/docs/huggingface_hub/hf_transfer
rem set HF_HUB_ENABLE_HF_TRANSFER=1

@REM To set mirror site for HuggingFace Hub, uncomment and edit the line below.
rem set HF_ENDPOINT=https://hf-mirror.com

@REM To set mirror site for PIP, uncomment and edit the line below.
rem set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

@REM Download and copy u2net.onnx to user's home path, if needed.
IF NOT EXIST "%USERPROFILE%\.u2net\u2net.onnx" (
    IF NOT EXIST ".\extras\u2net.onnx" (
        echo Downloading u2net.onnx...

        .\python_standalone\Scripts\aria2c.exe --allow-overwrite=false ^
        --auto-file-renaming=false --continue=true ^
        -d ".\extras" -o "u2net.tmp" ^
        "https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx"

        IF %errorlevel% == 0 (
            ren ".\extras\u2net.tmp" "u2net.onnx"
        )
    )
    IF EXIST ".\extras\u2net.onnx" (
        mkdir "%USERPROFILE%\.u2net" 2>nul
        copy ".\extras\u2net.onnx" "%USERPROFILE%\.u2net\u2net.onnx"
    )
)

set HF_HUB_CACHE=%~dp0\HuggingFaceHub

set PATH=%PATH%;%~dp0\python_standalone\Scripts

@REM Reinstall hf-hub
if not exist ".\python_standalone\Scripts\.hf-reinstalled" (
    echo Reinstalling huggingface-hub...
    .\python_standalone\python.exe -s -m pip uninstall --yes huggingface-hub
    .\python_standalone\python.exe -s -m pip install "huggingface-hub[hf-transfer]"
    if %errorlevel% equ 0 (
        echo.> ".\python_standalone\Scripts\.hf-reinstalled"
    )
)

@REM Reinstall InsightFace


echo The script has finished executing.

endlocal
pause
