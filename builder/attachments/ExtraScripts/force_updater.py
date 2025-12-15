import os
import re
import sys
import git
from concurrent.futures import ThreadPoolExecutor
from gooey import Gooey, GooeyParser

@Gooey(
    program_name="ComfyUI Force Update Tool",  # Program name
    progress_regex=r"^Progress: (\d+)/(\d+)$",  # Progress bar regex
    progress_expr="x[0] / x[1] * 100",  # Progress bar expression
    disable_progress_bar_animation=True,
    timing_options={
        'show_time_remaining': True,
    },
    clear_before_run=True,  # Clear console before running
)
def main():
    # Create Gooey argument parser
    parser = GooeyParser(
        description="Force update ComfyUI and its custom nodes.\n\n"
                    "Note: The force update only handles Git repositories and does not manage Python dependencies.\n"
                    "You may need to click 'Try Fix' in the Manager later to fix individual nodes."
    )

    # Set default directories
    default_comfyui_dir = os.path.join(os.getcwd(), 'ComfyUI')
    default_custom_nodes_dir = os.path.join(os.getcwd(), 'ComfyUI', 'custom_nodes')

    parser.add_argument(
        'comfyui_dir',  # Argument name
        metavar='ComfyUI Directory',  # Display name
        help='Select the ComfyUI root directory',  # Help message
        widget='DirChooser',  # Use directory chooser
        default=default_comfyui_dir,  # Default value
    )
    parser.add_argument(
        'custom_nodes_dir',  # Argument name
        metavar='Custom Nodes Directory',  # Display name
        help='Select the custom_nodes directory',  # Help message
        widget='DirChooser',  # Use directory chooser
        default=default_custom_nodes_dir,  # Default value
    )
    args = parser.parse_args()

    # Get the total number of folders in custom_nodes directory
    custom_nodes = [D for D in os.listdir(args.custom_nodes_dir) if os.path.isdir(os.path.join(args.custom_nodes_dir, D))]
    total_tasks = len(custom_nodes) + 1  # Include ComfyUI root directory
    completed_tasks = 0

    # Update progress bar
    def update_progress():
        nonlocal completed_tasks
        completed_tasks += 1
        print(f"Progress: {completed_tasks}/{total_tasks}")  # Gooey will update the progress bar based on this output
        sys.stdout.flush()  # Force flush output to ensure Gooey captures the progress

    # Update main repository
    try:
        git_pull(args.comfyui_dir)
        update_progress()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)  # Terminate the program

    # Update all subdirectories in custom_nodes directory
    with ThreadPoolExecutor() as executor:
        futures = []
        for D in custom_nodes:
            dir_path = os.path.join(args.custom_nodes_dir, D)
            futures.append(executor.submit(git_pull, dir_path))

        # Wait for all tasks to complete
        for future in futures:
            try:
                future.result()  # Get the task result; if there's an exception, it will be raised here
                update_progress()
            except Exception as e:
                print(f"Error: {e}")
                sys.exit(1)  # Terminate the program

def git_pull(repo_path):
    try:
        repo = git.Repo(repo_path)
        git_remote_url = repo.remotes.origin.url

        if re.match(r'^https:\/\/github\.com\/.*\.git$', git_remote_url):
            print(f"Updating: {repo_path}")
            repo.git.reset('--hard')
            repo.remotes.origin.pull()
            print(f"Done Updating: {repo_path}")
    except Exception as e:
        print(f"Error processing {repo_path}: {e}")
        raise  # Re-raise the exception to be caught by the caller

if __name__ == "__main__":
    main()
