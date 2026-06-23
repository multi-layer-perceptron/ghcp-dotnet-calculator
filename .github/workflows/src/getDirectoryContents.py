#!/usr/bin/env python3
"""
Script to list all repository contents recursively and save to artifacts folder.
This script is used in GitHub Actions workflow to capture repository structure.
"""

import os
import sys

from datetime import datetime

def list_directory_contents(root_path, output_file):
    """
    Recursively list all files and directories in the repository.
    
    Args:
        root_path (str): The root directory to scan
        output_file (str): The output file path to write results
    """
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(f"Repository Directory Contents\n")
            f.write(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}\n")
            f.write(f"Root path: {root_path}\n")
            f.write("=" * 80 + "\n\n")
            
            # Walk through all directories and files
            for root, dirs, files in os.walk(root_path):
                # Skip .git directory to avoid clutter
                if '.git' in dirs:
                    dirs.remove('.git')
                
                # Calculate relative path for cleaner output
                rel_path = os.path.relpath(root, root_path)
                if rel_path == '.':
                    rel_path = 'ROOT'
                
                f.write(f"Directory: {rel_path}\n")
                
                # List directories first
                for dir_name in sorted(dirs):
                    f.write(f"  [DIR]  {dir_name}/\n")
                
                # List files
                for file_name in sorted(files):
                    file_path = os.path.join(root, file_name)
                    try:
                        file_size = os.path.getsize(file_path)
                        f.write(f"  [FILE] {file_name} ({file_size} bytes)\n")
                    except (OSError, IOError):
                        f.write(f"  [FILE] {file_name} (size unknown)\n")
                
                f.write("\n")
        
        print(f"Directory contents successfully written to: {output_file}")
        
    except Exception as e:
        print(f"Error writing directory contents: {str(e)}", file=sys.stderr)
        sys.exit(1)

def main():
    """Main function to execute the directory listing."""
    # Get the repository root (current working directory in GitHub Actions)
    repo_root = os.getcwd()
    
    # Create artifacts directory if it doesn't exist
    artifacts_dir = os.path.join(repo_root, 'artifacts')
    os.makedirs(artifacts_dir, exist_ok=True)
    
    # Define output file path
    output_file = os.path.join(artifacts_dir, 'python-directory-contents.txt')
    
    print(f"Starting directory scan of: {repo_root}")
    print(f"Output file: {output_file}")
    
    # List directory contents
    list_directory_contents(repo_root, output_file)
    
    print("Python directory listing completed successfully!")

if __name__ == "__main__":
    main()
