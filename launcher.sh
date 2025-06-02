#!/usr/bin/env bash

# Collect launchable commands

# 1. Native (PATH)
native_cmds=$(compgen -c | sort -u | awk '{print "CMD\t" $1}')

# 2. Snaps
snap_cmds=""
if command -v snap >/dev/null 2>&1; then
    snap_cmds=$(ls /snap/bin/ 2>/dev/null | awk '{print "SNAP\t" $1}')
fi

# 3. Flatpaks
flatpak_cmds=""
if command -v flatpak >/dev/null 2>&1; then
    flatpak_cmds=$(flatpak list --columns=application 2>/dev/null \
        | grep -v '^Application' | awk '{print "FLATPAK\t" $1}')
fi

# 4. Desktop files (All common locations)
desktop_dirs=(
    "/usr/share/applications"
    "$HOME/.local/share/applications"
    "/var/lib/flatpak/exports/share/applications"
    "$HOME/.local/share/flatpak/exports/share/applications"
)

desktop_cmds=""
while IFS= read -r -d '' file; do
    name=$(grep -m1 "^Name=" "$file" | cut -d= -f2-)
    exec=$(grep -m1 "^Exec=" "$file" | cut -d= -f2- | sed 's/ .*$//')
    entry="${name:-$(basename "$file")}"
    [ -n "$entry" ] && desktop_cmds+=$'DESKTOP\t'"$entry"$'\t'"$file"$'\n'
done < <(find "${desktop_dirs[@]}" -type f -name "*.desktop" -print0 2>/dev/null)

# Present menu in fzf
selection=$( 
    (
        echo "$native_cmds"
        echo "$snap_cmds"
        echo "$flatpak_cmds"
        echo "$desktop_cmds"
    ) | fzf --with-nth=1.. --delimiter='\t' --tabstop=16 --preview '
        if [[ {1} == "DESKTOP" ]]; then
            grep -E "Name=|Comment=|Exec=" {3} | sed "s/^/    /"
        else
            echo "Type: {1}"
            echo "Command: {2}"
            [ {1} = FLATPAK ] && echo "flatpak run {2}"
            [ {1} = SNAP ] && echo "/snap/bin/{2}"
        fi
    '
)

[ -z "$selection" ] && exit 0

# Parse selection
type=$(echo "$selection" | awk -F'\t' '{print $1}')
cmd=$(echo "$selection" | awk -F'\t' '{print $2}')
file=$(echo "$selection" | awk -F'\t' '{print $3}')

case "$type" in
    CMD)
        # Run a shell command
        setsid "$cmd" &>/dev/null &
        ;;
    SNAP)
        # Snap binary, run as in PATH
        setsid "/snap/bin/$cmd" &>/dev/null &
        ;;
    FLATPAK)
        # Launch Flatpak app
        setsid flatpak run "$cmd" &>/dev/null &
        ;;
    DESKTOP)
        # Launch the desktop entry using gtk-launch or xdg-open
        exec_line=$(grep -m1 '^Exec=' "$file" | cut -d= -f2- | sed 's/ *%[fFuUdDnNickvm]//g')
        if [ -n "$exec_line" ]; then
            setsid bash -c "$exec_line" &>/dev/null &
        else
            desktop_id=$(basename "$file" .desktop)
            if command -v gtk-launch >/dev/null 2>&1; then
                setsid gtk-launch "$desktop_id" &>/dev/null &
            else
                setsid xdg-open "$file" &>/dev/null &
            fi
        fi
esac