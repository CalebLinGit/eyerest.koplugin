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
local AlarmView = require("alarmview")

local DEFAULTS = {
    mini_interval_minutes = 20,   -- 20-20-20 rule
    mini_duration_seconds = 20,
    long_break_every = 2,         -- 2 mini breaks, then a long break
    long_duration_seconds = 300,
    postpone_minutes = 5,
}

-- 剩余时间 -> 约分钟，避免 xx:xx 到底是「时:分」还是「分:秒」的歧义
local function fmtMinLeft(s)
    s = math.floor(s)
    if s < 60 then return _("<1 min") end
    return T(_("~%1 min"), math.ceil(s / 60))
end

-- 时长 -> 人类可读，避免 0:20 / 5:00 的冒号歧义
local function fmtDuration(s)
    s = math.floor(s)
    local m = math.floor(s / 60)
    local sec = s % 60
    if m == 0 then return T(_("%1 s"), sec) end
    if sec == 0 then return T(_("%1 min"), m) end
    return T(_("%1 min %2 s"), m, sec)
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
        -- 不推进计数；下次同类型休息在 postpone 分钟后弹出。
        -- 不能 clamp 到 0：当 postpone > interval 时 elapsed 需为负，
        -- 这样 remaining = interval - elapsed 才等于完整的 postpone 时长。
        self.settings.elapsed_seconds = self:intervalSeconds() - self:get("postpone_minutes") * 60
    else
        -- done / skip：推进循环，开始新一段
        self.settings.break_count = logic.advance(self.settings.break_count or 0, break_type)
        self.settings.elapsed_seconds = 0
    end
    self:startCounting()
    -- 休息弹窗刚关闭，状态栏此刻仍被全屏遮挡；延到下一帧再刷，确保新的倒计时
    -- 值真正画到可见的状态栏上（否则会停留在休息前的旧值）
    UIManager:nextTick(function() self:broadcastStatus() end)
end

-- break_due_cb：阅读累计到 interval 时触发
-- （注意：离开阅读/休眠会先 unschedule，故触发时必在阅读中）

-- ---------- 睡眠定时器（一次性倒计时，独立于护眼休息）----------
-- 存绝对 deadline（os.time 墙上时间），跨息屏/重启靠 reschedule 重排。
function EyeRest:sleepRemaining()
    if not self.settings.sleep_deadline then return nil end
    return self.settings.sleep_deadline - os.time()
end

function EyeRest:armSleepTimer(seconds)
    self.settings.sleep_deadline = os.time() + seconds
    UIManager:unschedule(self.sleep_cb)
    UIManager:scheduleIn(seconds, self.sleep_cb)
end

function EyeRest:cancelSleepTimer()
    self.settings.sleep_deadline = nil
    UIManager:unschedule(self.sleep_cb)
end

function EyeRest:fireSleepTimer()
    self.settings.sleep_deadline = nil
    UIManager:unschedule(self.sleep_cb)
    if self.alarm_view then return end
    self.alarm_view = AlarmView:new{
        on_done = function() self.alarm_view = nil end,
    }
    UIManager:show(self.alarm_view)
end

-- 跨息屏/重启后按绝对 deadline 重排；已过期则立即触发
function EyeRest:rescheduleSleepTimer()
    local rem = self:sleepRemaining()
    if rem == nil then return end
    UIManager:unschedule(self.sleep_cb)
    if rem <= 0 then
        self:fireSleepTimer()
    else
        UIManager:scheduleIn(rem, self.sleep_cb)
    end
end

-- ---------- 总开关 / 重置 ----------
function EyeRest:toggleEnabled()
    self.settings.enabled = (not self.settings.enabled) or nil
    if self.settings.enabled then
        self.settings.elapsed_seconds = 0
        self.settings.break_count = 0
        self:startCounting()
    else
        self:pauseCounting()
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
-- 纯分钟显示，避免 00:05 这种「时:分 / 分:秒」的歧义；不足一分钟显示 <1min
function EyeRest:remainingText()
    local rem = self:remaining()
    if rem < 60 then return _("in <1min") end
    return T(_("in %1min"), math.ceil(rem / 60))
end

