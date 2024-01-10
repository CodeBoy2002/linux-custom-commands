#!/bin/bash

# Function to display help message
display_help() {
    cat << 'EOF'
internsctl - custom Linux command for internship operations

Usage: internsctl [OPTIONS] [ARGUMENTS]

Options:
  -h, --help            Display this help message.
  -v, --version         Display version information.
  -l, --list            List all interns.
  -a, --add <name>      Add a new intern with the specified name.
  -r, --remove <name>   Remove the intern with the specified name.
  cpu getinfo           Get CPU information (similar to lscpu).
  memory getinfo        Get memory information (similar to free).
  user create <name>    Create a new user with the specified name.
  user list             List all regular users.
  user list --sudo-only List all users with sudo permissions.
  file getinfo <file>   Get information about a file.

Examples:
  internsctl -l
  internsctl -a John
  internsctl -r Jane
  internsctl cpu getinfo
  internsctl memory getinfo
  internsctl user create jdoe
  internsctl user list
  internsctl user list --sudo-only
  internsctl file getinfo hello.txt
  internsctl file getinfo --size hello.txt
  internsctl file getinfo --permissions hello.txt
  internsctl file getinfo --owner hello.txt
  internsctl file getinfo --last-modified hello.txt

EOF
}

# Function to display version information
display_version() {
    echo "internsctl v0.1.0"
}

# Function to get CPU information
get_cpu_info() {
    lscpu
}

# Function to get memory information
get_memory_info() {
    free
}

# Function to create a new user
create_user() {
    if [ -z "$1" ]; then
        echo "Error: Missing username. Usage: internsctl user create <username>"
        exit 1
    fi

    sudo useradd -m "$1"
    sudo passwd "$1"
}

# Function to list all regular users or users with sudo permissions
list_users() {
    if [ "$1" == "--sudo-only" ]; then
        getent passwd | grep -E 'sudo|admin' | cut -d: -f1
    else
        getent passwd | cut -d: -f1
    fi
}

# Function to get file information
get_file_info() {
    if [ -z "$1" ]; then
        echo "Error: Missing file name. Usage: internsctl file getinfo <file>"
        exit 1
    fi

    file="$1"

    if [ ! -e "$file" ]; then
        echo "Error: File '$file' does not exist."
        exit 1
    fi

    size=$(du -b "$file" | cut -f1)
    permissions=$(ls -l "$file" | awk '{print $1}')
    owner=$(stat -c %U "$file")
    last_modified=$(stat -c %y "$file")

    cat << EOF
File: $file
Access: $permissions
Size(B): $size
Owner: $owner
Modify: $last_modified
EOF
}

# Check for the presence of options
case "$1" in
    --help | -h)
        display_help
        exit 0
        ;;
    --version | -v)
        display_version
        exit 0
        ;;
    cpu)
        case "$2" in
            getinfo)
                get_cpu_info
                exit 0
                ;;
            *)
                echo "Invalid CPU command. See 'internsctl --help' for usage."
                exit 1
                ;;
        esac
        ;;
    memory)
        case "$2" in
            getinfo)
                get_memory_info
                exit 0
                ;;
            *)
                echo "Invalid memory command. See 'internsctl --help' for usage."
                exit 1
                ;;
        esac
        ;;
    user)
        case "$2" in
            create)
                create_user "$3"
                exit 0
                ;;
            list)
                list_users "$3"
                exit 0
                ;;
            *)
                echo "Invalid user command. See 'internsctl --help' for usage."
                exit 1
                ;;
        esac
        ;;
    file)
        case "$2" in
            getinfo)
                get_file_info "$3"
                exit 0
                ;;
            *)
                echo "Invalid file command. See 'internsctl --help' for usage."
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Invalid command. See 'internsctl --help' for usage."
        exit 1
        ;;
esac