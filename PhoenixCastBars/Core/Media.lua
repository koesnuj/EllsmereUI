-- PhoenixCastBars - Core/Media.lua
-- Registers custom textures/fonts with LibSharedMedia and manages the
-- minimap button via LibDBIcon + LibDataBroker.

local ADDON_NAME, PCB = ...

-- =====================================================================
-- LibSharedMedia registration
-- =====================================================================
function PCB:RegisterMedia()
    if not self.LSM or not self.LSM.Register then return end

    self.LSM:Register("statusbar", "Phoenix CastBar",
        "Interface\\AddOns\\PhoenixCastBars\\Media\\Phoenix_CastBar.blp")
    self.LSM:Register("statusbar", "Phoenix Feather",
        "Interface\\AddOns\\PhoenixCastBars\\Media\\Phoenix_Feather.blp")

    -- Re-apply when any new media is registered by other addons
    self.LSM.RegisterCallback(self, "LibSharedMedia_Registered", function(_, mediatype)
        if (mediatype == "statusbar" or mediatype == "font") and self.ApplyAll then
            self:ApplyAll()
        end
    end)
end

-- =====================================================================
-- Minimap button (LibDataBroker + LibDBIcon)
-- =====================================================================
function PCB:CreateMinimapButton()
    if not self.LDBIcon then
        self:Print("LibDBIcon not loaded — minimap button unavailable")
        return
    end

    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then
        self:Print("LibDataBroker not loaded — minimap button unavailable")
        return
    end

    self.minimapLDB = LDB:NewDataObject("PhoenixCastBars", {
        type = "launcher",
        text = "PhoenixCastBars",
        icon = "Interface\\AddOns\\PhoenixCastBars\\Media\\Phoenix_Addon_Logo.blp",

        OnClick = function(_, button)
            if button == "LeftButton" then
                if PCB.Options and PCB.Options.Open then
                    PCB.Options:Open()
                end
            elseif button == "RightButton" then
                PCB.db.locked = not PCB.db.locked
                PCB:ApplyAll()
                PCB:Print(PCB.db.locked and "Frames locked." or "Frames unlocked. Drag to move.")
            end
        end,

        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:SetText("PhoenixCastBars", 1, 1, 1)
            tooltip:AddLine("Left-click to open options",  0.2, 1, 0.2)
            tooltip:AddLine("Right-click to toggle lock",  0.2, 1, 0.2)
        end,
    })

    self.LDBIcon:Register("PhoenixCastBars", self.minimapLDB, self.db.minimapButton)
    self:UpdateMinimapButton()
end

function PCB:UpdateMinimapButton()
    if not self.LDBIcon then return end
    if self.db and self.db.minimapButton and self.db.minimapButton.show then
        self.LDBIcon:Show("PhoenixCastBars")
    else
        self.LDBIcon:Hide("PhoenixCastBars")
    end
end
