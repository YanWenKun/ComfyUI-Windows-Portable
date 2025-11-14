@echo on
setlocal

@REM If you don't want the browser to open automatically, add [ --disable-auto-launch ] after the last argument.
set "EXTRA_ARGS=--disable-auto-launch"

@REM To set proxy, edit and uncomment the two lines below (remove 'rem ' in the beginning of line).
rem set HTTP_PROXY=http://localhost:1080
rem set HTTPS_PROXY=http://localhost:1080

@REM To set mirror site for PIP & HuggingFace Hub, uncomment and edit the two lines below.
rem set PIP_INDEX_URL=https://mirrors.cernet.edu.cn/pypi/web/simple
rem set HF_ENDPOINT=https://hf-mirror.com

@REM To set HuggingFace Access Token, uncomment and edit the line below.
@REM https://huggingface.co/settings/tokens
rem set HF_TOKEN=

@REM ==========================================================================
@REM The following content generally does not require user modification.

@REM This command redirects HuggingFace-Hub to download model files in this folder.
set HF_HUB_CACHE=%~dp0\HuggingFaceHub

@REM This command redirects Pytorch Hub to download model files in this folder.
set TORCH_HOME=%~dp0\TorchHome

@REM This command will set PATH environment variable.
set PATH=%PATH%;%~dp0\MinGit\cmd;%~dp0\python_standalone\Scripts

@REM This command will let the .pyc files to be stored in one place.
set PYTHONPYCACHEPREFIX=%~dp0\pycache

.\python_standalone\python.exe -s ComfyUI\main.py --windows-standalone-build %EXTRA_ARGS%

endlocal
pause
