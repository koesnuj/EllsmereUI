-- PhoenixCastBars - Bars/State.lua
-- Low-level state management:
--   PCB.ResetState                 — wipe a frame back to idle
--   PCB.ReadUnitCast               — poll the WoW API for a unit's active cast
--   PCB.ConfigureStatusBarForState — set up the bar fill parameters for a cast
--
-- Helpers: uses PCB.Try.* and PCB.SafeDivMsToSec from Core/Util.lua.
-- Taint:   uses PCB.SafeBool from Core/Taint.lua.

local ADDON_NAME, PCB = ...

-- Empower spell name fragments — needed by ReadUnitCast to reclassify
-- channel→cast for empower spells. Duplicated in Empower.lua; Phase 2
-- will consolidate them into a shared location.
local EMPOWER_NAMES = {
    "empower", "deep breath", "fire breath", "eternity surge",
    "dream breath", "spiritbloom", "tip the scales",
}

local function IsEmpowerSpell(name)
    if not name then return false end
    local ok, lower = pcall(string.lower, name)
    if not ok or not lower then return false end
    for _, frag in ipairs(EMPOWER_NAMES) do
        if lower:find(frag, 1, true) then return true end
    end
    return false
end

-- =====================================================================
-- PCB.ResetState(f, forceHide)
-- Clears all cast state from a frame and optionally hides it.
-- =====================================================================
function PCB.ResetState(f, forceHide)
    -- Read the pre-computed boolean before clearing state.
    -- durationSec is a secret value on enemy units so we never compare it here.
    local isInstantCast = f._state and f._state.isInstantCast

    f._state          = nil
    f._endGraceUntil  = nil
    f._effectiveUnitActive = false
    f._textElapsed    = 0
    f._stopCheckAt    = nil
    f._stopUnit       = nil
    f._localStartTime = nil
    f._localEndTime   = nil
    f._localDuration  = nil
    if f.container then f.container._pcbActive = false end
    if f._state then f._state.nativeTimerActive = nil end

    PCB.Try.SetMinMax(f.bar, 0, 1)
    PCB.Try.SetValue(f.bar, 0)
    PCB.Try.SetText(f.timeText,  "")
    PCB.Try.SetText(f.spellText, "")

    PCB.Try.SetTexture(f.icon, nil)
    f.icon:Hide()
    if f.shield then f.shield:Hide() end

    if f.spark then f.spark:Hide() end
    if f.empowerStages then
        for i = 1, 3 do
            if f.empowerStages[i] then f.empowerStages[i]:Hide() end
        end
    end

    if forceHide and PCB.db and PCB.db.locked and not f.isMover and not f.test then
        local isInstant = isInstantCast
        if PCB.db.fadeOnEnd and f.container and not isInstant then
            -- Fade out over 0.4 s then hide
            UIFrameFadeOut(f.container, 0.4, f.container:GetAlpha(), 0)
            local container = f.container
            C_Timer.After(0.45, function()
                if container and not container._pcbActive then
                    container:Hide()
                    container:SetAlpha((PCB.db and PCB.db.bars and
                        PCB.db.bars[f.key] and PCB.db.bars[f.key].alpha) or 1)
                end
            end)
        else
            if f.container then f.container:Hide() end
            f:Hide()
        end
    end
end

-- =====================================================================
-- PCB.ReadUnitCast(unit)
-- Polls UnitCastingInfo / UnitChannelInfo.
-- Returns: kind, name, texture, startSec, endSec, notInterruptibleSecret, durationObj
--
-- IMPORTANT: notInterruptibleSecret is a raw tainted value from the WoW API.
-- Do NOT test it directly. Use PCB.SafeBool(secret) once, then store and
-- test the plain bool result (e.g. st.notInterruptibleBool).
-- Returns nil if nothing is casting.
-- =====================================================================
function PCB.ReadUnitCast(unit)
    local name, _, texture, startMS, endMS, _, _, notInterruptible = UnitCastingInfo(unit)
    local kind = "cast"

    if not name then
        name, _, texture, startMS, endMS, _, notInterruptible = UnitChannelInfo(unit)
        if name then kind = "channel" end
    end

    if not name or not startMS or not endMS then return nil end

    -- Reclassify empower spells from "channel" to "cast" so they fill forward
    if kind == "channel" and IsEmpowerSpell(name) then
        kind = "cast"
    end

    local durationObj = nil
    if PCB.HAS_DURATION_API then
        durationObj = PCB.GetDurationForUnit(unit, kind == "channel")
                   or PCB.GetDurationForUnit(unit, false)
    end

    -- Return the raw notInterruptible value. Callers must use PCB.SafeBool()
    -- before performing any boolean test on it.
    return kind, name, texture,
           PCB.SafeDivMsToSec(startMS), PCB.SafeDivMsToSec(endMS),
           notInterruptible, durationObj
end

-- =====================================================================
-- PCB.ConfigureStatusBarForState(f)
-- Resolves cast duration and configures the status bar fill direction.
-- Uses durationObj exclusively — GetTotalDuration() may be secret for
-- enemy units, but SetMinMaxValues/SetValue/SetTimerDuration all accept
-- secret values directly.  No Lua comparisons against the duration value.
-- =====================================================================
function PCB.ConfigureStatusBarForState(f)
    local st = f._state
    if not st or not f.bar then return end

    -- Require durationObj — without it we cannot configure the bar safely.
    if not st.durationObj or not st.durationObj.GetTotalDuration then return end

    local dTotal = st.durationObj:GetTotalDuration()  -- secret for enemy units; OK for widget APIs

    local useDuration = f.bar.SetTimerDuration ~= nil
    if useDuration and st.kind == "cast" then
        PCB.Try.SetMinMax(f.bar, 0, 1)
        PCB.Try.SetValue(f.bar, 0)
        if not PCB.Try.SetTimerDuration(f.bar, st.durationObj,
                                        PCB.DEFAULT_INTERPOLATION, PCB.DIR_ELAPSED) then
            st.durationObj = nil
            useDuration = false
        else
            st.nativeTimerActive = true  -- native timer is driving this bar; skip manual SetValue
        end
    else
        useDuration = false
    end

    if not useDuration then
        -- SetMinMaxValues and SetValue both accept secret values — no comparison needed.
        PCB.Try.SetMinMax(f.bar, 0, dTotal)
        PCB.Try.SetValue(f.bar, (st.kind == "channel") and dTotal or 0)
    end
end
