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
    ["0.5.3"] = [[
Dropdown arrows — all dropdown boxes now display a matching down/up arrow; the arrow inverts when the menu is open and animates when pressed, matching the LSM dropdown style
Current Profile label — the "Current Profile:" label in the Profiles tab now updates immediately when switching profiles via the Existing Profiles dropdown or the Create button
Vertical orientation sizing — toggling Vertical Orientation now correctly swaps the stored bar dimensions, so the bar starts at the right size for its new orientation instead of inheriting the old horizontal values
Fade on instant casts suppressed — the Fade Out on End option no longer triggers a brief flash on instant-cast spells (casts under 0.5 seconds are excluded from the fade)
Drag mode arrow keys — arrow keys are now fully consumed while bars are unlocked; they no longer move the player character in any situation
Drag mode Escape — pressing Escape while bars are unlocked deselects the currently selected bar
Drag mode click-outside — clicking anywhere outside a bar while unlocked now deselects the selected bar
Vertical icon sizing — the spell icon is now sized to the bar's short edge (thickness) when vertical, instead of the full bar height
Icon side: Top and Bottom — Icon Side now offers Top and Bottom options for vertical bars; the icon centres on the bar's width automatically
Icon off-centre fix — icons set to Top or Bottom are now correctly centred on the bar's horizontal axis
Vertical label layout — in vertical mode, spell name and timer labels are positioned outside the bar (left or right side) rather than squeezed into the 16 px width; a new Label Side option controls which side they appear on
Label position values renamed — Spell Name Align and Timer Align values now read "Top / Left", "Center", and "Bottom / Right" so they make sense in both orientations
Spark vertical fix — the cast bar spark now tracks the fill edge correctly in vertical mode (anchors to the top of the fill texture instead of the right)
Spark test mode fix — the spark position fix also applies during test mode previews
Spell Icon Y Offset slider — a Y Offset slider is now available for the spell icon; it is shown only when Vertical Orientation is enabled, allowing fine-tuning of the gap above or below the bar
Offset sliders always visible — X and Y offset sliders are both always shown so either can be adjusted regardless of icon side
Offset range widened — both X and Y offset sliders now range from -50 to +50 to cover all placement scenarios
Slider input box clamping — typing a value outside the slider's min/max range into the input box now snaps the box text to the clamped value instead of showing an out-of-range number
    ]],
    ["0.5.2"] = [[
Default profile — designate any profile as the global fallback; characters with no explicit profile assignment will use it automatically
Per-bar colour override — each bar tab has an Override Bar Colour option with its own colour picker, bypassing global cast/channel colours entirely
Label position per bar — choose how spell name and timer are arranged per bar: Split (name left, time right), Left, Centre, or Right
Icon side per bar — move the spell icon to the left or right side of each bar independently
Vertical orientation — any bar can be set to fill vertically instead of horizontally
GCD reverse fill (drain mode) — the GCD bar can now start full and drain to empty, mirroring a cooldown sweep
Fade out on end — bars can optionally fade out smoothly when a cast ends or is interrupted, rather than snapping away instantly
Improved unlock/drag — arrow keys nudge bars 1 px (10 px with Shift) while unlocked; live pixel coordinates are shown on the bar while dragging; positions snap to whole pixels on release
Create Profile button — a Create button now sits directly next to the profile name field in the Profiles tab for a faster workflow
Profile backfill — new settings are automatically applied to all existing profiles on load, preventing blank or broken values after an update
Fixed channel bar not animating — channelled casts were showing a static bar due to the native timer check always returning true; bar fill now updates correctly every frame
Fixed cast timer disappearing — spell name and timer texts were being re-anchored to the wrong frame level after an appearance update, making them invisible
    ]],
    ["0.5.1"] = [[
Independent interrupt detection — no longer relies on Blizzard's TargetFrameSpellBar shield flag; uses UNIT_SPELLCAST_INTERRUPTIBLE / NOT_INTERRUPTIBLE events directly
Configurable uninterruptible color — colorUninterruptible is now a user-settable color in the DB (was hardcoded red)
Cast success/fail/interrupt flash — bars briefly flash colorSuccess or colorFailed on the corresponding events (colors were previously defined but unused)
Latency safe-zone color — safeZoneColor from the DB is now applied dynamically each frame (was previously only set at frame creation)
Time format option — each bar now supports "remaining" (1.4s) or "both" (1.4 / 2.5s) time display formats via timeFormat in the DB
Pet bar — a new cast bar for the player's pet (Hunter/Warlock/etc.) is now available; disabled by default
Empower stage colors — the four empower stage colors are now user-configurable via db.empowerStage1-4Color
Backdrop/border colors — backdropColor and borderColor are now DB-configurable per bar
GCD refactor — GCD.lua now shares spark, time-text, flash, and bar-fill logic with the main bar pipeline (no more duplicate code)
Test mode kinds — /pcb test now supports cast, channel, and empower preview modes via db.testModeType
VEHICLE_UPDATE properly handled — now refreshes both player and pet bars on vehicle transitions
UNIT_PET event — pet bar resets and refreshes when the player's pet changes
    ]],
    ["0.5.0"] = [[
Full modular refactor — codebase split into focused single-responsibility modules (Core/, Bars/)
No functional changes; all features, settings, and SavedVariables are fully preserved
Improved maintainability and load-order clarity via updated .toc file
Groundwork laid for easier future feature additions and bug isolation
    ]],
    ["0.4.9"] = [[
Added interrupt shield icon support on the target cast bar — displays Blizzard's interrupt shield graphic when a cast cannot be interrupted
Cast bar now turns red when a target's cast is uninterruptible, giving an immediate at-a-glance warning
Shield icon and spell icon now correctly swap in sync with the native TargetFrameSpellBar interrupt state
Fixed stale interrupt state not being cleared between casts
Refactored bar colour pipeline — channel and cast colour paths are now cleanly separated
    ]],
    ["0.4.8"] = [[
Fixed GCD bar error (UnitCastingInfo no longer called on invalid unit)
Fixed latency tracking error with UNIT_SPELLCAST_SENT event parameters
Improved castGUID validation to prevent "table index is secret" errors
    ]],
    ["0.4.7"] = [[
Fixed sytanx error in 0.4.6 changelog that caused the addon to break. Apologies for the inconvenience!
    ]],
    ["0.4.6"] = [[
Improved internal cast timing tracking  
Fixed spark visibility default logic  
Added safe SavedVariables path helpers (GetValue / SetValue)  
Improved options panel stability  
Minor cleanup and structural refinements  
    ]],
    ["0.4.5"] = [[
Full and accurate Empower spell support
Rewritten GCD bar (no more flicker or misfires)
Fixed and improved Latency / Safe Zone scaling
Dropdown ESC behavior fixed
Cleaner event handling and performance improvements
UI and texture layering fixes
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
    f:SetSize(500, 560)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 8,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 }
    })
    f:SetBackdropColor(0.06, 0.06, 0.1, 0.97)
    f:SetBackdropBorderColor(1, 1, 1, 1)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", 0, -16)
    f.title:SetText("PhoenixCastBars Changelog")

    -- X close button top-right
    local xBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    xBtn:SetSize(26, 26)
    xBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    xBtn:SetScript("OnClick", function() f:Hide() end)

    -- ESC closes the window
    f:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then f:Hide() end
    end)
    f:EnableKeyboard(true)

    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 80)
    scrollFrame:EnableMouseWheel(true)
    local scrollChild  -- declared early so OnMouseWheel closes over it
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = math.max(0, scrollChild:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.min(math.max(0, current - delta * 20), maxScroll))
    end)

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(420)
    scrollChild:SetHeight(1)  -- will grow to fit content
    scrollFrame:SetScrollChild(scrollChild)

    local textFS = scrollChild:CreateFontString(nil, "OVERLAY")
    textFS:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
    textFS:SetPoint("TOPLEFT", 0, 0)
    textFS:SetWidth(420)
    textFS:SetJustifyH("LEFT")
    textFS:SetJustifyV("TOP")
    textFS:SetWordWrap(true)
    textFS:SetSpacing(4)

    f.editBox = {
        SetText = function(_, text)
            textFS:SetText(text)
            -- GetStringHeight() is valid synchronously when width is already set
            local h = textFS:GetStringHeight()
            scrollChild:SetHeight(math.max(h, 1))
            -- Clamp scroll: must happen after height is set
            local maxScroll = math.max(0, scrollChild:GetHeight() - scrollFrame:GetHeight())
            scrollFrame:SetVerticalScroll(math.min(0, maxScroll))
        end,
        SetCursorPosition = function() end,
    }

    -- Bottom row: [Update Addon]  [< Previous] [Next >]  [Close] [Don't show again]
    local updateBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    updateBtn:SetSize(110, 24)
    updateBtn:SetPoint("BOTTOMLEFT", 20, 30)
    updateBtn:SetText("Update Addon")
    updateBtn:SetScript("OnClick", function()
        UC:ShowDownloadLink()
    end)

    local leftBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    leftBtn:SetSize(90, 24)
    leftBtn:SetPoint("BOTTOMLEFT", 140, 30)
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
    rightBtn:SetSize(90, 24)
    rightBtn:SetPoint("BOTTOMLEFT", 238, 30)
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
    dismissBtn:SetPoint("BOTTOMRIGHT", -20, 30)
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
    local isLatest = (currentIdx == 1)

    local changelog = self.ChangeLogs[f.currentVersion]
        or "No changelog available for this version."

    -- Colour constants
    local C_GOLD    = "|cffffd100"   -- version header
    local C_ORANGE  = "|cffff9900"   -- "Latest" badge
    local C_GRAY    = "|cffaaaaaa"   -- your version line
    local C_WHITE   = "|cffffffff"   -- bullet text
    local C_DIM     = "|cff888888"   -- separator
    local C_BULLET  = "|cffff7c00"   -- bullet dot
    local R         = "|r"

    -- Header
    local badge = isLatest and (C_ORANGE .. "  * Latest" .. R) or ""
    local header = C_GOLD .. "Version " .. f.currentVersion .. R .. badge .. "\n"

    local yourVer = C_GRAY .. "Your installed version: " .. (f.localVersion or "0.0.0") .. R .. "\n"

    local sep = C_DIM .. "--------------------------------------------" .. R .. "\n"

    -- Format each bullet: replace leading "" with a coloured one, colour the text white
    local formatted = changelog:gsub("^%s+", ""):gsub("%s+$", "")
    local lines = {}
    for line in (formatted .. "\n"):gmatch("([^\n]*)\n") do
        line = line:match("^%s*(.-)%s*$")  -- trim
        if line == "" then
            lines[#lines + 1] = ""
        else
            -- Strip any leading bullet character (UTF-8 = \xe2\x80\xa2, or plain -)
            local text = line:gsub("^\xe2\x80\xa2%s*", ""):gsub("^%-%s*", "")
            lines[#lines + 1] = C_BULLET .. ">> " .. R .. C_WHITE .. text .. R
        end
    end

    local body = table.concat(lines, "\n")

    f.editBox:SetText(header .. yourVer .. sep .. body)
    f.editBox:SetCursorPosition(0)

    -- Navigation button visibility
    if currentIdx and currentIdx >= #sortedVersions then
        f.leftBtn:Hide()
    else
        f.leftBtn:Show()
    end

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

-- Opens the changelog directly, bypassing the dismissed check (e.g. from the options version button)
function UC:ShowChangelog()
    self:CreateWindow()

    local f = self._window
    local ver = PCB.version or "0.0.0"
    f.remoteVersion = ver
    f.localVersion  = ver
    f.currentVersion = ver

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
