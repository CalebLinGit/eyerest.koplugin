local DateTimeWidget = require("ui/widget/datetimewidget")
local Dispatcher = require("dispatcher")
local Event = require("ui/event")
local InfoMessage = require("ui/widget/infomessage")
local SpinWidget = require("ui/widget/spinwidget")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local time = require("ui/time")
local _ = require("gettext")
local T = require("ffi/util").template
local logic = require("breaklogic")
local BreakView = require("breakview")

local DEFAULTS = {
    mini_interval_minutes = 25,
    mini_duration_seconds = 300,
    long_break_every = 3,
    long_duration_seconds = 900,
    postpone_minutes = 5,
}
local MORNING_HOUR = 6

-- seconds -> "M:SS" (or "H:MM:SS" past an hour)
local function fmtClock(s)
    s = math.floor(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, sec) end
    return string.format("%d:%02d", m, sec)
end

local EyeRest = WidgetContainer:extend{
    name = "eyerest",
}

-- ---------- 设置访问 ----------
function EyeRest:get(key)
    local v = self.settings[key]
    if v == nil then return DEFAULTS[key] end
    return v
end

function EyeRest:intervalSeconds()
    return self:get("mini_interval_minutes") * 60
end

-- ---------- 计时核心：只累计阅读时间 ----------
function EyeRest:isReading()
    return self.ui ~= nil and self.ui.document ~= nil
end

function EyeRest:elapsed()
    local e = self.settings.elapsed_seconds or 0
    if self.reading_start then
        e = e + time.to_s(time.now() - self.reading_start)
    end
    return e
end

function EyeRest:remaining()
    return math.max(self:intervalSeconds() - self:elapsed(), 0)
end

function EyeRest:counting()
    return self.reading_start ~= nil
end

-- 开始/恢复累计并调度休息触发
function EyeRest:startCounting()
    if not self.settings.enabled then return end
    if logic.isPaused(self.settings.paused_until, os.time()) then return end
    if self.break_active then return end
    if self.reading_start then return end
    if not self:isReading() then return end
    self.reading_start = time.now()
    UIManager:scheduleIn(self:remaining(), self.break_due_cb)
    self:startStatusUpdates()
end

-- 暂停累计（保存已读秒数），用于关书/休眠/触发休息
function EyeRest:pauseCounting()
    if self.reading_start then
        self.settings.elapsed_seconds = (self.settings.elapsed_seconds or 0)
            + time.to_s(time.now() - self.reading_start)
        self.reading_start = nil
    end
    UIManager:unschedule(self.break_due_cb)
    self:stopStatusUpdates()
end

-- ---------- 休息触发与结果 ----------
function EyeRest:triggerBreak(force_type)
    if not self.settings.enabled then return end
    if not self:isReading() then return end
    if self.break_active then return end
    self:pauseCounting()
    local bt = force_type
        or logic.nextBreakType(self.settings.break_count or 0, self:get("long_break_every"))
    local dur = bt == "long" and self:get("long_duration_seconds")
        or self:get("mini_duration_seconds")
    self.break_active = true
    self.timer_view = BreakView:new{
        break_type = bt,
        duration = dur,
        strict = self.settings.strict_mode or false,
        on_done = function() self:onBreakResult(bt, "done") end,
        on_skip = function() self:onBreakResult(bt, "skip") end,
        on_postpone = function() self:onBreakResult(bt, "postpone") end,
    }
    UIManager:show(self.timer_view)
end

function EyeRest:onBreakResult(break_type, result)
    self.break_active = false
    self.timer_view = nil
    if result == "postpone" then
        -- 不推进计数；把 elapsed 设成「只剩 postpone_minutes」，下次弹同类型
        self.settings.elapsed_seconds = math.max(
            self:intervalSeconds() - self:get("postpone_minutes") * 60, 0)
    else
        -- done / skip：推进循环，开始新一段
        self.settings.break_count = logic.advance(self.settings.break_count or 0, break_type)
        self.settings.elapsed_seconds = 0
    end
    self:startCounting()
end

-- break_due_cb：阅读累计到 interval 时触发
-- （注意：离开阅读/休眠会先 unschedule，故触发时必在阅读中）

-- ---------- 手动暂停 ----------
function EyeRest:pauseBreaks(choice)
    local now = os.time()
    self.settings.paused_until = logic.pauseUntilTimestamp(now, choice, MORNING_HOUR)
    self:pauseCounting()
    UIManager:unschedule(self.resume_cb)
    if self.settings.paused_until ~= logic.INDEFINITE then
        local secs = self.settings.paused_until - now
        if secs > 0 then UIManager:scheduleIn(secs, self.resume_cb) end
    end
    self:broadcastStatus()  -- 立即在状态栏显示 ⏸
