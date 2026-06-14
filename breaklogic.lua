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

return BreakLogic
