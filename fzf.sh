#!/bin/bash
#
# fzfAll.sh - Unified script for all fzf-related functionality
#
# This script combines all fzf-related scripts into a single interface.
# Pass different flags to access different functionality.
#

# Detect if the script is being sourced
(return 0 2>/dev/null) && SOURCED=true || SOURCED=false

# Get absolute path to this script
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]:-$0}")

# Define constants
CACHE_DIR="$HOME/.cache/fzf"
CACHE_FILE="$CACHE_DIR/all"
ZED_PATH="$HOME/.local/bin/zed"

# Colors for output
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# Define all aliases and functions when script is sourced
if [[ "$SOURCED" = true ]]; then
    # Define all aliases
    alias fh="$SCRIPT_PATH --help"
    alias fc="$SCRIPT_PATH --update-cache"
    alias fp="$SCRIPT_PATH --path"
    alias fk="$SCRIPT_PATH --kill"
    alias fr="$SCRIPT_PATH --open-recursive"
    alias fz="$SCRIPT_PATH --open-zed"
    alias fv="$SCRIPT_PATH --open-nvim"
    
    # Define functions
    f() {
        local result
        result=$("$SCRIPT_PATH" --open)
        
        # If it's a directory path (result starts with "Directory selected:")
        if echo "$result" | grep -q "Directory selected:"; then
            # Extract just the path (last line)
            local dir=$(echo "$result" | tail -n 1)
            cd "$dir"
        fi
    }
    
    fr() {
        local result
        result=$("$SCRIPT_PATH" --open-recursive)
        
        # If it's a directory path (result starts with "Directory selected:")
        if echo "$result" | grep -q "Directory selected:"; then
            # Extract just the path (last line)
            local dir=$(echo "$result" | tail -n 1)
            cd "$dir"
        fi
    }
    
    fsz() {
        local query="${1:-}"  # Use $1 if provided, otherwise empty string
        "$SCRIPT_PATH" --search-zed "$query"
    }
    
    fsv() {
        local query="${1:-}"  # Use $1 if provided, otherwise empty string
        "$SCRIPT_PATH" --search-nvim "$query"
    }
    
    fsrz() {
        local query="${1:-}"  # Use $1 if provided, otherwise empty string
        "$SCRIPT_PATH" --search-rel-zed "$query"
    }
    
    fsrv() {
        local query="${1:-}"  # Use $1 if provided, otherwise empty string
        "$SCRIPT_PATH" --search-rel-nvim "$query"
    }
    
    return 0
fi

# Function to display usage and help
show_help() {
    echo -e "${BOLD}=======================================================${RESET}"
    echo -e "${BOLD}                FZF SHORTCUTS REFERENCE                ${RESET}"
    echo -e "${BOLD}=======================================================${RESET}"
    echo 
    echo -e "${BLUE}USAGE:${RESET} fzf.sh [COMMAND]"
    echo
    # Create a table with clear column separators
    printf "${BOLD}%-25s %-20s %-45s${RESET}\n" "COMMAND" "ALIAS" "DESCRIPTION"
    printf "${BOLD}%-25s %-20s %-45s${RESET}\n" "-------" "-----" "-----------"
    
    # Commands with perfectly aligned columns using printf
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--help" "fh" "Show this help message"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--update-cache" "fc" "Update the file/directory path cache"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--open" "f" "Fuzzy find and open files with default system app or cd to directory"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--open-recursive" "fr" "Fuzzy find and open files recursively from current directory"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--open-zed" "fz" "Fuzzy find and open files with Zed"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--open-nvim" "fv" "Fuzzy find and open files with Neovim"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--path" "fp" "Return a selected path from fuzzy finder"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--kill" "fk" "List and kill any process"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--search-zed" "fsz" "Search file contents and open in Zed"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--search-nvim" "fsv" "Search file contents and open in Neovim"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--search-rel-zed" "fsrz" "Search recursively in current directory, open in Zed"
    printf "${GREEN}%-25s${RESET} ${YELLOW}%-20s${RESET} %-45s\n" "--search-rel-nvim" "fsrv" "Search recursively in current directory, open in Neovim"
}

