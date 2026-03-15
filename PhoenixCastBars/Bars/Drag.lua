-- PhoenixCastBars - Bars/Drag.lua
-- PCB:SaveBarPosition  — persist a moved bar's anchors to the db
-- PCB:SetMoverMode(on) — toggle the unlock/drag UI overlay
--
-- Unlock behaviour:
--   • Coordinates shown right-aligned inside each bar
--   • Click a bar to select it; arrow keys nudge only the selected bar
--     (1 px normal, 10 px with Shift)
--   • Arrow keys are ALWAYS consumed when unlock is active — never reach game/character
--   • Escape deselects the selected bar (but still propagates for menu closes etc.)
--   • Full-screen click catcher: clicking outside any bar deselects
--   • Drag snaps to integer pixels on release

local ADDON_NAME, PCB = ...

-- =====================================================================
-- PCB:SaveBarPosition
-- =====================================================================
function PCB:SaveBarPosition(f)
    if not f or not f.key or not self.db then return end
    self.db.bars = self.db.bars or {}
    self.db.bars[f.key] = self.db.bars[f.key] or {}
    local bdb = self.db.bars[f.key]

    local frame = f.container or f
    local point, _, relPoint, x, y = frame:GetPoint(1)
    if not point then return end

    bdb.point    = point
    bdb.relPoint = relPoint or point
    bdb.x        = PCB.Round(x)
    bdb.y        = PCB.Round(y)

    frame:ClearAllPoints()
    frame:SetPoint(bdb.point, UIParent, bdb.relPoint, bdb.x, bdb.y)
end

-- =====================================================================
-- Live coordinate update
-- =====================================================================
local function UpdateCoordText(f, selected)
    if not f.dragText then return end
    local frame = f.container or f
    local _, _, _, x, y = frame:GetPoint(1)
    if x and y then
        if selected then
            f.dragText:SetText(string.format(
                "|cff00ff00%d, %d  [click to select]|r", PCB.Round(x), PCB.Round(y)))
        else
            f.dragText:SetText(string.format(
                "|cffffd700%d, %d|r", PCB.Round(x), PCB.Round(y)))
        end
    end
end

-- =====================================================================
-- Selection state
-- =====================================================================
local nudgeFrame   = nil
local clickCatcher = nil
local selectedBar  = nil

local function SetSelectedBar(f)
    if selectedBar and selectedBar ~= f then
        UpdateCoordText(selectedBar, false)
    end
    selectedBar = f
    if f then UpdateCoordText(f, true) end
end

local function DeselectBar()
    if selectedBar then
        UpdateCoordText(selectedBar, false)
        selectedBar = nil
    end
end

local function NudgeSelected(dx, dy)
    local f = selectedBar
    if not f then return end
    local frame = f.container or f
    local point, _, relPoint, x, y = frame:GetPoint(1)
    if not point then return end
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint or point,
        PCB.Round(x + dx), PCB.Round(y + dy))
    PCB:SaveBarPosition(f)
    UpdateCoordText(f, true)
end

-- =====================================================================
-- Nudge frame + click catcher creation
-- =====================================================================
local function CreateNudgeFrame()
    if nudgeFrame then return end

    -- Key capture: default to consuming all input while unlock is active.
    -- Arrow keys are ALWAYS consumed (never reach game movement).
    -- Other keys are passed through after a 0-tick so chat/etc still work.
    nudgeFrame = CreateFrame("Frame", "PhoenixCastBars_NudgeCapture", UIParent)
    nudgeFrame:SetSize(1, 1)
    nudgeFrame:SetPoint("CENTER")
    nudgeFrame:EnableKeyboard(false)
    nudgeFrame:SetPropagateKeyboardInput(false)

    nudgeFrame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            DeselectBar()
            -- Let Escape propagate so it can still close menus etc.
            nudgeFrame:SetPropagateKeyboardInput(true)
            C_Timer.After(0, function() nudgeFrame:SetPropagateKeyboardInput(false) end)
            return
        end

        if key == "LEFT" or key == "RIGHT" or key == "UP" or key == "DOWN" then
            -- Always consume arrow keys — never let them reach character movement
            if selectedBar then
                local step = IsShiftKeyDown() and 10 or 1
                local dx, dy = 0, 0
                if     key == "LEFT"  then dx = -step
                elseif key == "RIGHT" then dx =  step
                elseif key == "UP"    then dy =  step
                elseif key == "DOWN"  then dy = -step
                end
                NudgeSelected(dx, dy)
            end
            return  -- propagate stays false → key is fully consumed
        end

        -- Any other key: pass through so chat, abilities, etc. work normally
        nudgeFrame:SetPropagateKeyboardInput(true)
        C_Timer.After(0, function() nudgeFrame:SetPropagateKeyboardInput(false) end)
    end)

    -- Full-screen click catcher sits below the bar frames.
    -- Clicks on bars are caught by the bar frame first (higher strata/level).
    -- Clicks that reach this catcher are on empty space → deselect.
    clickCatcher = CreateFrame("Frame", "PhoenixCastBars_DragClickCatcher", UIParent)
    clickCatcher:SetAllPoints(UIParent)
    clickCatcher:EnableMouse(true)
    clickCatcher:SetFrameStrata("LOW")
    clickCatcher:SetFrameLevel(1)
    clickCatcher:Hide()
    clickCatcher:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            DeselectBar()
        end
    end)
