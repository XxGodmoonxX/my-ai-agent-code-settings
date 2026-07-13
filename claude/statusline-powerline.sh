#!/usr/bin/env bash

# Powerline-style status line for Claude Code
# Reads JSON input from stdin and creates a three-row status display
# Row 1: Model | Context | Version
# Row 2: Git branch (+ stats)
# Row 3: cwd

# Read JSON input
input=$(cat)

# Extract values
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
version=$(echo "$input" | jq -r '.version // ""')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
ctx_max=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
effort=$(echo "$input" | jq -r '.effort.level // empty')
# Dirs from user settings additionalDirectories are always present, so showing
# them is just noise — display only dirs added ad hoc via --add-dir / /add-dir
settings_dirs=()
if [ -f "$HOME/.claude/settings.json" ]; then
    while IFS= read -r line; do
        [ -n "$line" ] && settings_dirs+=("${line/#\~/$HOME}")
    done < <(jq -r '.permissions.additionalDirectories // [] | .[]' "$HOME/.claude/settings.json" 2>/dev/null)
fi
added_dirs=()
while IFS= read -r line; do
    [ -n "$line" ] || continue
    skip=false
    for sd in "${settings_dirs[@]}"; do
        if [ "${line%/}" = "${sd%/}" ]; then
            skip=true
            break
        fi
    done
    [ "$skip" = true ] || added_dirs+=("$line")
done < <(echo "$input" | jq -r '.workspace.added_dirs // [] | .[]')

# Powerline separators (UTF-8 bytes for U+E0B0 and U+E0B2)
SEP_RIGHT=$'\xEE\x82\xB0'  # Right-pointing separator
SEP_LEFT=$'\xEE\x82\xB2'   # Left-pointing separator

# Color definitions (using ANSI 256-color)
PURPLE_BG="\033[48;5;141m"
PURPLE_FG="\033[38;5;141m"
YELLOW_BG="\033[48;5;221m"
YELLOW_FG="\033[38;5;221m"
GREEN_BG="\033[48;5;114m"
GREEN_FG="\033[38;5;114m"
PINK_BG="\033[48;5;218m"
PINK_FG="\033[38;5;218m"
CYAN_BG="\033[48;5;117m"
CYAN_FG="\033[38;5;117m"
ORANGE_BG="\033[48;5;209m"
ORANGE_FG="\033[38;5;209m"
WHITE_FG="\033[38;5;231m"
BLACK_FG="\033[38;5;16m"
BLACK_BG="\033[48;5;16m"
RESET="\033[0m"

# === Row 1: Model | Context | Version ===
row1=""

# Model segment (purple bg, white text)
if [ -n "$effort" ]; then
    row1+="${PURPLE_BG}${BLACK_FG} Model: ${model} [${effort}] ${RESET}"
else
    row1+="${PURPLE_BG}${BLACK_FG} Model: ${model} ${RESET}"
fi
row1+="${PURPLE_FG}${YELLOW_BG}${SEP_RIGHT}${RESET}"

# Context segment (yellow bg, dark text)
if [ -n "$ctx_used" ]; then
    total_k=$(awk "BEGIN {printf \"%.1fk\", ($total_input + $total_output) / 1000}")
    max_k=$(awk "BEGIN {printf \"%.0fk\", $ctx_max / 1000}")
    pct=$(awk "BEGIN {printf \"%.0f\", $ctx_used}")
    row1+="${YELLOW_BG}${BLACK_FG} Ctx: ${total_k}/${max_k} (${pct}%) ${RESET}"
else
    row1+="${YELLOW_BG}${BLACK_FG} Ctx: 0k ${RESET}"
fi

row1+="${YELLOW_FG}${PINK_BG}${SEP_RIGHT}${RESET}"

# Version segment (pink bg, dark text)
if [ -n "$version" ]; then
    row1+="${PINK_BG}${BLACK_FG} v${version} ${RESET}"
fi

# === Row 2: Git Branch | Git Stats ===
row2=""

if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -z "$branch" ]; then
        branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
        branch="(detached:$branch)"
    fi

    row2+="${GREEN_BG}${BLACK_FG} branch: ${branch} ${RESET}"

    # Git stats (additions/deletions)
    git_stats=$(git -C "$cwd" --no-optional-locks diff --shortstat 2>/dev/null)
    if [ -n "$git_stats" ]; then
        additions=$(echo "$git_stats" | grep -o '[0-9]* insertion' | grep -o '[0-9]*')
        deletions=$(echo "$git_stats" | grep -o '[0-9]* deletion' | grep -o '[0-9]*')
        [ -z "$additions" ] && additions="0"
        [ -z "$deletions" ] && deletions="0"
        row2+="${GREEN_BG}${BLACK_FG} (+${additions},-${deletions}) ${RESET}"
    fi
fi

# === Row 3: CWD ===
row3=""

# Shorten cwd for display
short_cwd="${cwd/#$HOME/~}"
if [ ${#short_cwd} -gt 40 ]; then
    # Show .../<last 3 path components>
    IFS='/' read -ra parts <<< "$short_cwd"
    count=${#parts[@]}
    if [ "$count" -ge 4 ]; then
        short_cwd=".../${parts[$((count-3))]}/${parts[$((count-2))]}/${parts[$((count-1))]}"
    fi
fi

row3+="${CYAN_BG}${BLACK_FG} cwd: ${short_cwd} ${RESET}"

# === Row 4: Added directories (from --add-dir / /add-dir) ===
row4=""

if [ ${#added_dirs[@]} -gt 0 ]; then
    dirs_display=""
    for d in "${added_dirs[@]}"; do
        short_d="${d/#$HOME/~}"
        if [ -n "$dirs_display" ]; then
            dirs_display+=", ${short_d}"
        else
            dirs_display="${short_d}"
        fi
    done
    row4+="${ORANGE_BG}${BLACK_FG} add-dir: ${dirs_display} ${RESET}"
fi

# Output rows (row4 only when there are added directories)
if [ -n "$row4" ]; then
    printf "%b\n%b\n%b\n%b\n" "$row1" "$row2" "$row3" "$row4"
else
    printf "%b\n%b\n%b\n" "$row1" "$row2" "$row3"
fi
