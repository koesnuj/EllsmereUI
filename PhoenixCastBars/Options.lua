local ADDON_NAME, PCB = ...

-- =====================================================
-- DB Helpers (must be file-level, not inside functions)
-- =====================================================

local function GetValue(db, key)
    if not db or not key then return nil end
    local keys = { strsplit(".", key) }
    local val = db
    for i = 1, #keys do
        if type(val) ~= "table" then return nil end
        val = val[keys[i]]
        if val == nil then return nil end
    end
    return val
end

local function SetValue(db, key, value)
    local keys = { strsplit(".", key) }
    local val = db
    for i = 1, #keys - 1 do
        if type(val[keys[i]]) ~= "table" then
            val[keys[i]] = {}
        end
        val = val[keys[i]]
    end
    val[keys[#keys]] = value
end

-- ============================================================================
-- PhoenixCastBars - Safe Dropdown Manager (Patched)
-- ============================================================================

local PCB_DropdownManager = CreateFrame("Frame", "PCB_DropdownManager", UIParent)
PCB_DropdownManager:SetAllPoints(UIParent)
PCB_DropdownManager:Hide()

PCB_DropdownManager:EnableMouse(true)
PCB_DropdownManager:SetFrameStrata("HIGH")
PCB_DropdownManager:SetFrameLevel(10000)

PCB_DropdownManager.activeDropdown = nil

PCB_DropdownManager:SetScript("OnMouseDown", function(self)
    if self.activeDropdown then
        self.activeDropdown:Hide()
        self.activeDropdown = nil
    end
    self:Hide()
end)

PCB_DropdownManager:SetScript("OnHide", function(self)
    if self.activeDropdown then
        self.activeDropdown:Hide()
        self.activeDropdown = nil
    end
end)

local function PCB_ShowDropdown(dropdownFrame)
    if PCB_DropdownManager.activeDropdown 
       and PCB_DropdownManager.activeDropdown ~= dropdownFrame then
        PCB_DropdownManager.activeDropdown:Hide()
    end

    PCB_DropdownManager.activeDropdown = dropdownFrame

    dropdownFrame:SetFrameStrata("HIGH")
    dropdownFrame:SetFrameLevel(10001)
    dropdownFrame:Show()

    PCB_DropdownManager:Show()
end

local function PCB_HideDropdown(dropdownFrame)
    dropdownFrame:Hide()

    if PCB_DropdownManager.activeDropdown == dropdownFrame then
        PCB_DropdownManager.activeDropdown = nil
        PCB_DropdownManager:Hide()
    end
end

-- =====================================================================
-- Enhanced Blizzard Interface Options Panel
-- =====================================================================

local function OpenPhoenixCastBarsOptions()
    if PCB.Options and PCB.Options.Open then
        PCB.Options:Open()
    elseif PhoenixCastBarsOptionsFrame and PhoenixCastBarsOptionsFrame.Show then
        PhoenixCastBarsOptionsFrame:Show()
    elseif PCB.ShowOptions then
        PCB:ShowOptions()
    else
        message("PhoenixCastBars: Could not open options. Try using /pcb")
    end
end

-- Create the main options panel frame
local blizzPanel = CreateFrame("Frame", "PhoenixCastBarsBlizzOptionsPanel", UIParent)
blizzPanel.name = "PhoenixCastBars"

-- Title section with addon branding
local title = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("|cff1a80ffPhoenix|r|cffff6600CastBars|r")

-- Subtitle/Version
local subtitle = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
subtitle:SetTextColor(0.5, 0.5, 0.5, 1)
subtitle:SetText("v" .. (PCB.version or "0.0.0"))
blizzPanel:SetScript("OnShow", function()
    subtitle:SetText("v" .. (PCB.version or "0.0.0"))
end)

-- Description text area
local desc = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
desc:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
desc:SetWidth(400)
desc:SetJustifyH("LEFT")
desc:SetText("PhoenixCastBars replaces the default Blizzard cast bars with highly customizable alternatives. Configure cast bar appearance, positioning, colors, and behavior for Player, Target, Focus, and GCD bars.")

-- Features list
local featuresTitle = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
featuresTitle:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
featuresTitle:SetText("Features:")
featuresTitle:SetTextColor(1, 0.82, 0, 1)

local featuresText = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
featuresText:SetPoint("TOPLEFT", featuresTitle, "BOTTOMLEFT", 10, -8)
featuresText:SetWidth(380)
featuresText:SetJustifyH("LEFT")
featuresText:SetText("• Customizable cast bar textures, fonts, and colors\n• Individual settings for Player, Target, Focus, and GCD bars\n• Latency indicator for player casts\n• Profile management with spec-specific profiles\n• Movable frames with click-and-drag positioning")

-- Main action button - styled to match Phoenix theme
local openBtn = CreateFrame("Button", nil, blizzPanel, "UIPanelButtonTemplate")
openBtn:SetSize(220, 28)
openBtn:SetPoint("TOPLEFT", featuresText, "BOTTOMLEFT", -10, -24)
openBtn:SetText("Open PhoenixCastBars Options")

-- Add Phoenix-colored glow effect to button
local btnGlow = openBtn:CreateTexture(nil, "BACKGROUND")
btnGlow:SetPoint("CENTER", openBtn, "CENTER")
btnGlow:SetSize(230, 38)
btnGlow:SetTexture("Interface\\Buttons\\UI-Quickslot")
btnGlow:SetVertexColor(0.15, 0.45, 0.90, 0.3)
btnGlow:SetBlendMode("ADD")
btnGlow:Hide()

openBtn:SetScript("OnEnter", function(self)
    btnGlow:Show()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Open Options")
    GameTooltip:AddLine("Click to open the full PhoenixCastBars configuration window where you can customize all cast bar settings.", 1, 1, 1, true)
    GameTooltip:Show()
end)

openBtn:SetScript("OnLeave", function(self)
    btnGlow:Hide()
    GameTooltip:Hide()
end)

openBtn:SetScript("OnClick", function()
    if SettingsPanel and SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    elseif InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then
        HideUIPanel(InterfaceOptionsFrame)
    end

    local focus = GetCurrentKeyBoardFocus()
    if focus then focus:ClearFocus() end

    OpenPhoenixCastBarsOptions()
end)

-- Slash command reminder
local slashHint = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
slashHint:SetPoint("TOPLEFT", openBtn, "BOTTOMLEFT", 0, -12)
slashHint:SetText("You can also open options with: |cffaaaaaa/pcb|r or |cffaaaaaa/phoenixcastbars|r")

-- Support/Community section
local supportTitle = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
supportTitle:SetPoint("TOPLEFT", slashHint, "BOTTOMLEFT", 0, -30)
supportTitle:SetText("Support & Community")
supportTitle:SetTextColor(1, 0.82, 0, 1)

local supportText = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
supportText:SetPoint("TOPLEFT", supportTitle, "BOTTOMLEFT", 0, -8)
supportText:SetWidth(400)
supportText:SetJustifyH("LEFT")
supportText:SetText("Join our Discord community for support, feature requests, and updates. Click the Discord button in the options window or visit the addon page.")

-- =====================================================================
-- Register with Blizzard Interface Options (Modern & Classic Compatible)
-- =====================================================================

local function RegisterPhoenixCastBarsBlizzPanel()
    -- Modern WoW (Dragonflight 10.0+ / The War Within) uses Settings API
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(blizzPanel, blizzPanel.name)
        category.ID = blizzPanel.name
        Settings.RegisterAddOnCategory(category)
        blizzPanel._registered = true
        blizzPanel._settingsCategory = category
        return true
    end
end

-- Register panel when appropriate
local function RegisterPanelWhenReady()
    if RegisterPhoenixCastBarsBlizzPanel() then
        return
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, arg1)
        if RegisterPhoenixCastBarsBlizzPanel() then
            self:UnregisterAllEvents()
            self:SetScript("OnEvent", nil)
        end
    end)

    f:RegisterEvent("PLAYER_ENTERING_WORLD")
end

RegisterPanelWhenReady()

-- Alias for external access (Blizzard options panel button)
function PCB:ShowOptions()
    Options:Open()
end

-- Global variable to track which bar to reset
PCB._pendingResetBarKey = nil

-- Define the StaticPopupDialog at top-level scope so WoW can register it
StaticPopupDialogs["PCB_CONFIRM_RESET"] = {
    text = "Reset bar settings to defaults?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        print("PCB_CONFIRM_RESET OnAccept fired")
        if PCB._pendingResetBarKey and PCB.ResetBar then
            print("Calling PCB:ResetBar for", PCB._pendingResetBarKey)
            PCB:ResetBar(PCB._pendingResetBarKey)
            PCB._pendingResetBarKey = nil
        else
            print("PCB or PCB.ResetBar missing or no pending key")
        end
    end,
    OnCancel = function()
        print("PCB_CONFIRM_RESET OnCancel fired")
        PCB._pendingResetBarKey = nil
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local Options = {}
PCB.Options = Options

-- =====================================================================
-- Color Palette - Available globally across the addon
-- =====================================================================
PCB.COLORS = {
    -- Core brand colours
    PHOENIX_ORANGE_DARK   = { 0.85, 0.35, 0.05, 1 },
    PHOENIX_ORANGE        = { 0.95, 0.45, 0.10, 1 },
    PHOENIX_ORANGE_DIM    = { 0.65, 0.25, 0.05, 1 },

    PHOENIX_BLUE_DARK     = { 0.10, 0.35, 0.70, 1 },
    PHOENIX_BLUE          = { 0.15, 0.45, 0.90, 1 },
    PHOENIX_BLUE_DIM      = { 0.10, 0.30, 0.55, 1 },

    -- Neutrals
    PANEL_BG              = { 0.06, 0.06, 0.07, 0.95 },
    PANEL_BORDER          = { 0.25, 0.25, 0.25, 1 },

    TEXT_PRIMARY          = { 1.00, 0.82, 0.00, 1 }, -- Blizzard gold-ish
    TEXT_MUTED            = { 0.65, 0.70, 0.75, 1 },

    -- States
    ENABLED               = { 0.15, 0.90, 0.25, 1 },
    DISABLED              = { 0.50, 0.50, 0.50, 1 },
    ERROR                 = { 0.90, 0.20, 0.20, 1 },
}

-- Helper functions for applying colors
function PCB:SetColor(tex, color)
    tex:SetColorTexture(unpack(color))
end

-- Sets the vertex color of a region (e.g., FontString, Texture)
function PCB:SetVertexColor(region, color)
    region:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
end



local optionsFrame = nil
local selectedCategory = "general"  -- Track which category is currently displayed
local SkinCheckbox

-- =====================================================================
-- Options System Initialization
-- =====================================================================
function Options:Init()
    if self._inited then return end
    self._inited = true
    
    if not PCB.db then 
        PCB:InitDB()
    end
end

-- Opens (or toggles) the options window. If already open, it will close.
function Options:Open()
    if not self._inited then 
        self:Init() 
    end
    
    if optionsFrame and optionsFrame:IsShown() then
        optionsFrame:Hide()
        return
    end
    
    -- Lazily create the options window on first open
    if not optionsFrame then

        optionsFrame = CreateFrame("Frame", "PhoenixCastBarsOptionsFrame", UIParent)
        PCB.optionsFrame = optionsFrame  -- expose so changelog button can close it
        optionsFrame:SetFrameStrata("HIGH")
        optionsFrame:SetWidth(700)
        optionsFrame:SetHeight(600)
        optionsFrame:SetPoint("CENTER", UIParent, "CENTER")
        
                local bg = optionsFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(optionsFrame)
        bg:SetColorTexture(0.05, 0.05, 0.1, 1)
        
        optionsFrame:SetMovable(true)
        optionsFrame:EnableMouse(true)
        optionsFrame:RegisterForDrag("LeftButton")

        optionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        optionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        tinsert(UISpecialFrames, "PhoenixCastBarsOptionsFrame")

        -- Update arrow button to reflect menu open/closed state
        local function UpdateArrow(arrowBtn, isOpen)
            if not arrowBtn then return end
            local normalTex  = arrowBtn:GetNormalTexture()
            local pushedTex  = arrowBtn:GetPushedTexture()
            if isOpen then
                if normalTex then
                    normalTex:SetTexture("Interface\\Buttons\\Arrow-Up-Up")
                    normalTex:SetPoint("CENTER", arrowBtn, "CENTER", 3, 1)
                end
                if pushedTex then
                    pushedTex:SetTexture("Interface\\Buttons\\Arrow-Up-Down")
                    pushedTex:SetPoint("CENTER", arrowBtn, "CENTER", 3, 1)
                end
            else
                if normalTex then
                    normalTex:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
                    normalTex:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                end
                if pushedTex then
                    pushedTex:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
                    pushedTex:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                end
            end
        end

        -- Track all open dropdown menus (defined early for OnHide access)
        local activeMenus = {}
        local function CloseAllMenus()
            for menu in pairs(activeMenus) do
                if menu and menu.Hide then
                    menu:Hide()
                    UpdateArrow(menu._arrowBtn, false)
                end
            end
            activeMenus = {}
        end

        -- Cleanup on hide to prevent keyboard input issues
        optionsFrame:SetScript("OnHide", function(self)
            -- Clear keyboard focus when hiding
            local focus = GetCurrentKeyBoardFocus()
            if focus then
                focus:ClearFocus()
            end
            -- Ensure dropdown click catcher is hidden
            if dropdownClickCatcher then
                dropdownClickCatcher:Hide()
            end
            -- Close any open menus
            CloseAllMenus()
            -- Hide any popups that might be open
            if discordPopup then
                discordPopup:Hide()
            end
        end)

        -- Close all dropdown menus when clicking anywhere on the options frame
        -- (menus are FULLSCREEN_DIALOG strata so clicks on them still reach their buttons)
        optionsFrame:EnableMouse(true)
        optionsFrame:SetScript("OnMouseDown", function(_, button)
            if button == "LeftButton" then CloseAllMenus() end
        end)
         
        -- Custom font settings - CHANGE THESE to customize fonts
        local TITLE_FONT = "Interface\\AddOns\\PhoenixCastBars\\Media\\DorisPP.ttf" -- Title text
        local TITLE_SIZE = 18
        local TITLE_FLAGS = "OUTLINE"
        local CATEGORY_FONT = "Interface\\AddOns\\PhoenixCastBars\\Media\\DorisPP.ttf" -- Category buttons
        local CATEGORY_SIZE = 16
        local CATEGORY_FLAGS = "OUTLINE"
        local LABEL_FONT = "Interface\\AddOns\\PhoenixCastBars\\Media\\DorisPP.ttf"  -- Option labels
        local LABEL_SIZE = 12
        local LABEL_FLAGS = "OUTLINE"
        local SMALL_LABEL_FONT = "Interface\\AddOns\\PhoenixCastBars\\Media\\DorisPP.ttf"  -- Smaller text
        local SMALL_LABEL_SIZE = 8
        local SMALL_LABEL_FLAGS = "OUTLINE"
        
-- Title Text
local header = CreateFrame("Frame", nil, optionsFrame)
header:SetPoint("TOPLEFT", 10, -10)
header:SetPoint("TOPRIGHT", -10, -10)
header:SetHeight(30)
header:SetFrameLevel(optionsFrame:GetFrameLevel() + 50)

local headerBg = header:CreateTexture(nil, "BACKGROUND")
headerBg:SetAllPoints(header)
headerBg:SetColorTexture(0.1, 0.1, 0.15, 1)

-- Header border (bottom blue line)
local headerBorder = header:CreateTexture(nil, "BORDER")
headerBorder:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
headerBorder:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
headerBorder:SetHeight(1)
headerBorder:SetColorTexture(0.15, 0.45, 0.90, 1)

local titleFS = header:CreateFontString(nil, "OVERLAY")
titleFS:SetFont(TITLE_FONT, TITLE_SIZE, "THICKOUTLINE")
titleFS:SetPoint("CENTER", header, "CENTER", 0, 0)
titleFS:SetText("|cff1a80ffPhoenixCastBars |r|cffff6600Options|r")

        -- Close Button
        local closeBtn = CreateFrame("Button", nil, optionsFrame)
        closeBtn:SetWidth(20)
        closeBtn:SetHeight(20)
        closeBtn:SetPoint("TOPRIGHT", -14, -14)
        closeBtn:SetFrameLevel(header:GetFrameLevel() + 1)
        local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
        closeBg:SetAllPoints(closeBtn)
        closeBg:SetColorTexture(1, 0.2, 0, 1)
        local closeText = closeBtn:CreateFontString(nil, "OVERLAY")
        closeText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
        closeText:SetAllPoints(closeBtn)
        closeText:SetText("X")
        closeBtn:SetScript("OnClick", function() optionsFrame:Hide() end)

        -- Sidebar and Content Area

        local sidebar = CreateFrame("Frame", nil, optionsFrame)
        sidebar:SetWidth(150)
        sidebar:SetHeight(510)  -- Reduced from 550 to make room for footer
        sidebar:SetPoint("TOPLEFT", 10, -45)
        
        local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
        sidebarBg:SetAllPoints(sidebar)
        sidebarBg:SetColorTexture(0.1, 0.1, 0.15, 1)
        
        local content = CreateFrame("Frame", nil, optionsFrame)
        content:SetWidth(520)
        content:SetHeight(510)  -- Reduced from 550 to make room for footer
        content:SetPoint("TOPLEFT", 170, -45)
        
        local contentBg = content:CreateTexture(nil, "BACKGROUND")
        contentBg:SetAllPoints(content)
        contentBg:SetColorTexture(0.1, 0.1, 0.15, 1)
        
        local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 0)
        
        -- Hide scrollbar when not needed (prevents unnecessary scrolling on short pages)
        -- The scrollbar only appears when content height exceeds visible area
        local scrollBar = scrollFrame.ScrollBar
        if scrollBar then
            scrollBar:Hide()  -- Start hidden
            -- Monitor scroll range changes to show/hide scrollbar dynamically
            scrollFrame:HookScript("OnScrollRangeChanged", function(self, xRange, yRange)
                if yRange > 0 then
                    scrollBar:Show()  -- Content is taller than visible area
                else
                    scrollBar:Hide()  -- Content fits without scrolling
                end
            end)
        end
        
        local scrollContent = CreateFrame("Frame", nil, scrollFrame)
        scrollContent:SetWidth(480)
        scrollContent:SetHeight(1)  -- Will be set dynamically based on content
        scrollFrame:SetScrollChild(scrollContent)
        
        -- Live Preview Cast Bar
        local previewContainer = CreateFrame("Frame", nil, content)
        previewContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        previewContainer:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
        previewContainer:SetHeight(50)
        
        local previewBg = previewContainer:CreateTexture(nil, "BACKGROUND")
        previewBg:SetAllPoints(previewContainer)
        previewBg:SetColorTexture(0.08, 0.08, 0.12, 1)
        
        local previewLabel = previewContainer:CreateFontString(nil, "OVERLAY")
        previewLabel:SetFont(SMALL_LABEL_FONT, SMALL_LABEL_SIZE, SMALL_LABEL_FLAGS)
        previewLabel:SetPoint("TOPLEFT", 10, -5)
        previewLabel:SetText("Preview:")
        previewLabel:SetTextColor(0.15, 0.45, 0.90, 1)
        
        -- Create a preview cast bar frame (similar to actual cast bars)
        local previewBar = CreateFrame("Frame", nil, previewContainer)
        previewBar:SetWidth(350)
        previewBar:SetHeight(18)
        previewBar:SetPoint("CENTER", previewContainer, "CENTER", 0, 0)
        
        local previewBarBg = CreateFrame("Frame", nil, previewBar)
        previewBarBg:SetPoint("TOPLEFT", previewBar, "TOPLEFT", -2, 2)
        previewBarBg:SetPoint("BOTTOMRIGHT", previewBar, "BOTTOMRIGHT", 2, -2)
        
        -- Create outline textures manually for better compatibility
        local topEdge = previewBarBg:CreateTexture(nil, "BORDER")
        topEdge:SetColorTexture(1, 0.5, 0, 1)
        topEdge:SetPoint("TOPLEFT", -1, 1)
        topEdge:SetPoint("TOPRIGHT", 1, 1)
        topEdge:SetHeight(1)
        
        local bottomEdge = previewBarBg:CreateTexture(nil, "BORDER")
        bottomEdge:SetColorTexture(1, 0.5, 0, 1)
        bottomEdge:SetPoint("BOTTOMLEFT", -1, -1)
        bottomEdge:SetPoint("BOTTOMRIGHT", 1, -1)
        bottomEdge:SetHeight(1)
        
        local leftEdge = previewBarBg:CreateTexture(nil, "BORDER")
        leftEdge:SetColorTexture(1, 0.5, 0, 1)
        leftEdge:SetPoint("TOPLEFT", -1, 1)
        leftEdge:SetPoint("BOTTOMLEFT", -1, -1)
        leftEdge:SetWidth(1)
        
        local rightEdge = previewBarBg:CreateTexture(nil, "BORDER")
        rightEdge:SetColorTexture(1, 0.5, 0, 1)
        rightEdge:SetPoint("TOPRIGHT", 1, 1)
        rightEdge:SetPoint("BOTTOMRIGHT", 1, -1)
        rightEdge:SetWidth(1)
        
        -- Store edge textures for outline color updates
        previewBarBg._outlineEdges = {topEdge, bottomEdge, leftEdge, rightEdge}
        
        local previewStatusBar = CreateFrame("StatusBar", nil, previewBar)
        previewStatusBar:SetAllPoints(previewBar)
        previewStatusBar:SetMinMaxValues(0, 1)
        previewStatusBar:SetValue(0.65)
        
        local previewStatusBarBgTex = previewStatusBar:CreateTexture(nil, "BACKGROUND")
        previewStatusBarBgTex:SetAllPoints(previewStatusBar)
        previewStatusBarBgTex:SetTexture("Interface\\Buttons\\WHITE8x8")
        previewStatusBarBgTex:SetVertexColor(0, 0, 0, 0.35)
        
        
        -- Add spark to preview bar
        local previewSpark = previewContainer:CreateTexture(nil, "OVERLAY", nil, 7)
        local sparkLoaded = previewSpark:SetTexture("Interface\\AddOns\\PhoenixCastBars\\Media\\Phoenix_Spark.blp")
        if not sparkLoaded then
            previewSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        end
        previewSpark:SetWidth(4)
        previewSpark:SetHeight(18)
        previewSpark:SetBlendMode("ADD")
        previewSpark:SetAlpha(1.0)
        previewSpark:SetPoint("CENTER", previewStatusBar, "RIGHT", 0, 0)
        previewSpark:Hide()

        -- Add spell icon to preview bar
        local previewIcon = previewContainer:CreateTexture(nil, "OVERLAY", nil, 7)
        previewIcon:SetSize(20, 20)
        previewIcon:SetPoint("RIGHT", previewBar, "LEFT", -6, 0)
        previewIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        local iconLoaded = previewIcon:SetTexture("Interface\\Icons\\Spell_Frost_Frostbolt02")
        previewIcon:Hide()
        local previewSpellText = previewStatusBar:CreateFontString(nil, "OVERLAY")
        previewSpellText:SetFont(LABEL_FONT, LABEL_SIZE-2, LABEL_FLAGS)
        previewSpellText:SetPoint("LEFT", previewBar, "LEFT", 6, 0)
        previewSpellText:SetText("Frostbolt")
        
        local previewTimeText = previewStatusBar:CreateFontString(nil, "OVERLAY")
        previewTimeText:SetFont(LABEL_FONT, LABEL_SIZE-2, LABEL_FLAGS)
        previewTimeText:SetPoint("RIGHT", previewBar, "RIGHT", -6, 0)
        previewTimeText:SetText("1.5s")
        
        -- Store preview elements for updating
        optionsFrame.preview = {
            container = previewContainer,
            bar = previewBar,
            statusBar = previewStatusBar,
            statusBarBg = previewStatusBarBgTex,
            bgFrame = previewBarBg,
            spellText = previewSpellText,
            timeText = previewTimeText,
            spark = previewSpark,
            icon = previewIcon,
        }
        
        -- Adjust scroll frame to account for preview
        scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -50)

        -- Footer
        local footer = CreateFrame("Frame", nil, optionsFrame)
        footer:SetWidth(680)
        footer:SetHeight(40)
        footer:SetPoint("BOTTOMLEFT", 10, 10)
        
        local footerBg = footer:CreateTexture(nil, "BACKGROUND")
        footerBg:SetAllPoints(footer)
        footerBg:SetColorTexture(0.1, 0.1, 0.15, 1)
        
        local footerBorder = footer:CreateTexture(nil, "BORDER")
        footerBorder:SetPoint("TOPLEFT", footer, "TOPLEFT", 0, 0)
        footerBorder:SetPoint("TOPRIGHT", footer, "TOPRIGHT", 0, 0)
        footerBorder:SetHeight(1)
        footerBorder:SetColorTexture(0.15, 0.45, 0.90, 1)
        
        -- Discord link (bottom left)
        local discordBtn = CreateFrame("Button", nil, footer)
        discordBtn:SetWidth(70)
        discordBtn:SetHeight(10)
        discordBtn:SetPoint("LEFT", footer, "LEFT", 10, 0)
        
        -- Discord icon
        local discordIcon = discordBtn:CreateTexture(nil, "ARTWORK")
        discordIcon:SetSize(20, 20)
        discordIcon:SetPoint("LEFT", discordBtn, "LEFT", 0, 0)
        discordIcon:SetTexture("Interface\\AddOns\\PhoenixCastBars\\Media\\Discord.blp")
        
        local discordText = discordBtn:CreateFontString(nil, "OVERLAY")
        discordText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
        discordText:SetPoint("LEFT", discordIcon, "RIGHT", 5, 0)
        discordText:SetText("Discord")
        discordText:SetTextColor(
            PCB.COLORS.PHOENIX_BLUE[1],
            PCB.COLORS.PHOENIX_BLUE[2],
            PCB.COLORS.PHOENIX_BLUE[3]
        )
        
        discordBtn:SetScript("OnEnter", function()
            discordText:SetTextColor(
                PCB.COLORS.PHOENIX_ORANGE[1],
                PCB.COLORS.PHOENIX_ORANGE[2],
                PCB.COLORS.PHOENIX_ORANGE[3]
            )
        end)
        
        discordBtn:SetScript("OnLeave", function()
            discordText:SetTextColor(
                PCB.COLORS.PHOENIX_BLUE[1],
                PCB.COLORS.PHOENIX_BLUE[2],
                PCB.COLORS.PHOENIX_BLUE[3]
            )
        end)
        
        
