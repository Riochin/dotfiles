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

# brew と mise の更新件数を調べて $1 に書く。時間がかかるので裏で実行する
_refresh_update_status() {
  emulate -L zsh
  local out=$1 tmp="$1.$$"
  mkdir -p "${out:h}"
  local pinned=$(brew list --pinned 2>/dev/null)
  local brew_n=$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null | grep -vxF -e "${pinned:-__none__}" -f <(print -r -- "$pinned") | grep -c .)
  local mise_list=$(cd ~ && mise outdated --json 2>/dev/null | jq -r 'to_entries | map("\(.key) \(.value.current)→\(.value.latest)") | join(", ")' 2>/dev/null)
  local mise_n=0
  [[ -n $mise_list ]] && mise_n=${#${(s:, :)mise_list}}
  print -r -- "$brew_n" "$mise_n" "$mise_list" > "$tmp" && mv "$tmp" "$out"
}

# 挨拶の下に、brew と mise の更新件数を 1 行出す。
# 件数は 6 時間ごとに裏で取り直し、表示は前回の結果を使うので、起動は遅くならない
_show_update_status() {
  emulate -L zsh
  [[ -o interactive && -t 1 ]] || return
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/update-status
  local now=$(date +%s) mtime=0
  [[ -f $cache ]] && mtime=$(stat -f %m "$cache")
  if (( now - mtime > 6 * 3600 )); then
    _refresh_update_status "$cache" &>/dev/null &!
  fi
  [[ -r $cache ]] || return

  local brew_n mise_n mise_list
  read -r brew_n mise_n mise_list < "$cache"
  if (( brew_n == 0 && mise_n == 0 )); then
    printf '\033[38;2;166;227;161m  ✓ brew・mise は最新です\033[0m\n\n'
    return
  fi
  local msg="  ↑ 更新あり  brew ${brew_n}件 / mise ${mise_n}件"
  [[ -n $mise_list ]] && msg+="（${mise_list}）"
  printf '\033[38;2;250;179;135m%s\033[0m\n' "$msg"
  printf '\033[38;2;147;153;178m    brew は毎日、mise は毎週月曜に自動で更新されます\033[0m\n\n'
}

_show_greeting
_show_update_status
unset -f _show_greeting _show_update_status
