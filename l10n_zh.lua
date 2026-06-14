-- Eye Rest 中文翻译对照表（可编辑）
-- 格式： ["English msgid"] = { "简体 zh_CN", "繁體 zh_TW" }
--   · 左边英文 key 是源码里的原文，**不要改**（改了就对不上）。
--   · 右边两列随意改：第 1 个简体，第 2 个繁体。
--   · 含 %1 / %2 的是占位符（数字/时间会替换进去），位置可挪但要保留。
--   · 没填或留空的条目会自动回退到英文 / KOReader 自带翻译。
--
-- 接线后行为：
--   · 跟随系统语言：zh_CN 取第 1 列，zh_TW 取第 2 列，其它语言用英文原文。
--   · 状态栏图标 ☕ 会在代码里**后置**（呈现为「5分钟后☕」），所以这里只写文字。

return {

  -- ── 名称 / 描述 ──
  ["Eye Rest"] = { "护眼提醒", "護眼提醒" },
  ["Reminds you to rest your eyes with mini and long breaks, timed by how long you actually read."] =
    { "依你的实际阅读时长，用迷你休息和长休息提醒你放松眼睛。",
      "依你的實際閱讀時間，用迷你休息和長休息提醒你放鬆眼睛。" },

  -- ── 休息类型 ──
  ["Mini break"] = { "迷你休息", "迷你休息" },
  ["Long break"] = { "长休息", "長休息" },

  -- ── 休息倒计时屏（breakview）──
  ["%1 left"]              = { "还剩 %1", "還剩 %1" },
  ["Please rest your eyes."] = { "请让眼睛休息一下。", "請讓眼睛休息一下。" },
  ["Skip"]                 = { "跳过", "跳過" },
  ["Read a bit more"]      = { "再读一会儿", "再讀一會兒" },

  -- ── 睡眠提醒屏（alarmview）──
  ["Time to sleep"] = { "该睡觉了", "該睡覺了" },
  ["Your reading timer is up — time to rest your eyes and sleep."] =
    { "阅读计时到了——该休息眼睛、去睡觉了。", "閱讀計時到了——該休息眼睛、去睡覺了。" },
  ["OK"] = { "确定", "確定" },

  -- ── 状态栏倒计时（图标在代码里后置）──
  ["in %1min"]  = { "%1分钟后", "%1分鐘後" },
  ["in <1min"]  = { "<1分钟",  "<1分鐘"  },

  -- ── 主菜单 ──
  ["Eye Rest (next break in %1)"] = { "护眼提醒（%1后休息）", "護眼提醒（%1後休息）" },
  ["Breaks: off"]                 = { "休息提醒：已关闭", "休息提醒：已關閉" },
  ["Next break in %1"]            = { "距下次休息 %1", "距下次休息 %1" },
  ["Next long break after %1 break(s)"] =
    { " %1 次迷你休息后进入长休息", " %1 迷你休息後進入長休息" },
  ["Enable breaks"]   = { "启用休息提醒", "啟用休息提醒" },
  ["Skip to next"]    = { "立即休息", "立即休息" },
  ["Reset breaks"]    = { "重置循环", "重置循環" },
  ["Settings"]        = { "设置", "設定" },

  -- ── 睡眠定时器（菜单）──
  ["Sleep timer"]              = { "睡眠定时器", "睡眠定時器" },
  ["Sleep timer: %1 min left"] = { "睡眠定时：还剩 %1 分钟", "睡眠定時：還剩 %1 分鐘" },
  ["Sleep timer: off"]         = { "睡眠定时：未开启", "睡眠定時：未開啟" },
  ["Reminds you in %1 min"]    = { "%1 分钟后提醒你", "%1 分鐘後提醒你" },
  ["No timer set"]             = { "未设置定时", "未設定定時" },
  ["Set timer…"]               = { "设置定时…", "設定定時…" },
  ["Cancel timer"]             = { "取消定时", "取消定時" },
  ["Hours : minutes"]          = { "小时 : 分钟", "小時 : 分鐘" },
  ["Start"]                    = { "开始", "開始" },

  -- ── 设置项 ──
  ["Mini break interval: every %1 min"] = { "迷你休息间隔：每 %1 分钟", "迷你休息間隔：每 %1 分鐘" },
  ["Mini break duration"]               = { "迷你休息时长", "迷你休息時長" },
  ["Long break: every %1 mini breaks (0=off)"] =
    { "长休息：每 %1 次迷你休息（0=关）", "長休息：每 %1 次迷你休息（0=關）" },
  ["Long break duration"]               = { "长休息时长", "長休息時長" },
  ["Minutes : seconds"]                 = { "分钟 : 秒", "分鐘 : 秒" },
  ["Set"]                               = { "设定", "設定" },
  ["Strict mode"]                       = { "严格模式", "嚴格模式" },
  ["Postpone: %1 min"]                  = { "推迟：%1 分钟", "延後：%1 分鐘" },
  ["Show countdown in header"]          = { "在顶栏显示倒计时", "在頂欄顯示倒數" },
  ["Show countdown in footer"]          = { "在底栏显示倒计时", "在底欄顯示倒數" },
  ["How Eye Rest works"]                = { "护眼提醒怎么用", "護眼提醒怎麼用" },

  -- ── 时长 / 剩余时间格式 ──
  ["%1 s"]         = { "%1 秒",     "%1 秒"     },
  ["%1 min"]       = { "%1 分钟",   "%1 分鐘"   },
  ["%1 min %2 s"]  = { "%1 分 %2 秒", "%1 分 %2 秒" },
  ["~%1 min"]      = { "约 %1 分钟", "約 %1 分鐘" },
  ["<1 min"]       = { "<1 分钟",   "<1 分鐘"   },

  -- ── 长按帮助文案 ──
  ["Turn the break reminders on or off. While on, time is counted only while you are actually reading a book."] =
    { "开启或关闭休息提醒。开启后，只在你真正打开书本阅读时计时。",
      "開啟或關閉休息提醒。開啟後，只在你真正打開書本閱讀時計時。" },
  ["Start a mini break or a long break right now, instead of waiting for the timer."] =
    { "立刻开始一次迷你休息或长休息，不用等计时。",
      "立刻開始一次迷你休息或長休息，不用等計時。" },
  ["In strict mode the break screen has no Skip / Read-more buttons; you must wait out the countdown."] =
    { "严格模式下，休息界面没有「跳过 / 再读一会儿」按钮，必须等倒计时结束。",
      "嚴格模式下，休息畫面沒有「跳過 / 再讀一會兒」按鈕，必須等倒數結束。" },
  ["A one-shot countdown, separate from the eye breaks. When it runs out a full-screen reminder tells you to stop reading — useful as a bedtime limit, e.g. read for one hour then sleep."] =
    { "一次性倒计时，和护眼休息相互独立。时间到后会全屏提醒你停止阅读——适合当睡前限制，比如读一小时就睡。",
      "一次性倒數，和護眼休息相互獨立。時間到後會全螢幕提醒你停止閱讀——適合當睡前限制，比如讀一小時就睡。" },
  ["Start the cycle over: clear the mini-break count and restart timing the current stretch from now."] =
    { "重新开始循环：清空迷你休息计数，从现在起重新计时当前这一段。",
      "重新開始循環：清空迷你休息計數，從現在起重新計時當前這一段。" },
  ["Show '☕ in N min' (time to the next break) in the bottom status bar. The footer must allow external content: tap the bottom bar → Status bar settings → turn on 'Show external content', otherwise nothing shows."] =
    { "在底部状态栏显示「N分钟后☕」（距下次休息的时间）。底栏必须允许外部内容：点底栏 → 状态栏设置 → 打开「显示外部内容」，否则不显示。",
      "在底部狀態列顯示「N分鐘後☕」（距下次休息的時間）。底列必須允許外部內容：點底列 → 狀態列設定 → 開啟「顯示外部內容」，否則不顯示。" },

  -- ── Dispatcher 动作（手势/快捷可绑定）──
  ["Toggle reading breaks"]             = { "开关阅读休息提醒", "開關閱讀休息提醒" },
  ["Reading breaks: mini break now"]    = { "阅读休息：立即迷你休息", "閱讀休息：立即迷你休息" },
  ["Reading breaks: long break now"]    = { "阅读休息：立即长休息", "閱讀休息：立即長休息" },

  -- ──「护眼提醒怎么用」长说明（含示意图，注意占位对齐）──
  ["Eye Rest follows the 20-20-20 rule: every 20 minutes of reading, look about 20 feet (6 m) away for 20 seconds to relax your eyes.\n\n    Read 20m  →  ☕ 20s   (mini break)\n    Read 20m  →  ☕ 20s   (mini break)\n    Read 20m  →  ☕ 5m    (long break)\n    … then repeat\n\nTime counts only while a book is open, and pauses when you close the book or the device goes to sleep.\n\nOn a normal break you can Skip it or tap \"Read a bit more\" to postpone. Turn on Strict mode to make breaks unskippable. Long-press any menu item to see what it does."] =
    {
[[护眼提醒遵循 20-20-20 法则：每阅读 20 分钟，望向约 6 米（20 英尺）外的地方 20 秒，放松眼睛。

    阅读20分  →  ☕ 20秒   （迷你休息）
    阅读20分  →  ☕ 20秒   （迷你休息）
    阅读20分  →  ☕ 5分    （长休息）
    … 如此循环

只在打开书本时计时；关书或设备休眠时暂停。

普通休息可以点「跳过」，或点「再读一会儿」推迟。开启严格模式后休息无法跳过。长按任意菜单项即可查看它的说明。]],
[[護眼提醒遵循 20-20-20 法則：每閱讀 20 分鐘，望向約 6 公尺（20 英尺）外的地方 20 秒，放鬆眼睛。

    閱讀20分  →  ☕ 20秒   （迷你休息）
    閱讀20分  →  ☕ 20秒   （迷你休息）
    閱讀20分  →  ☕ 5分    （長休息）
    … 如此循環

只在打開書本時計時；關書或裝置休眠時暫停。

一般休息可以點「跳過」，或點「再讀一會兒」延後。開啟嚴格模式後休息無法跳過。長按任意選單項即可查看它的說明。]],
    },

}
