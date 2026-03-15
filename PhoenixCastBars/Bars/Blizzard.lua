-- PhoenixCastBars - Bars/Blizzard.lua
-- Non-destructive suppression of Blizzard's default cast bars.
-- When a PCB bar is enabled for a unit, the corresponding Blizzard bar
-- is hidden via a soft OnShow hook rather than UnregisterAllEvents,
-- so it can be safely restored if the user disables the PCB bar.

local ADDON_NAME, PCB = ...

PCB._blizzardBars = PCB._blizzardBars or {}

-- =====================================================================
-- Unit → Blizzard spell bar frame mapping
-- =====================================================================
local function GetSpellBarForUnit(unit)
    if unit == "player" then
        return _G.PlayerCastingBarFrame or _G.CastingBarFrame
    elseif unit == "target" then
        if _G.TargetFrame and _G.TargetFrame.spellbar then
            return _G.TargetFrame.spellbar
        end
        return _G.TargetFrameSpellBar
    elseif unit == "focus" then
        if _G.FocusFrame and _G.FocusFrame.spellbar then
            return _G.FocusFrame.spellbar
        end
        return _G.FocusFrameSpellBar
    elseif unit == "pet"      then return _G.PetCastingBarFrame
    elseif unit == "vehicle"  then return _G.VehicleCastingBarFrame
    elseif unit == "override" then return _G.OverrideActionBarSpellBar
    end
end

-- =====================================================================
-- Soft hook helpers
-- =====================================================================
local function SnapshotBar(bar)
    if not bar or PCB._blizzardBars[bar] then return end
    PCB._blizzardBars[bar] = { onShow = bar:GetScript("OnShow"), hooked = false }
end

local function EnsureSoftHook(bar)
    local info = PCB._blizzardBars and PCB._blizzardBars[bar]
    if not bar or not info or info.hooked then return end
    info.hooked = true

    bar:HookScript("OnShow", function(self)
        if self._pcbSuppressed then
            if self._pcbHiding then return end
            self._pcbHiding = true
            self:SetAlpha(0)
            self:Hide()
            self._pcbHiding = false
        end
    end)
end

local function SuppressBar(bar)
    if not bar then return end
    SnapshotBar(bar)
    EnsureSoftHook(bar)
    bar._pcbSuppressed = true
    bar:SetAlpha(0)
    bar:Hide()
end

local function RestoreBar(bar)
    if not bar then return end
    SnapshotBar(bar)
    EnsureSoftHook(bar)
    bar._pcbSuppressed = nil
    bar:SetAlpha(1)
    -- Do NOT force :Show(); Blizzard will show when appropriate.
end

-- =====================================================================
-- Internal helpers
-- =====================================================================
local function UnitEnabled(unitKey)
    local db = PCB and PCB.db
    if not db or not db.bars or not db.bars[unitKey] then return true end
    return db.bars[unitKey].enabled ~= false
end

local function UnitIsCastingOrChanneling(unit)
    if not unit or not UnitExists(unit) then return false end
    return UnitCastingInfo(unit) ~= nil or UnitChannelInfo(unit) ~= nil
end

-- =====================================================================
-- PCB API (called by Options, Bootstrap, and the watcher below)
-- =====================================================================
function PCB:ShouldSuppressAllTargetBlizzardBars()
    local db = self.db and self.db.bars and self.db.bars.target
    return db and db.enabled == true
end

function PCB:ShouldSuppressNameplateCastbar(unit)
    if not unit or not UnitIsUnit(unit, "target") then return false end
    local db = self.db and self.db.bars and self.db.bars.target
    return db and db.enabled == true
end

function PCB:UpdateBlizzardCastBars()
    local db = self.db

    -- Player / pet / vehicle / override bars
    local playerBars = { _G.PlayerCastingBarFrame, _G.CastingBarFrame }
    local petBar     = GetSpellBarForUnit("pet")
    local vehBar     = GetSpellBarForUnit("vehicle")
    local overBar    = GetSpellBarForUnit("override")

    if UnitEnabled("player") then
        for _, b in ipairs(playerBars) do SuppressBar(b) end
        SuppressBar(petBar); SuppressBar(vehBar); SuppressBar(overBar)
    else
        for _, b in ipairs(playerBars) do RestoreBar(b) end
        RestoreBar(petBar); RestoreBar(vehBar); RestoreBar(overBar)
    end

    -- Target / Focus — authoritative per-unit control
    local targetBar = GetSpellBarForUnit("target")
    local focusBar  = GetSpellBarForUnit("focus")

    if UnitEnabled("target") then
        SuppressBar(targetBar)
    else
        RestoreBar(targetBar)
        if targetBar then
            targetBar:SetAlpha(1)
            if UnitIsCastingOrChanneling("target") then targetBar:Show() end
        end
    end

    if UnitEnabled("focus") then
        SuppressBar(focusBar)
    else
        RestoreBar(focusBar)
        if focusBar then
            focusBar:SetAlpha(1)
            if UnitIsCastingOrChanneling("focus") then focusBar:Show() end
        end
    end

    -- Edge case: when target == player, suppress duplicate player bar
    if UnitEnabled("target") and UnitExists("target") and UnitIsUnit("target", "player") then
        for _, b in ipairs(playerBars) do SuppressBar(b) end
    end

    -- When target bar is disabled, re-allow nameplate castbars for the target
    if not UnitEnabled("target") and C_NamePlate and C_NamePlate.GetNamePlates then
        local plates = C_NamePlate.GetNamePlates() or {}
        for _, plate in ipairs(plates) do
            local uf   = plate and plate.UnitFrame
            local unit = uf and uf.unit
            if unit and UnitIsUnit(unit, "target") then
                local cb = uf.castBar or uf.CastBar
                         or (uf.UnitFrame and (uf.UnitFrame.castBar or uf.UnitFrame.CastBar))
                if cb then
                    cb:SetAlpha(1)
                    if UnitIsCastingOrChanneling(unit) then cb:Show() end
                end
            end
        end
    end
end

-- =====================================================================
-- Background watcher: re-enforces suppression on key events
-- =====================================================================
PCB._blizzBarWatcher = CreateFrame("Frame")
PCB._blizzBarWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
PCB._blizzBarWatcher:RegisterEvent("UI_SCALE_CHANGED")
PCB._blizzBarWatcher:RegisterEvent("ADDON_LOADED")
PCB._blizzBarWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
PCB._blizzBarWatcher:RegisterEvent("PLAYER_FOCUS_CHANGED")
PCB._blizzBarWatcher:RegisterUnitEvent("UNIT_SPELLCAST_START",         "player", "vehicle", "target", "focus")
PCB._blizzBarWatcher:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player", "vehicle", "target", "focus")
PCB._blizzBarWatcher:SetScript("OnEvent", function(_, event, arg1)
    if PCB and PCB.UpdateBlizzardCastBars then
        if event ~= "ADDON_LOADED" or
           (type(arg1) == "string" and arg1:match("^Blizzard_")) then
            PCB:UpdateBlizzardCastBars()
        end
    end
end)
