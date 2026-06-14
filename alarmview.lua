local Blitbuffer = require("ffi/blitbuffer")
local ButtonTable = require("ui/widget/buttontable")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local InputContainer = require("ui/widget/container/inputcontainer")
local Size = require("ui/size")
local TextWidget = require("ui/widget/textwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local _ = require("gettext")
local Screen = Device.screen

-- 睡眠定时器到点提示：复用 BreakView 的全屏 modal 外观，但只有一个确认按钮，
-- 没有倒计时条（倒计时在后台跑，这一屏是「时间到」的终点）。
local AlarmView = InputContainer:extend{
    title = nil,
    message = nil,
    on_done = nil,
}

function AlarmView:init()
    self.modal = true                -- 外部点击无效，只能按按钮关闭
    self.covers_fullscreen = true
    self.dimen = Screen:getSize()

    local title = self.title or _("Time to sleep")
    local message = self.message or _("Your reading timer is up — time to rest your eyes and sleep.")

    local vgroup = VerticalGroup:new{ align = "center" }
    table.insert(vgroup, TextWidget:new{ text = title, face = Font:getFace("tfont", 28) })
    table.insert(vgroup, VerticalSpan:new{ width = Size.padding.large })
    table.insert(vgroup, TextWidget:new{ text = message, face = Font:getFace("cfont", 18) })
    table.insert(vgroup, VerticalSpan:new{ width = Size.padding.large })
    table.insert(vgroup, ButtonTable:new{
        buttons = {{
            { text = _("OK"), callback = function() self:_close() end },
        }},
        show_parent = self,
    })

    self[1] = CenterContainer:new{
        dimen = Screen:getSize(),
        FrameContainer:new{
            background = Blitbuffer.COLOR_WHITE,
            bordersize = Size.border.window,
            padding = Size.padding.large,
            vgroup,
        },
    }
end

function AlarmView:onShow()
    UIManager:setDirty(self, "full")  -- 打开做一次全屏刷新清残影
    return true
end

function AlarmView:_close()
    UIManager:close(self)
    if self.on_done then self.on_done() end
end

function AlarmView:onCloseWidget()
    UIManager:setDirty(nil, "flashpartial")  -- 关闭清残影
end

return AlarmView
