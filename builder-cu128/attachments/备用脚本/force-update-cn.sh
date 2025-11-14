#!/bin/bash
# 注意：Windows 下运行需要安装 Git 并在安装时选择 Git Bash（默认）

set -eu

# 如果希望“尝试更新但不强制”，删除 git reset 行以避免还原本地变更
function set_url_and_pull () {
    git_remote_url=$(git -C "$1" remote get-url origin) ;

    if [[ $git_remote_url =~ ^(https:\/\/)(gh-proxy\.com|ghfast\.top)(\/)(.*)(\.git)$ ]]; then
        echo "正在更新: $1" ;
        git -C "$1" reset --hard ;
        git -C "$1" pull --ff-only ;
        echo "更新完成: $1" ;
    elif [[ $git_remote_url =~ ^(https:\/\/github\.com\/)(.*)(\.git)$ ]]; then
        echo "正在修改URL并更新: $1" ;
        git -C "$1" reset --hard ;
        git -C "$1" remote set-url origin "https://ghfast.top/$git_remote_url" ;
        git -C "$1" pull --ff-only ;
        echo "更新完成: $1" ;
    elif [[ $git_remote_url =~ ^(https:\/\/ghp\.ci\/)((https:\/\/github\.com\/)(.*)(\.git))$ ]]; then
        echo "正在修改URL并更新: $1" ;
        echo "提取URL: ${BASH_REMATCH[2]}" ;
        git -C "$1" reset --hard ;
        git -C "$1" remote set-url origin "https://ghfast.top/${BASH_REMATCH[2]}" ;
        git -C "$1" pull --ff-only ;
        echo "更新完成: $1" ;
    fi ;
}

set_url_and_pull ComfyUI

# 这里使用 & 将任务置入后台，以实现多线程（多进程），并等待全部任务完成
cd ./ComfyUI/custom_nodes
for D in *; do
    if [ -d "${D}" ]; then
        set_url_and_pull "${D}" &
    fi
done

wait $(jobs -p)

exit 0
