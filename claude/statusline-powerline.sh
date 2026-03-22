#!/usr/bin/env bash

# Powerline-style status line for Claude Code
# Reads JSON input from stdin and creates a two-row status display

# Read JSON input
input=$(cat)

# Extract values
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
version=$(echo "$input" | jq -r '.version // ""')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Powerline separators (UTF-8 bytes for U+E0B0 and U+E0B2)
SEP_RIGHT=$'\xEE\x82\xB0'  # Right-pointing separator
SEP_LEFT=$'\xEE\x82\xB2'   # Left-pointing separator

# Color definitions (using ANSI 256-color)
PURPLE_BG="\033[48;5;135m"
PURPLE_FG="\033[38;5;135m"
YELLOW_BG="\033[48;5;221m"
YELLOW_FG="\033[38;5;221m"
GREEN_BG="\033[48;5;114m"
GREEN_FG="\033[38;5;114m"
PINK_BG="\033[48;5;218m"
PINK_FG="\033[38;5;218m"
WHITE_FG="\033[38;5;231m"
BLACK_FG="\033[38;5;16m"
BLACK_BG="\033[48;5;16m"
RESET="\033[0m"

# === Row 1: Model | Context | Git Branch | Git Stats | Version ===
row1=""

# Model segment (purple bg, white text)
row1+="${PURPLE_BG}${BLACK_FG} Model: ${model} ${RESET}"
row1+="${PURPLE_FG}${YELLOW_BG}${SEP_RIGHT}${RESET}"

# Context segment (yellow bg, dark text)
if [ -n "$ctx_used" ]; then
    total_k=$(awk "BEGIN {printf \"%.1fk\", ($total_input + $total_output) / 1000}")
    row1+="${YELLOW_BG}${BLACK_FG} Ctx: ${total_k} ${RESET}"
else
    row1+="${YELLOW_BG}${BLACK_FG} Ctx: 0k ${RESET}"
fi

# Git info segment (green bg, dark text)
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    row1+="${YELLOW_FG}${GREEN_BG}${SEP_RIGHT}${RESET}"

    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -z "$branch" ]; then
        branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
        branch="(detached:$branch)"
    fi

    row1+="${GREEN_BG}${BLACK_FG} branch: ${branch} ${RESET}"

    # Git stats (additions/deletions)
    git_stats=$(git -C "$cwd" --no-optional-locks diff --shortstat 2>/dev/null)
    if [ -n "$git_stats" ]; then
        additions=$(echo "$git_stats" | grep -o '[0-9]* insertion' | grep -o '[0-9]*')
        deletions=$(echo "$git_stats" | grep -o '[0-9]* deletion' | grep -o '[0-9]*')
        [ -z "$additions" ] && additions="0"
        [ -z "$deletions" ] && deletions="0"
        row1+="${GREEN_BG}${BLACK_FG} (+${additions},-${deletions}) ${RESET}"
    fi

    row1+="${GREEN_FG}${PINK_BG}${SEP_RIGHT}${RESET}"
else
    row1+="${YELLOW_FG}${PINK_BG}${SEP_RIGHT}${RESET}"
fi

# Version segment (pink bg, dark text)
if [ -n "$version" ]; then
    row1+="${PINK_BG}${BLACK_FG} v${version} ${RESET}"
fi

# === Row 2: CWD ===
row2=""

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

row2+="${PURPLE_BG}${BLACK_FG} cwd: ${short_cwd} ${RESET}"

# Output both rows
printf "%b\n%b\n" "$row1" "$row2"