local DISCORD_URL = "https://discord.gg/3PeP4rGmS9"

-- Discord popup (created once, reused)
local discordPopup

local function ShowDiscordPopup()
    if not discordPopup then
        discordPopup = CreateFrame("Frame", "PhoenixCastBarsDiscordPopup", UIParent, "BackdropTemplate")
        discordPopup:SetFrameStrata("HIGH")
        discordPopup:SetSize(350, 150)
        discordPopup:SetPoint("TOP", 0, -100)
        discordPopup:EnableMouse(true)

        tinsert(UISpecialFrames, discordPopup:GetName())

        discordPopup:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        discordPopup:SetBackdropColor(1, 1, 1, 1)

        -- Title
        local title = discordPopup:CreateFontString(nil, "ARTWORK")
        title:SetFont(TITLE_FONT, 16, "THICKOUTLINE")
        title:SetPoint("TOP", discordPopup, "TOP", 0, -16)
        title:SetText("|cff1a80ffPhoenixCastBars|r |cffff6600Discord|r")

        -- Subtitle
        local subtitle = discordPopup:CreateFontString(nil, "ARTWORK")
        subtitle:SetFont(LABEL_FONT, 11, LABEL_FLAGS)
        subtitle:SetPoint("TOP", title, "BOTTOM", 0, -6)
        subtitle:SetText("Join the community Discord")

        -- Input label
        local inputLabel = discordPopup:CreateFontString(nil, "ARTWORK")
        inputLabel:SetFont(LABEL_FONT, 10, LABEL_FLAGS)
        inputLabel:SetPoint("TOP", subtitle, "BOTTOM", 0, -10)
        inputLabel:SetText("Invite link:")

        -- EditBox
        local editBox = CreateFrame("EditBox", nil, discordPopup, "InputBoxTemplate")
        editBox:SetAutoFocus(false)
        editBox:SetSize(200, 24)
        editBox:SetPoint("TOP", inputLabel, "BOTTOM", 0, -4)
        editBox:SetFont(LABEL_FONT, 11, "OUTLINE")
        editBox:SetText(DISCORD_URL)
        editBox:SetJustifyH("CENTER")
        editBox:HighlightText()
        editBox:SetCursorPosition(0)

        editBox:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)

        editBox:SetScript("OnMouseDown", function(self)
            self:HighlightText()
        end)

        editBox:SetScript("OnEscapePressed", function()
            discordPopup:Hide()
        end)

        editBox:SetScript("OnTextChanged", function(self, userInput)
            if userInput and self:GetText() ~= DISCORD_URL then
                self:SetText(DISCORD_URL)
                self:HighlightText()
                self:SetCursorPosition(0)
            end
        end)

        discordPopup.editBox = editBox

        -- Close button
        local closeBtn = CreateFrame("Button", nil, discordPopup, "UIPanelButtonTemplate")
        closeBtn:SetSize(100, 24)
        closeBtn:SetPoint("BOTTOM", discordPopup, "BOTTOM", 0, 16)
        closeBtn:SetText("Close")
        closeBtn:SetScript("OnClick", function()
            discordPopup:Hide()
        end)
    end

    discordPopup:Show()
    discordPopup.editBox:SetText(DISCORD_URL)
    discordPopup.editBox:SetFocus()
    discordPopup.editBox:HighlightText()
end

