import os
import sys
import json
import subprocess
from gooey import Gooey, GooeyParser

# Code mostly written by DeepSeek, Gemini and ChatGPT

# Configuration file path
CONFIG_FILE = "launcher_config.json"

def save_config(args):
    """Save user configuration to a file"""
    config = {
        "http_proxy": args.http_proxy,
        "https_proxy": args.https_proxy,
        "hf_token": args.hf_token,
        "pip_index_url": args.pip_index_url,
        "hf_endpoint": args.hf_endpoint,
        "disable_auto_launch": args.disable_auto_launch,
        "fast_mode": args.fast_mode,
        "disable_smart_memory": args.disable_smart_memory,
        "lowvram": args.lowvram,
        "use_pytorch_cross_attention": args.use_pytorch_cross_attention,
        "extra_args": args.extra_args,
    }
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f)

def load_config():
    """Load user configuration from a file"""
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    return None

@Gooey(program_name="ComfyUI Launcher for XPU", 
       language='english',
       tabbed_groups=True)  # Enable tabbed layout

def main():
    # Load the last configuration
    saved_config = load_config()

    parser = GooeyParser(description="Customize settings before launching ComfyUI")
    
    # Environment Variable Configuration Tab
    env_tab = parser.add_argument_group('Environment Variable Configuration', 
                                       'Configure the environment variables for ComfyUI',
                                       gooey_options={'show_border': True})
    env_tab.add_argument('--http_proxy', 
                         metavar='HTTP Proxy', 
                         help='Example: http://localhost:1080, leave empty to disable',
                         default=saved_config.get("http_proxy", "") if saved_config else '')
    env_tab.add_argument('--https_proxy', 
                         metavar='HTTPS Proxy', 
                         help='Example: http://localhost:1080, leave empty to disable',
                         default=saved_config.get("https_proxy", "") if saved_config else '')
    env_tab.add_argument('--hf_token', 
                         metavar='HuggingFace Token', 
                         help='Format: hf_xxxxxx, leave empty if not available (Invalid token may cause download issues)',
                         default=saved_config.get("hf_token", "") if saved_config else '')
    
    # PIP Mirror Settings (Text Box)
    env_tab.add_argument('--pip_index_url', 
                         metavar='PIP Mirror URL', 
                         help='If left empty, the default is https://pypi.org/simple',
                         default=saved_config.get("pip_index_url", "") if saved_config else '')
    
    # HuggingFace Mirror Settings (Text Box)
    env_tab.add_argument('--hf_endpoint', 
                         metavar='HuggingFace Mirror URL', 
                         help='If left empty, the default is https://huggingface.co/',
                         default=saved_config.get("hf_endpoint", "") if saved_config else '')
    
    # Launch Parameter Configuration Tab
    launch_tab = parser.add_argument_group('Launch Parameter Configuration', 
                                           'Configure the launch parameters for ComfyUI',
                                           gooey_options={'show_border': True})
    launch_tab.add_argument('--disable_auto_launch', 
                            metavar='Disable Auto Browser Launch', 
                            action='store_true',
                            help='Prevent automatic browser launch on startup (--disable-auto-launch)',
                            default=saved_config.get("disable_auto_launch", False) if saved_config else False)
    launch_tab.add_argument('--fast_mode', 
                            metavar='High-Performance Mode', 
                            action='store_true',
                            help='Enable experimental high-performance mode for RTX 40 series (Ada) and later GPUs (--fast)',
                            default=saved_config.get("fast_mode", False) if saved_config else False)
    launch_tab.add_argument('--disable_smart_memory', 
                            metavar='Disable Smart Memory Management', 
                            action='store_true',
                            help='Offloads models from VRAM to RAM more frequently to mitigate VRAM leaks (--disable-smart-memory)',
                            default=saved_config.get("disable_smart_memory", False) if saved_config else False)
    launch_tab.add_argument('--lowvram', 
                            metavar='Low VRAM Mode', 
                            action='store_true',
                            help='More conservative VRAM usage, reduce speed, recommended only when VRAM is insufficient (--lowvram)',
                            default=saved_config.get("lowvram", False) if saved_config else False)
    launch_tab.add_argument('--use-pytorch-cross-attention', 
                            metavar='Disable xFormers', 
                            action='store_true',
                            help='This will enable the native PyTorch cross-attention. Not recommended if you plan to generate videos (--use-pytorch-cross-attention)',
                            default=saved_config.get("use_pytorch_cross_attention", False) if saved_config else False)
    launch_tab.add_argument('--extra_args', 
                            metavar='Additional Launch Arguments', 
                            help='Refer to ComfyUI’s cli_args.py, add extra launch parameters (e.g., " --cpu" for CPU-only mode), mind spaces',
                            default=saved_config.get("extra_args", "") if saved_config else '')
    
    args = parser.parse_args()

    # Save the current configuration
    save_config(args)

    # Set environment variables
    if args.http_proxy:
        os.environ['HTTP_PROXY'] = args.http_proxy
    if args.https_proxy:
        os.environ['HTTPS_PROXY'] = args.https_proxy
    if args.hf_token:
        os.environ['HF_TOKEN'] = args.hf_token

    # Set PIP mirror
    os.environ['PIP_INDEX_URL'] = args.pip_index_url

    # Set HuggingFace mirror
    os.environ['HF_ENDPOINT'] = args.hf_endpoint

    # Set HuggingFace cache directory
    os.environ['HF_HUB_CACHE'] = os.path.join(os.getcwd(), 'HuggingFaceHub')
    os.environ['TORCH_HOME'] = os.path.join(os.getcwd(), 'TorchHome')
    os.environ['PYTHONPYCACHEPREFIX'] = os.path.join(os.getcwd(), 'pycache') # Duplicate, but keeping this line for code readability.

    # Configure PATH environment variable
    os.environ['PATH'] += os.pathsep + os.path.join(os.getcwd(), 'MinGit', 'cmd')
    os.environ['PATH'] += os.pathsep + os.path.join(os.getcwd(), 'python_standalone', 'Scripts')

    # Construct the launch command
    command = [
        sys.executable,  # Use the current Python interpreter
        '-s',
        os.path.join(os.getcwd(), 'ComfyUI', 'main.py'),
        '--windows-standalone-build'
    ]

    if args.disable_auto_launch:
        command.append('--disable-auto-launch')
    if args.fast_mode:
        command.append('--fast')
    if args.disable_smart_memory:
        command.append('--disable-smart-memory')
    if args.lowvram:
        command.append('--lowvram')
    if args.use_pytorch_cross_attention:
        command.append('--use-pytorch-cross-attention')

    # Add user-defined extra parameters
    if args.extra_args:
        import shlex
        extra_args = shlex.split(args.extra_args)
        command.extend(extra_args)

    # Launch ComfyUI
    subprocess.run(command)

if __name__ == '__main__':
    main()
