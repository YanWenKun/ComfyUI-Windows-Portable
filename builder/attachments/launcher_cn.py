import os
import sys
import json
import subprocess
from gooey import Gooey, GooeyParser

# 代码主要是 DeepSeek、Gemini、ChatGPT 写的

# 配置文件路径
CONFIG_FILE = "launcher_config.json"

def save_config(args):
    """保存用户配置到文件"""
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
        "use_sage_attention": args.use_sage_attention,
        "use_flash_attention": args.use_flash_attention,
        "extra_args": args.extra_args,
    }
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f)

def load_config():
    """从文件加载用户配置"""
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    return None

def create_channels_list():
    """让 ComfyUI-Manager 从国内镜像检查更新列表"""
    channels_list_path = os.path.join("ComfyUI", "user", "default", "ComfyUI-Manager", "channels.list")
    channels_list_content = """default::https://ghfast.top/https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main
recent::https://ghfast.top/https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/node_db/new
legacy::https://ghfast.top/https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/node_db/legacy
forked::https://ghfast.top/https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/node_db/forked
dev::https://ghfast.top/https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/node_db/dev
tutorial::https://ghfast.top/https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/node_db/tutorial
"""

    # 如果文件不存在，则创建并写入内容
    if not os.path.exists(channels_list_path):
        os.makedirs(os.path.dirname(channels_list_path), exist_ok=True)
        with open(channels_list_path, "w", encoding="utf-8") as f:
            f.write(channels_list_content)
        print(f"已创建文件: {channels_list_path}")
    else:
        print(f"文件已存在: {channels_list_path}")

def create_config_ini():
    """让 ComfyUI-Manager 从国内镜像检查更新列表"""
    config_ini_path = os.path.join("ComfyUI", "user", "default", "ComfyUI-Manager", "config.ini")
    config_ini_content = """[default]
channel_url = https://ghfast.top/https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main
"""

    # 如果文件不存在，则创建并写入内容
    if not os.path.exists(config_ini_path):
        os.makedirs(os.path.dirname(config_ini_path), exist_ok=True)
        with open(config_ini_path, "w", encoding="utf-8") as f:
            f.write(config_ini_content)
        print(f"已创建文件: {config_ini_path}")
    else:
        print(f"文件已存在: {config_ini_path}")

@Gooey(program_name="ComfyUI 启动器", 
       language='chinese',
       tabbed_groups=True)  # 启用分 Tab 布局
