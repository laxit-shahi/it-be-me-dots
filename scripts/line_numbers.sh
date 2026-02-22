#!/usr/bin/env bash

readonly LINE_NUMBER_PANE_WIDTH=3
readonly LINE_NUMBER_UPDATE_DELAY=0.1
readonly COLOR_NUMBERS_RGB="101;112;161"
readonly COLOR_ACTIVE_NUMBER_RGB="255;158;100"

escape_pgrep_pattern() {
    local input=$1
    printf '%s' "$input" | sed 's/[][.^$*+?(){}|\\]/\\&/g'
}

open_line_number_split() {
    local self_path
    local pane_id
    local pgrep_pattern

    self_path=$(realpath "$0")
    pane_id=$(tmux display-message -pF "#{pane_id}")

    if is_in_copy_mode "$pane_id"; then
        return
    fi

    pgrep_pattern=$(escape_pgrep_pattern "$self_path $pane_id")
    if pgrep -f -- "$pgrep_pattern" > /dev/null 2>&1; then
        return
    fi

    tmux split-window -h -l "$LINE_NUMBER_PANE_WIDTH" -b "$self_path" "$pane_id"
    tmux select-pane -l
}

enter_copy_mode() {
    local target_pane=$1
    tmux copy-mode -t "$target_pane"
}

get_cursor_line() {
    local target_pane=$1
    local output
    output=$(tmux display-message -pt "$target_pane" -F '#{copy_cursor_y}')
    echo "${output:-0}"
}

is_in_copy_mode() {
    local target_pane=$1
    local mode
    mode=$(tmux display-message -p -t "$target_pane" -F '#{pane_mode}')
    [[ -n "$mode" ]]
}

redraw_line_numbers() {
    local cursor_line=$1
    local lines
    lines=$(tput lines)
    lines=${lines:-0}

    clear

    printf '\033[38;2;%s;2m' "$COLOR_NUMBERS_RGB"
    seq "$cursor_line" -1 1
    printf '\033[0m'

    printf '\033[38;2;%s;1m 0\033[0m' "$COLOR_ACTIVE_NUMBER_RGB"

    if [[ "$lines" -gt $((cursor_line + 1)) ]]; then
        echo
        printf '\033[38;2;%s;2m' "$COLOR_NUMBERS_RGB"
        seq 1 "$((lines - cursor_line - 2))"
        printf "%s" "$((lines - cursor_line - 1))"
        printf '\033[0m'
    fi
}

update_loop() {
    local target_pane=$1
    local cursor_line=0
    local last_cursor_line=-1

    while is_in_copy_mode "$target_pane"; do
        cursor_line=$(get_cursor_line "$target_pane")

        if [[ "$cursor_line" -ne "$last_cursor_line" ]]; then
            redraw_line_numbers "$cursor_line"
            last_cursor_line=$cursor_line
        fi

        sleep "$LINE_NUMBER_UPDATE_DELAY"
    done
}

restore_pane_width() {
    local target_pane=$1
    local delta=$((LINE_NUMBER_PANE_WIDTH + 1))
    tmux resize-pane -t "$target_pane" -L "$delta"
}

main() {
    local target_pane=$1

    if [[ -z "$target_pane" ]]; then
        open_line_number_split
        exit 0
    else
        enter_copy_mode "$target_pane"
    fi

    update_loop "$target_pane"
    restore_pane_width "$target_pane"
}

main "$@"
