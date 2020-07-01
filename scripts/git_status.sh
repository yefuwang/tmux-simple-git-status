#!/usr/bin/env bash

PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")
cd $PANE_PATH

# Returns the number of untracked files
function evil_git_num_untracked_files {
   expr `git status --porcelain 2>/dev/null| grep "^??" | wc -l`
}

git_changes() {
  local changes=$(git diff --shortstat | sed 's/^[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*/\1;\2;\3/')
  local changes_array=(${changes//;/ })
  local result=()

  if [[ -n ${changes_array[0]} ]]; then
    result+=("~${changes_array[0]}")
  fi

  if [[ -n ${changes_array[1]} ]]; then
    result+=("+${changes_array[1]}")
  fi

  if [[ -n ${changes_array[2]} ]]; then
    result+=("-${changes_array[2]}")
  fi

  local untracked=$(evil_git_num_untracked_files)

  if [ "${untracked}" -ne "0" ]; then
      result+=("..u${untracked}")
  fi

  local joined=$(printf " %s" "${result[@]}")
  local joined=${joined:1}

  if [[ -n $joined ]]; then
    echo "$joined "
  fi
}

git_status() {
  local status=$(git rev-parse --abbrev-ref HEAD)
  local remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
  local changes=$(git_changes)

  if [[ -n $status ]]; then
      printf "▓${status}▓${remote} $changes"
  fi
}

main() {
  git_status
}

main
