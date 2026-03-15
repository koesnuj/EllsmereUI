-- PhoenixCastBars - Core/Bootstrap.lua
-- Loaded last. Hooks ADDON_LOADED/PLAYER_LOGIN events, patches Blizzard
-- cast bar globals, and registers the /pcb slash command.

local ADDON_NAME, PCB = ...

-- Capture Blizzard's TargetFrameSpellBar_Update at load time so we can
-- wrap it safely during PLAYER_LOGIN without losing the original reference.
local _TargetFrameSpellBar_Update = _G.TargetFrameSpellBar_Update

-- =====================================================================
-- Slash command handler
-- =====================================================================
local function SlashHandler(msg)
    msg = strtrim(strlower(msg or ""))

    if msg == "lock" or msg == "locked" then
        PCB.db.locked = true
        if PCB.ApplyAll then PCB:ApplyAll() end
        PCB:Print("Frames locked.")

    elseif msg == "unlock" then
        PCB.db.locked = false
        if PCB.ApplyAll then PCB:ApplyAll() end
        PCB:Print("Frames unlocked. Drag to move.")

    elseif msg == "reset" then
        PhoenixCastBarsDB = nil
        ReloadUI()

    elseif msg == "resetpos" or msg == "resetpositions" then
        if PCB.ResetPositions then
            PCB:ResetPositions()
            PCB:Print("All cast bar positions reset to defaults.")
        end

    elseif msg == "test" then
        if PCB.SetTestMode then
            local newState = not PCB.testMode
            PCB:SetTestMode(newState)
            PCB:Print(newState and "Test mode enabled" or "Test mode disabled")
        end

    elseif msg == "media" then
        if PCB.LSM then
            PCB:Print("Available textures:")
            for _, name in ipairs(PCB.LSM:List("statusbar")) do
                PCB:Print("  - " .. name)
            end
            PCB:Print("Available fonts:")
            for _, name in ipairs(PCB.LSM:List("font")) do
                PCB:Print("  - " .. name)
            end
        else
            PCB:Print("LibSharedMedia not loaded")
        end

    elseif msg == "list" then
        local num = GetNumAddOns()
        PCB:Print(("GetNumAddOns() = %d"):format(num))
        for i = 1, num do
            local name, title = GetAddOnInfo(i)
            if name == ADDON_NAME or title == ADDON_NAME
               or title == "PhoenixCastBars" then
                PCB:Print(("Found at index %d: name=%s title=%s")
                    :format(i, tostring(name), tostring(title)))
            end
        end
        local metaTitle     = GetAddOnMetadata(ADDON_NAME, "Title")     or "<nil>"
        local metaInterface = GetAddOnMetadata(ADDON_NAME, "Interface") or "<nil>"
        PCB:Print(("Metadata: Title=%s Interface=%s"):format(metaTitle, metaInterface))

    else
        if PCB.Options and PCB.Options.Open then
            PCB.Options:Open()
        else
            PCB:Print("Options UI failed to open. Try /pcb after the UI fully loads.")
        end
    end
end

SLASH_PHOENIXCASTBARS1 = "/pcb"
SlashCmdList["PHOENIXCASTBARS"] = SlashHandler

-- =====================================================================
-- Boot event frame
-- =====================================================================
local bootFrame = CreateFrame("Frame")
bootFrame:RegisterEvent("ADDON_LOADED")
bootFrame:RegisterEvent("PLAYER_LOGIN")

bootFrame:SetScript("OnEvent", function(_, event, arg1)
    -- ----------------------------------------------------------------
    -- ADDON_LOADED: initialise db and register media
    -- ----------------------------------------------------------------
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        PCB:InitDB()
        PCB:RegisterMedia()

    -- ----------------------------------------------------------------
    -- PLAYER_LOGIN: apply Blizzard patches, boot all subsystems
    -- ----------------------------------------------------------------
    elseif event == "PLAYER_LOGIN" then

        -- Wrap TargetFrameSpellBar_Update to prevent Blizzard showing a
        -- duplicate target spellbar while PCB's target bar is active.
        if not PCB._blizzTargetHooked and _G.TargetFrameSpellBar_Update then
            PCB._blizzTargetHooked = true
            local orig = _TargetFrameSpellBar_Update

            _G.TargetFrameSpellBar_Update = function(...)
                if PCB:ShouldSuppressAllTargetBlizzardBars() then
                    local spellbar = (TargetFrame and TargetFrame.spellbar)
                                  or _G.TargetFrameSpellBar
                    if spellbar then
                        spellbar:SetAlpha(0)
                        spellbar:Hide()
                    end
                    return
                end
                -- Restore alpha in case PCB suppressed it previously
                local spellbar = (TargetFrame and TargetFrame.spellbar)
                              or _G.TargetFrameSpellBar
                if spellbar then spellbar:SetAlpha(1) end
                if orig then return orig(...) end
            end
        end

        -- Hook nameplate cast bars to suppress the target's if PCB target
        -- bar is enabled (prevents double bar on enemy target nameplates).
        if not PCB._nameplateCastHooked and hooksecurefunc then
            PCB._nameplateCastHooked = true

            local function OnNamePlateAdded(unitFrame)
                local frame = unitFrame
                if type(frame) ~= "table" then return end

                local castBar = frame.castBar or frame.CastBar
                             or (frame.UnitFrame and
                                (frame.UnitFrame.castBar or frame.UnitFrame.CastBar))
                if not castBar or castBar._pcbHooked then return end
                castBar._pcbHooked = true

                castBar:HookScript("OnShow", function(bar)
                    local unit = frame.unit
                    if PCB:ShouldSuppressNameplateCastbar(unit) then
                        bar:SetAlpha(0)
                        bar:Hide()
                    else
                        bar:SetAlpha(1)
                    end
                end)

                if castBar:IsShown() and
                   PCB:ShouldSuppressNameplateCastbar(frame.unit) then
                    castBar:SetAlpha(0)
                    castBar:Hide()
                end
            end

            if _G.NamePlateUnitFrame_OnAdded then
                hooksecurefunc("NamePlateUnitFrame_OnAdded", OnNamePlateAdded)
            end
        end

        -- Boot subsystems
        if PCB.UpdateCheck and PCB.UpdateCheck.Init then
            PCB.UpdateCheck:Init()
        end

        PCB:CreateBars()
        PCB:CreateMinimapButton()

        if PCB.Options and PCB.Options.Init then
            PCB.Options:Init()
        end

        PCB:ApplyAll()
        PCB:Print(("Loaded v%s. Type /pcb to open settings."):format(PCB.version))
    end
end)