end

function EyeRest:resumeBreaks()
    self.settings.paused_until = nil
    UIManager:unschedule(self.resume_cb)
    self:startCounting()
    self:broadcastStatus()  -- 立即清掉 ⏸
end

-- ---------- 总开关 / 重置 ----------
function EyeRest:toggleEnabled()
    self.settings.enabled = (not self.settings.enabled) or nil
    if self.settings.enabled then
        self.settings.elapsed_seconds = 0
        self.settings.break_count = 0
        self.settings.paused_until = nil
        self:startCounting()
    else
        self:pauseCounting()
        self.settings.paused_until = nil
        self.settings.elapsed_seconds = 0
        self:broadcastStatus()  -- 立即清掉状态栏内容
    end
end

function EyeRest:resetBreaks()
    self.settings.break_count = 0
    self.settings.elapsed_seconds = 0
    self:pauseCounting()
    self:startCounting()
end

-- ---------- 状态栏 ----------
function EyeRest:remainingHM()
    local rem = self:remaining()
    return math.floor(rem / 3600), math.floor((rem % 3600) / 60)
end

function EyeRest:initStatusFuncs()
    self.timer_symbol = "\u{2615}"  -- ☕ break/rest, distinct from KOReader's ⌚/⏳ time items
    self.pause_symbol = "\u{23F8}"  -- ⏸ paused
    local function make_content(prefix)
        return function()
            if not self.settings.enabled then return end
            if logic.isPaused(self.settings.paused_until, os.time()) then
                return prefix .. self.pause_symbol
            end
            if self:counting() then
                local h, m = self:remainingHM()
                return prefix .. string.format("%02d:%02d", h, m)
            end
        end
    end
    self.additional_header_content_func = make_content(self.timer_symbol)
    self.additional_footer_content_func = make_content(self.timer_symbol .. " ")
end

function EyeRest:addHeaderContent()
    if self.ui.crelistener then
        self.ui.crelistener:addAdditionalHeaderContent(self.additional_header_content_func)
    end
end
function EyeRest:addFooterContent()
    if self.ui.view then
        self.ui.view.footer:addAdditionalFooterContent(self.additional_footer_content_func)
    end
end
function EyeRest:removeHeaderContent()
    if self.ui.crelistener then
        self.ui.crelistener:removeAdditionalHeaderContent(self.additional_header_content_func)
    end
end
function EyeRest:removeFooterContent()
    if self.ui.view then
        self.ui.view.footer:removeAdditionalFooterContent(self.additional_footer_content_func)
    end
end

function EyeRest:startStatusUpdates()
    if not (self.settings.show_value_in_header or self.settings.show_value_in_footer) then return end
    self:_tickStatus()
end
function EyeRest:stopStatusUpdates()
    UIManager:unschedule(self.status_tick_cb)
end
-- 立即刷新一次状态栏内容（不重排），用于暂停/恢复/开关后即时反映状态
function EyeRest:broadcastStatus()
    if self.settings.show_value_in_header then
        UIManager:broadcastEvent(Event:new("UpdateHeader"))
    end
    if self.settings.show_value_in_footer then
        UIManager:broadcastEvent(Event:new("RefreshAdditionalContent"))
    end
end
function EyeRest:_tickStatus()
    self:broadcastStatus()
    -- 对齐到下一个整分钟刷新，避免过度刷屏
    local rem = self:remaining()
    local delay = rem % 60
    if delay < 1 then delay = 60 end
    UIManager:scheduleIn(delay, self.status_tick_cb)
end

-- ---------- 菜单 ----------
function EyeRest:addToMainMenu(menu_items)
    menu_items.read_timer = {
        text = _("Eye Rest"),
        sub_item_table_func = function() return self:menuItems() end,
    }
end

