-- PhoenixCastBars - Bars/Actions.lua
-- Higher-level cast lifecycle logic:
--   PCB.ArmStopCheck            — schedule a deferred stop verification
--   PCB.VerifyAndStopIfInactive — execute the deferred stop check
--   PCB.StartOrRefreshFromUnit  — begin or refresh a cast on a frame
--   PCB.StopIfReallyStopped     — stop a bar only when the unit has truly stopped
--   PCB.RefreshFrame            — top-level refresh dispatcher
--
-- Helpers: uses PCB.Try.*, PCB.SafeNow from Core/Util.lua.
-- Taint:   uses PCB.SafeBool from Core/Taint.lua.

local ADDON_NAME, PCB = ...

-- =====================================================================
-- Icon / text visibility helpers
-- =====================================================================
local function SetIcon(f, texture)
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}
    if bdb.showIcon == false then
        PCB.Try.SetTexture(f.icon, nil)
        f.icon:Hide()
        return
    end
    if texture ~= nil then
        PCB.Try.SetTexture(f.icon, texture)
        f.icon:Show()
    else
        PCB.Try.SetTexture(f.icon, nil)
        f.icon:Hide()
    end
end
PCB.SetIcon = SetIcon   -- exposed for Test.lua

local function SetTexts(f, name, remainingSeconds)
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}

    if bdb.showSpellName == false then
        pcall(function() f.spellText:SetText("") end)
    else
        pcall(function() f.spellText:SetText(name or "") end)
    end

    if bdb.showTime ~= true then
        pcall(function() f.timeText:SetText("") end)
        return
    end

    if type(remainingSeconds) == "number" then
        pcall(function() f.timeText:SetFormattedText("%.1f", remainingSeconds) end)
    else
        pcall(function() f.timeText:SetText("") end)
    end
end
PCB.SetTexts = SetTexts

local function ApplySparkFromFillTexture(f)
    if not f.spark or not f.bar then return end
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}
    if bdb.showSpark == false then f.spark:Hide(); return end

    local tex
    local ok = pcall(function() tex = f.bar:GetStatusBarTexture() end)
    if not ok or not tex then f.spark:Hide(); return end

    local isShown = true
    pcall(function() isShown = tex:IsShown() end)
    if not isShown then f.spark:Hide(); return end

    f.spark:ClearAllPoints()
    if bdb.vertical then
        f.spark:SetPoint("CENTER", tex, "TOP", 0, 0)
    else
        f.spark:SetPoint("CENTER", tex, "RIGHT", 0, 0)
    end
    f.spark:Show()
end
PCB.ApplySparkFromFillTexture = ApplySparkFromFillTexture

local function EnsureVisible(f)
    if f.container and not f.container:IsShown() then f.container:Show() end
    if not f:IsShown() then f:Show() end
end
PCB.EnsureVisible = EnsureVisible

-- =====================================================================
-- PCB.TriggerFlash(f, kind)
-- kind: "success" | "failed"
-- =====================================================================
function PCB.TriggerFlash(f, kind)
    if not f or not f.flash then return end
    local db = PCB.db or {}
    local color
    if kind == "success" then
        color = db.colorSuccess or { r = 0.25, g = 0.90, b = 0.35, a = 1.0 }
    elseif kind == "failed" then
        color = db.colorFailed  or { r = 0.85, g = 0.25, b = 0.25, a = 1.0 }
    else
        return
    end
    local r = color.r or 1
    local g = color.g or 1
    local b = color.b or 1
    pcall(function()
        f.flash:SetVertexColor(r, g, b, 1)
        f.flash:SetAlpha(0.65)
        f.flash:Show()
    end)
    f._flashTimer    = 0
    f._flashDuration = 0.35
end

-- =====================================================================
-- PCB.ArmStopCheck(f, unitHint)
-- =====================================================================
function PCB.ArmStopCheck(f, unitHint)
    f._stopUnit    = unitHint or f.unit
    f._stopCheckAt = PCB.SafeNow() + PCB.END_GRACE_SECONDS
end

-- =====================================================================
-- PCB.VerifyAndStopIfInactive(f)
-- =====================================================================
function PCB.VerifyAndStopIfInactive(f)
    if not f._stopCheckAt then return end
    if PCB.SafeNow() < f._stopCheckAt then return end

    f._stopCheckAt = nil
    local unit = PCB.GetEffectiveUnit(f, f._stopUnit)
    f._stopUnit = nil

    if UnitCastingInfo(unit) ~= nil then return end
    if UnitChannelInfo(unit) ~= nil then return end

    PCB.ResetState(f, true)
end

