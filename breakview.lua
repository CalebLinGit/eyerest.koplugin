local Blitbuffer = require("ffi/blitbuffer")
local ButtonTable = require("ui/widget/buttontable")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local InputContainer = require("ui/widget/container/inputcontainer")
local Size = require("ui/size")
local TextWidget = require("ui/widget/textwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local Widget = require("ui/widget/widget")
local logic = require("breaklogic")
local _ = require("gettext")
local T = require("ffi/util").template
local Screen = Device.screen

local POLL_INTERVAL = 10  -- 秒：粗轮询间隔（详见 spec §3.3）
local STAGES = 5

-- 5 等份整格进度条（整格点亮，墨水屏友好）。核心 ProgressWidget 填充是连续的，
-- 做不到整格，故自写 paintTo（参考 s4m-mo/pomodoro.koplugin）。
local SegBar = Widget:extend{
    width = 0,
    height = 0,
    stages = STAGES,
    current = 0,
}
function SegBar:getSize() return Geom:new{ w = self.width, h = self.height } end
function SegBar:paintTo(bb, x, y)
    local fg = Blitbuffer.COLOR_BLACK
    local border = Size.border.thick
    bb:paintBorder(x, y, self.width, self.height, border, fg)
    local seg_w = math.floor(self.width / self.stages)
    for i = 1, self.stages do
        local rx = x + (i - 1) * seg_w
        if i <= self.current then
            bb:paintRect(rx, y, seg_w, self.height, fg)
        end
        if i < self.stages then
            bb:paintRect(rx + seg_w - border, y, border, self.height, fg)
        end
    end
end

local BreakView = InputContainer:extend{
    break_type = "mini",   -- "mini" | "long"
    duration = 300,         -- 秒
    strict = false,
    on_done = nil,
    on_skip = nil,
    on_postpone = nil,
}

function BreakView:init()
    self.modal = true               -- 输入只路由给本 widget，外部点击无效
    self.covers_fullscreen = true
    self.dimen = Screen:getSize()
    self.started = os.time()
    self.deadline = self.started + self.duration
    -- 粗轮询，但对很短的休息（按秒设置）收紧到每个阶段边界，保证 5 格都能走到
    self.poll_interval = math.max(1, math.min(POLL_INTERVAL, math.floor(self.duration / STAGES)))

    local title_text = self.break_type == "long" and _("Long break") or _("Mini break")
    self.bar = SegBar:new{
        width = math.floor(Screen:getWidth() * 0.7),
        height = Size.item.height_default,
        stages = STAGES,
        current = 0,
    }
    self.remaining_widget = TextWidget:new{
        text = self:_remainText(self.duration),
        face = Font:getFace("cfont", 20),
    }

    local vgroup = VerticalGroup:new{ align = "center" }
    table.insert(vgroup, TextWidget:new{ text = title_text, face = Font:getFace("tfont", 28) })
    table.insert(vgroup, VerticalSpan:new{ width = Size.padding.large })
    table.insert(vgroup, self.bar)
    table.insert(vgroup, VerticalSpan:new{ width = Size.padding.large })
    table.insert(vgroup, self.remaining_widget)
    table.insert(vgroup, VerticalSpan:new{ width = Size.padding.large })

    if self.strict then
        table.insert(vgroup, TextWidget:new{
            text = _("Please rest your eyes."),
            face = Font:getFace("cfont", 18),
        })
    else
        table.insert(vgroup, ButtonTable:new{
            buttons = {{
                { text = _("Skip"), callback = function() self:_finish("skip") end },
                { text = _("Read a bit more"), callback = function() self:_finish("postpone") end },
            }},
            show_parent = self,
        })
    end

    self[1] = CenterContainer:new{
        dimen = Screen:getSize(),
        FrameContainer:new{
            background = Blitbuffer.COLOR_WHITE,
            bordersize = Size.border.window,
            padding = Size.padding.large,
            vgroup,
        },
    }

    self._poll_cb = function() self:_poll() end
end

function BreakView:_remainText(remaining)
    remaining = math.max(math.floor(remaining), 0)
    return T(_("%1 left"), string.format("%d:%02d", math.floor(remaining / 60), remaining % 60))
end

function BreakView:onShow()
    UIManager:setDirty(self, "full")  -- 打开做一次全屏刷新清残影
    UIManager:scheduleIn(self.poll_interval, self._poll_cb)
    return true
end

function BreakView:_poll()
    local now = os.time()
    local remaining = self.deadline - now
    if remaining <= 0 then
        self:_finish("done")
        return
    end
    local stage = logic.stageOf(now - self.started, self.duration, STAGES)
    if stage ~= self.bar.current then
        self.bar.current = stage
        self.remaining_widget:setText(self:_remainText(remaining))
        UIManager:setDirty(self, "ui")  -- 仅阶段变化时局部刷新
    end
    UIManager:scheduleIn(self.poll_interval, self._poll_cb)
end

function BreakView:_finish(result)
    UIManager:unschedule(self._poll_cb)
    UIManager:close(self)
    -- result is "skip" | "postpone" | "done"; on_done is the fallback
    local cb = self["on_" .. result] or self.on_done
    if cb then cb() end
end

function BreakView:onCloseWidget()
    UIManager:unschedule(self._poll_cb)
    UIManager:setDirty(nil, "flashpartial")  -- 关闭清残影
end

return BreakView
