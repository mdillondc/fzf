# FZF Shortcuts

A unified shell utility that enhances fzf with powerful shortcuts for file navigation, content searching, editor integration, and process management—all with performance-optimized path caching.

This README is written for Ubuntu/Debian, however it should work on other Linux distributions as well.

## Overview

`fzf.sh` combines multiple fuzzy-finding capabilities into a single, easy-to-use interface. It extends the functionality of [fzf](https://github.com/junegunn/fzf) to provide shortcuts for:

- File and directory navigation
- Opening files with different editors (Zed, Neovim) - modify `fzf.sh` to use your preferred editors
- Searching file contents
- Process management / process kill
- Path caching for performance

This script streamlines your workflow with a consistent interface for common operations, making it faster to navigate your filesystem, find and open files, and manage processes.

## Dependencies

- [fzf](https://github.com/junegunn/fzf): Command-line fuzzy finder
- [ripgrep](https://github.com/BurntSushi/ripgrep): For content searching
- [bat](https://github.com/sharkdp/bat): For syntax-highlighted file previews
- [Zed](https://zed.dev/) and/or [Neovim](https://neovim.io/): For text editing features (again; substitute with your preferred editors)
- Standard Unix utilities: `find`, `grep`, `ps`, `kill`, `xdg-utils`

Install dependencies on Ubuntu/Debian:

```
sudo apt update && sudo apt install -y fzf ripgrep bat neovim xdg-utils
```

**Note**: On some Ubuntu versions, `bat` may be installed as `batcat`. Create a symlink with:
```
sudo ln -s /usr/bin/batcat /usr/local/bin/bat
```

For Zed, download from the [official website](https://zed.dev) as it's not in repositories.

## Installation

1. Clone or download this repository:
   ```
   git clone https://github.com/mdillondc/fzf.git
   ```

2. Source the script in your shell configuration:
   ```
   # Add this line to your .bashrc, .zshrc, or equivalent
   source ~/path/to/fzf/fzf.sh
   ```

3. Reload your shell configuration:
   ```
   source ~/.bashrc  # or source ~/.zshrc
   ```

4. Generate the initial cache:
   ```
   fCache
   ```
   This might take a few minutes on the first run, depending on the size of your home directory.

## Quick Start

After installation, you can immediately:

1. Navigate files and directories:
   - From cached paths with `f`
   - Recursively from current directory with `fr`
2. Open files with editors:
   - In Zed editor with `fz`
   - In Neovim with `fv`
3. Search file contents with `fSearchZed`
4. Kill processes with `fKill`
5. Run `fHelp` for more options than listed in README.md (`fHelp` will always be more up-to-date than README.md)

Run `fHelp` to view all available commands and shortcuts.

```bash
=======================================================
                FZF SHORTCUTS REFERENCE
=======================================================

USAGE: fzf.sh [COMMAND]

COMMAND                   ALIAS                DESCRIPTION
-------                   -----                -----------
--help                    fHelp                Show this help message
--update-cache            fCache               Update the file/directory path cache
--open                    f                    Fuzzy find and open files with default system app or cd to directory
--open-recursive          fr                   Fuzzy find and open files recursively from current directory
--open-zed                fz                   Fuzzy find and open files with Zed
--open-nvim               fv                   Fuzzy find and open files with Neovim
--path                    fp                   Return a selected path from fuzzy finder
--kill                    fKill                List and kill any process
--search-zed              fSearchZed           Search file contents and open in Zed
--search-nvim             fSearchVim           Search file contents and open in Neovim
--search-rel-zed          fSearchRelZed        Search recursively in current directory, open in Zed
--search-rel-nvim         fSearchRelVim        Search recursively in current directory, open in Neovim
```

## Usage Examples

### Navigate and Open Files

```
# Navigation commands
# Fuzzy find and navigate to directories or open files (uses global cache)
f
# Fuzzy find and navigate to files/directories recursively from current directory
fr

# Editor commands
# Find and open files specifically with Zed
fz
# Find and open files specifically with Neovim
fv
```

When you use `f` or `fr`, selecting a directory will automatically change to it, while selecting a file will open it in your system's default application. The difference is that `f` searches through your cached paths (potentially your entire home directory), while `fr` only searches recursively from your current directory.

### Process Management

```
# Interactively select and kill processes
fKill
```

## Cache System

The script uses a cache system to dramatically improve performance whenever possible:

1. The cache is stored in `$HOME/.cache/fzf/all`
2. It contains a list of all files and directories in specified locations
3. By default, the script caches paths from your home directory (`$HOME`)
4. Additional locations can be added in the `update_cache()` function

### Managing the Cache

```
# Update the cache manually
fCache

# Set up automatic cache updates with cron
0 */2 * * * ~/path/to/fzf/fzf.sh --update-cache > /dev/null 2>&1
```

### Exclusion Patterns

The script excludes certain directories and files from the cache by default:
- Hidden directories (`.git`, `.cache`, etc.)
- System directories (`snap`, `lost+found`, etc.)
- Package managers' directories (`vendor`, `node_modules`, etc.)
- Temporary files and directories

## Customization

You can modify the script to:

- Change the cache location by editing `CACHE_DIR` and `CACHE_FILE` variables
- Update the path to the Zed editor by editing the `ZED_PATH` variable or replace with your editor of choice
- Customize which directories are indexed by modifying the `INCLUDES` array
- Control which patterns are excluded by adjusting the `EXCLUDES` array

## How It Works

The script operates in two main modes:

1. **Sourced Mode**: When sourced in your shell configuration, it defines aliases and functions that you can use directly in your terminal.

2. **Command Mode**: When executed with flags (e.g., `./fzf.sh --help`), it performs the specified operation and exits.

Key features:
- When a directory is selected with `f` in an interactive shell, you'll be taken to that directory
- The script automatically detects file types and opens them with appropriate applications
- Text files open in text editors, while other file types open with the system default application
- Process selection with `fKill` uses a multi-step approach, trying regular termination first before escalating to stronger signals

## License

This script is provided as-is under the MIT License.