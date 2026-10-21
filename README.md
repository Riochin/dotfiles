# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理している個人用dotfiles。

## セットアップ(新しいMacの場合)

```sh
brew install chezmoi
chezmoi init --apply Riochin/dotfiles
```

続けて、chezmoiの外で管理しているものを設定する:

```sh
brew install mise jq
mise install                                               # ~/.config/mise/config.toml の言語を入れる
brew tap homebrew/autoupdate
brew autoupdate start 86400 --upgrade --cleanup            # brew を毎日自動で更新する
brew pin mysql mysql@8.0 postgresql@14                     # データベースは自動で上げない
```

## 管理しているもの

| ファイル / ディレクトリ | 内容 |
| --- | --- |
| `dot_zshrc` → `~/.zshrc` | zsh設定(oh-my-zsh, zinit, anyframe, WezTermのcmd+delete用bindkeyなど) |
| `dot_zprofile` → `~/.zprofile` | zshログインシェル設定 |
| `dot_zsh_greeting.zsh` → `~/.zsh_greeting.zsh` | 起動時の挨拶と、brew・miseの更新件数の表示 |
| `dot_p10k.zsh` → `~/.p10k.zsh` | Powerlevel10kのプロンプト設定 |
| `dot_gitconfig` → `~/.gitconfig` | git設定(HTTPSの証明書はbrewのca-certificatesを使う) |
| `dot_config/mise/config.toml` → `~/.config/mise/config.toml` | 言語の実行環境(Node / Python / Go / Ruby / uv)と `SSL_CERT_FILE` |
| `private_Library/LaunchAgents/` → `~/Library/LaunchAgents/` | miseの週次更新(毎週月曜10:00に同じ系列の最新版へ上げる) |
| `run_onchange_after_load-mise-weekly-upgrade.sh.tmpl` | 上のplistが変わったときに、launchdへ登録し直すスクリプト |
| `dot_config/wezterm/` → `~/.config/wezterm/` | WezTerm設定(テーマ、タブバー、キーバインド) |
| `dot_config/private_karabiner/` → `~/.config/karabiner/` | Karabiner-Elements設定(パーミッション600を保持) |
| `dot_config/git/` → `~/.config/git/` | グローバルgitignore |
| `dot_config/zed/` → `~/.config/zed/` | Zedエディタ設定 |
| `dot_vscode/` → `~/.vscode/` | VS Code CLI関連設定 |

`private_` プレフィックスが付いているファイル/ディレクトリは、元のパーミッション(600/700)を保つようchezmoiが自動的に付与したもの。中身を編集する際は `chezmoi edit <path>` か、対象を直接編集してから `chezmoi re-add` でソースに反映する。

## 特記事項: cmd+delete / option+delete

キーボードは Caps Lock → Cmd に変換しており(Karabiner)、物理Cmdキーは英数キーに割り当て直しているため、Cmd修飾キーを出せるのは実質Caps Lockのみ。

- **Option+Delete**(単語削除): WezTerm側で `ESC + Backspace` を送出し、zshのデフォルトバインド(`backward-kill-word`)にそのまま乗せている。
- **Cmd+Delete**(行頭まで削除): Karabiner側でWezTermがフォアグラウンドの時だけ `left_command + delete_or_backspace` を `Ctrl-X Ctrl-H` に変換し、`dot_zshrc` 側で `bindkey '^X^H' backward-kill-line` にバインドしている。WezTerm単体の修飾キー判定に依存しない、確実な経路。

## 変更を反映する

ライブファイルを直接編集した場合はソースに取り込む。引数なしだと変更のある管理ファイルが全部取り込まれるので、ファイルを指定する:

```sh
chezmoi re-add ~/.zshrc
```

取り込み忘れを防ぐなら、はじめから chezmoi 経由で編集する:

```sh
chezmoi edit --apply ~/.zshrc
```

ソース側を編集した場合は反映する:

```sh
chezmoi diff   # 事前確認
chezmoi apply
```
