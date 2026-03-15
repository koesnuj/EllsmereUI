-- PhoenixCastBars - Bars/Empower.lua
-- Draws stage-marker lines for Evoker empower spells and colour-grades
-- the bar fill based on progress through the stages.

local ADDON_NAME, PCB = ...

-- Spell name fragments that indicate an empower cast
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

-- Fallback colors used when DB keys are missing
local STAGE_FALLBACKS = {
    { r = 0.9,  g = 0.2,  b = 0.2,  a = 1.0 },  -- Stage 1: red
    { r = 1.0,  g = 0.8,  b = 0.0,  a = 1.0 },  -- Stage 2: yellow
    { r = 0.2,  g = 0.9,  b = 0.2,  a = 1.0 },  -- Stage 3: green
    { r = 0.15, g = 0.45, b = 0.9,  a = 1.0 },  -- Stage 4: blue
}

local STAGE_KEYS = {
    "empowerStage1Color",
    "empowerStage2Color",
    "empowerStage3Color",
    "empowerStage4Color",
}

-- =====================================================================
-- PCB.UpdateEmpowerStages(f)
-- Called each frame while a cast is active.
-- Shows/positions/hides the three stage-marker lines and colour-grades
-- the bar using user-configurable per-stage colors from the DB.
-- =====================================================================
function PCB.UpdateEmpowerStages(f)
    if not f.empowerStages then return end

    local st = f._state
    if not st or st.kind ~= "cast" or not IsEmpowerSpell(st.name) then
        for i = 1, 3 do
            if f.empowerStages[i] then f.empowerStages[i]:Hide() end
        end
        return
    end

    local barWidth  = f.bar:GetWidth()
    local barHeight = f.bar:GetHeight()
    if not (barWidth and barWidth > 0 and barHeight and barHeight > 0) then return end

    local positions = { 0.25, 0.50, 0.75 }
    for i = 1, 3 do
        local stage = f.empowerStages[i]
        if stage then
            stage:SetHeight(barHeight)
            stage:SetWidth(3)
            stage:ClearAllPoints()
            stage:SetPoint("CENTER", f.bar, "LEFT", barWidth * positions[i], 0)
            stage:Show()
        end
    end

    -- Colour-grade bar based on progress, using DB-configurable stage colors
    if f.bar and st.startSec and st.endSec then
        local now      = GetTime()
        local elapsed  = now - st.startSec
        local duration = st.endSec - st.startSec
        local progress = (duration > 0) and (elapsed / duration) or 0

        local db       = PCB.db or {}
        local stageIdx
        if     progress < 0.25 then stageIdx = 1
        elseif progress < 0.50 then stageIdx = 2
        elseif progress < 0.75 then stageIdx = 3
        else                        stageIdx = 4
        end

        local color = db[STAGE_KEYS[stageIdx]] or STAGE_FALLBACKS[stageIdx]
        local r = PCB.NormalizeColor and select(1, PCB.NormalizeColor(color, STAGE_FALLBACKS[stageIdx]))
                  or (color.r or 1)
        local g = PCB.NormalizeColor and select(2, PCB.NormalizeColor(color, STAGE_FALLBACKS[stageIdx]))
                  or (color.g or 1)
        local b = PCB.NormalizeColor and select(3, PCB.NormalizeColor(color, STAGE_FALLBACKS[stageIdx]))
                  or (color.b or 1)
        local a = PCB.NormalizeColor and select(4, PCB.NormalizeColor(color, STAGE_FALLBACKS[stageIdx]))
                  or (color.a or 1)

        pcall(function() f.bar:SetStatusBarColor(r, g, b, a) end)
    end
end
