-- 轻量翻译层，跟随 KOReader 界面语言：
--   zh_CN → 简体（表第 1 列），zh_TW → 繁体（表第 2 列），其它语言 → 英文原文。
-- 应用专属字符串查 l10n_zh 表；查不到的通用词（OK/Set/Cancel…）回退 KOReader 自带 gettext。
-- 用法与 gettext 一致：local _ = require("eyerest_l10n"); _("msgid")
-- 额外暴露 _.use_zh 供代码判断是否中文（如状态栏图标位置）。
local gettext = require("gettext")
local map = require("l10n_zh")

local lang = gettext.current_lang or ""
local idx = lang == "zh_CN" and 1 or (lang == "zh_TW" and 2 or nil)

local L = { use_zh = idx ~= nil }
return setmetatable(L, {
    __call = function(_, msgid)
        local e = idx and map[msgid]
        return (e and e[idx]) or gettext(msgid)
    end,
})
