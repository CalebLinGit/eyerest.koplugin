package.path = "./?.lua;" .. package.path
local L = require("breaklogic")

local passed, failed = 0, 0
local function eq(a, b, msg)
    if a == b then
        passed = passed + 1
    else
        failed = failed + 1
        print(("FAIL: %s (got %s, want %s)"):format(msg, tostring(a), tostring(b)))
    end
end

-- nextBreakType: long_break_every 是「触发深度休息前的小休息次数」
eq(L.nextBreakType(0, 3), "mini", "nbt 0/3")
eq(L.nextBreakType(2, 3), "mini", "nbt 2/3")
eq(L.nextBreakType(3, 3), "long", "nbt 3/3 -> long")
eq(L.nextBreakType(0, 0), "mini", "nbt long disabled")
eq(L.nextBreakType(5, nil), "mini", "nbt nil")

-- advance: 小休息 +1；深度休息归零
eq(L.advance(2, "mini"), 3, "advance mini")
eq(L.advance(3, "long"), 0, "advance long resets")
eq(L.advance(0, "mini"), 1, "advance from 0")

-- breaksUntilLong: 状态行「还有 M 次小休息后深度休息」
eq(L.breaksUntilLong(0, 3), 3, "bul 0/3")
eq(L.breaksUntilLong(2, 3), 1, "bul 2/3")
eq(L.breaksUntilLong(3, 3), 0, "bul 3/3")
eq(L.breaksUntilLong(0, 0), nil, "bul disabled")

-- stageOf: duration 300s / 5 阶段 = 每阶段 60s
eq(L.stageOf(0, 300, 5), 0, "stage 0")
eq(L.stageOf(59, 300, 5), 0, "stage <1")
eq(L.stageOf(60, 300, 5), 1, "stage 1")
eq(L.stageOf(300, 300, 5), 5, "stage full")
eq(L.stageOf(330, 300, 5), 5, "stage clamp")
eq(L.stageOf(0, 0, 5), 5, "stage zero-duration -> full")

-- coarseRemainingMin: 向上取整分钟
eq(L.coarseRemainingMin(180), 3, "coarse 3")
eq(L.coarseRemainingMin(181), 4, "coarse ceil")
eq(L.coarseRemainingMin(0), 0, "coarse 0")
eq(L.coarseRemainingMin(1), 1, "coarse 1")

print(("\n%d passed, %d failed"):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
