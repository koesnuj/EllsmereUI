-- PhoenixCastBars - UpdateCheck (Retail 12.x+)
-- Version broadcast + changelog popup container

local ADDON_NAME, PCB = ...
PCB.UpdateCheck = PCB.UpdateCheck or {}
local UC = PCB.UpdateCheck

-- =====================================================================
-- Configuration
-- =====================================================================

UC.PREFIX = "PHX_PCB"
local BROADCAST_MIN_INTERVAL = 300
local LOGIN_GRACE = 10

UC._lastBroadcast = 0
UC._highestSeen = nil
UC._notified = false
UC._inited = false
UC._popupQueued = false
UC._frame = nil
UC._window = nil

-- =====================================================================
-- Hardcoded Changelog Table
-- =====================================================================

UC.ChangeLogs = {
    ["0.4.9"] = [[
• Added interrupt shield icon support on the target cast bar — displays Blizzard's interrupt shield graphic when a cast cannot be interrupted
• Cast bar now turns red when a target's cast is uninterruptible, giving an immediate at-a-glance warning
• Shield icon and spell icon now correctly swap in sync with the native TargetFrameSpellBar interrupt state
• Fixed stale interrupt state not being cleared between casts
• Refactored bar colour pipeline — channel and cast colour paths are now cleanly separated
    ]],
    ["0.4.8"] = [[
• Fixed GCD bar error (UnitCastingInfo no longer called on invalid unit)
• Fixed latency tracking error with UNIT_SPELLCAST_SENT event parameters
• Improved castGUID validation to prevent "table index is secret" errors
    ]],
    ["0.4.7"] = [[
• Fixed sytanx error in 0.4.6 changelog that caused the addon to break. Apologies for the inconvenience!
    ]],
    ["0.4.6"] = [[
• Improved internal cast timing tracking  
• Fixed spark visibility default logic  
• Added safe SavedVariables path helpers (GetValue / SetValue)  
• Improved options panel stability  
• Minor cleanup and structural refinements  
    ]],
    ["0.4.5"] = [[
• Full and accurate Empower spell support
• Rewritten GCD bar (no more flicker or misfires)
• Fixed and improved Latency / Safe Zone scaling
• Dropdown ESC behavior fixed
• Cleaner event handling and performance improvements
• UI and texture layering fixes
]],
}

-- =====================================================================
-- SavedVariables
-- =====================================================================

local function InitDB()
    PhoenixCastBarsDB = PhoenixCastBarsDB or {}
    PhoenixCastBarsDB.dismissedVersions = PhoenixCastBarsDB.dismissedVersions or {}
end

local function IsDismissed(version)
    return PhoenixCastBarsDB.dismissedVersions[version]
end

local function DismissVersion(version)
    PhoenixCastBarsDB.dismissedVersions[version] = true
end

-- =====================================================================
-- Version Utilities
-- =====================================================================

local function ParseVersion(v)
    if type(v) ~= "string" then return nil end
    local a,b,c = v:match("^(%d+)%.(%d+)%.(%d+)$")
    if not a then return nil end
    return tonumber(a), tonumber(b), tonumber(c)
end

local function IsNewer(remote, localv)
    local ra, rb, rc = ParseVersion(remote)
    local la, lb, lc = ParseVersion(localv)
    if not ra or not la then return false end

    if ra ~= la then return ra > la end
    if rb ~= lb then return rb > lb end
    return rc > lc
end

local function GetLatestVersion()
    local latest = nil
    for version in pairs(UC.ChangeLogs) do
        if not latest or IsNewer(version, latest) then
            latest = version
        end
    end
    return latest or "0.0.0"
end

local function GetSortedVersions()
    local versions = {}
    for version in pairs(UC.ChangeLogs) do
        table.insert(versions, version)
    end
    table.sort(versions, function(a, b)
        return IsNewer(a, b)
    end)
    return versions
end

local function GetVersionIndex(version, sortedVersions)
    for i, v in ipairs(sortedVersions) do
        if v == version then
            return i
        end
    end
    return nil
end

-- =====================================================================
-- Download Link Window
-- =====================================================================

