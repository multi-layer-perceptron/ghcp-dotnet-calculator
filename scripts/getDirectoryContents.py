# Get the contents of the current directory. Use recursion. Include files and folders
import os

def get_directory_contents(path, level=0):
    try:
        for entry in os.listdir(path):
            if entry == '.git' and level == 0:
                continue
            full_path = os.path.join(path, entry)
            print('  ' * level + entry)
            if os.path.isdir(full_path):
                get_directory_contents(full_path, level + 1)
    except PermissionError:
        print('  ' * level + '[Permission Denied]')

if __name__ == "__main__":
    current_directory = os.getcwd()
    get_directory_contents(current_directory)