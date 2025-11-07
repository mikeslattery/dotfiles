#!/bin/bash
#shellcheck disable=SC2034

# Usage: . ~/bin/lib.sh
# This is meant to be sourced by other scripts.
# This should only include things that must be functions or variables.
# Anything else should be in ~/bin

# Checks
# The 'return' command is only valid in a sourced script or a function.
if [ -z "$BASH_VERSION" ] || ! (return 0 2>/dev/null); then
    echo "ERROR: lib.sh is only meant to be sourced by bash." >&2
    exit 1
fi

# EXIT trap management
_exit_traps=()
_exit_trap() {
    for t in "${_exit_traps[@]}"; do
        eval "$t"
    done
}
# Override trap to support multiple EXIT traps
trap() {
    if [[ "$2" == "EXIT" ]] && [[ "$#" -eq 2 ]]; then
        _exit_traps+=("$1")
    else
        command trap "$@"
    fi
}
# command trap _exit_trap EXIT

# Strict mode and error reporting
set -eu -o pipefail
set -o errtrace
export IFS=$'\n'
_print_stack_trace() {
    local exit_code=$?
    local line_no=${BASH_LINENO[0]}
    local source_file=${BASH_SOURCE[1]}
    local command="${BASH_COMMAND}"

    echo -e "\nError: Command '${command}' failed with exit code ${exit_code} at ${source_file}:${line_no}" >&2
    echo "Source code:" >&2
    sed -n "${line_no}s/^/    /p" "${source_file}" >&2
    echo "Stack trace:" >&2
    local i=0
    while caller $i; do
        ((i++))
    done | sed 's/^/    /' >&2
}
_print_lineno() {
    local line_no=${BASH_LINENO[0]}
    local source_file=${BASH_SOURCE[1]}

    echo -e "\nStopped at ${source_file}:${line_no}" >&2
}
# command trap _print_stack_trace ERR
# command trap _print_lineno INT

# Path of the script
DIRNAME="$(cd "$(dirname "$0")"; pwd; )"
BASENAME="$(basename "$0")"
ABSOLUTENAME="${DIRNAME}/${BASENAME}"
DOMAIN="${DOMAIN:-$BASENAME}"

# Explicit directory locations
export TMPDIR="${TMPDIR:-/tmp}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export CACHE_DIR="${XDG_CACHE_HOME}/${DOMAIN}"
if [[ -d "$XDG_CONFIG_HOME/nvim" ]]; then
    export NVIM_APPNAME="${NVIM_APPNAME:-nvim}"
fi

TAB=$'\t'

# if [[ -f .env ]]; then
#     source .env
# fi

isroot() {
  [[ "$(id -u)" -eq 0 ]]
}

# xargs for functions
# All functions and env vars will be accessible.
# default xargs options: -d"\n" -r
# No space in xargs options. Bad: -n 2.  Good: -n2 or --max-args=2
fargs() {
  # Find the index of the first non-option argument, which should be the command
  local cmd_start_index=1
  for arg in "$@"; do
    if [[ "$arg" != -* ]]; then
      break
    fi
    ((cmd_start_index++))
  done

  # Extract xargs options and the command
  local opts=("${@:1:$((cmd_start_index - 1))}")
  local cmd=("${@:$cmd_start_index}")
  if [[ ${#cmd[@]} -eq 0 ]]; then cmd=("echo"); fi

  # xargs builds command strings by passing stdin items as arguments to `echo`.
  # The resulting strings (e.g., "my_func arg1") are then executed by `eval`.
  # This allows xargs to call shell functions, which are not exported to subshells.
  eval "$(xargs -d"\n" -r "${opts[@]}" bash -c 'printf "%q " "$@"; echo' -- "${cmd[@]}")"
}

x() {
    fargs "$@"
}

log() {
    echo "$(date +%T) $*" | tee -a "$TMPDIR/bash.log" >&2
}

# Usage: operation || die "reason"
die() {
    log "ERROR: $*"
    exit 1
}

has() {
    command -v "$@" >/dev/null
}

requires() {
    has "$@" || die "Required to be installed: $*"
}

printargs() {
    printf $'%s\n' "$@"
}

# Convert stdin to an array, EOL-delimited
# Example: cat list.txt | readarray MYVAR
readarray() {
    command readarray -d$'\n' -t "$@"
}

mkparent() {
    printargs "$@" | x dirname | x mkdir -p
}

# cache output of a command line
# usage: cache [-f] <key> <command...>
#   -f will ignore cached data, if you want to always rebuild
# delete usage: cache -f <key>
cache() {
    local force
    if [[ "$1" == "-f" ]]; then
        force="true"
        shift
    else
        force="false"
    fi
    local key
    local keyfile
    if [[ "$1" == /* ]]; then
        # absolute path
        keyfile="$1"; shift
        key="$(basename "$keyfile")"
    else
        # relative path
        key="$1"; shift
        keyfile="${CACHE_DIR}/${key}"
    fi
    local tmpkeyfile="${TMPDIR}/${DOMAIN}/${key}"


    mkparent "$keyfile"
    mkparent "$tmpkeyfile"

    if [[ "$#" -eq 0 ]]; then
        # when no command is given, this is a delete operation
        if [[ "$force" == "true" ]]; then
            rm -f "$keyfile"
        else
            log "ERROR: no command given.  Fyi, delete requires -f"
        fi
    elif [[ "$force" == "false" ]] && [[ -f "$keyfile" ]]; then
        # cache hit.  but skip on -f
        cat "$keyfile"
    else
        # try the command, on success save to cache
        if "$@" | tee "$tmpkeyfile"; then
            mv "$tmpkeyfile" "$keyfile"
        else
            return "$?"
        fi
    fi
}

# usage: curljq <jq-query> <curl-args...>
curljq() {
    query="$1"; shift
    curl -sSf "$@" \
        -H 'content-type: application/json' |
        jq "$query"
}

# read line from stdin to stdout.  $1 optional prompt.
readline() {
    local _lines
    read -p "${1:-}" -r _lines
    echo "$_lines"
}

_temp_files=()
_CAPTURE_DIR="${TMPDIR}/${DOMAIN}/capture"

# usage: mktmp <suffix> [<basename>]
mktmp() {
    local suffix="$1"; shift
    local basename="${2:-$DOMAIN}"
    local tmp_file="$(mktemp --suffix="$suffix" -u "${basename}.XXXXXX")"
    _temp_files+=("$tmp_file")
    echo "$tmp_file"
}
_cleanup_temp_files() {
    # mktmp
    rm -f "${_temp_files[@]}"

    # cache
    # rm -rf "${_CAPTURE_DIR}/"
}
# trap _cleanup_temp_files EXIT

# usage: capture [<key>]
# Captures output for later use
capture() {
    mkdir -p "$_CAPTURE_DIR"
    tmp_file="$_CAPTURE_DIR/${1:-general}.txt"
    cat > "$tmp_file"
 }

captured() {
    tmp_file="$_CAPTURE_DIR/${1:-general}.txt"
    cat "$tmp_file"
}

# dispatchers for a subcommand script
# Usage at bottom of a file: dispatch "$@"
# A usage() function should exist at top.
dispatch() {
    [[ "$#" -gt 0 ]] || { usage | sed "s/\\\t/${TAB}/g;" >&2; exit 1; }

    local command="$1"
    shift

    "$command" "$@"
}

# Useful snippets
# # Read from stdin into an array
# readarray -d$'\n' array [-o start_index] [-s start_line] [-n max_lines]
# # Write array to stdout
# printf $'%s\n' "${array[@]}"
