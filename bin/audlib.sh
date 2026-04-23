#!/bin/bash
#shellcheck disable=SC2034

# Media library for bash

# Usage: . ~/bin/audlib.sh
# This is meant to be sourced by other scripts.

# Checks
# The 'return' command is only valid in a sourced script or a function.
if [ -z "$BASH_VERSION" ] || ! (return 0 2>/dev/null); then
    echo "ERROR: lib.sh is only meant to be sourced by bash." >&2
    exit 1
fi

audreset() {
    rm -rf /tmp/audout/
}

# output single file to output queue
# stdin: audio file
audout() {
    if ! [[ -d /tmp/audout ]]; then
        mkdir /tmp/audout
        touch /tmp/audout/files.txt
    fi
    local file="$(mktemp -d /tmp/audout/XXXX --dry-run --suffix=.wav)"
    cat > "$file"
    echo "$file" >> /tmp/audout/files.txt
}

# write audio file from output queue
# $1: file.mp3
splice() {
    outfile="$1"
    if ! [[ -d /tmp/audout ]]; then
        silent 0 > "$outfile"
    else
        wavfile="/tmp/audout/$(basename -s .mp3 "$outfile").wav"
        sed "s/^/file '/; s/$/'/;" < /tmp/audout/files.txt > /tmp/audout/ff.txt
        ffmpeg -v 16 -f concat -safe 0 -i /tmp/audout/ff.txt -c copy "$wavfile" 2>> /tmp/bash.log
        ffmpeg -i "$wavfile" -codec:a libmp3lame -y "$outfile" 2>> /tmp/bash.log
        rm /tmp/audout -rf
    fi
}

say() {
  opts="${1:-}"
  curl -X POST -sSf "http://localhost:59125/api/tts?${opts}" --data @-
}

germansay() {
  say 'voice=de_DE/thorsten_low&lengthScale=2.2'
}

sound() {
  aplay -q /dev/stdin
}

silent() {
  seconds="${1:-2}"
  file="/tmp/silent${seconds}.wav"
  if [[ ! -f "$file" ]]; then
    ffmpeg -v 24 -f lavfi -i "anullsrc=r=44100:cl=mono" -t "$seconds" "$file" 2>> /tmp/bash.log
  fi
  cat "$file"
}
