#!/usr/bin/env bash
# Mac / Linux: rebuilds images/data/*.js for every image in /images
# (lets Download work when the site is opened by double-click).
cd "$(dirname "$0")" || exit 1
mkdir -p images/data && rm -f images/data/*.js
n=0
while IFS= read -r -d '' f; do
  rel="${f#images/}"
  ext="$(printf '%s' "${f##*.}" | tr 'A-Z' 'a-z')"
  case "$ext" in jpg|jpeg) mime=image/jpeg ;; png|webp|gif) mime="image/$ext" ;; *) continue ;; esac
  key="images/$rel"; key="${key//\\/\\\\}"; key="${key//\"/\\\"}"
  printf '(window.__WC_IMG=window.__WC_IMG||{})["%s"]='"'"'data:%s;base64,%s'"'"';' \
    "$key" "$mime" "$(base64 < "$f" | tr -d '\n')" > "images/data/${rel//\//__}.js"
  n=$((n+1))
done < <(find images -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) \
          -not -path 'images/data/*' -not -path 'images/icons/*' -print0)
echo "  Download files updated ($n images)."
