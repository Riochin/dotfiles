-- wezterm APIを読み込む
local wezterm = require("wezterm")

-- ここに設定内容を記述
local config = wezterm.config_builder()

-- 設定ファイルの変更を自動で読み込む
config.automatically_reload_config = true

-- font
config.font_size = 18.0
config.font = wezterm.font(
    "Terminus (TTF)"
)

-- background
config.window_background_opacity = 0.6
config.macos_window_background_blur = 40

config.background = {
  {
    source = { File = wezterm.config_dir .. "/background.gif" },
    opacity = 0.5,
    hsb = { brightness = 0.7, saturation = 1.2 },
    horizontal_align = "Center",
    vertical_align = "Middle",
    repeat_x = "Repeat",
    repeat_y = "Repeat",
  },
  {
    source = { Color = "#0d0515" },
    opacity = 0.6,
    height = "100%",
    width = "100%",
  },
}

-- color scheme
config.color_scheme = "Catppuccin Mocha"

-- tab colors
config.colors = {
  tab_bar = {
    background = "#1e1e2e",
    active_tab = {
      bg_color = "#f5c2e7",
      fg_color = "#1e1e2e",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#45475a",
    },
    inactive_tab_hover = {
      bg_color = "#313244",
      fg_color = "#cba6f7",
    },
    new_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#45475a",
    },
    new_tab_hover = {
      bg_color = "#313244",
      fg_color = "#f5c2e7",
    },
  },
}

-- window
config.window_decorations = "RESIZE"

config.window_frame = {
  font = wezterm.font("Terminus (TTF)", { bold = true }),
  font_size = 14,
  active_titlebar_bg = "#1e1e2e",
  inactive_titlebar_bg = "#45475a",
  active_titlebar_fg = "#1e1e2e",
  inactive_titlebar_fg = "#6c7086",
  active_titlebar_border_bottom = "#9775d6",
  inactive_titlebar_border_bottom = "#313244",
  button_fg = "#1e1e2e",
  button_bg = "#cba6f7",
  button_hover_fg = "#1e1e2e",
  button_hover_bg = "#f5c2e7",
}

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- アナログ感（テキストをわずかに暗く・くすませる）
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 0.9,
  brightness = 0.85,
}

-- キーバインド
config.keys = {
  -- option + delete: カーソル前の単語を削除 (zshの ESC+Backspace = backward-kill-word にマッチさせる)
  {
    key = "Backspace",
    mods = "OPT",
    action = wezterm.action.SendString("\x1b\x7f"),
  },
  -- cmd + delete: カーソル位置から行頭まで削除 (dot_zshrc 側で ^X^H を backward-kill-line にbind)
  {
    key = "Backspace",
    mods = "CMD",
    action = wezterm.action.SendString("\x18\x08"),
  },
}

require("tab").apply_to_config(config)

-- 最後に、weztermに設定を渡す
return config