function UC:ShowDownloadLink()
    local URL = "https://www.curseforge.com/wow/addons/phoenixcastbars"

    if self._window then
        self._window:Hide()
    end

    if self._downloadFrame then
        local f = self._downloadFrame
        f:Show()
        f.editBox:SetText(URL)
        f.editBox:HighlightText()
        f.editBox:SetFocus()
        f.statusText:SetText("Press Ctrl+C to copy")
        return
    end

    local f = CreateFrame("Frame", "PhoenixCastBarsDownloadFrame", UIParent, "BackdropTemplate")
    f:SetSize(460, 170)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("Download PhoenixCastBars")

    local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    editBox:SetPoint("TOPLEFT", 30, -55)
    editBox:SetPoint("TOPRIGHT", -30, -55)
    editBox:SetHeight(30)
    editBox:SetAutoFocus(true)
    editBox:SetText(URL)
    editBox:SetCursorPosition(0)
    editBox:SetScript("OnEscapePressed", function() f:Hide() end)

    f.editBox = editBox

    local statusText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("TOP", editBox, "BOTTOM", 0, -8)
    statusText:SetText("Press Ctrl+C to copy")
    f.statusText = statusText

    local copyBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    copyBtn:SetSize(110, 24)
    copyBtn:SetPoint("BOTTOMLEFT", 60, 25)
    copyBtn:SetText("Copy")
    copyBtn:SetScript("OnClick", function()
        editBox:HighlightText()
        editBox:SetFocus()
        statusText:SetText("|cff00ff00Ready to copy! Press Ctrl+C|r")
        C_Timer.After(2.5, function()
            if f:IsShown() then
                statusText:SetText("Press Ctrl+C to copy")
            end
        end)
    end)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(110, 24)
    closeBtn:SetPoint("BOTTOMRIGHT", -60, 25)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    self._downloadFrame = f

    editBox:HighlightText()
    editBox:SetFocus()
end

-- =====================================================================
-- UI Construction
-- =====================================================================

function UC:CreateWindow()
    if self._window then return end

    local f = CreateFrame("Frame", "PhoenixCastBarsUpdateWindow", UIParent, "BackdropTemplate")
    f:SetSize(500, 400)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    f:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", 0, -16)
    f.title:SetText("PhoenixCastBars Changelog")

    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 80)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject("GameFontHighlight")
    editBox:SetWidth(420)
    editBox:SetAutoFocus(false)
    editBox:EnableMouse(true)
    editBox:SetEnabled(false) -- Make it read-only
    editBox:SetScript("OnEscapePressed", function() editBox:ClearFocus() end)

    scrollFrame:SetScrollChild(editBox)

    f.editBox = editBox

    local updateBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    updateBtn:SetSize(120, 24)
    updateBtn:SetPoint("BOTTOMLEFT", 30, 30)
    updateBtn:SetText("Update Addon")
    updateBtn:SetScript("OnClick", function()
        UC:ShowDownloadLink()
    end)

    local leftBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    leftBtn:SetSize(80, 24)
    leftBtn:SetPoint("BOTTOMLEFT", 160, 30)
    leftBtn:SetText("< Previous")
    leftBtn:SetScript("OnClick", function()
        local sortedVersions = GetSortedVersions()
        local currentIdx = GetVersionIndex(f.currentVersion, sortedVersions)
        if currentIdx and currentIdx < #sortedVersions then
            f.currentVersion = sortedVersions[currentIdx + 1]
            UC:UpdateChangelogDisplay()
        end
    end)
    f.leftBtn = leftBtn

    local rightBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rightBtn:SetSize(80, 24)
    rightBtn:SetPoint("BOTTOMLEFT", 250, 30)
    rightBtn:SetText("Next >")
    rightBtn:SetScript("OnClick", function()
        local sortedVersions = GetSortedVersions()
        local currentIdx = GetVersionIndex(f.currentVersion, sortedVersions)
        if currentIdx and currentIdx > 1 then
            f.currentVersion = sortedVersions[currentIdx - 1]
            UC:UpdateChangelogDisplay()
        end
    end)
    f.rightBtn = rightBtn

    local dismissBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    dismissBtn:SetSize(120, 24)
    dismissBtn:SetPoint("BOTTOMRIGHT", -30, 30)
    dismissBtn:SetText("Don't show again")
    dismissBtn:SetScript("OnClick", function()
        if f.remoteVersion then
            DismissVersion(f.remoteVersion)
        end
        f:Hide()
    end)

    self._window = f
end

-- =====================================================================
-- Update Changelog Display
-- =====================================================================