discordBtn:SetScript("OnClick", ShowDiscordPopup)

        
        -- Version number (bottom right)
        local footerVersion = CreateFrame("Button", nil, footer)
        footerVersion:SetSize(60, 20)
        footerVersion:SetPoint("RIGHT", footer, "RIGHT", -10, 0)

        local fvText = footerVersion:CreateFontString(nil, "OVERLAY")
        fvText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
        fvText:SetAllPoints(footerVersion)
        fvText:SetJustifyH("RIGHT")
        fvText:SetText("v" .. (PCB.version or "0.0.0"))
        fvText:SetTextColor(0.5, 0.5, 0.5, 1)

        footerVersion:SetScript("OnEnter", function()
            fvText:SetTextColor(
                PCB.COLORS.PHOENIX_ORANGE[1],
                PCB.COLORS.PHOENIX_ORANGE[2],
                PCB.COLORS.PHOENIX_ORANGE[3]
            )
            GameTooltip:SetOwner(footerVersion, "ANCHOR_TOP")
            GameTooltip:SetText("View Changelog")
            GameTooltip:Show()
        end)
        footerVersion:SetScript("OnLeave", function()
            fvText:SetTextColor(0.5, 0.5, 0.5, 1)
            GameTooltip:Hide()
        end)
        footerVersion:SetScript("OnClick", function()
            if PCB.UpdateCheck then
                if PCB.optionsFrame then PCB.optionsFrame:Hide() end
                PCB.UpdateCheck:ShowChangelog()
            end
        end)

        -- Assign frames to optionsFrame for later use
        optionsFrame.sidebar = sidebar
        optionsFrame.scrollContent = scrollContent
        optionsFrame.scrollFrame = scrollFrame
        optionsFrame.categoryButtons = {}
        optionsFrame.contentWidgets = {}  -- Track created widgets for cleanup

        
        local categories = {
            general = {
                name = "General",
                options = {
                    { type = "button",  label = "Toggle Test Mode", onClick = "toggleTestMode" },
                    { type = "checkboxpair", label1 = "Lock Frames", key1 = "locked", label2 = "Show Minimap Button", key2 = "minimapButton.show" },
                    { type = "space" },
                    { type = "lsmdropdown", label = "Castbar Texture", key = "textureKey", mediaType = "statusbar" },
                    { type = "lsmdropdown", label = "Font", key = "fontKey", mediaType = "font" },
                    { type = "outlinedropdown", label = "Font Outline", key = "outline" },
                    { type = "space" },
                    { type = "space" },
                    { type = "slider", label = "Font Size", key = "fontSize", min = 8, max = 20, step = 1 },
                    { type = "colorpickergrid", pickers = {
                        { label = "Regular Cast", key = "colorCast" },
                        { label = "Channeled Cast", key = "colorChannel" },
                        { label = "Successful Cast", key = "colorSuccess" },
                        { label = "Failed/Interrupted", key = "colorFailed" },
                        { label = "Latency Indicator", key = "safeZoneColor" },
                        { label = "Castbar Outline", key = "outlineColor" },
                    }},
                }
            },
            profiles = {
                name = "Profiles",
                options = {
                    { type = "description", text = "You can change the active database profile, so you can have different settings for every character.\nReset the current profile back to its default values, in case your configuration is broken, or you simply want to start over." },
                    { type = "button", label = "Reset Profile", onClick = "resetProfile" },
                    { type = "label", text = "Current Profile: %s", getValue = "currentProfile" },
                    { type = "space" },
                    { type = "description", text = "You can either create a new profile by entering a name and clicking Create, or choose one of the already existing profiles." },
                    { type = "editbox", label = "New", placeholder = "Profile name", key = "newProfile" },
                    { type = "button",  label = "Create", onClick = "createProfile" },
                    { type = "dropdown", label = "Existing Profiles", key = "existingProfile" },
                    { type = "space" },
                    { type = "description", text = "Set a default profile that will be applied to any character that has not chosen a profile yet." },
                    { type = "dropdown", label = "Default Profile", key = "defaultProfile" },
                    { type = "space" },
                    { type = "checkbox", label = "Enable spec profiles", tooltip = "When enabled, your profile will be set to the specified profile when you change specialization.", key = "profileMode", isProfileMode = "spec" },
                    { type = "specdropdown", specIndex = 1 },
                    { type = "specdropdown", specIndex = 2 },
                    { type = "specdropdown", specIndex = 3 },
                    { type = "specdropdown", specIndex = 4 },
                    { type = "space" },
                    { type = "description", text = "Copy the settings from one existing profile into the currently active profile." },
                    { type = "dropdown", label = "Copy from", key = "copyProfile" },
                    { type = "space" },
                    { type = "description", text = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file." },
                    { type = "dropdown", label = "Delete a Profile", key = "deleteProfile" },
                }
            },
            player = {
                name = "Player Bar",
                options = {
                    { type = "checkboxbutton", label = "Enable Player Bar", key = "bars.player.enabled", buttonLabel = "Reset", onClick = "resetBar_player" },
                    { type = "space" },
                    { type = "slidergrid", sliders = {
                        { label = "Width", key = "bars.player.width", min = 100, max = 500, step = 10 },
                        { label = "Height", key = "bars.player.height", min = 10, max = 50, step = 1 },
                        { label = "Alpha", key = "bars.player.alpha", min = 0, max = 1, step = 0.05 },
                        { label = "Scale", key = "bars.player.scale", min = 0.5, max = 2.0, step = 0.1 },
                    }},
                    { type = "checkbox", label = "Enable Texture Override", key = "bars.player.enableTextureOverride", tooltip = "Override global texture settings for this bar only" },
                                { type = "lsmdropdown", label = "", key = "bars.player.textureKey", mediaType = "statusbar", allowBlank = true, visibleIf = function() return PCB.db.bars.player.enableTextureOverride end },
                    { type = "checkbox", label = "Enable Font Override", key = "bars.player.enableFontOverride", tooltip = "Override global font settings for this bar only" },
                                { type = "lsmdropdown", label = "", key = "bars.player.fontKey", mediaType = "font", allowBlank = true, visibleIf = function() return PCB.db.bars.player.enableFontOverride end },
                    { type = "checkbox", label = "Enable Outline Override", key = "bars.player.enableOutlineOverride", tooltip = "Override global outline settings for this bar only" },
                                { type = "outlinedropdown", label = "", key = "bars.player.outline", allowBlank = true, visibleIf = function() return PCB.db.bars.player.enableOutlineOverride end },
                    { type = "checkbox", label = "Override Bar Colour", key = "bars.player.enableColorOverride", tooltip = "Use a custom colour for this bar instead of the global cast/channel colours." },
						{ type = "colorpickergrid", visibleIf = function() return PCB.db.bars.player.enableColorOverride end, pickers = {
							{ label = "Bar Colour", key = "bars.player.colorOverride" },
                    }},
                    { type = "space" },
                    { type = "twocolumngrid", items = {
                        { type = "checkbox", label = "Show Spell Name", key = "bars.player.showSpellName" },
                        { type = "checkbox", label = "Show Spell Icon", key = "bars.player.showIcon" },
                        { type = "checkbox", label = "Show Spark", key = "bars.player.showSpark" },
                        { type = "checkbox", label = "Show Time", key = "bars.player.showTime" },
                        { type = "checkbox", label = "Show Latency", key = "bars.player.showLatency" },
                    }},
                    { type = "slidergrid", sliders = {
                        { label = "Spell Icon X Offset", key = "bars.player.iconOffsetX", min = -50, max = 50, step = 1 },
                        { label = "Spell Icon Y Offset", key = "bars.player.iconOffsetY", min = -50, max = 50, step = 1, visibleIf = function() return PCB.db and PCB.db.bars and PCB.db.bars.player and PCB.db.bars.player.vertical end },
                    }},
                    { type = "checkbox", label = "Vertical Orientation", key = "bars.player.vertical", tooltip = "Rotate the bar to fill vertically instead of horizontally." },
                    { type = "checkbox", label = "Fade Out on End", key = "fadeOnEnd", tooltip = "Fade bars out when a cast ends or is interrupted." },
                    { type = "space" },
                    { type = "simpledropdown", label = "Spell Name Align", key = "bars.player.spellLabelPosition",
                      values = { left="Top / Left", center="Center", right="Bottom / Right" } },
                    { type = "simpledropdown", label = "Timer Align", key = "bars.player.timeLabelPosition",
                      values = { left="Top / Left", center="Center", right="Bottom / Right" } },
                    { type = "simpledropdown", label = "Icon Side", key = "bars.player.iconSide",
                      values = { left="Left", right="Right", top="Top", bottom="Bottom" } },
                    { type = "simpledropdown", label = "Label Side", key = "bars.player.verticalLabelSide",
                      values = { left="Left", right="Right" },
                      visibleIf = function() return PCB.db and PCB.db.bars and PCB.db.bars.player and PCB.db.bars.player.vertical end },
                }
            },
            target = {
                name = "Target Bar",
                options = {
                    { type = "checkboxbutton", label = "Enable Target Bar", key = "bars.target.enabled", buttonLabel = "Reset", onClick = "resetBar_target" },
                    { type = "space" },
                    { type = "slidergrid", sliders = {
                        { label = "Width", key = "bars.target.width", min = 100, max = 500, step = 10 },
                        { label = "Height", key = "bars.target.height", min = 10, max = 50, step = 1 },
                        { label = "Alpha", key = "bars.target.alpha", min = 0, max = 1, step = 0.05 },
                        { label = "Scale", key = "bars.target.scale", min = 0.5, max = 2.0, step = 0.1 },
                    }},
                    { type = "checkbox", label = "Enable Texture Override", key = "bars.target.enableTextureOverride", tooltip = "Override global texture settings for this bar only" },
                                { type = "lsmdropdown", label = "", key = "bars.target.textureKey", mediaType = "statusbar", allowBlank = true, visibleIf = function() return PCB.db.bars.target.enableTextureOverride end },
                    { type = "checkbox", label = "Enable Font Override", key = "bars.target.enableFontOverride", tooltip = "Override global font settings for this bar only" },
                                { type = "lsmdropdown", label = "", key = "bars.target.fontKey", mediaType = "font", allowBlank = true, visibleIf = function() return PCB.db.bars.target.enableFontOverride end },
                    { type = "checkbox", label = "Enable Outline Override", key = "bars.target.enableOutlineOverride", tooltip = "Override global outline settings for this bar only" },
                                { type = "outlinedropdown", label = "", key = "bars.target.outline", allowBlank = true, visibleIf = function() return PCB.db.bars.target.enableOutlineOverride end },
                    { type = "checkbox", label = "Override Bar Colour", key = "bars.target.enableColorOverride", tooltip = "Use a custom colour for this bar instead of the global cast/channel colours." },
                                { type = "colorpickergrid", visibleIf = function() return PCB.db.bars.target.enableColorOverride end, pickers = {
                                    { label = "Bar Colour", key = "bars.target.colorOverride" },
                                }},
                    { type = "space" },
                    { type = "twocolumngrid", items = {
                        { type = "checkbox", label = "Show Spell Name", key = "bars.target.showSpellName" },
                        { type = "checkbox", label = "Show Spell Icon", key = "bars.target.showIcon" },
                        { type = "checkbox", label = "Show Spark", key = "bars.target.showSpark" },
                        { type = "checkbox", label = "Show Time", key = "bars.target.showTime" },
                    }},
                    { type = "space" },
                    { type = "slidergrid", sliders = {
                        { label = "Spell Icon X Offset", key = "bars.target.iconOffsetX", min = -50, max = 50, step = 1 },
                        { label = "Spell Icon Y Offset", key = "bars.target.iconOffsetY", min = -50, max = 50, step = 1, visibleIf = function() return PCB.db and PCB.db.bars and PCB.db.bars.target and PCB.db.bars.target.vertical end },
                    }},
                    { type = "checkbox", label = "Vertical Orientation", key = "bars.target.vertical", tooltip = "Rotate the bar to fill vertically instead of horizontally." },
                    { type = "space" },
                    { type = "simpledropdown", label = "Spell Name Align", key = "bars.target.spellLabelPosition",
                      values = { left="Top / Left", center="Center", right="Bottom / Right" } },
                    { type = "simpledropdown", label = "Timer Align", key = "bars.target.timeLabelPosition",
                      values = { left="Top / Left", center="Center", right="Bottom / Right" } },
                    { type = "simpledropdown", label = "Icon Side", key = "bars.target.iconSide",
                      values = { left="Left", right="Right", top="Top", bottom="Bottom" } },
                    { type = "simpledropdown", label = "Label Side", key = "bars.target.verticalLabelSide",
                      values = { left="Left", right="Right" },
                      visibleIf = function() return PCB.db and PCB.db.bars and PCB.db.bars.target and PCB.db.bars.target.vertical end },
                }
            },
            focus = {
                name = "Focus Bar",
                options = {
                    { type = "checkboxbutton", label = "Enable Focus Bar", key = "bars.focus.enabled", buttonLabel = "Reset", onClick = "resetBar_focus" },
                    { type = "space" },
                    { type = "slidergrid", sliders = {
                        { label = "Width", key = "bars.focus.width", min = 100, max = 500, step = 10 },
                        { label = "Height", key = "bars.focus.height", min = 10, max = 50, step = 1 },
                        { label = "Alpha", key = "bars.focus.alpha", min = 0, max = 1, step = 0.05 },
                        { label = "Scale", key = "bars.focus.scale", min = 0.5, max = 2.0, step = 0.1 },
                    }},
                    { type = "checkbox", label = "Enable Texture Override", key = "bars.focus.enableTextureOverride", tooltip = "Override global texture settings for this bar only" },
                                { type = "lsmdropdown", label = "", key = "bars.focus.textureKey", mediaType = "statusbar", allowBlank = true, visibleIf = function() return PCB.db.bars.focus.enableTextureOverride end },
                    { type = "checkbox", label = "Enable Font Override", key = "bars.focus.enableFontOverride", tooltip = "Override global font settings for this bar only" },
                                { type = "lsmdropdown", label = "", key = "bars.focus.fontKey", mediaType = "font", allowBlank = true, visibleIf = function() return PCB.db.bars.focus.enableFontOverride end },
                    { type = "checkbox", label = "Enable Outline Override", key = "bars.focus.enableOutlineOverride", tooltip = "Override global outline settings for this bar only" },
                                { type = "outlinedropdown", label = "", key = "bars.focus.outline", allowBlank = true, visibleIf = function() return PCB.db.bars.focus.enableOutlineOverride end },
                    { type = "checkbox", label = "Override Bar Colour", key = "bars.focus.enableColorOverride", tooltip = "Use a custom colour for this bar instead of the global cast/channel colours." },
                                { type = "colorpickergrid", visibleIf = function() return PCB.db.bars.focus.enableColorOverride end, pickers = {
                                    { label = "Bar Colour", key = "bars.focus.colorOverride" },
                                }},
                    { type = "space" },
                    { type = "twocolumngrid", items = {
                        { type = "checkbox", label = "Show Spell Name", key = "bars.focus.showSpellName" },
                        { type = "checkbox", label = "Show Spell Icon", key = "bars.focus.showIcon" },
                        { type = "checkbox", label = "Show Spark", key = "bars.focus.showSpark" },
                        { type = "checkbox", label = "Show Time", key = "bars.focus.showTime" },
                    }},
                    { type = "space" },
                    { type = "slidergrid", sliders = {
                        { label = "Spell Icon X Offset", key = "bars.focus.iconOffsetX", min = -50, max = 50, step = 1 },
                        { label = "Spell Icon Y Offset", key = "bars.focus.iconOffsetY", min = -50, max = 50, step = 1, visibleIf = function() return PCB.db and PCB.db.bars and PCB.db.bars.focus  and PCB.db.bars.focus.vertical end },
                    }},
                    { type = "checkbox", label = "Vertical Orientation", key = "bars.focus.vertical", tooltip = "Rotate the bar to fill vertically instead of horizontally." },
                    { type = "space" },
                    { type = "simpledropdown", label = "Spell Name Align", key = "bars.focus.spellLabelPosition",
                      values = { left="Top / Left", center="Center", right="Bottom / Right" } },
                    { type = "simpledropdown", label = "Timer Align", key = "bars.focus.timeLabelPosition",
                      values = { left="Top / Left", center="Center", right="Bottom / Right" } },
                    { type = "simpledropdown", label = "Icon Side", key = "bars.focus.iconSide",
                      values = { left="Left", right="Right", top="Top", bottom="Bottom" } },
                    { type = "simpledropdown", label = "Label Side", key = "bars.focus.verticalLabelSide",
                      values = { left="Left", right="Right" },
                      visibleIf = function() return PCB.db and PCB.db.bars and PCB.db.bars.focus and PCB.db.bars.focus.vertical end },
                }
            },
            uninterruptible = {
                name = "Uninterruptible",
                options = {
                    { type = "description", text = "When a cast cannot be interrupted, these overrides replace the bar's normal backdrop, border, and fill texture — making it immediately obvious at a glance." },
                    { type = "space" },
                    { type = "checkbox", label = "Enable Uninterruptible Styling", key = "uninterruptible.enabled" },
                    { type = "space" },
                    { type = "colorpickergrid", pickers = {
                        { label = "Fill Color",     key = "colorUninterruptible" },
                        { label = "Backdrop Color", key = "uninterruptible.backdropColor" },
                        { label = "Border Color",   key = "uninterruptible.borderColor" },
                    }},
                    { type = "space" },
                    { type = "checkbox", label = "Use Custom Fill Texture", key = "uninterruptible.useCustomTexture", tooltip = "Replace the normal fill texture with a different one when the cast is uninterruptible." },
                    { type = "lsmdropdown", label = "", key = "uninterruptible.textureKey", mediaType = "statusbar", allowBlank = true, visibleIf = function() return PCB.db.uninterruptible and PCB.db.uninterruptible.useCustomTexture end },
                    { type = "space" },
                    { type = "description", text = "The Fill Color above is the bar's foreground color. Backdrop and Border Color change the frame's background and outline. The optional Custom Fill Texture swaps the bar's texture when an uninterruptible cast is active." },
                },
            },
            gcd = {
                name = "GCD Bar",
                options = {
                    { type = "checkboxbutton", label = "Enable GCD Bar", key = "bars.gcd.enabled", buttonLabel = "Reset", onClick = "resetBar_gcd" },
                    { type = "space" },
                    { type = "slidergrid", sliders = {
                        { label = "Width", key = "bars.gcd.width", min = 50, max = 400, step = 10 },
                        { label = "Height", key = "bars.gcd.height", min = 4, max = 30, step = 1 },
                        { label = "Alpha", key = "bars.gcd.alpha", min = 0, max = 1, step = 0.05 },
                        { label = "Scale", key = "bars.gcd.scale", min = 0.5, max = 2.0, step = 0.1 },
                    }},
                    { type = "checkbox", label = "Enable Texture Override", key = "bars.gcd.enableTextureOverride", tooltip = "Override global texture settings for the GCD bar" },
                    { type = "lsmdropdown", label = "", key = "bars.gcd.textureKey", mediaType = "statusbar", allowBlank = true, visibleIf = function() return PCB.db.bars.gcd.enableTextureOverride end },
                    { type = "checkbox", label = "Enable Font Override", key = "bars.gcd.enableFontOverride", tooltip = "Override global font settings for the GCD bar" },
                    { type = "lsmdropdown", label = "", key = "bars.gcd.fontKey", mediaType = "font", allowBlank = true, visibleIf = function() return PCB.db.bars.gcd.enableFontOverride end },
                    { type = "checkbox", label = "Enable Outline Override", key = "bars.gcd.enableOutlineOverride", tooltip = "Override global outline settings for the GCD bar" },
                    { type = "outlinedropdown", label = "", key = "bars.gcd.outline", allowBlank = true, visibleIf = function() return PCB.db.bars.gcd.enableOutlineOverride end },
                    { type = "checkbox", label = "Override Bar Colour", key = "bars.gcd.enableColorOverride", tooltip = "Use a custom colour for the GCD bar." },
                                { type = "colorpickergrid", visibleIf = function() return PCB.db.bars.gcd.enableColorOverride end, pickers = {
                                    { label = "Bar Colour", key = "bars.gcd.colorOverride" },
                                }},
                    { type = "space" },
                    { type = "twocolumngrid", items = {
                        { type = "checkbox", label = "Show Spark", key = "bars.gcd.showSpark" },
                        { type = "checkbox", label = "Show Time", key = "bars.gcd.showTime" },
                        { type = "checkbox", label = "Reverse Fill (drain)", key = "bars.gcd.gcdReverseFill", tooltip = "Start full and drain right-to-left instead of filling left-to-right." },
                        { type = "checkbox", label = "Vertical Orientation", key = "bars.gcd.vertical", tooltip = "Rotate the bar to fill vertically." },
                    }},
                    { type = "space" },
                    { type = "description", text = "The GCD bar appears whenever you use an ability that triggers the global cooldown." },
                }
            },
        }
                
        -- =====================================================================
        -- Live Preview Update (defined early so callbacks can use it)
        -- =====================================================================
        
        local function UpdatePreview()
            if not optionsFrame.preview then 
                return 
            end
            local preview = optionsFrame.preview
            
            -- Get current settings from db
            local barKey = selectedCategory == "player" and "player" or
                          selectedCategory == "target" and "target" or
                          selectedCategory == "focus" and "focus" or
                          selectedCategory == "gcd" and "gcd" or "player"
            
            local barSettings = PCB.db.bars[barKey] or {}
            
            -- Update bar appearance
            local size = barSettings.size or {width = 300, height = 20}
            preview.bar:SetSize(280, 18)  -- Keep preview compact
            
            -- Apply texture - check for override first, then bar-specific, then global LSM setting
            local texture = "Interface\\Buttons\\WHITE8x8"
            
            if barSettings.enableTextureOverride and barSettings.texture and barSettings.texture ~= "" then
                texture = barSettings.texture
            elseif PCB.db.textureKey and PCB.db.textureKey ~= "" and PCB.db.textureKey ~= true then
                -- Fetch texture from LSM using the textureKey
                if PCB.LSM then
                    texture = PCB.LSM:Fetch("statusbar", PCB.db.textureKey) or "Interface\\Buttons\\WHITE8x8"
                else
                    texture = "Interface\\Buttons\\WHITE8x8"
                end
            end
            
            if not texture or texture == "" then texture = "Interface\\Buttons\\WHITE8x8" end
            preview.statusBar:SetStatusBarTexture(texture)
            
            -- Ensure statusbar background is set
            if preview.statusBarBg then
                preview.statusBarBg:SetTexture("Interface\\Buttons\\WHITE8x8")
                preview.statusBarBg:SetVertexColor(0, 0, 0, 0.35)
            end
            
            -- Apply colors
            local color = barSettings.color or {r = 0.15, g = 0.45, b = 0.9}
            preview.statusBar:SetStatusBarColor(color.r or 0.15, color.g or 0.45, color.b or 0.9, 1)
            
            -- Apply outline color (global setting)
            local outlineColor = PCB.db.outlineColor or {r = 1, g = 0.5, b = 0}
            if preview.bgFrame and preview.bgFrame._outlineEdges then
                for _, edge in ipairs(preview.bgFrame._outlineEdges) do
                    edge:SetColorTexture(outlineColor.r or 1, outlineColor.g or 0.5, outlineColor.b or 0, 1)
                end
            end
            
            -- Update display based on category - RESPECT SHOW/HIDE SETTINGS
            -- Check showSpellName setting
            if barSettings.showSpellName ~= false then
                if barKey == "gcd" then
                    preview.spellText:SetText("Global Cooldown")
                elseif barKey == "target" then
                    preview.spellText:SetText("Target Cast")
                elseif barKey == "focus" then
                    preview.spellText:SetText("Focus Cast")
                elseif selectedCategory == "general" then
                    preview.spellText:SetText("Frostbolt")
                else  -- player bar tab
                    preview.spellText:SetText("Player Cast")
                end
            else
                preview.spellText:SetText("")
            end

            -- Check showTime setting
            if barSettings.showTime then
                if barKey == "gcd" then
                    preview.timeText:SetText("1.5s")
                elseif barKey == "target" then
                    preview.timeText:SetText("2.0s")
                elseif barKey == "focus" then
                    preview.timeText:SetText("1.8s")
                else
                    preview.timeText:SetText("2.0s")
                end
            else
                preview.timeText:SetText("")
            end

            -- Update spark visibility based on showSpark setting
            if preview.spark then
                if barSettings.showSpark ~= false then
                    -- Position spark at the current bar value position
                    local barWidth = preview.statusBar:GetWidth()
                    local minVal, maxVal = preview.statusBar:GetMinMaxValues()
                    local currentVal = preview.statusBar:GetValue()
                    local pct = (currentVal - minVal) / (maxVal - minVal)
                    local xPos = barWidth * pct
                    preview.spark:ClearAllPoints()
                    preview.spark:SetPoint("CENTER", preview.statusBar, "LEFT", xPos, 0)
                    preview.spark:SetAlpha(1.0)  -- Ensure full alpha
                    preview.spark:SetVertexColor(1, 1, 1, 1)  -- Ensure white color
                    preview.spark:Show()
                else
                    preview.spark:Hide()
                end
            end

            -- Update icon visibility based on showIcon setting
            if preview.icon then
                if barSettings.showIcon ~= false then
                    -- Use iconOffsetX from settings, fallback to -6 (matches your default)
                    local iconOffsetX = barSettings.iconOffsetX or -6
                    preview.icon:ClearAllPoints()
                    preview.icon:SetPoint("RIGHT", preview.bar, "LEFT", iconOffsetX, 0)
                    preview.icon:SetAlpha(1.0)
                    preview.icon:SetVertexColor(1, 1, 1, 1)
                    preview.icon:Show()
                else
                    preview.icon:Hide()
                end
            end
            
            -- Apply font settings - check for override first, then global setting
            local fontKey = barSettings.enableFontOverride and barSettings.fontKey or PCB.db.fontKey or "Friz Quadrata TT"
            local fontSize = barSettings.enableFontOverride and barSettings.fontSize or PCB.db.fontSize or 12
            local fontOutline = barSettings.enableOutlineOverride and barSettings.outline or PCB.db.outline or "OUTLINE"
            
            -- Convert font key to font path using LSM
            local font = "Fonts\\FRIZQT__.TTF"
            if PCB.LSM and fontKey then
                font = PCB.LSM:Fetch("font", fontKey) or font
            end
            
            -- Fallback to addon's built-in DorisPP font if fontKey is DorisPP
            if font == "Fonts\\FRIZQT__.TTF" and fontKey == "DorisPP" then
                font = "Interface\\AddOns\\PhoenixCastBars\\Media\\DorisPP.ttf"
            end
            
            fontSize = tonumber(fontSize) or 12
            -- Handle empty string (None) by not setting an outline
            local outline = (fontOutline and fontOutline ~= "") and fontOutline or nil
            
            if preview.spellText then 
                if outline then
                    preview.spellText:SetFont(font, fontSize - 2, outline)
                else
                    preview.spellText:SetFont(font, fontSize - 2)
                end
            end
            if preview.timeText then 
                if outline then
                    preview.timeText:SetFont(font, fontSize - 2, outline)
                else
                    preview.timeText:SetFont(font, fontSize - 2)
                end
            end
        end
        
        -- Helper function to add a checkbox
        -- Simple key→value dropdown (for labelPosition, iconSide, etc.)
        -- values: { key = "Display Text", ... }
        local function AddSimpleDropdown(parent, label, dbKey, values, y)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(400, 24)

            local labelBg = container:CreateTexture(nil, "BACKGROUND")
            labelBg:SetPoint("LEFT", -4, 0)
            labelBg:SetSize(150, 24)
            labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)

            local labelText = container:CreateFontString(nil, "OVERLAY")
            labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            labelText:SetPoint("LEFT", 0, 0)
            labelText:SetText(label)

            local dropdown = CreateFrame("Button", nil, container)
            dropdown:SetPoint("LEFT", container, "LEFT", 160, 0)  -- fixed x so all dropdowns align
            dropdown:SetSize(180, 22)

            local dropBg = dropdown:CreateTexture(nil, "BACKGROUND")
            dropBg:SetAllPoints()
            dropBg:SetColorTexture(0.12, 0.12, 0.18, 1)

            local border = dropdown:CreateTexture(nil, "BORDER")
            border:SetAllPoints()
            border:SetColorTexture(0.25, 0.25, 0.25, 1)

            local text = dropdown:CreateFontString(nil, "OVERLAY")
            text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            text:SetPoint("LEFT", 6, 0)
            text:SetPoint("RIGHT", dropdown, "RIGHT", -22, 0)  -- leave room for arrow
            text:SetJustifyH("LEFT")

            -- Arrow button (matches LSM/Outline style)
            local arrowBtn = CreateFrame("Button", nil, dropdown)
            arrowBtn:SetSize(16, 16)
            arrowBtn:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)

            local arrowHighlight = arrowBtn:CreateTexture(nil, "HIGHLIGHT")
            arrowHighlight:SetAllPoints(arrowBtn)
            arrowHighlight:SetColorTexture(1, 1, 1, 0.2)

            local normal = arrowBtn:CreateTexture(nil, "ARTWORK")
            normal:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
            normal:SetSize(12, 12)
            normal:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
            normal:SetTexCoord(0, 1, 0, 1)
            arrowBtn:SetNormalTexture(normal)

            local pushed = arrowBtn:CreateTexture(nil, "ARTWORK")
            pushed:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
            pushed:SetSize(12, 12)
            pushed:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
            pushed:SetTexCoord(0, 1, 0, 1)
            arrowBtn:SetPushedTexture(pushed)

            dropdown:SetScript("OnEnter", function() border:SetColorTexture(0.35, 0.35, 0.35, 1) end)
            dropdown:SetScript("OnLeave", function() border:SetColorTexture(0.25, 0.25, 0.25, 1) end)

            -- Build ordered key list
            local orderedKeys = {}
            for k in pairs(values) do orderedKeys[#orderedKeys+1] = k end
            table.sort(orderedKeys)

            local function Refresh()
                local cur = GetValue(PCB.db, dbKey) or orderedKeys[1]
                text:SetText(values[cur] or cur)
            end
            Refresh()

            local menu = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
            menu:SetFrameStrata("FULLSCREEN_DIALOG")
            menu:SetWidth(180)
            menu:Hide()
            if menu.SetBackdrop then
                menu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
                menu:SetBackdropColor(0.10, 0.10, 0.14, 0.98)
                menu:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
            end

            for i, k in ipairs(orderedKeys) do
                local btn = CreateFrame("Button", nil, menu)
                btn:SetWidth(180)
                btn:SetHeight(20)
                btn:SetPoint("TOP", menu, "TOP", 0, -10 - (i-1)*20)
                local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                btnBg:SetAllPoints()
                btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                local btnText = btn:CreateFontString(nil, "OVERLAY")
                btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                btnText:SetPoint("LEFT", 8, 0)
                btnText:SetText(values[k])
                btn:SetScript("OnEnter", function() btnBg:SetColorTexture(0.4, 0.4, 0.4, 1) end)
                btn:SetScript("OnLeave", function() btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8) end)
                btn:SetScript("OnClick", function()
                    SetValue(PCB.db, dbKey, k)
                    Refresh()
                    if PCB.ApplyAll then PCB:ApplyAll() end
                    menu:Hide()
                    activeMenus[menu] = nil
                end)
            end
            menu:SetHeight(math.max(40, 20 + #orderedKeys * 20))

            menu._arrowBtn = arrowBtn

            local function ToggleMenu()
                if menu:IsShown() then
                    menu:Hide()
                    activeMenus[menu] = nil
                    UpdateArrow(arrowBtn, false)
                else
                    CloseAllMenus()
                    menu:ClearAllPoints()
                    menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -4)
                    menu:Show()
                    activeMenus[menu] = true
                    UpdateArrow(arrowBtn, true)
                end
            end

            dropdown:SetScript("OnClick", ToggleMenu)
            arrowBtn:SetScript("OnClick", ToggleMenu)

            container.Refresh = Refresh
            return container
        end

        local function AddCheckbox(parent, label, dbKey, y, isProfileMode, tooltip)
            local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
            cb:SetPoint("TOPLEFT", 10, y)
            SkinCheckbox(cb)
            
            -- Label background
            local labelBg = cb:CreateTexture(nil, "BACKGROUND")
            labelBg:SetPoint("LEFT", cb, "RIGHT", 1, 0)
            labelBg:SetSize(180, 20)
            labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)
            
            local text = cb:CreateFontString(nil, "OVERLAY")
            text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
            text:SetText(label)
            
            if isProfileMode then
                -- Special handling for profile mode (toggle between spec and character mode)
                local targetMode = isProfileMode -- "spec"
                cb:SetChecked(PCB:GetProfileMode() == targetMode)
                cb:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        PCB:SetProfileMode(targetMode)
                    else
                        -- Uncheck reverts to character mode
                        PCB:SetProfileMode("character")
                    end
                    if PCB.ApplyAll then PCB:ApplyAll() end
                    -- Refresh the options UI to show/hide spec dropdowns and enable/disable existing profiles
                    if optionsFrame and optionsFrame.UpdateContent then 
                        optionsFrame.UpdateContent(selectedCategory) 
                    end
                end)
                cb.profileMode = targetMode  -- Mark this as a profile mode checkbox
            else
                cb:SetChecked(GetValue(PCB.db, dbKey) or false)
                cb:SetScript("OnClick", function(self)
                    SetValue(PCB.db, dbKey, self:GetChecked())
                    -- When toggling vertical orientation, swap stored w/h so the bar
                    -- gets sensible dimensions instead of keeping the old orientation's sizes.
                    if dbKey and dbKey:match("%.vertical$") then
                        local barKey = dbKey:match("bars%.(.+)%.vertical$")
                        if barKey and PCB.db and PCB.db.bars and PCB.db.bars[barKey] then
                            local bdb = PCB.db.bars[barKey]
                            if bdb.width and bdb.height then
                                bdb.width, bdb.height = bdb.height, bdb.width
                            else
                                bdb.width  = nil
                                bdb.height = nil
                            end
                        end
                    end
                    if dbKey == "minimapButton.show" and PCB.UpdateMinimapButton then
                        PCB:UpdateMinimapButton()
                    end
                    if PCB.ApplyAll then PCB:ApplyAll() end
                    if optionsFrame and optionsFrame.UpdateContent then optionsFrame.UpdateContent(selectedCategory) end
                end)
            end
            
            -- Add tooltip if provided (must be set after OnClick to avoid being overwritten)
            if tooltip then
                cb:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(tooltip)
                    GameTooltip:Show()
                end)
                cb:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end
            
            return cb
        end
        
        -- =====================================================================
        -- UI Helper Builders (checkboxes, sliders, dropdowns, etc.)
        -- =====================================================================
        -- Helper function to add two checkboxes side-by-side
        local function AddCheckboxPair(parent, label1, dbKey1, label2, dbKey2, y)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(480, 25)
            
            -- First checkbox
            local cb1 = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
            cb1:SetPoint("TOPLEFT", 0, 0)
            SkinCheckbox(cb1)
            
            -- Label background
            local labelBg1 = cb1:CreateTexture(nil, "BACKGROUND")
            labelBg1:SetPoint("LEFT", cb1, "RIGHT", 1, 0)
            labelBg1:SetSize(160, 20)
            labelBg1:SetColorTexture(0.08, 0.08, 0.12, 1)
            
            local text1 = cb1:CreateFontString(nil, "OVERLAY")
            text1:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            text1:SetPoint("LEFT", cb1, "RIGHT", 5, 0)
            text1:SetText(label1)
            
            cb1:SetChecked(GetValue(PCB.db, dbKey1) or false)
            cb1:SetScript("OnClick", function(self)
                SetValue(PCB.db, dbKey1, self:GetChecked())
                if PCB.ApplyAll then PCB:ApplyAll() end
                if optionsFrame and optionsFrame.UpdateContent then optionsFrame.UpdateContent(selectedCategory) end
            end)
            
            -- Second checkbox (positioned to the right)
            local cb2 = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
            cb2:SetPoint("LEFT", cb1, "RIGHT", 150, 0)
            SkinCheckbox(cb2)
            
            -- Label background
            local labelBg2 = cb2:CreateTexture(nil, "BACKGROUND")
            labelBg2:SetPoint("LEFT", cb2, "RIGHT", 1, 0)
            labelBg2:SetSize(200, 20)
            labelBg2:SetColorTexture(0.08, 0.08, 0.12, 1)
            
            local text2 = cb2:CreateFontString(nil, "OVERLAY")
            text2:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            text2:SetPoint("LEFT", cb2, "RIGHT", 5, 0)
            text2:SetText(label2)
            
            cb2:SetChecked(GetValue(PCB.db, dbKey2) or false)
            cb2:SetScript("OnClick", function(self)
                SetValue(PCB.db, dbKey2, self:GetChecked())
                if PCB.ApplyAll then PCB:ApplyAll() end
                if optionsFrame and optionsFrame.UpdateContent then optionsFrame.UpdateContent(selectedCategory) end
            end)
            
            return container
        end
        
        -- Helper function to add a checkbox with a button on the same row
        local function AddCheckboxButton(parent, label, dbKey, buttonLabel, onClick, y)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(480, 25)
            
            -- Checkbox on the left
            local cb = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
            cb:SetPoint("TOPLEFT", 0, 0)
            SkinCheckbox(cb)
            
            -- Label background
            local labelBg = cb:CreateTexture(nil, "BACKGROUND")
            labelBg:SetPoint("LEFT", cb, "RIGHT", 1, 0)
            labelBg:SetSize(180, 20)
            labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)
            
            local text = cb:CreateFontString(nil, "OVERLAY")
            text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
            text:SetText(label)
            
            cb:SetChecked(GetValue(PCB.db, dbKey) or false)
            cb:SetScript("OnClick", function(self)
                SetValue(PCB.db, dbKey, self:GetChecked())
                if dbKey == "minimapButton.show" and PCB.UpdateMinimapButton then
                    PCB:UpdateMinimapButton()
                end
                if PCB.ApplyAll then PCB:ApplyAll() end
                if optionsFrame and optionsFrame.UpdateContent then optionsFrame.UpdateContent(selectedCategory) end
            end)
            
            -- Button on the right
            local btn = CreateFrame("Button", nil, container)
            btn:SetWidth(140)
            btn:SetHeight(22)
            btn:SetPoint("LEFT", cb, "RIGHT", 150, 0)

            -- Custom button styling
            local bg = btn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.15, 0.15, 0.15, 1)

            local border = btn:CreateTexture(nil, "ARTWORK")
            border:SetPoint("TOPLEFT", 1, -1)
            border:SetPoint("BOTTOMRIGHT", -1, 1)
            border:SetColorTexture(0.25, 0.25, 0.25, 1)

            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(1, 1, 1, 0.1)

            local btnText = btn:CreateFontString(nil, "OVERLAY")
            btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            btnText:SetPoint("CENTER")
            btnText:SetText(buttonLabel)
            btnText:SetTextColor(1, 1, 1, 1)

            btn:SetScript("OnEnter", function()
                bg:SetColorTexture(0.25, 0.25, 0.25, 1)
                border:SetColorTexture(0.35, 0.35, 0.35, 1)
            end)
            btn:SetScript("OnLeave", function()
                bg:SetColorTexture(0.15, 0.15, 0.15, 1)
                border:SetColorTexture(0.25, 0.25, 0.25, 1)
            end)

            if onClick == "toggleTestMode" then
                btn:SetScript("OnClick", function()
                    if PCB.SetTestMode then
                        local newState = not PCB.testMode
                        PCB:SetTestMode(newState)
                        PCB:Print(newState and "Test mode enabled" or "Test mode disabled")
                    end
                end)
            elseif onClick == "createProfile" then
                btn:SetScript("OnClick", function()
                    -- Find the newProfile editbox in the same scroll content
                    local eb = scrollContent and scrollContent._newProfileEditBox
                    local newName = eb and eb:GetText()
                    if newName and newName ~= "" then
                        PCB:EnsureProfile(newName)
                        PCB:SetActiveProfileName(newName)
                        PCB:Print("Created and switched to profile: " .. newName)
                        if eb then eb:SetText("") end
                        if PCB.ApplyAll then PCB:ApplyAll() end
                        -- Rebuild panel so profile dropdown shows the new profile
                        if optionsFrame and optionsFrame.UpdateContent then
                            optionsFrame.UpdateContent(PCB.Options.selectedCategory or "general")
                        end
                    else
                        PCB:Print("Enter a profile name first.")
                    end
                end)
            elseif onClick == "resetProfile" then
                btn:SetScript("OnClick", function()
                    if PCB.ResetProfile then PCB:ResetProfile() end
                    PCB:Print("Profile reset to defaults.")
                    if PCB.ApplyAll then PCB:ApplyAll() end
                end)
            elseif type(onClick) == "string" and onClick:match("^resetBar_") then
                local barKey = onClick:match("^resetBar_(.+)$")
                btn:SetScript("OnClick", function()
                    print("Reset button clicked for bar:", barKey)
                    PCB._pendingResetBarKey = barKey
                    -- Update the popup text dynamically
                    StaticPopupDialogs["PCB_CONFIRM_RESET"].text = string.format("Reset %s bar settings to defaults?", barKey:gsub("^%l", string.upper))
                    print("About to call StaticPopup_Show for PCB_CONFIRM_RESET")
                    StaticPopup_Show("PCB_CONFIRM_RESET")
                end)
            end

            return container
        end

        -- =====================================================================
        -- Slider Skinning (custom look)
        -- =====================================================================
        local function SkinSlider(slider)
            if not slider or slider._pcbSkinned then return end
            slider._pcbSkinned = true

            -- Hide Blizzard default textures (track + thumb)
            if slider.SetBackdrop then
                slider:SetBackdrop(nil)
            end
            local thumb = slider.GetThumbTexture and slider:GetThumbTexture()
            if thumb then thumb:SetTexture(nil) end

            -- Remove default regions if present
            local low = slider.Low
            local high = slider.High
            if low then 
                low:SetFont(SMALL_LABEL_FONT, SMALL_LABEL_SIZE, SMALL_LABEL_FLAGS)
            end
            if high then 
                high:SetFont(SMALL_LABEL_FONT, SMALL_LABEL_SIZE, SMALL_LABEL_FLAGS)
            end

            -- Custom track background
            local track = slider:CreateTexture(nil, "BACKGROUND")
            track:SetPoint("LEFT", slider, "LEFT", 3, 0)
            track:SetPoint("RIGHT", slider, "RIGHT", -3, 0)
            track:SetHeight(6)
            track:SetColorTexture(0.12, 0.12, 0.16, 1)

            -- Track border
            local trackBorder = slider:CreateTexture(nil, "BORDER")
            trackBorder:SetPoint("TOPLEFT", track, "TOPLEFT", -1, 1)
            trackBorder:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", 1, -1)
            trackBorder:SetColorTexture(0.25, 0.25, 0.3, 1)

            -- Filled portion (left of thumb)
            local fill = slider:CreateTexture(nil, "ARTWORK")
            fill:SetPoint("LEFT", track, "LEFT", 0, 0)
            fill:SetHeight(6)
            fill:SetColorTexture(0.15, 0.45, 0.90, 1)
            slider._pcbFill = fill

            -- Custom thumb
            local thumbTex = slider:CreateTexture(nil, "OVERLAY")
            thumbTex:SetSize(5, 18)
            thumbTex:SetColorTexture(0.95, 0.45, 0.10, 1)
            slider:SetThumbTexture(thumbTex)

            -- Keep fill aligned with thumb position
            -- OnUpdate provides smooth real-time updates as the slider is dragged
            slider._pcbLastValue = slider:GetValue()  -- Cache to detect changes
            
            slider:SetScript("OnUpdate", function(self)
                local currentValue = self:GetValue()
                -- Only update when value actually changes (optimization)
                if currentValue ~= self._pcbLastValue then
                    self._pcbLastValue = currentValue
                    -- Calculate fill percentage based on slider range
                    local minVal, maxVal = self:GetMinMaxValues()
                    local pct = 0
                    if maxVal and maxVal > minVal then
                        pct = (currentValue - minVal) / (maxVal - minVal)
                    end
                    -- Set fill width to match thumb position
                    local trackWidth = track:GetWidth() or 1
                    fill:SetWidth(math.max(1, trackWidth * pct))  -- Min 1px to stay visible
                end
            end)
        end

        -- =====================================================================
        -- Checkbox Skinning (custom look)
        -- =====================================================================
        -- Replaces default Blizzard checkbox textures with custom dark theme
        SkinCheckbox = function(cb)
            if not cb or cb._pcbSkinned then return end  -- Already skinned, skip
            cb._pcbSkinned = true  -- Mark as skinned

            cb:SetSize(18, 18)

            -- Remove all default Blizzard textures
            local normal = cb.GetNormalTexture and cb:GetNormalTexture()
            local pushed = cb.GetPushedTexture and cb:GetPushedTexture()
            local highlight = cb.GetHighlightTexture and cb:GetHighlightTexture()
            local checked = cb.GetCheckedTexture and cb:GetCheckedTexture()
            local disabledChecked = cb.GetDisabledCheckedTexture and cb:GetDisabledCheckedTexture()

            if normal then normal:SetTexture(nil) end
            if pushed then pushed:SetTexture(nil) end
            if highlight then highlight:SetTexture(nil) end
            if checked then checked:SetTexture(nil) end
            if disabledChecked then disabledChecked:SetTexture(nil) end

            -- Dark background
            local bg = cb:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(cb)
            bg:SetColorTexture(0.12, 0.12, 0.16, 1)

            -- Border for depth
            local border = cb:CreateTexture(nil, "BORDER")
            border:SetPoint("TOPLEFT", cb, "TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", 1, -1)
            border:SetColorTexture(0.25, 0.25, 0.3, 1)

            -- Gold check mark when checked
            local checkTex = cb:CreateTexture(nil, "ARTWORK")
            checkTex:SetPoint("TOPLEFT", cb, "TOPLEFT", 3, -3)
            checkTex:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", -3, 3)
            checkTex:SetColorTexture(1, 0.82, 0, 1)  -- Gold color
            cb:SetCheckedTexture(checkTex)

            -- Hover highlight
            local hl = cb:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints(cb)
            hl:SetColorTexture(1, 1, 1, 0.08)  -- Subtle white glow on hover
        end

        local dropdownClickCatcher = CreateFrame("Frame", "PCB_DropdownClickCatcher", optionsFrame)
        dropdownClickCatcher:SetAllPoints(optionsFrame)
        dropdownClickCatcher:EnableMouse(true)
        dropdownClickCatcher:SetFrameStrata("HIGH")
        dropdownClickCatcher:SetFrameLevel(optionsFrame:GetFrameLevel() + 50)
        dropdownClickCatcher:Hide()

        dropdownClickCatcher:SetScript("OnMouseDown", function(self)
            CloseAllMenus()
            self:Hide()
        end)

            -- Helper function to add a simple dropdown (used for profiles)
            local function AddDropdown(parent, label, y, key)
                local container = CreateFrame("Frame", nil, parent)
                container:SetPoint("TOPLEFT", 10, y)
                container:SetSize(400, 24)

                -- Label background
                local labelBg = container:CreateTexture(nil, "BACKGROUND")
                labelBg:SetPoint("LEFT", -4, 0)
                labelBg:SetSize(150, 24)
                labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)

                local labelText = container:CreateFontString(nil, "OVERLAY")
                labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                labelText:SetPoint("LEFT", 0, 0)
                labelText:SetText(label)
                container.labelText = labelText

                local dropdown = CreateFrame("Button", nil, container)
                dropdown:SetWidth(180)
                dropdown:SetHeight(24)
                dropdown:SetPoint("LEFT", 120, 0)

                local bg = dropdown:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(0.15, 0.15, 0.15, 1)

                local border = dropdown:CreateTexture(nil, "ARTWORK")
                border:SetPoint("TOPLEFT", 1, -1)
                border:SetPoint("BOTTOMRIGHT", -1, 1)
                border:SetColorTexture(0.25, 0.25, 0.25, 1)

                local text = dropdown:CreateFontString(nil, "OVERLAY")
                text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                text:SetPoint("LEFT", 8, 0)
                text:SetPoint("RIGHT", -20, 0)
                text:SetJustifyH("LEFT")
                text:SetTextColor(1, 1, 1, 1)

                local arrowBtn = CreateFrame("Button", nil, dropdown)
                arrowBtn:SetSize(16, 16)
                arrowBtn:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
                
                local arrowHighlight = arrowBtn:CreateTexture(nil, "HIGHLIGHT")
                arrowHighlight:SetAllPoints(arrowBtn)
                arrowHighlight:SetColorTexture(1, 1, 1, 0.2)

                -- Custom arrow - create textures manually
                local normal = arrowBtn:CreateTexture(nil, "ARTWORK")
                normal:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
                normal:SetSize(12, 12)
                normal:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                normal:SetTexCoord(0, 1, 0, 1)
                arrowBtn:SetNormalTexture(normal)
                
                local pushed = arrowBtn:CreateTexture(nil, "ARTWORK")
                pushed:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
                pushed:SetSize(12, 12)
                pushed:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                pushed:SetTexCoord(0, 1, 0, 1)
                arrowBtn:SetPushedTexture(pushed)

                dropdown:SetScript("OnEnter", function() border:SetColorTexture(0.35, 0.35, 0.35, 1) end)
                dropdown:SetScript("OnLeave", function() border:SetColorTexture(0.25, 0.25, 0.25, 1) end)

                -- Menu frame parented to UIParent so it can extend beyond scroll frame
                local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
                menu:SetFrameStrata("TOOLTIP")
                menu:SetFrameLevel(1000)
                menu:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true, tileSize = 32, edgeSize = 32,
                    insets = { left = 11, right = 12, top = 12, bottom = 11 }
                })
                menu:SetWidth(200)
                menu:Hide()

                local menuButtons = {}

                local function GetProfiles()
                    local profiles = {}
                    local playerName = UnitName("player")
                    local realmName = GetRealmName()
                    local _, className = UnitClass("player")

                    if playerName and realmName then
                        local charProfile = playerName .. " - " .. realmName
                        table.insert(profiles, charProfile)
                    end
                    if realmName then
                        table.insert(profiles, realmName)
                    end
                    if className then
                        table.insert(profiles, className)
                    end

                    if PCB.dbRoot and PCB.dbRoot.profiles then
                        for name in pairs(PCB.dbRoot.profiles) do
                            local exists = false
                            for _, p in ipairs(profiles) do
                                if p == name then exists = true; break end
                            end
                            if not exists then table.insert(profiles, name) end
                        end
                    end

                    table.sort(profiles, function(a, b)
                        if a == "Default" then return true end
                        if b == "Default" then return false end
                        return a < b
                    end)

                    return profiles
                end

                local function UpdateDropdown()
                    for _, btn in ipairs(menuButtons) do
                        btn:Hide()
                        btn:SetParent(nil)
                    end
                    menuButtons = {}

                    local profiles = GetProfiles()
                    local currentProfile = PCB:GetActiveProfileName()

                    if key == "existingProfile" then
                        text:SetText(currentProfile or "Default")
                    elseif key == "defaultProfile" then
                        text:SetText(PCB:GetDefaultProfile() or "None")
                    elseif key == "copyProfile" or key == "deleteProfile" then
                        text:SetText("Select...")
                    end

                    local function GetCharKey()
                        local name = UnitName("player") or "Unknown"
                        local realm = GetRealmName() or "Realm"
                        realm = realm:gsub("%s+", "")
                        return name .. " - " .. realm
                    end

                    local charKey = GetCharKey()

                    for i, profileName in ipairs(profiles) do
                        local btn = CreateFrame("Button", nil, menu)
                        btn:SetWidth(180)
                        btn:SetHeight(20)
                        btn:SetPoint("TOP", menu, "TOP", 0, -10 - (i-1) * 20)

                        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                        btnBg:SetAllPoints()
                        btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

                        local check = btn:CreateTexture(nil, "OVERLAY")
                        check:SetSize(16, 16)
                        check:SetPoint("LEFT", 5, 0)
                        check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                        if profileName == currentProfile then check:Show() else check:Hide() end

                        local function ToTitleCase(str)
                            return str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
                        end

                        local btnText = btn:CreateFontString(nil, "OVERLAY")
                        btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                        btnText:SetPoint("LEFT", 25, 0)
                        btnText:SetText(ToTitleCase(profileName))
                        if profileName == currentProfile then btnText:SetTextColor(1, 0.82, 0, 1) else btnText:SetTextColor(1,1,1,1) end

                        btn:SetScript("OnEnter", function() btnBg:SetColorTexture(0.4, 0.4, 0.4, 1) end)
                        btn:SetScript("OnLeave", function() btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8) end)
                        btn:SetScript("OnClick", function()
                            if key == "existingProfile" then
                                if not PCB.dbRoot.profiles[profileName] then
                                    PCB:EnsureProfile(profileName)
                                    PCB:Print("Created new profile: " .. profileName)
                                end
                                PCB:SetActiveProfileName(profileName)
                                PCB:Print("Switched to profile: " .. profileName)
                                if PCB.ApplyAll then PCB:ApplyAll() end
                                menu:Hide()
                                activeMenus[menu] = nil
                                UpdateArrow(menu._arrowBtn, false)
                                if optionsFrame and optionsFrame.UpdateContent then
                                    optionsFrame.UpdateContent(selectedCategory)
                                end
                            elseif key == "defaultProfile" then
                                PCB:SetDefaultProfile(profileName)
                                PCB:Print("Default profile set to: " .. profileName)
                                text:SetText(profileName)
                            elseif key == "copyProfile" then
                                local currentName = PCB:GetActiveProfileName()
                                if profileName ~= currentName and PCB.dbRoot.profiles[profileName] then
                                    PCB.dbRoot.profiles[currentName] = PCB.DeepCopy(PCB.dbRoot.profiles[profileName])
                                    PCB:SelectActiveProfile()
                                    PCB:Print("Copied settings from " .. profileName)
                                    if PCB.ApplyAll then PCB:ApplyAll() end
                                end
                            elseif key == "deleteProfile" then
                                if profileName ~= "Default" and profileName ~= currentProfile and PCB.dbRoot.profiles[profileName] then
                                    PCB.dbRoot.profiles[profileName] = nil
                                    PCB:Print("Deleted profile: " .. profileName)
                                    UpdateDropdown()
                                else
                                    PCB:Print("Cannot delete Default, currently active profile, or non-existent profile")
                                end
                            end
                            menu:Hide()
                            activeMenus[menu] = nil
                            dropdownClickCatcher:Hide()
                        end)

                        table.insert(menuButtons, btn)
                    end

                    menu:SetHeight(math.max(40, 20 + #profiles * 20))
                end

                menu._arrowBtn = arrowBtn

                local function ToggleMenu()
                    UpdateDropdown()
                    if menu:IsShown() then
                        menu:Hide()
                        activeMenus[menu] = nil
                        dropdownClickCatcher:Hide()
                        UpdateArrow(arrowBtn, false)
                    else
                        CloseAllMenus()
                        menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -4)
                        menu:Show()
                        activeMenus[menu] = true
                        UpdateArrow(arrowBtn, true)
                        -- Push click catcher to top of ESC stack (only if not already present)
                        local alreadyInList = false
                        for i = 1, #UISpecialFrames do
                            if UISpecialFrames[i] == "PCB_DropdownClickCatcher" then
                                alreadyInList = true
                                break
                            end
                        end
                        if not alreadyInList then
                            tinsert(UISpecialFrames, "PCB_DropdownClickCatcher")
                        end
                        dropdownClickCatcher:Show()
                    end
                end

                dropdown:SetScript("OnClick", ToggleMenu)
                arrowBtn:SetScript("OnClick", ToggleMenu)

                UpdateDropdown()
                
                -- Store reference to enable/disable later
                container.dropdown = dropdown
                container.UpdateDropdown = UpdateDropdown
                
                return container
            end
            
            -- Helper function to add a spec-specific profile dropdown
            local function AddSpecDropdown(parent, specIndex, y)
                -- Get spec info for the current class
                local specID, specName
                if GetSpecializationInfo then
                    local id, name = GetSpecializationInfo(specIndex)
                    specID = id
                    specName = name
                end
                
                -- Return nil if this spec doesn't exist for the class
                if not specID or not specName then
                    return nil
                end
                
                local container = CreateFrame("Frame", nil, parent)
                container:SetPoint("TOPLEFT", 10, y)
                container:SetSize(400, 24)
                container.specID = specID
                container.specIndex = specIndex

                -- Label background
                local labelBg = container:CreateTexture(nil, "BACKGROUND")
                labelBg:SetPoint("LEFT", -4, 0)
                labelBg:SetSize(150, 24)
                labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)

                local labelText = container:CreateFontString(nil, "OVERLAY")
                labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                labelText:SetPoint("LEFT", 0, 0)
                labelText:SetText(specName)
                container.labelText = labelText

                local dropdown = CreateFrame("Button", nil, container)
                dropdown:SetWidth(180)
                dropdown:SetHeight(24)
                dropdown:SetPoint("LEFT", 120, 0)

                local bg = dropdown:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(0.15, 0.15, 0.15, 1)

                local border = dropdown:CreateTexture(nil, "ARTWORK")
                border:SetPoint("TOPLEFT", 1, -1)
                border:SetPoint("BOTTOMRIGHT", -1, 1)
                border:SetColorTexture(0.25, 0.25, 0.25, 1)

                local text = dropdown:CreateFontString(nil, "OVERLAY")
                text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                text:SetPoint("LEFT", 8, 0)
                text:SetPoint("RIGHT", -20, 0)
                text:SetJustifyH("LEFT")
                text:SetTextColor(1, 1, 1, 1)

                local arrowBtn = CreateFrame("Button", nil, dropdown)
                arrowBtn:SetSize(16, 16)
                arrowBtn:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
                
                local arrowHighlight = arrowBtn:CreateTexture(nil, "HIGHLIGHT")
                arrowHighlight:SetAllPoints(arrowBtn)
                arrowHighlight:SetColorTexture(1, 1, 1, 0.2)

                -- Custom arrow - create textures manually
                local normal = arrowBtn:CreateTexture(nil, "ARTWORK")
                normal:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
                normal:SetSize(12, 12)
                normal:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                normal:SetTexCoord(0, 1, 0, 1)
                arrowBtn:SetNormalTexture(normal)
                
                local pushed = arrowBtn:CreateTexture(nil, "ARTWORK")
                pushed:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
                pushed:SetSize(12, 12)
                pushed:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                pushed:SetTexCoord(0, 1, 0, 1)
                arrowBtn:SetPushedTexture(pushed)

                dropdown:SetScript("OnEnter", function() border:SetColorTexture(0.35, 0.35, 0.35, 1) end)
                dropdown:SetScript("OnLeave", function() border:SetColorTexture(0.25, 0.25, 0.25, 1) end)

                -- Menu frame parented to UIParent so it can extend beyond scroll frame
                local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
                menu:SetFrameStrata("TOOLTIP")
                menu:SetFrameLevel(1000)
                menu:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true, tileSize = 32, edgeSize = 32,
                    insets = { left = 11, right = 12, top = 12, bottom = 11 }
                })
                menu:SetWidth(200)
                menu:Hide()

                local menuButtons = {}

                local function GetProfiles()
                    local profiles = {}
                    local playerName = UnitName("player")
                    local realmName = GetRealmName()
                    local _, className = UnitClass("player")

                    if playerName and realmName then
                        local charProfile = playerName .. " - " .. realmName
                        table.insert(profiles, charProfile)
                    end
                    if realmName then
                        table.insert(profiles, realmName)
                    end
                    if className then
                        table.insert(profiles, className)
                    end

                    if PCB.dbRoot and PCB.dbRoot.profiles then
                        for name in pairs(PCB.dbRoot.profiles) do
                            local exists = false
                            for _, p in ipairs(profiles) do
                                if p == name then exists = true; break end
                            end
                            if not exists then table.insert(profiles, name) end
                        end
                    end

                    table.sort(profiles, function(a, b)
                        if a == "Default" then return true end
                        if b == "Default" then return false end
                        return a < b
                    end)

                    return profiles
                end
                
                local function GetCharKey()
                    local name = UnitName("player") or "Unknown"
                    local realm = GetRealmName() or "Realm"
                    realm = realm:gsub("%s+", "")
                    return name .. " - " .. realm
                end

                local function UpdateDropdown()
                    for _, btn in ipairs(menuButtons) do
                        btn:Hide()
                        btn:SetParent(nil)
                    end
                    menuButtons = {}

                    local profiles = GetProfiles()
                    local charKey = GetCharKey()
                    
                    -- Get the current profile for this spec
                    local currentProfile = "Default"
                    if PCB.dbRoot and PCB.dbRoot.chars and PCB.dbRoot.chars[charKey] then
                        local charData = PCB.dbRoot.chars[charKey]
                        if charData.specProfiles and charData.specProfiles[specID] then
                            currentProfile = charData.specProfiles[specID]
                        end
                    end

                    text:SetText(currentProfile or "Default")

                    for i, profileName in ipairs(profiles) do
                        local btn = CreateFrame("Button", nil, menu)
                        btn:SetWidth(180)
                        btn:SetHeight(20)
                        btn:SetPoint("TOP", menu, "TOP", 0, -10 - (i-1) * 20)

                        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                        btnBg:SetAllPoints()
                        btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

                        local check = btn:CreateTexture(nil, "OVERLAY")
                        check:SetSize(16, 16)
                        check:SetPoint("LEFT", 5, 0)
                        check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                        if profileName == currentProfile then check:Show() else check:Hide() end

                        local function ToTitleCase(str)
                            return str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
                        end

                        local btnText = btn:CreateFontString(nil, "OVERLAY")
                        btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                        btnText:SetPoint("LEFT", 25, 0)
                        btnText:SetText(ToTitleCase(profileName))
                        if profileName == currentProfile then btnText:SetTextColor(1, 0.82, 0, 1) else btnText:SetTextColor(1,1,1,1) end

                        btn:SetScript("OnEnter", function() btnBg:SetColorTexture(0.4, 0.4, 0.4, 1) end)
                        btn:SetScript("OnLeave", function() btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8) end)
                        btn:SetScript("OnClick", function()
                            -- Ensure profile exists
                            if not PCB.dbRoot.profiles[profileName] then
                                PCB:EnsureProfile(profileName)
                            end
                            
                            -- Set the spec profile
                            PCB.dbRoot.chars[charKey] = PCB.dbRoot.chars[charKey] or { profile = "Default", specProfiles = {} }
                            PCB.dbRoot.chars[charKey].specProfiles[specID] = profileName
                            
                            -- Update text and apply
                            text:SetText(profileName)
                            PCB:SelectActiveProfile()
                            PCB:Print("Set " .. specName .. " spec to use profile: " .. profileName)
                            if PCB.ApplyAll then PCB:ApplyAll() end
                            
                            menu:Hide()
                            activeMenus[menu] = nil
                            dropdownClickCatcher:Hide()
                        end)

                        table.insert(menuButtons, btn)
                    end

                    menu:SetHeight(math.max(40, 20 + #profiles * 20))
                end

                menu._arrowBtn = arrowBtn

                local function ToggleMenu()
                    UpdateDropdown()
                    if menu:IsShown() then
                        menu:Hide()
                        activeMenus[menu] = nil
                        dropdownClickCatcher:Hide()
                        UpdateArrow(arrowBtn, false)
                    else
                        CloseAllMenus()
                        menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -4)
                        menu:Show()
                        activeMenus[menu] = true
                        UpdateArrow(arrowBtn, true)
                        -- Push click catcher to top of ESC stack (only if not already present)
                        local alreadyInList = false
                        for i = 1, #UISpecialFrames do
                            if UISpecialFrames[i] == "PCB_DropdownClickCatcher" then
                                alreadyInList = true
                                break
                            end
                        end
                        if not alreadyInList then
                            tinsert(UISpecialFrames, "PCB_DropdownClickCatcher")
                        end
                        dropdownClickCatcher:Show()
                    end
                end

                dropdown:SetScript("OnClick", ToggleMenu)
                arrowBtn:SetScript("OnClick", ToggleMenu)

                UpdateDropdown()
                
                -- Store reference to enable/disable later
                container.dropdown = dropdown
                container.UpdateDropdown = UpdateDropdown
                
                return container
            end
        
        -- Helper function to add a slider
        local function AddSlider(parent, label, dbKey, y, minVal, maxVal, stepVal)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetWidth(200)
    slider:SetHeight(20)
    slider:SetPoint("TOPLEFT", 10, y)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(stepVal)
    slider:SetObeyStepOnDrag(true)
    SkinSlider(slider)

    -- Set min/max labels to actual values
    if slider.Low then slider.Low:SetText(tostring(minVal)) end
    if slider.High then slider.High:SetText(tostring(maxVal)) end

    -- Label
    local labelText = slider:CreateFontString(nil, "OVERLAY")
    labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
    labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 2)
    labelText:SetText(label)

    -- Value input (editable)
    local valueBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    valueBox:SetAutoFocus(false)
    valueBox:SetSize(36, 18)
    valueBox:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 0)
    valueBox:SetJustifyH("CENTER")
    valueBox:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