# Function to update cache
update_cache() {
    echo "Updating cache..."

    mkdir -p "$CACHE_DIR"
    >"$CACHE_FILE" # Clear the cache file instead of deleting

    case "$HOSTNAME" in
    *desktop*) 
        INCLUDES=(
            "$HOME"
            "/media/$USER/vault-1"
            "/media/$USER/vault-2"
        )
        ;;
    *) 
        INCLUDES=(
            "$HOME"
        )
        ;;
    esac

    EXCLUDES=(
        "*.abook*"
        "*.cache*"
        "*.cargo*"
        "*.docker*"
        "*.gnome*"
        "*.gnupg*"
        "*.icons*"
        "*.ipython*"
        "*.java*"
        "*.lando*"
        "*.local*"
        "*.ollama*"
        "*.pki*"
        "*.mozilla*"
        "*.mplayer*"
        "*.var*"
        "*.msmtprc*"
        # "*.config*"
        "*.themes*"
        "*.vscode*"
        "*.git*"
        ".ddev"
        "*.Trash*"
        "*lost+found*"
        "*.idea*"
        "*.steam*"
        "*__pycache__*"
        "*tmp**"
        "*tmp2**"
        "*restic**"
        "*snap*"
        "*sshfs*"
        "*vendor*"
        "*cpresources*"
        "*cache*"
        "*compiled_templates*"
    )

    FIND_ARGS=()
    for EXCLUDE in "${EXCLUDES[@]}"; do
        FIND_ARGS+=(! -path "$EXCLUDE")
    done

    for INCLUDE_PATH in "${INCLUDES[@]}"; do
        if [ -d "$INCLUDE_PATH" ] || [ -f "$INCLUDE_PATH" ]; then
            echo "Processing $INCLUDE_PATH..."
            find "$INCLUDE_PATH" -xdev "${FIND_ARGS[@]}" \( -type f -o -type d \) -print0 >>"$CACHE_FILE"
        else
            echo "Warning: Path $INCLUDE_PATH does not exist, skipping..."
        fi
    done
    echo "Cache update complete."
}

# Function to fuzzy search paths and return the selected path
fuzzy_path() {
    # Check if cache exists
    if [[ ! -r "$CACHE_FILE" ]]; then
        echo "Cache file not found or not readable: $CACHE_FILE" >&2
        exit 1
    fi

    # Tell fzf to read null-delimited input from the cache
    selected_path=$(cat "$CACHE_FILE" | fzf --read0)

    # Check if fzf was cancelled (e.g., ESC pressed)
    if [ $? -ne 0 ]; then
        echo "No path selected." >&2
        exit 1
    fi

    if [[ -n "$selected_path" ]]; then
        echo "$selected_path"
    else
        echo "No path selected." >&2
        exit 1
    fi
}

# Function to fuzzy find and open files/directories
fuzzy_open() {
    local use_nvim=$1
    local use_zed=$2
    local use_default_app=$3
    local recursive=$4
    
    if [[ "$recursive" = true ]]; then
        # Use find to get all files and directories recursively from current directory
        selected_path=$(find . -type f -o -type d 2>/dev/null | sort | fzf)
    else
        # Check if cache exists
        if [[ ! -r "$CACHE_FILE" ]]; then
            echo "Cache file not found or not readable: $CACHE_FILE" >&2
            exit 1
        fi

        # Tell fzf to read null-delimited input from the cache
        selected_path=$(cat "$CACHE_FILE" | fzf --read0)
    fi

    # Check if fzf was cancelled (e.g., ESC pressed)
    if [ $? -ne 0 ]; then
        echo "No path selected." >&2
        exit 1
    fi

    if [[ -n "$selected_path" ]]; then # Check if anything was selected
        if [[ -d "$selected_path" ]]; then
            # Handle directories differently based on the specified editor
            if [[ "$use_zed" = true ]]; then
                # Open directory in Zed
                if [[ -x "$ZED_PATH" ]]; then
                    "$ZED_PATH" "$selected_path" &>/dev/null &
                    echo "Opened directory in Zed: $selected_path"
                else
                    echo "Zed not found or not executable at: $ZED_PATH" >&2
                    exit 1
                fi
            elif [[ "$use_nvim" = true ]]; then
                # For neovim, use netrw to browse directory
                nvim "$selected_path"
            else
                # For default app, just print the path
                echo "Directory selected: $selected_path"
                echo "NOTE: Running in a subshell, can't directly change your current directory."
                echo "You can copy this path or manually cd to it:"
                echo "$selected_path"
            fi
        elif [[ -f "$selected_path" ]]; then
            if [[ "$use_default_app" = true ]]; then
                # Use system default application
                xdg-open "$selected_path" &>/dev/null &
                echo "# Opened $selected_path with default application"
            elif [[ "$use_zed" = true ]]; then
                # When --editor-zed is specified, use Zed
                if [[ -x "$ZED_PATH" ]]; then
                    "$ZED_PATH" "$selected_path" &>/dev/null &
                    echo "# Opened $selected_path with Zed"
                else
                    echo "# Zed not found or not executable at: $ZED_PATH" >&2
                    exit 1
                fi
            else
                text_file_pattern="(^\.|^.+\.(txt|md|markdown|text|tex|log|rtf|m3u|asc|asciidoc|csv|json|xml|yaml|yml|html|htm|css|scss|less|js|ts|php|twig|py|rb|java|c|cpp|h|go|sh|pl|lua|rs|swift|sql|ini|conf|cfg|bat|.bashrc|.zshrc|.*)|^([^\.]+)$)"
                if [[ "$selected_path" =~ $text_file_pattern ]]; then
                    if [[ "$use_nvim" = true ]]; then
                        nvim "$selected_path"
                    else
                        # Original behavior - try zed, fall back to nvim/editor
                        if command -v zed >/dev/null 2>&1; then
                            zed "$selected_path" &>/dev/null &
                            echo "# Opened $selected_path with Zed"
                        else
                            ${EDITOR:-nvim} "$selected_path"
                        fi
                    fi
                else
                    xdg-open "$selected_path" &>/dev/null &
                    echo "# Opened $selected_path with default application"
                fi
            fi
        else
            # This case might happen if a file was deleted after caching
            echo "echo \"Error: Selected path no longer exists: $selected_path\"" >&2
            exit 1
        fi
    else
        # This case might be redundant due to the exit status check above, but harmless
        echo "No path selected." >&2
        exit 1
    fi
}

