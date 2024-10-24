@REM To set proxy, edit and uncomment the two lines below (remove 'rem ' in the beginning of line).
@REM 如需配置代理，编辑下两行命令，并取消注释（移除行首的 'rem '）。
rem set HTTP_PROXY=http://localhost:1081
rem set HTTPS_PROXY=http://localhost:1081

@REM To set mirror site for PIP & HuggingFace Hub, uncomment and edit the two lines below.
@REM 如需配置 PIP 与 HuggingFace Hub 镜像，取消注释并编辑下两行。
rem set PIP_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
rem set HF_ENDPOINT=https://hf-mirror.com

@REM In order to save your time on compiling PyTorch JIT CPP extensions, edit this line according to your GPU arch.
@REM 依照下表，修改为你的 GPU 对应架构，以节约 JIT 编译 PyTorch C++ 扩展的时间：
@REM Ref: https://github.com/ashawkey/stable-dreamfusion/issues/360#issuecomment-2292510049
set TORCH_CUDA_ARCH_LIST=5.2+PTX;6.0;6.1+PTX;7.5;8.0;8.6;8.9+PTX

@REM This command will set PATH environment variable.
@REM 该行命令会配置 PATH 环境变量。
set PATH=%PATH%;%~dp0\python_embeded\Scripts

@REM This command will let the .pyc files to be stored in one place.
@REM 该行命令会使 .pyc 文件集中保存在一处。
set PYTHONPYCACHEPREFIX=%~dp0\pycache

@REM If you don't want the browser to open automatically, add " --disable-auto-launch" (without quotation marks) to the end of the line below.
@REM 如果不想要 ComfyUI 启动后自动打开浏览器，添加" --disable-auto-launch"（不含引号）到下行末尾。
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build

pause