def main():
    # 加载上一次的配置
    saved_config = load_config()

    parser = GooeyParser(description="在启动 ComfyUI 前自定义设置")
    
    # 环境变量配置 Tab
    env_tab = parser.add_argument_group('环境变量配置', 
                                       '配置 ComfyUI 的环境变量',
                                       gooey_options={'show_border': True})
    env_tab.add_argument('--http_proxy', 
                         metavar='HTTP 代理', 
                         help='例如： http://localhost:1080 ， 留空则不启用',
                         default=saved_config.get("http_proxy", "") if saved_config else '')
    env_tab.add_argument('--https_proxy', 
                         metavar='HTTPS 代理', 
                         help='例如： http://localhost:1080 ， 留空则不启用',
                         default=saved_config.get("https_proxy", "") if saved_config else '')
    env_tab.add_argument('--hf_token', 
                         metavar='HuggingFace 令牌', 
                         help='形如 hf_xxxxxx ，如无则务必留空 （无效令牌会影响正常下载）',
                         default=saved_config.get("hf_token", "") if saved_config else '')
    
    # PIP 镜像设置（文本框）
    env_tab.add_argument('--pip_index_url', 
                         metavar='PIP 镜像地址', 
                         help='国内用户推荐 https://mirrors.cernet.edu.cn/pypi/web/simple',
                         default=saved_config.get("pip_index_url", "https://mirrors.cernet.edu.cn/pypi/web/simple") if saved_config else "https://mirrors.cernet.edu.cn/pypi/web/simple")
    
    # HuggingFace 镜像设置（文本框）
    env_tab.add_argument('--hf_endpoint', 
                         metavar='HuggingFace 镜像地址', 
                         help='国内用户推荐 https://hf-mirror.com',
                         default=saved_config.get("hf_endpoint", "https://hf-mirror.com") if saved_config else "https://hf-mirror.com")
    
    # 启动参数配置 Tab
    launch_tab = parser.add_argument_group('启动参数配置', 
                                           '配置 ComfyUI 的启动参数',
                                           gooey_options={'show_border': True})
    launch_tab.add_argument('--disable_auto_launch', 
                            metavar='不要启动浏览器', 
                            action='store_true',
                            help='禁止程序在启动后自动打开浏览器 (--disable-auto-launch)',
                            default=saved_config.get("disable_auto_launch", False) if saved_config else False)
    launch_tab.add_argument('--fast_mode', 
                            metavar='高性能模式', 
                            action='store_true',
                            help='启用实验性高性能模式，适用于 40 系 (Ada) 及后续显卡 (--fast)',
                            default=saved_config.get("fast_mode", False) if saved_config else False)
    launch_tab.add_argument('--disable_smart_memory', 
                            metavar='禁用智能内存管理', 
                            action='store_true',
                            help='更频繁地将显存中的模型卸载到内存中， 用于缓解显存泄露 (--disable-smart-memory)',
                            default=saved_config.get("disable_smart_memory", False) if saved_config else False)
    launch_tab.add_argument('--lowvram', 
                            metavar='低显存模式', 
                            action='store_true',
                            help='更“节约”地使用显存， 牺牲速度， 仅建议显存不足时开启 (--lowvram)',
                            default=saved_config.get("lowvram", False) if saved_config else False)
    launch_tab.add_argument('--extra_args', 
                            metavar='额外启动参数', 
                            help='参数列表在 ComfyUI 的 cli_args.py， 注意添加空格 （例如 " --cpu" 启用仅 CPU 模式）',
                            default=saved_config.get("extra_args", "") if saved_config else '')
    
    # 注意力实现配置 Tab
    attn_tab = parser.add_argument_group('注意力实现配置 ', 
                                           '各选项互斥，请勿多选，不选则默认使用 xFormers',
                                           gooey_options={'show_border': True})
    attn_tab.add_argument('--use-pytorch-cross-attention', 
                            metavar='禁用 xFormers/FlashAttention/SageAttention', 
                            action='store_true',
                            help='使用 PyTorch 原生交叉注意力实现， 图像生成更稳定（不是更好）。 不适合视频生成 (--use-pytorch-cross-attention)',
                            default=saved_config.get("use_pytorch_cross_attention", False) if saved_config else False)
    attn_tab.add_argument('--use-sage-attention',
                            metavar='使用 SageAttention',
                            action='store_true',
                            help='性能更佳， 但可能有兼容性问题 (--use-sage-attention)',
                            default=saved_config.get("use_sage_attention", False) if saved_config else False)
    attn_tab.add_argument('--use-flash-attention',
                            metavar='使用 FlashAttention',
                            action='store_true',
                            help='理论上与 xFormers 相当 (--use-flash-attention)',
                            default=saved_config.get("use_flash_attention", False) if saved_config else False)
    
    args = parser.parse_args()

    # 保存当前配置
    save_config(args)

    # 设置环境变量
    if args.http_proxy:
        os.environ['HTTP_PROXY'] = args.http_proxy
    if args.https_proxy:
        os.environ['HTTPS_PROXY'] = args.https_proxy
    if args.hf_token:
        os.environ['HF_TOKEN'] = args.hf_token

    # 设置 PIP 镜像
    os.environ['PIP_INDEX_URL'] = args.pip_index_url

    # 设置 HuggingFace 镜像
    os.environ['HF_ENDPOINT'] = args.hf_endpoint

    # 设置 HuggingFace 缓存目录
    os.environ['HF_HUB_CACHE'] = os.path.join(os.getcwd(), 'HuggingFaceHub')
    os.environ['TORCH_HOME'] = os.path.join(os.getcwd(), 'TorchHome')
    os.environ['PYTHONPYCACHEPREFIX'] = os.path.join(os.getcwd(), 'pycache') # 功能重复，但为方便理解代码，保留该行

    # 配置 PATH 环境变量
    os.environ['PATH'] += os.pathsep + os.path.join(os.getcwd(), 'MinGit', 'cmd')
    os.environ['PATH'] += os.pathsep + os.path.join(os.getcwd(), 'python_standalone', 'Scripts')

    # 配置 ComfyUI-Manager 使用国内镜像（仅限列表，无法影响下载）
    create_channels_list()
    create_config_ini()

    # 构建启动命令
    command = [
        sys.executable,  # 使用当前 Python 解释器
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
    if args.use_sage_attention:
        command.append('--use-sage-attention')
    if args.use_flash_attention:
        command.append('--use-flash-attention')

    # 添加用户自定义的额外参数
    if args.extra_args:
        # 使用 shlex.split 来正确处理带空格的参数
        import shlex
        extra_args = shlex.split(args.extra_args)  # 使用 shlex.split 解析参数
        command.extend(extra_args)

    # 启动 ComfyUI
    subprocess.run(command)

if __name__ == '__main__':
    main()
