# ターミナル起動時に時間帯別の挨拶を大きく表示する
# ※ Powerlevel10k の instant prompt キャッシュに巻き込まれないよう、
#   このファイルは ~/.zshrc の instant prompt ブロックより前で source すること。

_show_greeting() {
  emulate -L zsh
  [[ -o interactive ]] || return
  [[ -t 1 ]] || return
  command -v figlet >/dev/null 2>&1 || return

  local hour=$((10#$(date +%H)))
  local greeting emoji
  if   (( hour >= 5  && hour < 10 )); then greeting="Good Morning,";   emoji="🌅"
  elif (( hour >= 10 && hour < 17 )); then greeting="Good Afternoon,"; emoji="☀️"
  elif (( hour >= 17 && hour < 21 )); then greeting="Good Evening,";   emoji="🌇"
  else                                     greeting="Good Night,";     emoji="🌙"
  fi

  # 端末幅に収まる範囲でできるだけ大きいフォントを選ぶ
  local cols=${COLUMNS:-80}
  local -a fonts=(big standard small)
  local font width w1 w2
  for font in $fonts; do
    w1=$(figlet -w 999 -f "$font" "$greeting" 2>/dev/null | awk '{ if (length>m) m=length } END{ print m+0 }')
    w2=$(figlet -w 999 -f "$font" "Riochin"   2>/dev/null | awk '{ if (length>m) m=length } END{ print m+0 }')
    width=$(( w1 > w2 ? w1 : w2 ))
    if (( width <= cols )); then
      break
    fi
  done

  # Catppuccin Mocha 系のグラデーション（mauve → pink → lavender）
  local -a rgb=(
    "203;166;247"
    "218;178;237"
    "233;186;227"
    "245;194;231"
    "212;192;243"
    "180;190;254"
  )

  # 端末幅いっぱいの装飾枠
  local unit="✦ ⋆ ✧ ⋆ "
  local border=""
  while (( ${#border} < cols )); do
    border+="$unit"
  done
  border="${border[1,cols]}"

  printf '\033[38;2;180;190;254m%s\033[0m\n' "$border"

  local idx=1 line color
  while IFS= read -r line; do
    color="${rgb[idx]}"
    printf '\033[38;2;%sm%s\033[0m\n' "$color" "$line"
    idx=$(( idx % ${#rgb[@]} + 1 ))
  done < <(figlet -w 999 -f "$font" "$greeting"; figlet -w 999 -f "$font" "Riochin")

  printf '\033[38;2;180;190;254m%s\033[0m\n' "$border"
  printf '\033[38;2;245;194;231m  %s  %s  %s\033[0m\n\n' "$emoji" "$(date '+%Y/%m/%d (%a)  %H:%M')" "$emoji"
}

_show_greeting
unset -f _show_greeting