end

-- =====================================================================
-- Per-bar drag enable / disable
-- =====================================================================
local function EnableDragging(f)
    if not f or f._dragEnabled then return end
    f._dragEnabled = true

    local dragFrame = f.container or f
    -- Must be above the click catcher (LOW strata) so clicks on bars don't deselect
    dragFrame:SetFrameStrata("MEDIUM")
    dragFrame:EnableMouse(true)
    dragFrame:RegisterForDrag("LeftButton")

    dragFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then SetSelectedBar(f) end
    end)

    dragFrame:SetScript("OnDragStart", function(self)
        if PCB.db and PCB.db.locked then return end
        SetSelectedBar(f)
        pcall(function() self:StopMovingOrSizing() end)
        pcall(function() self:StartMoving() end)
    end)

    dragFrame:SetScript("OnDragStop", function(self)
        pcall(function() self:StopMovingOrSizing() end)
        if PCB and PCB.SaveBarPosition then PCB:SaveBarPosition(f) end
        UpdateCoordText(f, selectedBar == f)
    end)

    dragFrame:SetScript("OnUpdate", function()
        if dragFrame:IsMovable() and dragFrame:IsMouseOver() then
            UpdateCoordText(f, selectedBar == f)
        end
    end)
end

local function DisableDragging(f)
    if not f or not f._dragEnabled then return end
    f._dragEnabled = nil

    local dragFrame = f.container or f
    dragFrame:SetFrameStrata("BACKGROUND")
    dragFrame:RegisterForDrag()
    dragFrame:EnableMouse(false)
    dragFrame:SetScript("OnMouseDown", nil)
    dragFrame:SetScript("OnDragStart", nil)
    dragFrame:SetScript("OnDragStop",  nil)
    dragFrame:SetScript("OnUpdate",    nil)
end

-- =====================================================================
-- Mover overlay show / hide
-- =====================================================================
local function ShowMover(f)
    f.isMover = true
    if f.container then f.container:Show() end
    f:Show()

    PCB.Try.SetMinMax(f.bar, 0, 1)
    PCB.Try.SetValue(f.bar, 0.75)
    PCB.Try.SetText(f.spellText, "")
    PCB.Try.SetText(f.timeText,  "")
    f.icon:Hide()
    if f.spark then f.spark:Hide() end

    if f.dragText then
        UpdateCoordText(f, false)
        f.dragText:Show()
    end

    if f.unlockLabel then
        local labels = { player = "Player", target = "Target", focus = "Focus",
                         pet = "Pet", gcd = "GCD" }
        f.unlockLabel:SetText(labels[f.key] or tostring(f.key or "Cast Bar"))
        f.unlockLabel:Show()
    end

    PCB.ApplyCastBarColor(f)
end

local function HideMover(f)
    f.isMover = false
    if f.dragText    then f.dragText:Hide()    end
    if f.unlockLabel then f.unlockLabel:Hide() end
    if (PCB.db and PCB.db.locked) and not f._state and not f.test then
        if f.container then f.container:Hide() end
        f:Hide()
    end
    if selectedBar == f then selectedBar = nil end
end

-- =====================================================================
-- PCB:SetMoverMode(enabled)
-- =====================================================================
function PCB:SetMoverMode(enabled)
    if not self.Bars then return end
    CreateNudgeFrame()

    if not enabled then DeselectBar() end

    for _, f in pairs(self.Bars) do
        local key        = f and f.key
        local barEnabled = (key and PCB:IsBarEnabled(key)) or true

        if enabled and barEnabled then
            ShowMover(f)
            EnableDragging(f)
        else
            DisableDragging(f)
            HideMover(f)
        end

        if not barEnabled then PCB.ResetState(f, true) end
    end

    if nudgeFrame then
        nudgeFrame:EnableKeyboard(enabled)
        if enabled then nudgeFrame:SetFrameStrata("DIALOG") end
    end

    if clickCatcher then
        if enabled then clickCatcher:Show() else clickCatcher:Hide() end
    end
end
