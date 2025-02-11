import argparse
import subprocess
import os
from gooey import Gooey

@Gooey(program_name="ComfyUI Launcher")
def main():
    parser = argparse.ArgumentParser(description="ComfyUI Launcher")

    # 添加参数
    parser.add_argument("--http-proxy", help="HTTP 代理地址", default="http://localhost:1080")
    parser.add_argument("--https-proxy", help="HTTPS 代理地址", default="http://localhost:1080")
    parser.add_argument("--pip-mirror", help="PIP 镜像地址", default="https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple")
    parser.add_argument("--hf-mirror", help="Hugging Face 镜像地址", default="https://hf-mirror.com")
    parser.add_argument("--hf-token", help="Hugging Face Token", widget="PasswordField")  # 密码字段

    args = parser.parse_args()

    # 构建命令
    command = [
        ".\\python_standalone\\python.exe",
        "-s",
        "ComfyUI\\main.py",
        "--windows-standalone-build"
    ]

    # 设置环境变量
    env = os.environ.copy()
    if args.http_proxy:
        env["HTTP_PROXY"] = args.http_proxy
    if args.https_proxy:
        env["HTTPS_PROXY"] = args.https_proxy
    if args.pip_mirror:
        env["PIP_INDEX_URL"] = args.pip_mirror
    if args.hf_mirror:
        env["HF_ENDPOINT"] = args.hf_mirror
    if args.hf_token:
        env["HF_TOKEN"] = args.hf_token

    env["HF_HUB_CACHE"] = os.path.join(os.path.dirname(os.path.abspath(__file__)), "HuggingFaceHub")
    env["TORCH_HOME"] = os.path.join(os.path.dirname(os.path.abspath(__file__)), "TorchHome")
    env["PATH"] = env["PATH"] + ";" + os.path.join(os.path.dirname(os.path.abspath(__file__)), "python_standalone\\Scripts")
    env["PYTHONPYCACHEPREFIX"] = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pycache")

    # 运行 ComfyUI
    subprocess.Popen(command, env=env)

if __name__ == "__main__":
    main()
