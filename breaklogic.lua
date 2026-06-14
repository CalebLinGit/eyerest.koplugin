local BreakLogic = {}

function BreakLogic.nextBreakType(break_count, long_break_every)
    break_count = break_count or 0
    if long_break_every and long_break_every > 0 and break_count >= long_break_every then
        return "long"
    end
    return "mini"
end

function BreakLogic.advance(break_count, break_type)
    break_count = break_count or 0
    if break_type == "long" then return 0 end
    return break_count + 1
end

function BreakLogic.breaksUntilLong(break_count, long_break_every)
    if not long_break_every or long_break_every <= 0 then return nil end
    local n = long_break_every - (break_count or 0)
    if n < 0 then n = 0 end
    return n
end

BreakLogic.INDEFINITE = -1

function BreakLogic.stageOf(elapsed, duration, stages)
    if duration <= 0 then return stages end
    local s = math.floor(elapsed / (duration / stages))
    if s < 0 then s = 0 end
    if s > stages then s = stages end
    return s
end

function BreakLogic.coarseRemainingMin(remaining_seconds)
    if remaining_seconds <= 0 then return 0 end
    return math.ceil(remaining_seconds / 60)
end

local PAUSE_OFFSETS = { ["30m"] = 1800, ["1h"] = 3600, ["2h"] = 7200 }

function BreakLogic.pauseUntilTimestamp(now, choice, morning_hour)
    local offset = PAUSE_OFFSETS[choice]
    if offset then return now + offset end
    if choice == "indefinitely" then return BreakLogic.INDEFINITE end
    if choice == "until_morning" then
        local t = os.date("*t", now)
        t.sec = 0
        t.min = 0
        if t.hour >= morning_hour then
            t.day = t.day + 1  -- 已过当日 morning_hour -> 次日
        end
        t.hour = morning_hour
        return os.time(t)
    end
    return now
end

function BreakLogic.isPaused(paused_until, now)
    if paused_until == nil then return false end
    if paused_until == BreakLogic.INDEFINITE then return true end
    return paused_until > now
end

return BreakLogic