function EyeRest:initStatusFuncs()
    self.timer_symbol = "\u{2615}"  -- ☕ break/rest, distinct from KOReader's ⌚/⏳ time items
    local function make_content(prefix)
        return function()
            if not self.settings.enabled then return end
            if self:counting() then
                return prefix .. self:remainingText()
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
        text_func = function()
            if self.settings.enabled and self:counting() then
                return T(_("Eye Rest (next break in %1)"), fmtMinLeft(self:remaining()))
            end
            return _("Eye Rest")
        end,
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
                return T(_("Next long break after %1 break(s)"), m or 0)
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
        help_text = _("Start a mini break or a long break right now, instead of waiting for the timer."),
        enabled_func = function() return self.settings.enabled == true and self:isReading() end,
        sub_item_table = {
            {
                text = _("Mini break"),
                keep_menu_open = false,
                callback = function() self:triggerBreak("mini") end,
            },
            {
                text = _("Long break"),
                keep_menu_open = false,
                callback = function() self:triggerBreak("long") end,
            },
        },
    })

    -- Sleep timer（一次性倒计时，独立于护眼休息）
    table.insert(items, {
        text_func = function()
            local rem = self:sleepRemaining()
            if rem and rem > 0 then
                return T(_("Sleep timer: %1 min left"), math.ceil(rem / 60))
            end
            return _("Sleep timer: off")
        end,
        help_text = _("A one-shot countdown, separate from the eye breaks. When it runs out a full-screen reminder tells you to stop reading — useful as a bedtime limit, e.g. read for one hour then sleep."),
        sub_item_table_func = function() return self:sleepTimerItems() end,
    })

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

function EyeRest:sleepTimerItems()
    return {
        {
            text_func = function()
                local rem = self:sleepRemaining()
                if rem and rem > 0 then return T(_("Reminds you in %1 min"), math.ceil(rem / 60)) end
                return _("No timer set")
            end,
            enabled = false,
            separator = true,
        },
        {
            text = _("Set timer…"),
            keep_menu_open = true,
            callback = function(touchmenu)
                local rem = self:sleepRemaining()
                local total = (rem and rem > 0) and rem or 3600  -- 默认 1 小时
                UIManager:show(DateTimeWidget:new{
                    title_text = _("Sleep timer"),
                    info_text = _("Hours : minutes"),
                    hour = math.floor(total / 3600),
                    min = math.floor((total % 3600) / 60),
                    ok_text = _("Start"),
                    callback = function(w)
                        local secs = (w.hour or 0) * 3600 + (w.min or 0) * 60
                        if secs > 0 then self:armSleepTimer(secs) else self:cancelSleepTimer() end
                        if touchmenu then touchmenu:updateItems() end
                    end,
                })
            end,
        },
        {
            text = _("Cancel timer"),
            enabled_func = function() local r = self:sleepRemaining(); return r ~= nil and r > 0 end,
            keep_menu_open = true,
            callback = function(touchmenu) self:cancelSleepTimer(); if touchmenu then touchmenu:updateItems() end end,
        },
    }
end

function EyeRest:statusLine()
    if not self.settings.enabled then return _("Breaks: off") end
    return T(_("Next break in %1"), fmtMinLeft(self:remaining()))
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
        text_func = function() return label .. ": " .. fmtDuration(self:get(key)) end,
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
        self:spinItem(_("Long break: every %1 mini breaks (0=off)"), "long_break_every", 0, 10),
        self:durationItem(_("Long break duration"), "long_duration_seconds"),
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
            help_text = _("Show '☕ in N min' (time to the next break) in the bottom status bar. The footer must allow external content: tap the bottom bar → Status bar settings → turn on 'Show external content', otherwise nothing shows."),
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
                    text = _([[Eye Rest follows the 20-20-20 rule: every 20 minutes of reading, look about 20 feet (6 m) away for 20 seconds to relax your eyes.

    Read 20m  →  ☕ 20s   (mini break)
    Read 20m  →  ☕ 20s   (mini break)
    Read 20m  →  ☕ 5m    (long break)
    … then repeat

Time counts only while a book is open, and pauses when you close the book or the device goes to sleep.

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
        { category="none", event="EyeRestSkipLong", title=_("Reading breaks: long break now"), general=true, separator=true })
end

function EyeRest:onEyeRestToggle() self:toggleEnabled(); return true end
function EyeRest:onEyeRestSkipMini() self:triggerBreak("mini"); return true end
function EyeRest:onEyeRestSkipLong() self:triggerBreak("long"); return true end

-- ---------- 生命周期 ----------
function EyeRest:init()
    self.settings = G_reader_settings:readSetting("eyerest", {})
    self.reading_start = nil
    self.break_active = false
    self.break_due_cb = function() self:triggerBreak() end
    self.sleep_cb = function() self:fireSleepTimer() end
    self.status_tick_cb = function() self:_tickStatus() end

    self:initStatusFuncs()
    if self.settings.show_value_in_header then self:addHeaderContent() end
    if self.settings.show_value_in_footer then self:addFooterContent() end

    self.ui.menu:registerToMainMenu(self)
    self:onDispatcherRegisterActions()
end

function EyeRest:onReaderReady()
    self:startCounting()
    self:rescheduleSleepTimer()  -- 重启/换书后按绝对 deadline 恢复睡眠定时器
end

function EyeRest:onResume()
    self:startCounting()
    self:rescheduleSleepTimer()  -- 唤醒后重排；睡眠期间已过点则立即提示
end

function EyeRest:onSuspend()
    self:pauseCounting()
end

function EyeRest:onCloseWidget()
    self:pauseCounting()
    UIManager:unschedule(self.sleep_cb)
end

return EyeRest