-- =====================================================================
-- PCB.StartOrRefreshFromUnit(f, unitHint)
-- =====================================================================
function PCB.StartOrRefreshFromUnit(f, unitHint)
    local unit = PCB.GetEffectiveUnit(f, unitHint)

    local kind, name, texture, startSec, endSec, notInterruptible, durationObj =
        PCB.ReadUnitCast(unit)
    if not kind then return false end

    if (f.key == "target" or f.key == "focus") and unit ~= PCB.BAR_UNITS[f.key] then
        f._effectiveUnitActive = true
        f._effectiveUnit       = unit
    end

    f._stopCheckAt = nil
    f._stopUnit    = nil

    -- Clear any leftover flash so it doesn't bleed into the new cast.
    if f.flash then
        f.flash:Hide()
        f.flash:SetAlpha(0)
    end
    f._flashTimer    = 0
    f._flashDuration = 0

    -- Write state first so every subsequent call reads the correct values.
    local st = f._state or {}
    f._state = st

    st.kind             = kind
    st.unit             = unit
    st.name             = name
    st.texture          = texture
    st.durationObj      = durationObj
    
    -- Use durationObject:GetTotalDuration() for the cast duration.
    -- This mirrors UltimateCastbars: vars.dTime = durationObject:GetTotalDuration().
    -- GetTotalDuration() is secret for enemy units — store it for widget APIs
    -- (SetMinMaxValues/SetValue accept secret values) but never compare it in Lua.
    st.durationSec = nil
    if durationObj and durationObj.GetTotalDuration then
        st.durationSec = durationObj:GetTotalDuration()
    end
    -- nil check only — never compare the value itself
    if not st.durationSec then
        st.durationSec = (kind == "channel") and 3.0 or 1.5
    end

    -- Detect instant casts: compare raw duration before it's stored as a secret value.
    -- pcall is required because GetTotalDuration() returns a secret value for enemy units.
    -- We check the raw durationObj here, before the fallback inflates it to 1.5.
    local isInstant = false
    if kind ~= "channel" and kind ~= "empower" and durationObj and durationObj.GetTotalDuration then
        local ok, result = pcall(function()
            return durationObj:GetTotalDuration() < 0.5
        end)
        if ok then isInstant = result end
    end
    st.isInstantCast = isInstant

    -- Don't show the bar at all for instant casts — nothing to display.
    if isInstant then return false end
    
    -- Store the raw notInterruptible value directly — mirrors UCB vars.nIntr = notInterruptible.
    -- For enemy units this is a secret value from the WoW API; never compare it in Lua.
    -- Color.lua uses C_CurveUtil.EvaluateColorFromBoolean to pick bar colour.
    -- Update.lua uses EvaluateColorValueFromBoolean + SetAlpha for shield/icon visibility.
    -- Events still write a plain bool when UNIT_SPELLCAST_(NOT_)INTERRUPTIBLE fires.
    st.notInterruptible = notInterruptible

    PCB.ApplyAppearance(f)
    PCB.ApplyCastBarColor(f)
    SetIcon(f, texture)

    -- Spell name
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}
    if f.spellText then
        pcall(function()
            f.spellText:SetText((bdb.showSpellName ~= false) and (name or "") or "")
        end)
    end

    PCB.ConfigureStatusBarForState(f)

    -- No channel seek needed here: ConfigureStatusBarForState sets SetValue(dTotal)
    -- as the initial position, and FrameOnUpdate calls GetRemainingDuration() each
    -- frame and drives SetValue directly — matching how UCB's CastBar_OnUpdate works.

    f._pollElapsed   = 0
    f._textElapsed   = 0
    f._endGraceUntil = nil

    if f.container then
        f.container._pcbActive = true
        -- Cancel any in-progress fade from a previous cast ending.
        UIFrameFadeRemoveFrame(f.container)
        f.container:Show()
        f.container:SetAlpha((PCB.db and PCB.db.bars and
            PCB.db.bars[f.key] and PCB.db.bars[f.key].alpha) or 1)
    end
    f:Show()

    f:SetScript("OnUpdate", PCB.FrameOnUpdate)

    return true
end

-- =====================================================================
-- PCB.StopIfReallyStopped(f, unitHint)
-- =====================================================================
local function ShouldStillBeCasting(unit)
    if UnitCastingInfo(unit) ~= nil then return true end
    if UnitChannelInfo(unit) ~= nil then return true end
    return false
end

function PCB.StopIfReallyStopped(f, unitHint)
    if not f or not f._state then return end
    local st   = f._state
    local unit = PCB.GetEffectiveUnit(f, unitHint or st.unit)

    if f._endGraceUntil and PCB.SafeNow() < f._endGraceUntil then return end
    if ShouldStillBeCasting(unit) then return end

    PCB.ResetState(f, true)
end

-- =====================================================================
-- PCB.RefreshFrame(f, unitHint)
-- =====================================================================
function PCB.RefreshFrame(f, unitHint)
    if not f then return end
    if f.key and not PCB:IsBarEnabled(f.key) then
        PCB.ResetState(f, true)
        return
    end
    local unit = PCB.GetEffectiveUnit(f, unitHint)

    if not PCB.StartOrRefreshFromUnit(f, unit) then
        if f._state then
            f._endGraceUntil = PCB.SafeNow() + PCB.END_GRACE_SECONDS
            PCB.StopIfReallyStopped(f, unit)
        else
            PCB.ResetState(f, true)
        end
    end
end
