@REM To set proxy, edit and uncomment the two lines below (remove 'rem ' in the beginning of line).
@REM 如需配置代理，编辑下两行命令，并取消注释（移除行首的 'rem '）。
rem set HTTP_PROXY=http://localhost:1081
rem set HTTPS_PROXY=http://localhost:1081

@REM This command will set PATH environment variable.
@REM 该行命令会配置 PATH 环境变量。
set PATH=%PATH%;%~dp0\python_embeded\Scripts\

@REM This command will let the .pyc files to be stored in one place.
@REM 该行命令会使 .pyc 文件集中保存在一处。
set PYTHONPYCACHEPREFIX=.\pycache

@REM If you don't want the browser to open automatically,
@REM add " --disable-auto-launch" (without quotation marks) to the end of the line below.
@REM 如果不想要 ComfyUI 启动后自动打开浏览器，添加" --disable-auto-launch"（不含引号）到下行末尾。
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build

pause