#!/bin/bash
# 注意：Windows 下运行需要安装 Git 并在安装时选择 Git Bash（默认）

set -eu

# 如果希望“尝试更新但不强制”，删除 git reset 行以避免还原本地变更
function change_url_or_pull () {
    git_remote_url=$(git -C "$1" remote get-url origin) ;

    if [[ $git_remote_url =~ ^(https:\/\/ghp\.ci\/)(.*)(\.git)$ ]]; then
        echo "正在更新: $1" ;
        git -C "$1" reset --hard ;
        git -C "$1" pull --ff-only ;
        echo "更新完成: $1" ;
    elif [[ $git_remote_url =~ ^(https:\/\/github\.com\/)(.*)(\.git)$ ]]; then
        echo "正在修改URL并更新: $1" ;
        git -C "$1" reset --hard ;
        git -C "$1" remote set-url origin "https://gh-proxy.com/$git_remote_url" ;
        git -C "$1" pull --ff-only ;
        echo "更新完成: $1" ;
    fi ;
}

change_url_or_pull ComfyUI

# 这里使用 & 将任务置入后台，以实现多线程，并等待全部任务完成
cd ./ComfyUI/custom_nodes
for D in *; do
    if [ -d "${D}" ]; then
        change_url_or_pull "${D}" &
    fi
done

wait $(jobs -p)

exit 0