-- Keep the edit box visibility in sync with the slider (e.g. when toggling override options).
slider:HookScript("OnShow", function() valueBox:Show() end)
slider:HookScript("OnHide", function() valueBox:Hide() end)


    -- Ensure the edit box is actually clickable even if frames overlap
    valueBox:SetFrameStrata(slider:GetFrameStrata())
    valueBox:SetFrameLevel(slider:GetFrameLevel() + 1)

    -- Now that we know the valueBox size, shrink the slider's click area on the right.
    -- (SetHitRectInsets: positive insets shrink the clickable area)
    slider:SetHitRectInsets(0, valueBox:GetWidth() + 14, 0, 0)

    local function FormatValue(v)
        -- Keep consistent formatting across float/int sliders
        if stepVal and stepVal >= 1 then
            return string.format("%.0f", v)
        end
        return string.format("%.2f", v)
    end

    local function RoundToStep(v)
        if not stepVal or stepVal <= 0 then return v end
        return math.floor(v / stepVal + 0.5) * stepVal
    end

    local function Clamp(v)
        if v < minVal then return minVal end
        if v > maxVal then return maxVal end
        return v
    end


    local function ApplyFromBox()
        local n = tonumber(valueBox:GetText())
        if not n then
            -- Revert if invalid
            valueBox:SetText(FormatValue(slider:GetValue() or minVal))
            return
        end
        -- Clamp and show the clamped value in the box for user feedback
        if n > maxVal then
            n = maxVal
        elseif n < minVal then
            n = minVal
        else
            n = Clamp(RoundToStep(n))
        end
        slider:SetValue(n) -- drives OnValueChanged -> DB + ApplyAll
        valueBox:SetText(FormatValue(n))
        valueBox:ClearFocus()
    end

    valueBox:SetScript("OnEnterPressed", ApplyFromBox)
    valueBox:SetScript("OnEscapePressed", function(self)
        self:SetText(FormatValue(slider:GetValue() or minVal))
        self:ClearFocus()
    end)
    valueBox:SetScript("OnEditFocusLost", function(self)
        -- Apply if the user typed something and then clicked away
        ApplyFromBox()
    end)

    local currentValue = GetValue(PCB.db, dbKey) or minVal
    slider:SetValue(currentValue)
    valueBox:SetText(FormatValue(currentValue))

    slider:SetScript("OnValueChanged", function(self, value)
        -- Ensure value is clamped and rounded to step
        value = Clamp(RoundToStep(value))
        -- Save to database
        SetValue(PCB.db, dbKey, value)

        -- Update text box display (but don't interrupt user typing)
        if not valueBox:HasFocus() then
            valueBox:SetText(FormatValue(value))
        end

        -- Apply changes to all cast bars immediately
        if PCB.ApplyAll then PCB:ApplyAll() end
        -- Update preview
        if optionsFrame and optionsFrame.UpdatePreview then
            optionsFrame:UpdatePreview()
        end
        -- Directly update icon position for iconOffsetX slider
        if dbKey and dbKey:match("iconOffsetX$") and optionsFrame.preview and optionsFrame.preview.icon then
            optionsFrame.preview.icon:ClearAllPoints()
            optionsFrame.preview.icon:SetPoint("RIGHT", optionsFrame.preview.bar, "LEFT", value, 0)
        end
    end)

    return slider
end

        
        -- Helper function to add a 2x2 grid of sliders
        -- Creates a compact layout for related settings (e.g., X/Y offsets, Width/Height)
        local function AddSliderGrid(parent, y, sliders)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)

            -- Filter to visible sliders only
            local visibleSliders = {}
            for _, sd in ipairs(sliders) do
                local show = true
                if sd.visibleIf then
                    local ok, val = pcall(sd.visibleIf)
                    show = ok and val
                end
                if show then visibleSliders[#visibleSliders + 1] = sd end
            end

            local rows = math.ceil(#visibleSliders / 2)
            container:SetSize(480, math.max(1, rows) * 60)

            for i, sliderData in ipairs(visibleSliders) do
                local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
                slider:SetWidth(220)
                slider:SetHeight(20)
                
                -- Grid position calculation:
                -- Row: top row (i <= 2) or bottom row (i > 2)
                -- Col: left column (odd i) or right column (even i)
                local row = (i <= 2) and 0 or 1  -- 0 = top row, 1 = bottom row
                local col = ((i - 1) % 2)         -- 0 = left col, 1 = right col
                local xOffset = col * 240         -- 240px horizontal spacing
                local yOffset = row * -60         -- 60px vertical spacing (negative = down)
                
                slider:SetPoint("TOPLEFT", xOffset, yOffset)
                slider:SetMinMaxValues(sliderData.min, sliderData.max)
                slider:SetValueStep(sliderData.step)
                slider:SetObeyStepOnDrag(true)
                SkinSlider(slider)
                
                -- Set min/max labels to actual values
                if slider.Low then slider.Low:SetText(tostring(sliderData.min)) end
                if slider.High then slider.High:SetText(tostring(sliderData.max)) end
                
                -- Label
                local labelText = slider:CreateFontString(nil, "OVERLAY")
                labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 2)
                labelText:SetText(sliderData.label)
                
                -- Value input box
                local valueBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
                valueBox:SetAutoFocus(false)
                valueBox:SetSize(36, 18)
                valueBox:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 0)
                valueBox:SetJustifyH("CENTER")
                valueBox:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                valueBox:SetFrameStrata(slider:GetFrameStrata())
                valueBox:SetFrameLevel(slider:GetFrameLevel() + 10)
                
                local function FormatValue(v)
                    if sliderData.step and sliderData.step >= 1 then
                        return string.format("%.0f", v)
                    end
                    return string.format("%.2f", v)
                end
                
                local function RoundToStep(v)
                    if not sliderData.step or sliderData.step <= 0 then return v end
                    return math.floor(v / sliderData.step + 0.5) * sliderData.step
                end
                
                local function Clamp(v)
                    if v < sliderData.min then return sliderData.min end
                    if v > sliderData.max then return sliderData.max end
                    return v
                end
                
                local function ApplyFromBox()
                    local n = tonumber(valueBox:GetText())
                    if not n then
                        valueBox:SetText(FormatValue(slider:GetValue() or sliderData.min))
                        return
                    end
                    n = Clamp(RoundToStep(n))
                    slider:SetValue(n)
                    valueBox:SetText(FormatValue(n))
                    valueBox:ClearFocus()
                end
                
                valueBox:SetScript("OnEnterPressed", ApplyFromBox)
                valueBox:SetScript("OnEscapePressed", function(self)
                    self:SetText(FormatValue(slider:GetValue() or sliderData.min))
                    self:ClearFocus()
                end)
                valueBox:SetScript("OnEditFocusLost", ApplyFromBox)
                
                local currentValue = GetValue(PCB.db, sliderData.key) or sliderData.min
                slider:SetValue(currentValue)
                valueBox:SetText(FormatValue(currentValue))
                
                slider:SetScript("OnValueChanged", function(self, value)
                    value = Clamp(RoundToStep(value))
                    SetValue(PCB.db, sliderData.key, value)
                    if not valueBox:HasFocus() then
                        valueBox:SetText(FormatValue(value))
                    end
                    if PCB.ApplyAll then PCB:ApplyAll() end
                    -- Update preview
                    if optionsFrame and optionsFrame.UpdatePreview then
                        optionsFrame:UpdatePreview()
                    end
                    -- Directly update icon position for iconOffsetX slider
                    if sliderData.key and sliderData.key:match("iconOffsetX$") and optionsFrame.preview and optionsFrame.preview.icon then
                        optionsFrame.preview.icon:ClearAllPoints()
                        optionsFrame.preview.icon:SetPoint("RIGHT", optionsFrame.preview.bar, "LEFT", value, 0)
                    end
                end)
            end
            
            return container
        end
        
        -- Helper function to add a description text
        local function AddDescription(parent, text, y)
            local desc = parent:CreateFontString(nil, "OVERLAY")
            desc:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            desc:SetPoint("TOPLEFT", 10, y)
            desc:SetPoint("TOPRIGHT", -10, y)
            desc:SetJustifyH("LEFT")
            desc:SetJustifyV("TOP")
            desc:SetText(text)
            desc:SetWordWrap(true)
            desc:SetNonSpaceWrap(false)
            -- Calculate height based on text
            desc:SetHeight(desc:GetStringHeight() + 5)
            return desc
        end
        
        -- Helper function to add a label
        local function AddLabel(parent, text, y, getValue)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 8, y)
            container:SetSize(300, 20)

            local labelBg = container:CreateTexture(nil, "BACKGROUND")
            labelBg:SetAllPoints()
            labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)

            local label = container:CreateFontString(nil, "OVERLAY")
            label:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            label:SetPoint("LEFT", 2, 0)
            if getValue == "currentProfile" then
                label:SetText(string.format(text, PCB:GetActiveProfileName() or "Default"))
            else
                label:SetText(text)
            end
            return container
        end
        
        -- Helper function to add a button
        local function AddButton(parent, label, y, onClick)
            local btn = CreateFrame("Button", nil, parent)
            btn:SetWidth(120)
            btn:SetHeight(22)
            btn:SetPoint("TOPLEFT", 10, y)
            
            -- Custom button styling
            local bg = btn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.15, 0.15, 0.15, 1)
            
            local border = btn:CreateTexture(nil, "ARTWORK")
            border:SetPoint("TOPLEFT", 1, -1)
            border:SetPoint("BOTTOMRIGHT", -1, 1)
            border:SetColorTexture(0.25, 0.25, 0.25, 1)
            
            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(1, 1, 1, 0.1)
            
            local btnText = btn:CreateFontString(nil, "OVERLAY")
            btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            btnText:SetPoint("CENTER")
            btnText:SetText(label)
            btnText:SetTextColor(1, 1, 1, 1)
            
            btn:SetScript("OnEnter", function()
                bg:SetColorTexture(0.25, 0.25, 0.25, 1)
                border:SetColorTexture(0.35, 0.35, 0.35, 1)
            end)
            btn:SetScript("OnLeave", function()
                bg:SetColorTexture(0.15, 0.15, 0.15, 1)
                border:SetColorTexture(0.25, 0.25, 0.25, 1)
            end)
            
            if onClick == "resetProfile" then
                btn:SetScript("OnClick", function()
                    if PCB.ResetProfile then
                        PCB:ResetProfile()
                        PCB:Print("Profile reset to default values.")
                        if PCB.ApplyAll then PCB:ApplyAll() end
                    end
                end)
            elseif onClick:match("^resetBar_") then
                local barKey = onClick:match("^resetBar_(.+)$")
                btn:SetScript("OnClick", function()
                    print("Reset button clicked for bar:", barKey)
                    PCB._pendingResetBarKey = barKey
                    -- Update the popup text dynamically
                    StaticPopupDialogs["PCB_CONFIRM_RESET"].text = string.format("Reset %s bar settings to defaults?", barKey:gsub("^%l", string.upper))
                    print("About to call StaticPopup_Show for PCB_CONFIRM_RESET")
                    StaticPopup_Show("PCB_CONFIRM_RESET")
                end)
            elseif onClick == "toggleTestMode" then
                btn:SetScript("OnClick", function()
                    if PCB.SetTestMode then
                        local newState = not PCB.testMode
                        PCB:SetTestMode(newState)
                        PCB:Print(newState and "Test mode enabled" or "Test mode disabled")
                    end
                end)
            end
            
            return btn
        end
        
        -- Helper function to add a color picker
        local function AddColorPicker(parent, label, dbKey, y)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(400, 30)
            
            local labelText = container:CreateFontString(nil, "OVERLAY")
            labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            labelText:SetPoint("TOPLEFT", 0, -5)
            labelText:SetText(label)
            
            local colorBtn = CreateFrame("Button", nil, container)
            colorBtn:SetWidth(40)
            colorBtn:SetHeight(20)
            colorBtn:SetPoint("LEFT", labelText, "RIGHT", 10, 0)
            
            -- Color swatch background
            local bg = colorBtn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.15, 0.15, 0.15, 1)
            
            -- Color swatch
            local swatch = colorBtn:CreateTexture(nil, "ARTWORK")
            swatch:SetPoint("TOPLEFT", 2, -2)
            swatch:SetPoint("BOTTOMRIGHT", -2, 2)
            
            -- Border
            local border = colorBtn:CreateTexture(nil, "OVERLAY")
            border:SetColorTexture(1, 1, 1, 0.3)
            border:SetPoint("TOPLEFT", 1, -1)
            border:SetPoint("BOTTOMRIGHT", -1, 1)
            
            -- Update color display
            local function UpdateColor()
                local color = GetValue(PCB.db, dbKey) or {r=1, g=1, b=1, a=1}
                swatch:SetColorTexture(color.r, color.g, color.b, color.a or 1)
            end
            
            UpdateColor()
            
            -- Color picker callback
            local function OnColorChanged(restore)
                local newR, newG, newB, newA
                if restore then
                    newR, newG, newB, newA = unpack(restore)
                else
                    newR, newG, newB = ColorPickerFrame:GetColorRGB()
                    newA = (ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha()) or 1
                end
                
                SetValue(PCB.db, dbKey, {r = newR, g = newG, b = newB, a = newA})
                UpdateColor()
                if PCB.ApplyAll then PCB:ApplyAll() end
                UpdatePreview()
            end
            
            -- Open color picker
            colorBtn:SetScript("OnClick", function()
                local color = GetValue(PCB.db, dbKey) or {r=1, g=1, b=1, a=1}
                local r, g, b, a = color.r or 1, color.g or 1, color.b or 1, color.a or 1
                
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r,
                    g = g,
                    b = b,
                    opacity = a,
                    hasOpacity = true,
                    swatchFunc = OnColorChanged,
                    opacityFunc = OnColorChanged,
                    cancelFunc = function()
                        OnColorChanged({r, g, b, a})
                    end,
                })
            end)
            
            -- Hover effect
            colorBtn:SetScript("OnEnter", function()
                border:SetColorTexture(1, 1, 1, 0.6)
            end)
            colorBtn:SetScript("OnLeave", function()
                border:SetColorTexture(1, 1, 1, 0.3)
            end)
            
            return container
        end
        
        -- Helper function to add a 2-column grid of color pickers
        local function AddColorPickerGrid(parent, y, pickers)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(480, 100)
            
            local maxHeight = 0
            
            for i, pickerData in ipairs(pickers) do
                local col = ((i - 1) % 2)  -- 0 for left, 1 for right
                local row = math.floor((i - 1) / 2)
                
                local xOffset = col * 240
                local yOffset = -row * 40
                
                local pickerContainer = CreateFrame("Frame", nil, container)
                pickerContainer:SetPoint("TOPLEFT", xOffset, yOffset)
                pickerContainer:SetSize(220, 30)
                
                -- Label background
                local labelBg = pickerContainer:CreateTexture(nil, "BACKGROUND")
                labelBg:SetPoint("TOPLEFT", 0, -2)
                labelBg:SetSize(155, 20)
                labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)
                
                local labelText = pickerContainer:CreateFontString(nil, "OVERLAY")
                labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                labelText:SetPoint("TOPLEFT", 0, -5)
                labelText:SetWidth(145)
                labelText:SetJustifyH("LEFT")
                labelText:SetText(pickerData.label)
                
                local colorBtn = CreateFrame("Button", nil, pickerContainer)
                colorBtn:SetWidth(40)
                colorBtn:SetHeight(20)
                colorBtn:SetPoint("TOPLEFT", 155, -3)
                
                -- Color swatch background
                local bg = colorBtn:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(0.15, 0.15, 0.15, 1)
                
                -- Color swatch
                local swatch = colorBtn:CreateTexture(nil, "ARTWORK")
                swatch:SetPoint("TOPLEFT", 2, -2)
                swatch:SetPoint("BOTTOMRIGHT", -2, 2)
                
                -- Border
                local border = colorBtn:CreateTexture(nil, "OVERLAY")
                border:SetColorTexture(1, 1, 1, 0.3)
                border:SetPoint("TOPLEFT", 1, -1)
                border:SetPoint("BOTTOMRIGHT", -1, 1)
                
                -- Update color display
                local function UpdateColor()
                    local color = GetValue(PCB.db, pickerData.key) or {r=1, g=1, b=1, a=1}
                    swatch:SetColorTexture(color.r, color.g, color.b, color.a or 1)
                end
                
                UpdateColor()
                
                -- Color picker callback
                local function OnColorChanged(restore)
                    local newR, newG, newB, newA
                    if restore then
                        newR, newG, newB, newA = unpack(restore)
                    else
                        newR, newG, newB = ColorPickerFrame:GetColorRGB()
                        newA = (ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha()) or 1
                    end
                    
                    SetValue(PCB.db, pickerData.key, {r = newR, g = newG, b = newB, a = newA})
                    UpdateColor()
                    if PCB.ApplyAll then PCB:ApplyAll() end
                end
                
                -- Open color picker
                colorBtn:SetScript("OnClick", function()
                    local color = GetValue(PCB.db, pickerData.key) or {r=1, g=1, b=1, a=1}
                    local r, g, b, a = color.r or 1, color.g or 1, color.b or 1, color.a or 1
                    
                    ColorPickerFrame:SetupColorPickerAndShow({
                        r = r,
                        g = g,
                        b = b,
                        opacity = a,
                        hasOpacity = true,
                        swatchFunc = OnColorChanged,
                        opacityFunc = OnColorChanged,
                        cancelFunc = function()
                            OnColorChanged({r, g, b, a})
                        end,
                    })
                end)
                
                -- Hover effect
                colorBtn:SetScript("OnEnter", function()
                    border:SetColorTexture(1, 1, 1, 0.6)
                end)
                colorBtn:SetScript("OnLeave", function()
                    border:SetColorTexture(1, 1, 1, 0.3)
                end)
                
                maxHeight = math.max(maxHeight, (row + 1) * 40)
            end
            
            container:SetHeight(maxHeight)
            return container
        end
        
        -- Helper function to add an editbox
        local function AddEditBox(parent, label, y, placeholder)
            -- Container to hold both label and editbox
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(400, 24)
            
            -- Label background
            local labelBg = container:CreateTexture(nil, "BACKGROUND")
            labelBg:SetPoint("TOPLEFT", -2, 2)
            labelBg:SetSize(60, 20)
            labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)
            
            local labelText = container:CreateFontString(nil, "OVERLAY")
            labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            labelText:SetPoint("TOPLEFT", 0, 0)
            labelText:SetText(label)
            
            local editbox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editbox:SetWidth(180)
            editbox:SetHeight(20)
            editbox:SetPoint("LEFT", labelText, "RIGHT", 10, 0)
            editbox:SetAutoFocus(false)
            editbox:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            editbox:SetScript("OnEnterPressed", function(self)
                local newName = self:GetText()
                if newName and newName ~= "" then
                    if PCB.EnsureProfile then
                        PCB:EnsureProfile(newName)
                        PCB:SetActiveProfileName(newName)
                        PCB:Print("Created and switched to profile: " .. newName)
                        self:SetText("")
                        if PCB.ApplyAll then PCB:ApplyAll() end
                    end
                end
                self:ClearFocus()
            end)
            -- Tag so the Create button can look it up
            if scrollContent then scrollContent._newProfileEditBox = editbox end
            
            return container
        end
        
        -- Helper function to add a dropdown
        local function AddLSMDropdown(parent, option, y)
            local LSM = PCB.LSM
            local label = option.label
            local dbKey = option.key
            local mediaType = option.mediaType
            if not LSM then
                local fallback = parent:CreateFontString(nil, "OVERLAY")
                fallback:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                fallback:SetPoint("TOPLEFT", 10, y)
                fallback:SetText(label .. ": LibSharedMedia not loaded")
                return fallback
            end

            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(400, 24)

            -- Label background (only if label is not empty)
            if label and label ~= "" then
                local labelBg = container:CreateTexture(nil, "BACKGROUND")
                labelBg:SetPoint("LEFT", -4, 0)
                labelBg:SetWidth(128)
                labelBg:SetHeight(24)
                labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)
            end

            local labelText = container:CreateFontString(nil, "OVERLAY")
            labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            labelText:SetPoint("LEFT", 0, 0)
            labelText:SetWidth(120)
            labelText:SetJustifyH("LEFT")
            labelText:SetText(label)

            container.labelText = labelText

            local dropdown = CreateFrame("Button", nil, container)
            dropdown:SetWidth(180)
            dropdown:SetHeight(24)
            dropdown:SetPoint("LEFT", 120, 0)

            local bg = dropdown:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.15, 0.15, 0.15, 1)

            local border = dropdown:CreateTexture(nil, "ARTWORK")
            border:SetPoint("TOPLEFT", 1, -1)
            border:SetPoint("BOTTOMRIGHT", -1, 1)
            border:SetColorTexture(0.25, 0.25, 0.25, 1)

            local text = dropdown:CreateFontString(nil, "OVERLAY")
            text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            text:SetPoint("LEFT", 8, 0)
            text:SetPoint("RIGHT", -20, 0)
            text:SetJustifyH("LEFT")
            text:SetTextColor(1, 1, 1, 1)

            local arrowBtn = CreateFrame("Button", nil, dropdown)
            arrowBtn:SetSize(16, 16)
            arrowBtn:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
            
            local arrowHighlight = arrowBtn:CreateTexture(nil, "HIGHLIGHT")
            arrowHighlight:SetAllPoints(arrowBtn)
            arrowHighlight:SetColorTexture(1, 1, 1, 0.2)

            -- Custom arrow - create textures manually
            local normal = arrowBtn:CreateTexture(nil, "ARTWORK")
            normal:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
            normal:SetSize(12, 12)
            normal:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
            normal:SetTexCoord(0, 1, 0, 1)
            arrowBtn:SetNormalTexture(normal)
            
            local pushed = arrowBtn:CreateTexture(nil, "ARTWORK")
            pushed:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
            pushed:SetSize(12, 12)
            pushed:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
            pushed:SetTexCoord(0, 1, 0, 1)
            arrowBtn:SetPushedTexture(pushed)

            dropdown:SetScript("OnEnter", function() border:SetColorTexture(0.35, 0.35, 0.35, 1) end)
            dropdown:SetScript("OnLeave", function() border:SetColorTexture(0.25, 0.25, 0.25, 1) end)

            -- Menu frame parented to UIParent so it can extend beyond scroll frame
            local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            menu:SetFrameStrata("TOOLTIP")
            menu:SetFrameLevel(1000)
            menu:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true, tileSize = 32, edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })
            menu:SetWidth(200)
            menu:Hide()
            
            -- Create scroll frame for menu
            local scrollFrame = CreateFrame("ScrollFrame", nil, menu)
            scrollFrame:SetPoint("TOPLEFT", 12, -12)
            scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12)
            
            local scrollChild = CreateFrame("Frame", nil, scrollFrame)
            scrollFrame:SetScrollChild(scrollChild)
            scrollChild:SetWidth(176)
            
            -- Enable mouse wheel scrolling
            menu:EnableMouseWheel(true)
            menu:SetScript("OnMouseWheel", function(self, delta)
                local current = scrollFrame:GetVerticalScroll()
                local maxScroll = scrollChild:GetHeight() - scrollFrame:GetHeight()
                if maxScroll > 0 then
                    scrollFrame:SetVerticalScroll(math.max(0, math.min(maxScroll, current - (delta * 20))))
                end
            end)
            
            local menuButtons = {}
            local maxVisibleItems = 7

            local function UpdateLSMDropdown()
                for _, btn in ipairs(menuButtons) do
                    btn:Hide()
                    btn:SetParent(nil)
                end
                menuButtons = {}
                
                local mediaList = LSM:List(mediaType) or {}
                
                -- For fonts, ensure DorisPP is always available (addon's built-in font)
                if mediaType == "font" then
                    local hasDoris = false
                    for _, name in ipairs(mediaList) do
                        if name == "DorisPP" then
                            hasDoris = true
                            break
                        end
                    end
                    if not hasDoris then
                        table.insert(mediaList, 1, "DorisPP")  -- Add to top of list
                    end
                    table.sort(mediaList)  -- Sort alphabetically
                end
                
                local currentValue = GetValue(PCB.db, dbKey) or "Blizzard"
                text:SetText(currentValue)
                
                local isTexture = (mediaType == "statusbar")
                local isFont = (mediaType == "font")
                local itemHeight = isTexture and 30 or 24
                
                for i, mediaName in ipairs(mediaList) do
                    local btn = CreateFrame("Button", nil, scrollChild)
                    btn:SetWidth(176)
                    btn:SetHeight(itemHeight)
                    btn:SetPoint("TOP", scrollChild, "TOP", 0, -(i-1) * itemHeight)
                    
                    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                    btnBg:SetAllPoints()
                    btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                    
                    if isTexture then
                        -- Texture preview bar
                        local texturePath = LSM:Fetch(mediaType, mediaName)
                        local previewBar = btn:CreateTexture(nil, "ARTWORK")
                        previewBar:SetPoint("TOPLEFT", 5, -5)
                        previewBar:SetPoint("TOPRIGHT", -5, -5)
                        previewBar:SetHeight(20)
                        previewBar:SetTexture(texturePath)
                        previewBar:SetVertexColor(0.3, 0.6, 1, 1)
                        
                        -- Font for the name overlaid on texture
                        local fontKey = GetValue(PCB.db, "fontKey") or "Friz Quadrata TT"
                        local fontPath = LSM:Fetch("font", fontKey)
                        local btnText = btn:CreateFontString(nil, "OVERLAY")
                        btnText:SetPoint("CENTER", btn, "CENTER", 0, 0)
                        btnText:SetFont(fontPath, 11)
                        btnText:SetText(mediaName)
                        btnText:SetTextColor(1, 1, 1, 1)
                    elseif isFont then
                        -- Font preview using the font itself
                        local fontPath = LSM:Fetch(mediaType, mediaName)
                        
                        -- Fallback to addon's built-in DorisPP font if not found
                        if not fontPath and mediaName == "DorisPP" then
                            fontPath = "Interface\\AddOns\\PhoenixCastBars\\Media\\DorisPP.ttf"
                        end
                        
                        local btnText = btn:CreateFontString(nil, "OVERLAY")
                        btnText:SetPoint("LEFT", 5, 0)
                        btnText:SetFont(fontPath, 12)
                        btnText:SetText(mediaName)
                        
                        if mediaName == currentValue then
                            btnText:SetTextColor(1, 0.82, 0, 1)
                        else
                            btnText:SetTextColor(1, 1, 1, 1)
                        end
                    else
                        -- Fallback for other media types
                        local btnText = btn:CreateFontString(nil, "OVERLAY")
                        btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                        btnText:SetPoint("LEFT", 5, 0)
                        btnText:SetText(mediaName)
                        
                        if mediaName == currentValue then
                            btnText:SetTextColor(1, 0.82, 0, 1)
                        else
                            btnText:SetTextColor(1, 1, 1, 1)
                        end
                    end
                    
                    btn:SetScript("OnEnter", function() btnBg:SetColorTexture(0.4, 0.4, 0.4, 1) end)
                    btn:SetScript("OnLeave", function() btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8) end)
                    btn:SetScript("OnClick", function()
                        SetValue(PCB.db, dbKey, mediaName)
                        text:SetText(mediaName)
                        menu:Hide()
                        activeMenus[menu] = nil
                        dropdownClickCatcher:Hide()
                        if PCB.ApplyAll then PCB:ApplyAll() end
                        UpdatePreview()
                    end)
                    
                    table.insert(menuButtons, btn)
                end
                
                -- Set scrollChild height based on content
                scrollChild:SetHeight(math.max(1, #mediaList * itemHeight))
                
                -- Set menu height based on visible items
                local visibleItems = math.min(maxVisibleItems, #mediaList)
                menu:SetHeight(visibleItems * itemHeight + 24)
                
                -- Reset scroll position
                scrollFrame:SetVerticalScroll(0)
            end
            
            menu._arrowBtn = arrowBtn

            local function ToggleMenu()
                UpdateLSMDropdown()
                if menu:IsShown() then
                    menu:Hide()
                    activeMenus[menu] = nil
                    dropdownClickCatcher:Hide()
                    UpdateArrow(arrowBtn, false)
                else
                    CloseAllMenus()
                    menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -4)
                    menu:Show()
                    activeMenus[menu] = true
                    UpdateArrow(arrowBtn, true)
                    -- Push click catcher to top of ESC stack (only if not already present)
                    local alreadyInList = false
                    for i = 1, #UISpecialFrames do
                        if UISpecialFrames[i] == "PCB_DropdownClickCatcher" then
                            alreadyInList = true
                            break
                        end
                    end
                    if not alreadyInList then
                        tinsert(UISpecialFrames, "PCB_DropdownClickCatcher")
                    end
                    dropdownClickCatcher:Show()
                end
            end
            
            dropdown:SetScript("OnClick", ToggleMenu)
            arrowBtn:SetScript("OnClick", ToggleMenu)

            UpdateLSMDropdown()

            -- expose internals for external control
            container.dropdown = dropdown
            container.arrowBtn = arrowBtn
            container.text = text
            container.option = option

            -- Apply disabledIf if present
            if option.disabledIf then
                local isDisabled = false
                local ok, res = pcall(option.disabledIf)
                if ok then isDisabled = res end
                dropdown:EnableMouse(not isDisabled)
                arrowBtn:EnableMouse(not isDisabled)
                dropdown:SetAlpha(isDisabled and 0.5 or 1)
                text:SetTextColor(isDisabled and 0.5 or 1, isDisabled and 0.5 or 1, isDisabled and 0.5 or 1, 1)
            end

            return container
        end
        
        -- Helper function to add outline dropdown
        local function AddOutlineDropdown(parent, option, y)
            local outlines = {
                { name = "Outline", value = "OUTLINE" },
                { name = "Thick Outline", value = "THICKOUTLINE" },
                { name = "None", value = "" },
            }
            local label = option.label
            local dbKey = option.key

            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(400, 24)

            -- Label background (only if label is not empty)
            if label and label ~= "" then
                local labelBg = container:CreateTexture(nil, "BACKGROUND")
                labelBg:SetPoint("LEFT", -4, 0)
                labelBg:SetWidth(128)
                labelBg:SetHeight(24)
                labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)
            end

            local labelText = container:CreateFontString(nil, "OVERLAY")
            labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            labelText:SetPoint("LEFT", 0, 0)
            labelText:SetWidth(120)
            labelText:SetJustifyH("LEFT")
            labelText:SetText(label)

            local dropdown = CreateFrame("Button", nil, container)
            dropdown:SetWidth(180)
            dropdown:SetHeight(24)
            dropdown:SetPoint("LEFT", 120, 0)

            local bg = dropdown:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.15, 0.15, 0.15, 1)

            local border = dropdown:CreateTexture(nil, "ARTWORK")
            border:SetPoint("TOPLEFT", 1, -1)
            border:SetPoint("BOTTOMRIGHT", -1, 1)
            border:SetColorTexture(0.25, 0.25, 0.25, 1)

            local text = dropdown:CreateFontString(nil, "OVERLAY")
            text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
            text:SetPoint("LEFT", 8, 0)
            text:SetPoint("RIGHT", -20, 0)
            text:SetJustifyH("LEFT")
            text:SetTextColor(1, 1, 1, 1)

            local arrowBtn = CreateFrame("Button", nil, dropdown)
            arrowBtn:SetSize(16, 16)
            arrowBtn:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
            
            local arrowHighlight = arrowBtn:CreateTexture(nil, "HIGHLIGHT")
            arrowHighlight:SetAllPoints(arrowBtn)
            arrowHighlight:SetColorTexture(1, 1, 1, 0.2)

            -- Custom arrow - create textures manually
            local normal = arrowBtn:CreateTexture(nil, "ARTWORK")
            normal:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
            normal:SetSize(12, 12)
            normal:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
            normal:SetTexCoord(0, 1, 0, 1)
            arrowBtn:SetNormalTexture(normal)
            
            local pushed = arrowBtn:CreateTexture(nil, "ARTWORK")
            pushed:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
            pushed:SetSize(12, 12)
            pushed:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
            pushed:SetTexCoord(0, 1, 0, 1)
            arrowBtn:SetPushedTexture(pushed)

            dropdown:SetScript("OnEnter", function() border:SetColorTexture(0.35, 0.35, 0.35, 1) end)
            dropdown:SetScript("OnLeave", function() border:SetColorTexture(0.25, 0.25, 0.25, 1) end)
            
            -- Menu frame parented to UIParent so it can extend beyond scroll frame
            local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            menu:SetFrameStrata("TOOLTIP")
            menu:SetFrameLevel(1000)
            menu:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true, tileSize = 32, edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })
            menu:SetWidth(200)
            menu:Hide()
            
            local menuButtons = {}
            
            local function UpdateOutlineDropdown()
                for _, btn in ipairs(menuButtons) do
                    btn:Hide()
                    btn:SetParent(nil)
                end
                menuButtons = {}
                
                local currentValue = GetValue(PCB.db, dbKey) or "OUTLINE"
                
                -- Find matching name for display
                local displayName = "Outline"
                for _, outline in ipairs(outlines) do
                    if outline.value == currentValue then
                        displayName = outline.name
                        break
                    end
                end
                text:SetText(displayName)
                
                for i, outline in ipairs(outlines) do
                    local btn = CreateFrame("Button", nil, menu)
                    btn:SetWidth(180)
                    btn:SetHeight(20)
                    btn:SetPoint("TOP", menu, "TOP", 0, -10 - (i-1) * 20)
                    
                    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                    btnBg:SetAllPoints()
                    btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                    
                    local btnText = btn:CreateFontString(nil, "OVERLAY")
                    btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                    btnText:SetPoint("LEFT", 5, 0)
                    btnText:SetText(outline.name)
                    
                    if outline.value == currentValue then
                        btnText:SetTextColor(1, 0.82, 0, 1)
                    else
                        btnText:SetTextColor(1, 1, 1, 1)
                    end
                    
                    btn:SetScript("OnEnter", function() btnBg:SetColorTexture(0.4, 0.4, 0.4, 1) end)
                    btn:SetScript("OnLeave", function() btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8) end)
                    btn:SetScript("OnClick", function()
                        SetValue(PCB.db, dbKey, outline.value)
                        text:SetText(outline.name)
                        menu:Hide()
                        activeMenus[menu] = nil
                        dropdownClickCatcher:Hide()
                        if PCB.ApplyAll then PCB:ApplyAll() end
                        UpdatePreview()
                    end)
                    
                    table.insert(menuButtons, btn)
                end
                
                menu:SetHeight(math.max(40, 20 + #outlines * 20))
            end
            
            menu._arrowBtn = arrowBtn

            local function ToggleMenu()
                UpdateOutlineDropdown()
                if menu:IsShown() then
                    menu:Hide()
                    activeMenus[menu] = nil
                    dropdownClickCatcher:Hide()
                    UpdateArrow(arrowBtn, false)
                else
                    CloseAllMenus()
                    menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -4)
                    menu:Show()
                    activeMenus[menu] = true
                    UpdateArrow(arrowBtn, true)
                    -- Push click catcher to top of ESC stack (only if not already present)
                    local alreadyInList = false
                    for i = 1, #UISpecialFrames do
                        if UISpecialFrames[i] == "PCB_DropdownClickCatcher" then
                            alreadyInList = true
                            break
                        end
                    end
                    if not alreadyInList then
                        tinsert(UISpecialFrames, "PCB_DropdownClickCatcher")
                    end
                    dropdownClickCatcher:Show()
                end
            end
            
            dropdown:SetScript("OnClick", ToggleMenu)
            arrowBtn:SetScript("OnClick", ToggleMenu)
            
            UpdateOutlineDropdown()

            -- expose internals for external control
            container.dropdown = dropdown
            container.arrowBtn = arrowBtn
            container.text = text
            container.option = option

            -- Apply disabledIf if present
            if option.disabledIf then
                local isDisabled = false
                local ok, res = pcall(option.disabledIf)
                if ok then isDisabled = res end
                dropdown:EnableMouse(not isDisabled)
                arrowBtn:EnableMouse(not isDisabled)
                dropdown:SetAlpha(isDisabled and 0.5 or 1)
                text:SetTextColor(isDisabled and 0.5 or 1, isDisabled and 0.5 or 1, isDisabled and 0.5 or 1, 1)
            end

            return container
        end
        
        -- Helper function to add spacing
        local function AddSpace(parent, y)
            -- Just return a dummy frame for tracking
            local space = CreateFrame("Frame", nil, parent)
            space:SetHeight(1)
            return space
        end
        
        -- Helper function to add a 2-column grid layout for mixed widgets
        local function AddTwoColumnGrid(parent, y, items)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", 10, y)
            container:SetSize(480, 100)  -- Will be adjusted based on content
            
            -- Dynamic 2-column flow layout (fixes overlap for tall widgets like sliders/dropdowns)
            -- We can't use a fixed row height because some widgets (slider/dropdown) are taller than checkboxes.
            local yCursor = 0          -- Negative values move down
            local col = 0              -- 0 = left, 1 = right
            local rowHeight = 0        -- Max height of widgets in current row

            for i, item in ipairs(items) do
                -- Sliders are full-width (they look bad paired with a right-column checkbox and can overlap labels)
                local fullWidth = (item.type == "slider")

                -- If we're about to place a full-width widget but we're currently in the right column,
                -- finalize the current row first.
                if fullWidth and col == 1 then
                    yCursor = yCursor - (rowHeight + 4)
                    rowHeight = 0
                    col = 0
                end

                local xOffset = col * 240  -- 240px spacing between columns
                local yOffset = yCursor
	            local extraTop = 0
	            if item.type == "slider" then
	                -- Sliders have label/value text above the thumb *and* benefit from an additional visual gap
	                -- from the checkbox block above. Treat this as a top padding for the entire slider row.
	                extraTop = 28
	                yOffset = yCursor - extraTop
	            end
                
                                if item.type == "space" then
                    -- Spacer row (for manual vertical padding in option lists)
                    local h = tonumber(item.height) or 12
                    rowHeight = math.max(rowHeight, h)
                elseif item.type == "lsmdropdown" then
                    -- Create LSM dropdown
                    local LSM = PCB.LSM
                    if LSM then
                        local label = container:CreateFontString(nil, "OVERLAY")
                        label:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                        label:SetPoint("TOPLEFT", xOffset, yOffset)
                        label:SetWidth(220)
                        label:SetText(item.label)
                        
                        local dropdown = CreateFrame("Button", nil, container)
                        dropdown:SetWidth(220)
                        dropdown:SetHeight(24)
                        dropdown:SetPoint("TOPLEFT", xOffset, yOffset - 20)
                        
                        -- Background
                        local bg = dropdown:CreateTexture(nil, "BACKGROUND")
                        bg:SetAllPoints()
                        bg:SetColorTexture(0.15, 0.15, 0.15, 1)
                        
                        -- Border
                        local border = dropdown:CreateTexture(nil, "ARTWORK")
                        border:SetPoint("TOPLEFT", 1, -1)
                        border:SetPoint("BOTTOMRIGHT", -1, 1)
                        border:SetColorTexture(0.25, 0.25, 0.25, 1)
                        
                        -- Text
                        local text = dropdown:CreateFontString(nil, "OVERLAY")
                        text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                        text:SetPoint("LEFT", 8, 0)
                        text:SetPoint("RIGHT", -20, 0)
                        text:SetJustifyH("LEFT")
                        text:SetTextColor(1, 1, 1, 1)
                        
                        -- Arrow button
                        local arrowBtn = CreateFrame("Button", nil, dropdown)
                        arrowBtn:SetSize(16, 16)
                        arrowBtn:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
                        
                        local arrowHighlight = arrowBtn:CreateTexture(nil, "HIGHLIGHT")
                        arrowHighlight:SetAllPoints(arrowBtn)
                        arrowHighlight:SetColorTexture(1, 1, 1, 0.2)

                        -- Custom arrow - create textures manually
                        local normal = arrowBtn:CreateTexture(nil, "ARTWORK")
                        normal:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
                        normal:SetSize(12, 12)
                        normal:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                        normal:SetTexCoord(0, 1, 0, 1)
                        arrowBtn:SetNormalTexture(normal)
                        
                        local pushed = arrowBtn:CreateTexture(nil, "ARTWORK")
                        pushed:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
                        pushed:SetSize(12, 12)
                        pushed:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                        pushed:SetTexCoord(0, 1, 0, 1)
                        arrowBtn:SetPushedTexture(pushed)
                        
                        -- Highlight
                        dropdown:SetScript("OnEnter", function()
                            border:SetColorTexture(0.35, 0.35, 0.35, 1)
                        end)
                        dropdown:SetScript("OnLeave", function()
                            border:SetColorTexture(0.25, 0.25, 0.25, 1)
                        end)
                        
                        -- Get current value
                        local currentValue = GetValue(PCB.db, item.key)
                        local mediaList = LSM:List(item.mediaType)
                        
                        -- Find current selection
                        for _, mediaName in ipairs(mediaList) do
                            if currentValue == mediaName then
                                text:SetText(mediaName)
                                break
                            end
                        end
                        
                        if text:GetText() == "" then
                            text:SetText(mediaList[1] or "None")
                        end
                        
                        -- Create menu for dropdown
                        local menu = CreateFrame("ScrollFrame", nil, dropdown)
                        menu:SetFrameStrata("HIGH")
                        menu:SetSize(220, 240)
                        menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -4)
                        menu:Hide()
                        
                        local menuChild = CreateFrame("Frame", nil, menu)
                        menuChild:SetWidth(200)
                        menu:SetScrollChild(menuChild)
                        
                        local menuBg = menu:CreateTexture(nil, "BACKGROUND")
                        menuBg:SetAllPoints(menu)
                        menuBg:SetColorTexture(0.1, 0.1, 0.1, 0.95)
                        
                        local menuButtons = {}
                        
                        local function UpdateLSMDropdown()
                            -- Clear old buttons
                            for _, btn in ipairs(menuButtons) do
                                btn:Hide()
                                btn:SetParent(nil)
                            end
                            menuButtons = {}
                            
                            local mediaList = LSM:List(item.mediaType)
                            local currentValue = GetValue(PCB.db, item.key)
                            
                            local itemHeight = (item.mediaType == "statusbar") and 30 or 24
                            local totalHeight = #mediaList * itemHeight
                            menuChild:SetHeight(math.max(totalHeight, 240))
                            
                            for i, mediaName in ipairs(mediaList) do
                                local btn = CreateFrame("Button", nil, menuChild)
                                btn:SetWidth(200)
                                btn:SetHeight(itemHeight)
                                btn:SetPoint("TOP", menuChild, "TOP", 0, -(i-1) * itemHeight)
                                
                                if item.mediaType == "statusbar" then
                                    -- Texture preview
                                    local preview = btn:CreateTexture(nil, "ARTWORK")
                                    preview:SetPoint("TOPLEFT", 5, -5)
                                    preview:SetPoint("BOTTOMRIGHT", -5, 5)
                                    preview:SetTexture(LSM:Fetch("statusbar", mediaName))
                                    preview:SetVertexColor(0.3, 0.6, 1)
                                    
                                    local previewText = btn:CreateFontString(nil, "OVERLAY")
                                    previewText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                                    previewText:SetPoint("CENTER", btn, "CENTER")
                                    previewText:SetText(mediaName)
                                    previewText:SetTextColor(1, 1, 1, 1)
                                elseif item.mediaType == "font" then
                                    -- Font preview
                                    local fontPath = LSM:Fetch("font", mediaName)
                                    local fontText = btn:CreateFontString(nil, "OVERLAY")
                                    fontText:SetFont(fontPath, 12)
                                    fontText:SetPoint("LEFT", 10, 0)
                                    fontText:SetText(mediaName)
                                    fontText:SetTextColor(1, 1, 1, 1)
                                end
                                
                                -- Highlight
                                local highlight = btn:CreateTexture(nil, "BACKGROUND")
                                highlight:SetAllPoints()
                                if mediaName == currentValue then
                                    highlight:SetColorTexture(0.3, 0.5, 0.7, 0.5)
                                else
                                    highlight:SetColorTexture(0.2, 0.2, 0.2, 0.5)
                                end
                                
                                btn:SetScript("OnEnter", function()
                                    highlight:SetColorTexture(0.4, 0.6, 0.8, 0.5)
                                end)
                                btn:SetScript("OnLeave", function()
                                    if mediaName == GetValue(PCB.db, item.key) then
                                        highlight:SetColorTexture(0.3, 0.5, 0.7, 0.5)
                                    else
                                        highlight:SetColorTexture(0.2, 0.2, 0.2, 0.5)
                                    end
                                end)
                                
                                btn:SetScript("OnClick", function()
                                    SetValue(PCB.db, item.key, mediaName)
                                    text:SetText(mediaName)
                                    menu:Hide()
                                    activeMenus[menu] = nil
                                    dropdownClickCatcher:Hide()
                                    UpdateLSMDropdown()
                                    if PCB.ApplyAll then PCB:ApplyAll() end
                                end)
                                
                                table.insert(menuButtons, btn)
                            end
                        end
                        
                        menu._arrowBtn = arrowBtn

                        local function ToggleLSMMenu()
                            if menu:IsShown() then
                                menu:Hide()
                                activeMenus[menu] = nil
                                UpdateArrow(arrowBtn, false)
                            else
                                CloseAllMenus()
                                UpdateLSMDropdown()
                                menu:Show()
                                activeMenus[menu] = true
                                UpdateArrow(arrowBtn, true)
                            end
                        end
                        
                        dropdown:SetScript("OnClick", ToggleLSMMenu)
                        arrowBtn:SetScript("OnClick", ToggleLSMMenu)
                        
                        menu:EnableMouseWheel(true)
                        menu:SetScript("OnMouseWheel", function(self, delta)
                            local current = self:GetVerticalScroll()
                            local maxScroll = menuChild:GetHeight() - self:GetHeight()
                            local newScroll = math.max(0, math.min(maxScroll, current - (delta * 20)))
                            self:SetVerticalScroll(newScroll)
                        end)
                        
                        rowHeight = math.max(rowHeight, 70)
                    end
                    
                elseif item.type == "outlinedropdown" then
                    -- Create outline dropdown
                    local label = container:CreateFontString(nil, "OVERLAY")
                    label:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                    label:SetPoint("TOPLEFT", xOffset, yOffset)
                    label:SetWidth(220)
                    label:SetText(item.label)
                    
                    local dropdown = CreateFrame("Button", nil, container)
                    dropdown:SetWidth(220)
                    dropdown:SetHeight(24)
                    dropdown:SetPoint("TOPLEFT", xOffset, yOffset - 20)
                    
                    -- Background
                    local bg = dropdown:CreateTexture(nil, "BACKGROUND")
                    bg:SetAllPoints()
                    bg:SetColorTexture(0.15, 0.15, 0.15, 1)
                    
                    -- Border
                    local border = dropdown:CreateTexture(nil, "ARTWORK")
                    border:SetPoint("TOPLEFT", 1, -1)
                    border:SetPoint("BOTTOMRIGHT", -1, 1)
                    border:SetColorTexture(0.25, 0.25, 0.25, 1)
                    
                    -- Text
                    local text = dropdown:CreateFontString(nil, "OVERLAY")
                    text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                    text:SetPoint("LEFT", 8, 0)
                    text:SetPoint("RIGHT", -20, 0)
                    text:SetJustifyH("LEFT")
                    text:SetTextColor(1, 1, 1, 1)
                    
                    -- Arrow button
                    local arrowBtn = CreateFrame("Button", nil, dropdown)
                    arrowBtn:SetSize(16, 16)
                    arrowBtn:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
                    
                    local arrowHighlight = arrowBtn:CreateTexture(nil, "HIGHLIGHT")
                    arrowHighlight:SetAllPoints(arrowBtn)
                    arrowHighlight:SetColorTexture(1, 1, 1, 0.2)

                    -- Custom arrow - create textures manually
                    local normal = arrowBtn:CreateTexture(nil, "ARTWORK")
                    normal:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
                    normal:SetSize(12, 12)
                    normal:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                    normal:SetTexCoord(0, 1, 0, 1)
                    arrowBtn:SetNormalTexture(normal)
                    
                    local pushed = arrowBtn:CreateTexture(nil, "ARTWORK")
                    pushed:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
                    pushed:SetSize(12, 12)
                    pushed:SetPoint("CENTER", arrowBtn, "CENTER", 1, -3)
                    pushed:SetTexCoord(0, 1, 0, 1)
                    arrowBtn:SetPushedTexture(pushed)
                    
                    -- Highlight
                    dropdown:SetScript("OnEnter", function()
                        border:SetColorTexture(0.35, 0.35, 0.35, 1)
                    end)
                    dropdown:SetScript("OnLeave", function()
                        border:SetColorTexture(0.25, 0.25, 0.25, 1)
                    end)
                    
                    local outlineOptions = {"", "OUTLINE", "THICKOUTLINE"}
                    local outlineLabels = {"None", "Outline", "Thick Outline"}
                    
                    local currentValue = GetValue(PCB.db, item.key) or ""
                    for i, val in ipairs(outlineOptions) do
                        if val == currentValue then
                            text:SetText(outlineLabels[i])
                            break
                        end
                    end
                    
                    -- Create menu
                    local menu = CreateFrame("Frame", nil, dropdown)
                    menu:SetFrameStrata("HIGH")
                    menu:SetSize(220, 80)
                    menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -4)
                    menu:Hide()
                    
                    local menuBg = menu:CreateTexture(nil, "BACKGROUND")
                    menuBg:SetAllPoints(menu)
                    menuBg:SetColorTexture(0.1, 0.1, 0.1, 0.95)
                    
                    for i, val in ipairs(outlineOptions) do
                        local btn = CreateFrame("Button", nil, menu)
                        btn:SetWidth(200)
                        btn:SetHeight(24)
                        btn:SetPoint("TOP", menu, "TOP", 0, -4 - (i-1) * 24)
                        
                        local btnText = btn:CreateFontString(nil, "OVERLAY")
                        btnText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                        btnText:SetPoint("LEFT", 10, 0)
                        btnText:SetText(outlineLabels[i])
                        
                        local highlight = btn:CreateTexture(nil, "BACKGROUND")
                        highlight:SetAllPoints()
                        if val == currentValue then
                            highlight:SetColorTexture(0.3, 0.5, 0.7, 0.5)
                        else
                            highlight:SetColorTexture(0.2, 0.2, 0.2, 0.5)
                        end
                        
                        btn:SetScript("OnEnter", function()
                            highlight:SetColorTexture(0.4, 0.6, 0.8, 0.5)
                        end)
                        btn:SetScript("OnLeave", function()
                            if val == GetValue(PCB.db, item.key) then
                                highlight:SetColorTexture(0.3, 0.5, 0.7, 0.5)
                            else
                                highlight:SetColorTexture(0.2, 0.2, 0.2, 0.5)
                            end
                        end)
                        
                        btn:SetScript("OnClick", function()
                            SetValue(PCB.db, item.key, val)
                            text:SetText(outlineLabels[i])
                            menu:Hide()
                            activeMenus[menu] = nil
                            dropdownClickCatcher:Hide()
                            if PCB.ApplyAll then PCB:ApplyAll() end
                        end)
                    end
                    
                    menu._arrowBtn = arrowBtn

                    local function ToggleOutlineMenu()
                        if menu:IsShown() then
                            menu:Hide()
                            activeMenus[menu] = nil
                            UpdateArrow(arrowBtn, false)
                        else
                            CloseAllMenus()
                            menu:Show()
                            activeMenus[menu] = true
                            UpdateArrow(arrowBtn, true)
                        end
                    end
                    
                    dropdown:SetScript("OnClick", ToggleOutlineMenu)
                    arrowBtn:SetScript("OnClick", ToggleOutlineMenu)
                    
                    rowHeight = math.max(rowHeight, 70)
                    
                elseif item.type == "slider" then
                    -- Create slider
                    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
                    slider:SetWidth(220)
                    slider:SetHeight(20)
                    slider:SetPoint("TOPLEFT", xOffset, yOffset)
                    slider:SetMinMaxValues(item.min, item.max)
                    slider:SetValueStep(item.step)
                    slider:SetObeyStepOnDrag(true)
                    SkinSlider(slider)
                    
                    if slider.Low then slider.Low:SetText(tostring(item.min)) end
                    if slider.High then slider.High:SetText(tostring(item.max)) end
                    
                    local labelText = slider:CreateFontString(nil, "OVERLAY")
                    labelText:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                    labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 2)
                    labelText:SetText(item.label)
                    
                    -- Value input box
                    local valueBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
                    valueBox:SetAutoFocus(false)
                    valueBox:SetSize(36, 18)
                    valueBox:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 0)
                    valueBox:SetJustifyH("CENTER")
                    valueBox:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                    valueBox:SetFrameStrata(slider:GetFrameStrata())
                    valueBox:SetFrameLevel(slider:GetFrameLevel() + 1)
                    
                    local function FormatValue(v)
                        if item.step and item.step >= 1 then
                            return string.format("%.0f", v)
                        end
                        return string.format("%.2f", v)
                    end
                    
                    local function RoundToStep(v)
                        if not item.step or item.step <= 0 then return v end
                        return math.floor(v / item.step + 0.5) * item.step
                    end
                    
                    local function Clamp(v)
                        if v < item.min then return item.min end
                        if v > item.max then return item.max end
                        return v
                    end
                    
                    local function ApplyFromBox()
                        local n = tonumber(valueBox:GetText())
                        if not n then
                            valueBox:SetText(FormatValue(slider:GetValue() or item.min))
                            return
                        end
                        n = Clamp(RoundToStep(n))
                        slider:SetValue(n)
                        valueBox:ClearFocus()
                    end
                    
                    valueBox:SetScript("OnEnterPressed", ApplyFromBox)
                    valueBox:SetScript("OnEscapePressed", function(self)
                        self:SetText(FormatValue(slider:GetValue() or item.min))
                        self:ClearFocus()
                    end)
                    valueBox:SetScript("OnEditFocusLost", ApplyFromBox)
                    
                    local currentValue = GetValue(PCB.db, item.key) or item.min
                    slider:SetValue(currentValue)
                    valueBox:SetText(FormatValue(currentValue))
                    
                    slider:SetScript("OnValueChanged", function(self, value)
                        value = Clamp(RoundToStep(value))
                        SetValue(PCB.db, item.key, value)
                        if not valueBox:HasFocus() then
                            valueBox:SetText(FormatValue(value))
                        end
                        if PCB.ApplyAll then PCB:ApplyAll() end
                        -- Update preview immediately
                        if optionsFrame and optionsFrame.UpdatePreview then
                            optionsFrame:UpdatePreview()
                        end
                        -- Directly update icon position for iconOffsetX slider
                        if item.key and item.key:match("iconOffsetX$") and optionsFrame.preview and optionsFrame.preview.icon then
                            optionsFrame.preview.icon:ClearAllPoints()
                            optionsFrame.preview.icon:SetPoint("RIGHT", optionsFrame.preview.bar, "LEFT", value, 0)
                        end
                    end)
                    
                    rowHeight = math.max(rowHeight, 70 + extraTop)
                    
                elseif item.type == "checkbox" then
                    -- Create checkbox
                    local cb = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
                    cb:SetPoint("TOPLEFT", xOffset, yOffset)
                    SkinCheckbox(cb)
                    
                    -- Label background
                    local labelBg = cb:CreateTexture(nil, "BACKGROUND")
                    labelBg:SetPoint("LEFT", cb, "RIGHT", 1, 0)
                    labelBg:SetSize(200, 20)
                    labelBg:SetColorTexture(0.08, 0.08, 0.12, 1)
                    
                    local text = cb:CreateFontString(nil, "OVERLAY")
                    text:SetFont(LABEL_FONT, LABEL_SIZE, LABEL_FLAGS)
                    text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
                    text:SetText(item.label)
                    
                    cb:SetChecked(GetValue(PCB.db, item.key) or false)
                    cb:SetScript("OnClick", function(self)
                        SetValue(PCB.db, item.key, self:GetChecked())
                        if PCB.ApplyAll then PCB:ApplyAll() end
                        if optionsFrame and optionsFrame.UpdateContent then optionsFrame.UpdateContent(selectedCategory) end
                    end)
                    
                    rowHeight = math.max(rowHeight, 20) -- Reduce checkbox row height
                end

                -- Advance the 2-column flow layout.
                -- (rowHeight has already been updated by the widget creation blocks above)
                if fullWidth then
                    -- Full-width widgets always consume a full row.
                    yCursor = yCursor - (rowHeight + 4)
                    rowHeight = 0
                    col = 0
                else
                    if col == 1 then
                        -- Completed the right column -> advance to next row.
                        yCursor = yCursor - (rowHeight + 4)
                        rowHeight = 0
                        col = 0
                    else
                        -- Next item goes to the right column.
                        col = 1
                    end
                end

            end

            -- If the last row only had a left-column item, finalize it.
            if col == 1 then
                yCursor = yCursor - (rowHeight + 4)
            end

            container:SetHeight((-yCursor) + 10)
            
            return container
        end
        
        -- =====================================================================
        -- Category Rendering
        -- =====================================================================
        -- Rebuilds the right-hand panel based on the selected category
        local function UpdateContent(categoryKey)
            -- Clear previous content widgets
            for _, widget in ipairs(optionsFrame.contentWidgets) do
                if widget.Hide then
                    widget:Hide()
                    widget:SetParent(nil)
                end
            end
            optionsFrame.contentWidgets = {}
            
            selectedCategory = categoryKey
            PCB.Options.selectedCategory = categoryKey
            local category = categories[categoryKey]
            
            if category then
                -- Add options for this category
                local y = -10
                local opts = category.options
                local i = 1
                while i <= #opts do
                    local option = opts[i]
                    local widget

                    -- Evaluate visibleIf if provided; skip this option entirely if it returns false
                    local show = true
                    if option.visibleIf then
                        local ok, val = pcall(option.visibleIf)
                        if ok then show = val else show = false end
                    end

                    -- Inline checkbox + dropdown: if this option is a checkbox and the next option
                    -- is an lsm/outline dropdown with an empty label, render them on one row.
                    local inlined = false
                    local nextOpt = opts[i+1]
                    if show and option.type == "checkbox" and nextOpt and (nextOpt.type == "lsmdropdown" or nextOpt.type == "outlinedropdown") and (nextOpt.label == nil or nextOpt.label == "") then
                        -- Evaluate visibility of nextOpt as well
                        local nextShow = true
                        if nextOpt.visibleIf then
                            local ok2, val2 = pcall(nextOpt.visibleIf)
                            if ok2 then nextShow = val2 else nextShow = false end
                        end
                        if nextShow then
                            -- Create checkbox (returns the CheckButton)
                            local cb = AddCheckbox(scrollContent, option.label, option.key, y, option.isProfileMode, option.tooltip)
                            widget = cb
                            table.insert(optionsFrame.contentWidgets, widget)

                            -- Create inline dropdown using existing helper, then reposition and hide its label
                            local dropdownContainer
                            if nextOpt.type == "lsmdropdown" then
                                dropdownContainer = AddLSMDropdown(scrollContent, nextOpt, y)
                            else
                                dropdownContainer = AddOutlineDropdown(scrollContent, nextOpt, y)
                            end
                            -- Position the dropdown to the right of the checkbox
                            dropdownContainer:ClearAllPoints()
                            dropdownContainer:SetPoint("TOPLEFT", cb, "TOPRIGHT", 100, 0)
                            if dropdownContainer.labelText then dropdownContainer.labelText:Hide() end
                            table.insert(optionsFrame.contentWidgets, dropdownContainer)

                            -- Advance past the next option since we've handled it inline
                            inlined = true
                            i = i + 2
                            y = y - 35
                        else
                            -- nextOpt not shown; fall through to normal checkbox handling
                        end
                    end

                    if not inlined then
                        if not show then
                            -- skip creating this widget and do not advance y
                        else
                        if option.type == "description" then
                            widget = AddDescription(scrollContent, option.text, y)
                            y = y - (widget:GetHeight() + 10)
                        elseif option.type == "label" then
                            widget = AddLabel(scrollContent, option.text, y, option.getValue)
                            y = y - 25
                        elseif option.type == "button" then
                            widget = AddButton(scrollContent, option.label, y, option.onClick)
                            y = y - 35
                        elseif option.type == "editbox" then
                            widget = AddEditBox(scrollContent, option.label, y, option.placeholder)
                            y = y - 35
                        elseif option.type == "dropdown" then
                            widget = AddDropdown(scrollContent, option.label, y, option.key)
                            -- If this is the "Existing Profiles" dropdown, disable it when spec profiles are enabled
                            if option.key == "existingProfile" then
                                local isSpecMode = PCB and PCB.GetProfileMode and PCB:GetProfileMode() == "spec"
                                if widget and widget.dropdown then
                                    widget.dropdown:SetEnabled(not isSpecMode)
                                    if isSpecMode then
                                        widget.dropdown:SetAlpha(0.5)
                                    else
                                        widget.dropdown:SetAlpha(1.0)
                                    end
                                end
                            end
                            y = y - 35
                        elseif option.type == "specdropdown" then
                            -- Only show spec dropdowns when spec profile mode is enabled
                            local isSpecMode = PCB and PCB.GetProfileMode and PCB:GetProfileMode() == "spec"
                            if isSpecMode then
                                widget = AddSpecDropdown(scrollContent, option.specIndex, y)
                                -- Only increment y if the spec exists for this class
                                if widget then
                                    y = y - 35
                                end
                            end
                        elseif option.type == "lsmdropdown" then
                            widget = AddLSMDropdown(scrollContent, option, y)
                            y = y - 35
                        elseif option.type == "outlinedropdown" then
                            widget = AddOutlineDropdown(scrollContent, option, y)
                            y = y - 35
                        elseif option.type == "checkboxpair" then
                            widget = AddCheckboxPair(scrollContent, option.label1, option.key1, option.label2, option.key2, y)
                            y = y - 35
                        elseif option.type == "checkboxbutton" then
                            widget = AddCheckboxButton(scrollContent, option.label, option.key, option.buttonLabel, option.onClick, y)
                            y = y - 35
                        elseif option.type == "space" then
                            widget = AddSpace(scrollContent, y)
                            y = y - 15
                        elseif option.type == "slidergrid" then
                            widget = AddSliderGrid(scrollContent, y, option.sliders)
                            y = y - (widget:GetHeight() + 10)
                        elseif option.type == "twocolumngrid" then
                            widget = AddTwoColumnGrid(scrollContent, y, option.items)
                            y = y - (widget:GetHeight() + 10)
                        elseif option.type == "slider" then
                            widget = AddSlider(scrollContent, option.label, option.key, y, option.min, option.max, option.step)
                            y = y - 65
                        elseif option.type == "colorpicker" then
                            widget = AddColorPicker(scrollContent, option.label, option.key, y)
                            y = y - 40
                        elseif option.type == "colorpickergrid" then
                            widget = AddColorPickerGrid(scrollContent, y, option.pickers)
                            y = y - (widget:GetHeight() + 10)
                        elseif option.type == "simpledropdown" then
                            widget = AddSimpleDropdown(scrollContent, option.label, option.key, option.values, y)
                            y = y - 35
                        elseif option.type == "checkbox" then
                            widget = AddCheckbox(scrollContent, option.label, option.key, y, option.isProfileMode, option.tooltip)
                            y = y - 35
                        end
                        end
                        if widget then
                            table.insert(optionsFrame.contentWidgets, widget)
                        end
                        i = i + 1
                    end
                end
                
                -- Set scroll content height dynamically based on content
                local contentHeight = math.abs(y)
                scrollContent:SetHeight(contentHeight)
                scrollFrame:SetVerticalScroll(0)
                
                -- Show/hide preview based on category (hide only on profiles)
                if selectedCategory == "profiles" then
                    if optionsFrame.preview then optionsFrame.preview.container:Hide() end
                    scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -10)
                else
                    if optionsFrame.preview then optionsFrame.preview.container:Show() end
                    scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -50)
                    -- Update preview for all categories (general uses player bar for preview)
                    UpdatePreview()
                end
            end
        end
        
        -- Create category buttons in sidebar (in specific order)
        -- Expose UpdateContent on the optionsFrame so other handlers can trigger a refresh
        optionsFrame.UpdateContent = UpdateContent
        local categoryOrder = {"general", "player", "target", "focus", "gcd", "uninterruptible", "profiles"}
        local catY = -10
        for _, catKey in ipairs(categoryOrder) do
            local catData = categories[catKey]
            if catData then
                local btn = CreateFrame("Button", nil, sidebar)
                btn:SetWidth(130)
                btn:SetHeight(25)
                btn:SetPoint("TOP", sidebar, "TOP", 0, catY)  -- Changed to TOP for centering
                
                -- Background for category button
                local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                btnBg:SetAllPoints(btn)
                btnBg:SetColorTexture(0.08, 0.08, 0.12, 1)
                btn.__bg = btnBg
                
                -- Create FontString manually
                local btnText = btn:CreateFontString(nil, "OVERLAY")
                btnText:SetFont(CATEGORY_FONT, 13, CATEGORY_FLAGS)
                btnText:SetPoint("CENTER", btn, "CENTER", 0, 0)  -- Changed to CENTER
                btnText:SetText(catData.name)
                btnText:SetTextColor(
                    PCB.COLORS.PHOENIX_BLUE[1],
                    PCB.COLORS.PHOENIX_BLUE[2],
                    PCB.COLORS.PHOENIX_BLUE[3]
                )
                btn.__text = btnText
                
                btn:SetScript("OnEnter", function()
                    if selectedCategory ~= catKey then
                        btnText:SetTextColor(
                            PCB.COLORS.PHOENIX_ORANGE[1] * 0.7,
                            PCB.COLORS.PHOENIX_ORANGE[2] * 0.7,
                            PCB.COLORS.PHOENIX_ORANGE[3] * 0.7
                        )
                    end
                end)
                
                btn:SetScript("OnLeave", function()
                    if selectedCategory == catKey then
                        btnText:SetTextColor(
                            PCB.COLORS.PHOENIX_ORANGE[1],
                            PCB.COLORS.PHOENIX_ORANGE[2],
                            PCB.COLORS.PHOENIX_ORANGE[3]
                        )
                    else
                        btnText:SetTextColor(
                            PCB.COLORS.PHOENIX_BLUE[1],
                            PCB.COLORS.PHOENIX_BLUE[2],
                            PCB.COLORS.PHOENIX_BLUE[3]
                        )
                    end
                end)
                
                btn:SetScript("OnClick", function()
                    UpdateContent(catKey)
                    -- Update button text colors
                    for btnKey, btnRef in pairs(optionsFrame.categoryButtons) do
                        if btnKey == catKey then
                            btnRef.btn.__text:SetTextColor(
                                PCB.COLORS.PHOENIX_ORANGE[1],
                                PCB.COLORS.PHOENIX_ORANGE[2],
                                PCB.COLORS.PHOENIX_ORANGE[3]
                            )
                        else
                            btnRef.btn.__text:SetTextColor(
                                PCB.COLORS.PHOENIX_BLUE[1],
                                PCB.COLORS.PHOENIX_BLUE[2],
                                PCB.COLORS.PHOENIX_BLUE[3]
                            )
                        end
                    end
                end)
                
                optionsFrame.categoryButtons[catKey] = { btn = btn }
                
                catY = catY - 30
            end
        end
        
        -- Load initial category
        UpdateContent("general")
        UpdatePreview()
        
        -- Highlight the initial selected button (safely)
        if optionsFrame.categoryButtons and optionsFrame.categoryButtons.general then
            optionsFrame.categoryButtons.general.btn.__text:SetTextColor(
                PCB.COLORS.PHOENIX_ORANGE[1],
                PCB.COLORS.PHOENIX_ORANGE[2],
                PCB.COLORS.PHOENIX_ORANGE[3]
            )
        end
    end
    
    -- Clear any existing keyboard focus before showing
    -- This prevents the frame from stealing input from game bindings
    local focus = GetCurrentKeyBoardFocus()
    if focus then
        focus:ClearFocus()
    end

    optionsFrame:Show()
end
