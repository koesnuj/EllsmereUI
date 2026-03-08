-- PhoenixCastBars - GCD.lua
-- This file handles Global Cooldown (GCD) tracking

local ADDON_NAME, PCB = ...
PCB = PCB or {}
PCB.GCD = PCB.GCD or {}

-- =====================================================================
-- GCD Configuration
-- =====================================================================
local GCD_SPELL_ID = 61304  -- Spell ID used to track GCD
local MIN_GCD_DURATION = 0.5  -- Minimum GCD duration to display (in seconds)
local TEXT_UPDATE_INTERVAL = 0.05  -- How often to update time text

-- =====================================================================
-- GCD Bar OnUpdate Handler
-- =====================================================================
-- Updates the GCD bar fill and hides it when complete
local function GCD_OnUpdate(f, elapsed)
    if not f or not f._state then
        f:SetScript("OnUpdate", nil)
        return
    end

    local st = f._state
    local now = GetTime()

    -- Check if GCD has expired
    if st.endSec and now >= st.endSec then
        -- GCD complete, hide the bar
        if f.container then f.container:Hide() end
        f:Hide()
        f._state = nil
        f:SetScript("OnUpdate", nil)
        return
    end

    -- Update bar value (fill from 0 to duration)
    if f.bar and st.startSec and st.endSec then
        local elapsedTime = now - st.startSec
        local progress = math.min(elapsedTime / st.durationSec, 1)
        f.bar:SetValue(elapsedTime)

        -- Update spark position (only if enabled)
        local db = PCB.db.bars.gcd or {}
        if f.spark then
            if db.showSpark ~= false then
                local tex = f.bar:GetStatusBarTexture()
                if tex then
                    f.spark:ClearAllPoints()
                    f.spark:SetPoint("CENTER", tex, "RIGHT", 0, 0)
                    f.spark:Show()
                end
            else
                f.spark:Hide()
            end
        end
    end

    -- Update time text throttled (only if enabled)
    local db = PCB.db.bars.gcd or {}
    if db.showTime == true and f.timeText and st.endSec then
        f._textElapsed = (f._textElapsed or 0) + (elapsed or 0)
        if f._textElapsed >= TEXT_UPDATE_INTERVAL then
            f._textElapsed = 0
            local remaining = st.endSec - now
            if remaining > 0 then
                local ok, s = pcall(string.format, "%.1f", remaining)
                if ok then
                    f.timeText:SetText(s)
                end
            else
                f.timeText:SetText("")
            end
        end
    elseif f.timeText then
        f.timeText:SetText("")
    end
end

-- =====================================================================
-- GCD Bar Initialization
-- =====================================================================
-- Starts the GCD bar when a spell triggers the global cooldown
function PCB.GCD.StartGCDBar(f)
    if not f or f.key ~= "gcd" then return end
    if not PCB:IsBarEnabled("gcd") then return end

    -- Get GCD information using new API
    local cooldownInfo = C_Spell.GetSpellCooldown(GCD_SPELL_ID)
    if not cooldownInfo or not cooldownInfo.startTime or cooldownInfo.startTime == 0 
       or not cooldownInfo.duration or cooldownInfo.duration == 0 then
        return false
    end

    local start = cooldownInfo.startTime
    local duration = cooldownInfo.duration
    local now = GetTime()
    local endTime = start + duration

    -- Don't show very short GCDs or if already expired
    if duration < MIN_GCD_DURATION or endTime <= now then
        return false
    end

    -- Apply visual styling
    PCB.ApplyAppearance(f)
    PCB.ApplyCastBarColor(f)

    -- Set up the state for GCD tracking FIRST
    local st = f._state or {}
    f._state = st

    st.kind = "gcd"
    st.unit = "player"
    st.name = "Global Cooldown"
    st.texture = nil
    st.notInterruptible = true
    st.startSec = start
    st.endSec = endTime
    st.durationObj = nil  -- GCD doesn't use Duration objects
    st.durationSec = duration

    -- NOW apply spark and time visibility based on settings (after st is created)
    local db = PCB.db.bars.gcd or {}
    if f.spark then
        f.spark:SetShown(db.showSpark ~= false) -- default true if nil
    end
    if f.timeText then
        f.timeText:SetShown(db.showTime == true) -- default false if nil
    end

    if f.spellText then
        f.spellText:SetText("")
    end

    -- For GCD, we don't use SetTimerDuration since we manage it manually
    -- Set up manual min/max for the status bar
    if f.bar then
        if f.bar.SetReverseFill then
            f.bar:SetReverseFill(false)
        end
        f.bar:SetMinMaxValues(0, duration)
        f.bar:SetValue(0)
    end

    f._pollElapsed = 0
    f._textElapsed = 0
    f._endGraceUntil = nil

    if f.container then f.container:Show() end
    f:Show()
    f:SetScript("OnUpdate", GCD_OnUpdate)

    return true
end

-- =====================================================================
-- GCD Bar Stop Check
-- =====================================================================
-- Checks if the GCD has expired and should hide the bar
function PCB.GCD.ShouldStopGCD(f)
    if not f or not f._state or f._state.kind ~= "gcd" then
        return false
    end

    local st = f._state
    local now = GetTime()

    -- Check if the GCD timer has expired
    if st.endSec and now >= st.endSec then
        return true
    end

    return false
end