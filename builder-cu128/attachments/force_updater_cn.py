import os
import re
import sys
import git
from concurrent.futures import ThreadPoolExecutor
from gooey import Gooey, GooeyParser

@Gooey(
    program_name="ComfyUI 强制更新工具",  # 程序名称
    language='chinese',
    progress_regex=r"^进度: (\d+)/(\d+)$",  # 进度条正则表达式
    progress_expr="x[0] / x[1] * 100",  # 进度条显示格式
    disable_progress_bar_animation=True,  # 禁用进度条动画
    timing_options={
        'show_time_remaining': True,
    },
    clear_before_run=True,  # 运行前清空控制台
)
def main():
    # 创建 Gooey 参数解析器
    parser = GooeyParser(
        description="强制更新 ComfyUI 及其自定义节点，且将远程 GitHub 地址替换为国内镜像。\n\n"
                    "提示：强制更新仅处理 Git 仓库， 不处理 Python 依赖包，\n"
                    "后续可能需要在 Manager 中点击 Try Fix 修复个别节点。"
    )

    # 添加镜像地址参数
    parser.add_argument(
        'mirror_url',  # 参数名称
        metavar='镜像站点',  # 参数显示名称
        help='用于访问 GitHub 的镜像／代理站点（例如：https://ghfast.top 或 https://gh-proxy.com）',  # 帮助信息
        default='https://ghfast.top',  # 设置默认值
    )

    # 设置默认目录
    default_comfyui_dir = os.path.join(os.getcwd(), 'ComfyUI')
    default_custom_nodes_dir = os.path.join(os.getcwd(), 'ComfyUI', 'custom_nodes')

    parser.add_argument(
        'comfyui_dir',  # 参数名称
        metavar='ComfyUI 目录',  # 参数显示名称
        help='选择 ComfyUI 根目录',  # 帮助信息
        widget='DirChooser',  # 使用目录选择器
        default=default_comfyui_dir,  # 设置默认值
    )
    parser.add_argument(
        'custom_nodes_dir',  # 参数名称
        metavar='自定义节点目录',  # 参数显示名称
        help='选择 custom_nodes 目录',  # 帮助信息
        widget='DirChooser',  # 使用目录选择器
        default=default_custom_nodes_dir,  # 设置默认值
    )
    args = parser.parse_args()

    # 获取镜像地址
    mirror_url = args.mirror_url

    # 获取 custom_nodes 目录下的文件夹总数
    custom_nodes = [D for D in os.listdir(args.custom_nodes_dir) if os.path.isdir(os.path.join(args.custom_nodes_dir, D))]
    total_tasks = len(custom_nodes) + 1  # 包括 ComfyUI 根目录
    completed_tasks = 0

    # 更新进度条
    def update_progress():
        nonlocal completed_tasks
        completed_tasks += 1
        print(f"进度: {completed_tasks}/{total_tasks}")  # Gooey 会根据正则表达式更新进度条
        sys.stdout.flush()  # 强制刷新输出，确保 Gooey 捕获到进度信息

    # 更新主仓库
    try:
        print(f"ComfyUI 根目录:  {args.comfyui_dir}")
        print(f"custom_nodes 目录： {args.custom_nodes_dir}")
        set_url_and_pull(args.comfyui_dir, mirror_url)
        update_progress()
    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)  # 终止程序

    # 更新 custom_nodes 目录下的所有子目录
    with ThreadPoolExecutor() as executor:
        futures = []
        for D in custom_nodes:
            dir_path = os.path.join(args.custom_nodes_dir, D)
            futures.append(executor.submit(set_url_and_pull, dir_path, mirror_url))

        # 等待所有任务完成
        for future in futures:
            try:
                future.result()  # 获取任务结果，如果任务中有异常会抛出
                update_progress()
            except Exception as e:
                print(f"错误: {e}")
                sys.exit(1)  # 终止程序

def set_url_and_pull(repo_path, mirror_url):
    try:
        repo = git.Repo(repo_path)
        git_remote_url = repo.remotes.origin.url

        # 提取文件夹名称
        repo_foldername = os.path.basename(repo_path)

        # 确保 URL 以 .git 结尾
        if not git_remote_url.endswith('.git'):
            print(f"忽略 {repo_foldername} ，非标准 Git 仓库（仓库地址不以 .git 结尾）： {git_remote_url}")
            return

        # 1. 直接下载：如果 remote URL 以 mirror_url 开头，则直接 pull
        if git_remote_url.startswith(f'{mirror_url}/'):
            print(f"正在更新: {repo_foldername}")
            repo.git.reset('--hard')
            repo.remotes.origin.pull()
            print(f"更新完成: {repo_foldername}")
        # 2. 添加镜像（代理）：如果 remote URL 以 https://github.com/ 开头，则在开头添加 mirror_url
        elif git_remote_url.startswith('https://github.com/'):
            print(f"正在修改 GitHub URL 并更新: {repo_foldername}")
            new_url = f'{mirror_url}/{git_remote_url}'
            repo.git.reset('--hard')
            repo.remotes.origin.set_url(new_url)
            repo.remotes.origin.pull()
            print(f"更新完成: {repo_foldername}")
        # 3. 替换镜像（代理）：如果 remote URL 包含 /https://github.com/，则替换镜像站点
        elif '/https://github.com/' in git_remote_url:
            print(f"正在修改镜像 URL 并更新: {repo_foldername}")
            # 提取 https://github.com/ 之后的部分
            github_part = git_remote_url.split('/https://github.com/')[1]
            new_url = f'{mirror_url}/https://github.com/{github_part}'
            repo.git.reset('--hard')
            repo.remotes.origin.set_url(new_url)
            repo.remotes.origin.pull()
            print(f"更新完成: {repo_foldername}")
        else:
            print(f"忽略 {repo_foldername}，未知 URL 格式的仓库: {git_remote_url}")
    except Exception as e:
        print(f"处理 {repo_foldername} 时出错: {e}")
        raise  # 重新抛出异常，让上层捕获并终止程序

if __name__ == "__main__":
    main()
