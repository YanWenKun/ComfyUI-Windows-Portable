setlocal
set PYTHONPYCACHEPREFIX=%~dp0\pycache
.\python_standalone\python.exe -s launcher.py
endlocal
