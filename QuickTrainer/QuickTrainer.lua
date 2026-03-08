----------------------------------------------------------------------
--  QuickTrainer  –  Trainer auto-advance
--
--  After learning a recipe from a trainer NPC:
--    1. Hides already-learned ("used") entries from the list
--    2. Auto-selects the next available (learnable) recipe
--    3. Scrolls the list so that recipe is visible
--
--  Uses Blizzard's own ClassTrainer_SelectNearestLearnableSkill()
--  which already exists but is only called when the trainer window
--  first opens — not after each purchase.
----------------------------------------------------------------------
local ADDON_NAME, NS = ...

----------------------------------------------------------------------
--  Defaults & saved variables
----------------------------------------------------------------------
local defaults = {
    enabled  = true,
    hideUsed = true,
}

local db

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, addon)
    if addon ~= ADDON_NAME then return end
    f:UnregisterEvent("ADDON_LOADED")

    QuickTrainerDB = QuickTrainerDB or {}
    db = setmetatable(QuickTrainerDB, { __index = defaults })
end)

----------------------------------------------------------------------
--  Hook BuyTrainerService
----------------------------------------------------------------------
local hooked = false

local function HookTrainer()
    if hooked then return end
    hooked = true

    hooksecurefunc("BuyTrainerService", function(index)
        if not db or not db.enabled then return end

        -- 1. Hide already-learned entries so they disappear from the list
        if db.hideUsed then
            if GetTrainerServiceTypeFilter and SetTrainerServiceTypeFilter then
                if GetTrainerServiceTypeFilter("used") then
                    SetTrainerServiceTypeFilter("used", false)
                end
            end
        end

        -- 2. After TRAINER_UPDATE fires (which refreshes the list),
        --    auto-select the next available recipe.
        --    Small delay lets the event propagate and the list rebuild.
        C_Timer.After(0.15, function()
            if ClassTrainer_SelectNearestLearnableSkill then
                ClassTrainer_SelectNearestLearnableSkill()
            end
        end)
    end)
end

----------------------------------------------------------------------
--  Wait for Blizzard_TrainerUI to load (it's a load-on-demand addon)
----------------------------------------------------------------------
local waitFrame = CreateFrame("Frame")
waitFrame:RegisterEvent("ADDON_LOADED")
waitFrame:SetScript("OnEvent", function(self, event, addon)
    if addon == "Blizzard_TrainerUI" then
        self:UnregisterEvent("ADDON_LOADED")
        HookTrainer()
    end
end)

-- In case it's already loaded (e.g. user /reload while trainer is open)
if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_TrainerUI") then
    HookTrainer()
elseif IsAddOnLoaded and IsAddOnLoaded("Blizzard_TrainerUI") then
    HookTrainer()
end

----------------------------------------------------------------------
--  Slash command
----------------------------------------------------------------------
SLASH_QUICKTRAINER1 = "/quicktrainer"
SLASH_QUICKTRAINER2 = "/qt"

SlashCmdList["QUICKTRAINER"] = function(msg)
    local cmd = strtrim(msg):lower()
    if not db then db = setmetatable(QuickTrainerDB or {}, { __index = defaults }) end

    if cmd == "on" or cmd == "enable" then
        db.enabled = true
        print("|cff00ccffQuickTrainer|r: |cff00ff00Enabled|r")
    elseif cmd == "off" or cmd == "disable" then
        db.enabled = false
        print("|cff00ccffQuickTrainer|r: |cffff0000Disabled|r")
    elseif cmd == "hideused" then
        db.hideUsed = not db.hideUsed
        print("|cff00ccffQuickTrainer|r: Hide learned recipes " .. (db.hideUsed and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
    else
        print("|cff00ccffQuickTrainer|r commands:")
        print("  /qt |cffffff00on|r / |cffffff00off|r — Toggle auto-advance")
        print("  /qt |cffffff00hideused|r — Toggle hide learned recipes")
    end
end
