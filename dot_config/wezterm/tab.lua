local wezterm = require("wezterm")
local module = {}

-- -----------------------------------------------------------------------------
-- 色の設定: ここを書き換えるだけで配色を変えられます
-- -----------------------------------------------------------------------------
local COLORS = {
  -- アクティブ（選択中）タブ
  active_bg = "#cba6f7", -- 背景色（紫）
  active_fg = "#1e1e2e", -- 文字色（ダーク）

  -- 非アクティブタブ
  inactive_bg = "none", -- "none" で透過
  inactive_fg = "#f5c2e7", -- 淡いピンク
}

-- タブの左右につける半円（丸タブの見た目を作る）

-- -----------------------------------------------------------------------------
-- メイン処理
-- -----------------------------------------------------------------------------
function module.apply_to_config(config)
  -- タブバー自体の設定
  config.use_fancy_tab_bar = true
  config.tab_bar_at_bottom = false -- タブバーを上に表示
  config.hide_tab_bar_if_only_one_tab = false -- タブが1つでも表示する
  config.show_new_tab_button_in_tab_bar = true -- 「+」ボタンを表示
  config.tab_max_width = 50 -- タブの最大幅

  -- タブのタイトルを描画する
  wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    -- アクティブかどうかで色を切り替える
    local bg = tab.is_active and COLORS.active_bg or COLORS.inactive_bg
    local fg = tab.is_active and COLORS.active_fg or COLORS.inactive_fg

    -- タブ番号 + パネルのタイトル
    -- 左の余白(1) + 左右の半円(2) のぶんを max_width から引いて切り詰めないと、
    -- タブ幅の上限を超えて右の半円が切れる
    local min_width = 10
    local raw = string.format("%d: %s", tab.tab_index + 1, tab.active_pane.title)
    if #raw < min_width then
      raw = raw .. string.rep(" ", min_width - #raw)
    end
    local title = "  " .. raw .. "  "
    title = wezterm.truncate_right(title, max_width)

    return {
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Text = title },
    }
  end)
end

return module
