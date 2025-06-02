# FZF Shortcuts

A unified shell utility that enhances fzf with powerful shortcuts for file navigation, content searching, editor integration, and process management—all with performance-optimized path caching.

This README is written for Ubuntu/Debian, however it should work on other Linux distributions as well.

## Overview

`fzf.sh` combines multiple fuzzy-finding capabilities into a single, easy-to-use interface. It extends the functionality of [fzf](https://github.com/junegunn/fzf) to provide shortcuts for:

- File and directory navigation
- Opening files with different editors (Zed, Neovim) - modify `fzf.sh` to use your preferred editors
- Searching file contents
- Process management / process kill
- Application launching (commands, snaps, flatpaks, desktop apps)
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
   fc
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
3. Search file contents with `fsz`
4. Kill processes with `fk`
5. Launch applications with `fl`
6. Run `fh` for more options than listed in README.md (`fh` will always be more up-to-date than README.md)

Run `fh` to view all available commands and shortcuts.

```bash
=======================================================
                FZF SHORTCUTS REFERENCE
=======================================================

USAGE: fzf.sh [COMMAND]

COMMAND                   ALIAS                DESCRIPTION
-------                   -----                -----------
--help                    fh                   Show this help message
--update-cache            fc                   Update the file/directory path cache
--open                    f                    Fuzzy find and open files with default system app or cd to directory
--open-recursive          fr                   Fuzzy find and open files recursively from current directory
--open-zed                fz                   Fuzzy find and open files with Zed
--open-nvim               fv                   Fuzzy find and open files with Neovim
--path                    fp                   Return a selected path from fuzzy finder
--kill                    fk                   List and kill any process
--search-zed              fsz                  Search file contents and open in Zed
--search-nvim             fsv                  Search file contents and open in Neovim
--search-rel-zed          fsrz                 Search recursively in current directory, open in Zed
--search-rel-nvim         fsrv                 Search recursively in current directory, open in Neovim
--launcher                fl                   Application launcher for commands, snaps, flatpaks, and desktop apps
```


## Application Launcher

The `fl` command provides a unified interface to launch applications from multiple sources:

- **Native Commands**: All commands available in your PATH
- **Snap Packages**: Installed snap applications
- **Flatpak Applications**: Installed flatpak apps
- **Desktop Applications**: Apps with .desktop files (system and user locations)

The launcher uses fzf to provide fuzzy searching with previews showing:
- Command type and name
- For desktop apps: Name, Comment, and Exec information
- Launch commands for different package types

Simply run `fl`, start typing to filter, and press Enter to launch the selected application.

## Cache System

The script uses a cache system to dramatically improve performance whenever possible:

1. The cache is stored in `$HOME/.cache/fzf/all`
2. It contains a list of all files and directories in specified locations
3. By default, the script caches paths from your home directory (`$HOME`)
4. Additional locations can be added in the `update_cache()` function

### Managing the Cache

```
# Update the cache manually
fc

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