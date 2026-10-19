#!/usr/bin/env bash
# Mac / Linux: downloads every photo listed in images/image-list.txt from Unsplash.
cd "$(dirname "$0")" || exit 1
trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }
ok=0; fail=0
while IFS='|' read -r path id width || [ -n "$path" ]; do
  path="$(trim "$path")"; id="$(trim "$id")"; width="$(trim "$width")"
  case "$path" in ''|\#*) continue ;; esac
  [ -z "$id" ] && continue
  [ -z "$width" ] && width=1080
  mkdir -p "$(dirname "$path")"
  printf '  %-45s' "$path"
  if curl -fsSL -A "Mozilla/5.0" "https://unsplash.com/photos/$id/download?force=true&w=$width" -o "$path.part" \
     && [ "$(wc -c < "$path.part")" -gt 5000 ]; then
    mv -f "$path.part" "$path"; echo "OK"; ok=$((ok+1))
  else
    rm -f "$path.part"; echo "failed - kept the old image"; fail=$((fail+1))
  fi
done < images/image-list.txt
echo; echo "  Done: $ok photos downloaded, $fail failed."
bash ./update-download-files.sh