function EyeRest:menuItems()
    local items = {}

    -- 状态行
    table.insert(items, {
        text_func = function() return self:statusLine() end,
        enabled = false,
    })
    if self:get("long_break_every") > 0 then
        table.insert(items, {
            text_func = function()
                local m = logic.breaksUntilLong(self.settings.break_count or 0, self:get("long_break_every"))
                return T(_("Next deep rest after %1 break(s)"), m or 0)
            end,
            enabled = false,
            separator = true,
        })
    else
        items[#items].separator = true
    end

    -- 总开关
    table.insert(items, {
        text = _("Enable breaks"),
        help_text = _("Turn the break reminders on or off. While on, time is counted only while you are actually reading a book."),
        checked_func = function() return self.settings.enabled == true end,
        callback = function() self:toggleEnabled() end,
    })

    -- Skip to next
    table.insert(items, {
        text = _("Skip to next"),
        help_text = _("Start a mini break or a deep rest right now, instead of waiting for the timer."),
        enabled_func = function() return self.settings.enabled == true and self:isReading() end,
        sub_item_table = {
            {
                text = _("Mini break"),
                keep_menu_open = false,
                callback = function() self:triggerBreak("mini") end,
            },
            {
                text = _("Deep rest"),
                keep_menu_open = false,
                callback = function() self:triggerBreak("long") end,
            },
        },
    })

    -- Pause / Resume
    local paused = logic.isPaused(self.settings.paused_until, os.time())
    if paused then
        table.insert(items, {
            text = _("Resume breaks"),
            callback = function(touchmenu) self:resumeBreaks(); if touchmenu then touchmenu:updateItems() end end,
        })
    else
        table.insert(items, {
            text = _("Pause breaks"),
            help_text = _("Stop reminding you for a while (the status bar shows a pause mark). Breaks resume automatically when the time is up."),
            enabled_func = function() return self.settings.enabled == true end,
            sub_item_table = {
                self:pauseChoice(_("30 minutes"), "30m"),
                self:pauseChoice(_("1 hour"), "1h"),
                self:pauseChoice(_("2 hours"), "2h"),
                self:pauseChoice(_("Until tomorrow morning"), "until_morning"),
                self:pauseChoice(_("Indefinitely"), "indefinitely"),
            },
        })
    end

    -- Reset
    table.insert(items, {
        text = _("Reset breaks"),
        help_text = _("Start the cycle over: clear the mini-break count and restart timing the current stretch from now."),
        enabled_func = function() return self.settings.enabled == true end,
        keep_menu_open = true,
        callback = function(touchmenu) self:resetBreaks(); if touchmenu then touchmenu:updateItems() end end,
        separator = true,
    })

    -- Settings
    table.insert(items, { text = _("Settings"), sub_item_table_func = function() return self:settingsItems() end })

    return items
end

function EyeRest:pauseChoice(text, choice)
    return {
        text = text,
        keep_menu_open = false,
        callback = function() self:pauseBreaks(choice) end,
    }
end

function EyeRest:statusLine()
    if not self.settings.enabled then return _("Breaks: off") end
    if logic.isPaused(self.settings.paused_until, os.time()) then
        if self.settings.paused_until == logic.INDEFINITE then return _("Paused") end
        return T(_("Paused until %1"), os.date("%H:%M", self.settings.paused_until))
    end
    return T(_("Next break in %1"), fmtClock(self:remaining()))
end

function EyeRest:spinItem(title, key, vmin, vmax, rearm)
    return {
        text_func = function() return T(title, self:get(key)) end,
        keep_menu_open = true,
        callback = function(touchmenu)
            UIManager:show(SpinWidget:new{
                title_text = title:gsub("%%1.*", ""),
                value = self:get(key),
                value_min = vmin,
                value_max = vmax,
                value_step = 1,
                value_hold_step = 5,
                ok_always_enabled = true,
                callback = function(spin)
                    self.settings[key] = spin.value
                    -- 改了影响当前计时段的设置时，按新值重排休息触发
                    if rearm and self:counting() then
                        self:pauseCounting()
                        self:startCounting()
                    end
                    if touchmenu then touchmenu:updateItems() end
                end,
            })
        end,
    }
end

-- 分:秒 时长设置（存为秒），用 min+sec 选择器，便于设到几十秒
function EyeRest:durationItem(label, key)
    return {
        text_func = function() return label .. ": " .. fmtClock(self:get(key)) end,
        keep_menu_open = true,
        callback = function(touchmenu)
            local total = self:get(key)
            UIManager:show(DateTimeWidget:new{
                title_text = label,
                info_text = _("Minutes : seconds"),
                min = math.floor(total / 60),
                sec = total % 60,
                ok_text = _("Set"),
                callback = function(w)
                    self.settings[key] = math.max((w.min or 0) * 60 + (w.sec or 0), 5)
                    if touchmenu then touchmenu:updateItems() end
                end,
            })
        end,
    }
end

function EyeRest:settingsItems()
    return {
        self:spinItem(_("Mini break interval: every %1 min"), "mini_interval_minutes", 1, 180, true),
        self:durationItem(_("Mini break duration"), "mini_duration_seconds"),
        self:spinItem(_("Deep rest: every %1 mini breaks (0=off)"), "long_break_every", 0, 10),
        self:durationItem(_("Deep rest duration"), "long_duration_seconds"),
        {
            text = _("Strict mode"),
            help_text = _("In strict mode the break screen has no Skip / Read-more buttons; you must wait out the countdown."),
            checked_func = function() return self.settings.strict_mode == true end,
            callback = function() self.settings.strict_mode = (not self.settings.strict_mode) or nil end,
            separator = true,
        },
        self:spinItem(_("Postpone: %1 min"), "postpone_minutes", 1, 30),
        {
            text = _("Show countdown in header"),
            checked_func = function() return self.settings.show_value_in_header == true end,
            callback = function()
                self.settings.show_value_in_header = (not self.settings.show_value_in_header) or nil
                if self.settings.show_value_in_header then self:addHeaderContent() else self:removeHeaderContent() end
            end,
        },
        {
            text = _("Show countdown in footer"),
            checked_func = function() return self.settings.show_value_in_footer == true end,
            callback = function()
                self.settings.show_value_in_footer = (not self.settings.show_value_in_footer) or nil
                if self.settings.show_value_in_footer then self:addFooterContent() else self:removeFooterContent() end
            end,
            separator = true,
        },
        {
            text = _("How Eye Rest works"),
            keep_menu_open = true,
            callback = function()
                UIManager:show(InfoMessage:new{
                    text = _([[Eye Rest reminds you to rest your eyes, timed by how long you actually read — time in menus, the file browser, or while the device is asleep does not count.

After each reading stretch a countdown break appears. Most are short mini breaks; every few mini breaks becomes a longer deep rest.

On a normal break you can Skip it or tap "Read a bit more" to postpone. Turn on Strict mode to make breaks unskippable. Long-press any menu item to see what it does.]]),
                })
            end,
        },
    }
end

-- ---------- Dispatcher ----------
function EyeRest:onDispatcherRegisterActions()
    Dispatcher:registerAction("eyerest_toggle",
        { category="none", event="EyeRestToggle", title=_("Toggle reading breaks"), general=true })
    Dispatcher:registerAction("eyerest_skip_mini",
        { category="none", event="EyeRestSkipMini", title=_("Reading breaks: mini break now"), general=true })
    Dispatcher:registerAction("eyerest_skip_long",
        { category="none", event="EyeRestSkipLong", title=_("Reading breaks: long break now"), general=true })
    Dispatcher:registerAction("eyerest_pause",
        { category="none", event="EyeRestPause", title=_("Reading breaks: pause/resume"), general=true, separator=true })
end

function EyeRest:onEyeRestToggle() self:toggleEnabled(); return true end
function EyeRest:onEyeRestSkipMini() self:triggerBreak("mini"); return true end
function EyeRest:onEyeRestSkipLong() self:triggerBreak("long"); return true end
function EyeRest:onEyeRestPause()
    if logic.isPaused(self.settings.paused_until, os.time()) then
        self:resumeBreaks()
    else
        self:pauseBreaks("indefinitely")
    end
    return true
end

-- ---------- 生命周期 ----------
function EyeRest:init()
    self.settings = G_reader_settings:readSetting("eyerest", {})
    self.reading_start = nil
    self.break_active = false
    self.break_due_cb = function() self:triggerBreak() end
    self.resume_cb = function() self:resumeBreaks() end
    self.status_tick_cb = function() self:_tickStatus() end

    self:initStatusFuncs()
    if self.settings.show_value_in_header then self:addHeaderContent() end
    if self.settings.show_value_in_footer then self:addFooterContent() end

    self.ui.menu:registerToMainMenu(self)
    self:onDispatcherRegisterActions()
end

-- 手动暂停未过期则（重）排自动恢复定时器；已过期或未暂停则开始计时
function EyeRest:resumeOrStartCounting()
    local now = os.time()
    if logic.isPaused(self.settings.paused_until, now) then
        if self.settings.paused_until ~= logic.INDEFINITE then
            UIManager:unschedule(self.resume_cb)
            UIManager:scheduleIn(self.settings.paused_until - now, self.resume_cb)
        end
        return
    end
    self.settings.paused_until = nil
    self:startCounting()
end

function EyeRest:onReaderReady()
    self:resumeOrStartCounting()
end

function EyeRest:onResume()
    self:resumeOrStartCounting()
end

function EyeRest:onSuspend()
    self:pauseCounting()
end

function EyeRest:onCloseWidget()
    self:pauseCounting()
    UIManager:unschedule(self.resume_cb)
end

return EyeRest
