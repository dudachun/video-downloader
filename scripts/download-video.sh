#!/usr/bin/env bash
set -euo pipefail

DEFAULT_LOCAL_WRAPPER="/Users/dachun/Documents/Codex/2026-06-19/y-t/outputs/yt-dlp/run-yt-dlp.sh"

usage() {
  cat <<'USAGE'
Usage:
  download-video.sh URL [OUTPUT_DIR]

Defaults:
  OUTPUT_DIR=~/Desktop/video-downloads

Environment:
  YTDLP_WRAPPER=/path/to/run-yt-dlp.sh  Use a specific yt-dlp wrapper.
USAGE
}

find_ytdlp() {
  if [[ -n "${YTDLP_WRAPPER:-}" && -x "$YTDLP_WRAPPER" ]]; then
    printf '%s\n' "$YTDLP_WRAPPER"
    return 0
  fi

  if [[ -x "$DEFAULT_LOCAL_WRAPPER" ]]; then
    printf '%s\n' "$DEFAULT_LOCAL_WRAPPER"
    return 0
  fi

  if command -v yt-dlp >/dev/null 2>&1; then
    command -v yt-dlp
    return 0
  fi

  if python3 -c 'import yt_dlp' >/dev/null 2>&1; then
    printf 'python3 -m yt_dlp\n'
    return 0
  fi

  return 1
}

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

url="$1"
output_dir="${2:-$HOME/Desktop/video-downloads}"

if [[ "$url" =~ douyin\.com/.*modal_id=([0-9]+) ]]; then
  url="https://www.douyin.com/video/${BASH_REMATCH[1]}"
fi

ytdlp_command="$(find_ytdlp)" || {
  echo "yt-dlp was not found. Install yt-dlp or set YTDLP_WRAPPER=/path/to/run-yt-dlp.sh" >&2
  exit 2
}

mkdir -p "$output_dir"

# shellcheck disable=SC2086
exec $ytdlp_command \
  -f "bv*+ba/bestvideo*+bestaudio/best" \
  --merge-output-format mp4 \
  --no-playlist \
  -o "$output_dir/%(title).120B-%(id)s.%(ext)s" \
  "$url"
