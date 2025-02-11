# You need to install Git for Windows and select Git Bash (Default)
# https://git-scm.com/download/win

# If you don't want a FORCE update, remove the "git reset" line within the function

function git_pull {
    param(
        [string]$repo
    )

    $git_remote_url = git -C $repo remote get-url origin

    if ($git_remote_url -match "^https://github\.com/.*\.git$") {
        Write-Host "Updating: $repo"
        git -C $repo reset --hard
        git -C $repo pull --ff-only
        Write-Host "Done Updating: $repo"
    }
}

git_pull ComfyUI

$custom_nodes_dirs = Get-ChildItem -Path ".\ComfyUI\custom_nodes" -Directory

$jobs = foreach ($dir in $custom_nodes_dirs) {
    Start-Job -ScriptBlock {
        param(
            [string]$dir_path
        )
        git_pull $dir_path
    } -ArgumentList $dir.FullName
}

Wait-Job -Job $jobs

Write-Host "All updates complete."