# Function to search file contents
search_file_contents() {
    local initial_query="$1"
    local relative_scope=$2
    local use_nvim=$3

    # Use a simple preview command
    preview_cmd="bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null || echo 'Cannot display file'"

    # Determine search scope
    search_path="$HOME"
    if [[ "$relative_scope" = true ]]; then
        search_path="."
        echo "Searching in current directory: $(pwd)"
    fi

    # Use ripgrep with inclusions instead of exclusions
    result=$(rg --fixed-strings --color=always --line-number --no-heading --smart-case \
        --max-filesize=1M \
        --glob='*.{txt,md,markdown,rst,adoc,php,twig,html,htm,css,scss,sass,less,js,jsx,ts,tsx,json,vue,svelte,py,pyi,ipynb,pyc,pyd,pyw,pyx,php,phtml,php3,php4,php5,php7,php8,phptml,inc,yml,yaml,toml,ini,conf,cfg,htaccess,env,example,sh,bash,zsh,fish,bashrc,zshrc,profile,bash_profile,composer.json,package.json,requirements.txt,Pipfile,gitignore,gitattributes,.gitkeep,xml,log,diff,patch}' \
        "${initial_query:-.}" "$search_path" 2>/dev/null |
        fzf --ansi --query="$initial_query" \
            --delimiter : \
            --preview "$preview_cmd" \
            --preview-window 'right,70%,border-left,wrap')

    # Process the result
    if [ -n "$result" ]; then
        file=$(echo "$result" | cut -d: -f1)
        line=$(echo "$result" | cut -d: -f2)
        
        # Open the file at the specified line
        if [ -f "$file" ]; then
            if [[ "$use_nvim" = true ]]; then
                nvim "+$line" "$file"
            elif command -v zed >/dev/null 2>&1; then
                zed "$file:$line"
            else
                ${EDITOR:-nvim} "+$line" "$file"
            fi
        else
            echo "Error: File $file not found."
            exit 1
        fi
    else
        # User cancelled or no results
        exit 1
    fi
}

# Function to kill processes with fzf
kill_process() {
    # Get the list of processes and let user select with fzf
    pid=$(ps -ef | 
        sed 1d | 
        fzf -m \
            --header="[Enter:Kill] Select process to kill" \
            --preview="echo Process: {}" \
            --preview-window=down:3:wrap |
        awk '{print $2}')

    # If no process was selected, exit
    if [ -z "$pid" ]; then
        echo "No process selected."
        exit 1
    fi

    # Confirm before killing
    echo "Killing process $pid"
    ps -p "$pid" -o comm=

    # Try normal kill first, then escalate to kill -9 if needed
    kill "$pid" 2>/dev/null

    if [ $? -ne 0 ]; then
        echo "Process resistant to normal termination. Using kill -9..."
        kill -9 "$pid" 2>/dev/null || sudo kill -9 "$pid"
    fi

    echo "Process terminated."
}

# If no arguments provided, default to help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Process command line arguments
case "$1" in
    --help)
        show_help
        ;;
    --update-cache)
        update_cache
        ;;
    --path)
        fuzzy_path
        ;;
    --open)
        fuzzy_open false false true false
        ;;
    --open-recursive)
        fuzzy_open false false true true
        ;;
    --open-nvim)
        fuzzy_open true false false false
        ;;
    --open-zed)
        fuzzy_open false true false false
        ;;
    --kill)
        kill_process
        ;;
    --search-zed)
        search_file_contents "$2" false false
        ;;
    --search-nvim)
        search_file_contents "$2" false true
        ;;
    --search-rel-zed)
        search_file_contents "$2" true false
        ;;
    --search-rel-nvim)
        search_file_contents "$2" true true
        ;;
    *)
        echo -e "${RED}Error: Unknown option '$1'${RESET}"
        show_help
        exit 1
        ;;
esac

exit 0