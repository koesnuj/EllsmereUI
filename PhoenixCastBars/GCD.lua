-- PhoenixCastBars - GCD.lua
-- Global Cooldown bar. Refactored to share the main PCB.FrameOnUpdate
-- pipeline (spark, time text, flash, bar fill) — no more duplicate code.

local ADDON_NAME, PCB = ...
PCB = PCB or {}
PCB.GCD = PCB.GCD or {}

local GCD_SPELL_ID   = 61304  -- Spell ID used to track GCD
local MIN_GCD_DURATION = 0.5  -- Minimum GCD duration to display (seconds)

-- =====================================================================
-- PCB.GCD.StartGCDBar(f)
-- Starts the GCD bar when a spell triggers the global cooldown.
-- OnUpdate is handed off to PCB.FrameOnUpdate (kind == "gcd" path).
-- =====================================================================
function PCB.GCD.StartGCDBar(f)
    if not f or f.key ~= "gcd" then return end
    if not PCB:IsBarEnabled("gcd") then return end

    local cooldownInfo = C_Spell.GetSpellCooldown(GCD_SPELL_ID)
    if not cooldownInfo or not cooldownInfo.startTime or cooldownInfo.startTime == 0
       or not cooldownInfo.duration or cooldownInfo.duration == 0 then
        return false
    end

    local start    = cooldownInfo.startTime
    local duration = cooldownInfo.duration
    local now      = GetTime()
    local endTime  = start + duration

    if duration < MIN_GCD_DURATION or endTime <= now then
        return false
    end

    PCB.ApplyAppearance(f)
    PCB.ApplyCastBarColor(f)

    local st = f._state or {}
    f._state = st

    st.kind             = "gcd"
    st.unit             = "player"
    st.name             = nil
    st.texture          = nil
    st.notInterruptible = false
    st.startSec         = start
    st.endSec           = endTime
    st.durationObj      = nil
    st.durationSec      = duration

    if f.bar then
        local bdb     = (PCB.db and PCB.db.bars and PCB.db.bars["gcd"]) or {}
        local reverse = bdb.gcdReverseFill == true
        -- Drain mode: SetReverseFill(false) + start at max, count down to 0.
        -- This makes the fill (left-to-right) shrink from the right edge — a drain effect.
        -- SetReverseFill(true) would fill right-to-left which is the opposite of what we want.
        if f.bar.SetReverseFill then f.bar:SetReverseFill(false) end
        f.bar:SetMinMaxValues(0, duration)
        f.bar:SetValue(reverse and duration or 0)
    end

    if f.spellText then f.spellText:SetText("") end

    f._pollElapsed   = 0
    f._textElapsed   = 0
    f._flashTimer    = 0
    f._flashDuration = 0
    f._endGraceUntil = nil

    if f.container then f.container:Show() end
    f:Show()

    -- Hand off to the shared FrameOnUpdate (defined in Update.lua).
    -- The kind == "gcd" branch handles expiry + bar fill; the rest of the
    -- function handles spark, time text, and flash — shared for free.
    f:SetScript("OnUpdate", PCB.FrameOnUpdate)

    return true
end

-- =====================================================================
-- PCB.GCD.ShouldStopGCD(f)  [kept for any external callers]
-- =====================================================================
function PCB.GCD.ShouldStopGCD(f)
    if not f or not f._state or f._state.kind ~= "gcd" then return false end
    return GetTime() >= (f._state.endSec or 0)
end
