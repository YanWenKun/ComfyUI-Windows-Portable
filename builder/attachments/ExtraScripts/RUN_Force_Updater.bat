setlocal
set PATH=%PATH%;%~dp0\MinGit\cmd;%~dp0\python_standalone\Scripts
set PYTHONPYCACHEPREFIX=%~dp0\pycache
.\python_standalone\python.exe -s force_updater.py
endlocal