function UC:UpdateChangelogDisplay()
    local f = self._window
    if not f or not f.currentVersion then return end

    local sortedVersions = GetSortedVersions()
    local currentIdx = GetVersionIndex(f.currentVersion, sortedVersions)

    local changelog = self.ChangeLogs[f.currentVersion]
        or "No changelog available for this version."

    f.editBox:SetText(
        "Your version: " .. (f.localVersion or "0.0.0") .. "\n" ..
        "Viewing version: " .. f.currentVersion .. "\n\n" ..
        "Changelog:\n\n" .. changelog
    )

    f.editBox:SetCursorPosition(0)

    -- Hide left button if at the oldest version
    if currentIdx and currentIdx >= #sortedVersions then
        f.leftBtn:Hide()
    else
        f.leftBtn:Show()
    end

    -- Hide right button if at the latest version
    if currentIdx and currentIdx <= 1 then
        f.rightBtn:Hide()
    else
        f.rightBtn:Show()
    end
end

-- =====================================================================
-- Show Window
-- =====================================================================

function UC:ShowUpdateWindow(localVersion, remoteVersion)
    if not remoteVersion then return end
    if IsDismissed(remoteVersion) then return end

    if InCombatLockdown() then
        if not self._popupQueued then
            self._popupQueued = true
            self._frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        return
    end

    self:CreateWindow()

    local f = self._window
    f.remoteVersion = remoteVersion
    f.localVersion = localVersion
    f.currentVersion = remoteVersion

    self:UpdateChangelogDisplay()

    f:Show()
end

-- =====================================================================
-- Broadcasting & Events
-- =====================================================================

function UC:Broadcast(force)
    local now = GetTime()
    if not force and (now - self._lastBroadcast) < BROADCAST_MIN_INTERVAL then return end

    local ch
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() then
        ch = "INSTANCE_CHAT"
    elseif IsInRaid() then
        ch = "RAID"
    elseif IsInGroup() then
        ch = "PARTY"
    elseif IsInGuild() then
        ch = "GUILD"
    end

    if not ch then return end

    self._lastBroadcast = now

    C_ChatInfo.SendAddonMessage(
        self.PREFIX,
        ("VER:%s"):format(PCB.version or "0.0.0"),
        ch
    )
end

function UC:Handle(prefix, message)
    if prefix ~= self.PREFIX then return end
    local remote = message:match("^VER:(%d+%.%d+%.%d+)$")
    if not remote then return end

    if not self._highestSeen or IsNewer(remote, self._highestSeen) then
        self._highestSeen = remote
    end

    if IsNewer(remote, PCB.version or "0.0.0") then
        self:ShowUpdateWindow(PCB.version or "0.0.0", remote)
    end
end

-- =====================================================================
-- Init
-- =====================================================================

function UC:Init()
    if self._inited then return end
    self._inited = true

    InitDB()

    -- ==============================
    -- Developer Test Slash Commands
    -- ==============================

    SLASH_PCBUPDATE1 = "/pcbupdate"
    SLASH_PCBUPDATE2 = "/pcbchangelog"

    SlashCmdList["PCBUPDATE"] = function(msg)
        msg = msg and msg:match("^%s*(.-)%s*$") or ""

        if msg ~= "" then
            UC:ShowUpdateWindow(PCB.version or "0.0.0", msg)
        else
            UC:ShowUpdateWindow(PCB.version or "0.0.0", GetLatestVersion())
        end
    end

    SLASH_PCBDOWNLOAD1 = "/pcbdownload"
    SlashCmdList["PCBDOWNLOAD"] = function()
        UC:ShowDownloadLink()
    end

    SLASH_PCBRESETUPDATE1 = "/pcbresetupdate"
    SlashCmdList["PCBRESETUPDATE"] = function()
        PhoenixCastBarsDB.dismissedVersions = {}
        print("|cff00d1ffPhoenixCastBars|r: Update dismissals reset.")
    end

    -- ==============================

    C_ChatInfo.RegisterAddonMessagePrefix(self.PREFIX)

    local f = CreateFrame("Frame")
    self._frame = f

    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("CHAT_MSG_ADDON")

    f:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LOGIN" then
            C_Timer.After(LOGIN_GRACE, function()
                UC:Broadcast(true)
            end)

        elseif event == "GROUP_ROSTER_UPDATE" then
            UC:Broadcast(false)

        elseif event == "CHAT_MSG_ADDON" then
            local prefix, message = ...
            UC:Handle(prefix, message)

        elseif event == "PLAYER_REGEN_ENABLED" then
            f:UnregisterEvent("PLAYER_REGEN_ENABLED")
            UC._popupQueued = false
            if UC._highestSeen then
                UC:ShowUpdateWindow(PCB.version or "0.0.0", UC._highestSeen)
            end
        end
    end)
end