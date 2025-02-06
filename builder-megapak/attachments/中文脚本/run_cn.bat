@REM 如需配置代理，取消注释（移除行首的 'rem '）并编辑下两行环境变量。
rem set HTTP_PROXY=http://localhost:1080
rem set HTTPS_PROXY=http://localhost:1080

@REM 如需配置 HuggingFace Access Token（访问令牌），取消注释并编辑。
@REM 管理令牌： https://huggingface.co/settings/tokens
rem set HF_TOKEN=

@REM 该环境变量配置 PIP 使用国内镜像站点。
set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

@REM 该环境变量配置 HuggingFace Hub 使用国内镜像站点。
set HF_ENDPOINT=https://hf-mirror.com

@REM 该环境变量指示 HuggingFace Hub 下载模型到"本目录\HuggingFaceHub"，而不是"用户\.cache"目录。
set HF_HUB_CACHE=%~dp0\HuggingFaceHub

@REM 该环境变量指示 Pytorch Hub 下载模型到"本目录\TorchHome"，而不是"用户\.cache"目录。
set TORCH_HOME=%~dp0\TorchHome

@REM 该命令配置 PATH 环境变量。
set PATH=%PATH%;%~dp0\python_standalone\Scripts

@REM 该环境变量使 .pyc 缓存文件集中保存在一个文件夹下，而不是随 .py 文件分布。
set PYTHONPYCACHEPREFIX=%~dp0\pycache

@REM 如不希望 ComfyUI 启动后自动打开浏览器，添加 --disable-auto-launch 到下行末尾（注意空格）。
@REM 如在用 40 系显卡，可添加 --fast 开启实验性高性能模式。
.\python_standalone\python.exe -s ComfyUI\main.py --windows-standalone-build

pause
