-------------------------------------------------------------------------------
--  EllesmereUI_PageSwitch.lua
--
--  Adds Shift+MouseWheel page switching to EllesmereUIActionBars MainBar.
--  Shift+WheelUp  = switch to Bar6 slot range (145-156)
--  Shift+WheelDown = switch back to default Bar1 slots (1-12)
--
--  Hooks into EAB's UpdateOffset RunAttribute for combat-safe operation.
--  Survives EllesmereUIActionBars updates — no files modified in that addon.
-------------------------------------------------------------------------------
local ADDON_NAME = ...

local BAR6_OFFSET      = 144   -- Bar6 = MultiBar5, slots 145-156
local NUM_BUTTONS      = 12
local MAINBAR_FRAME    = "EABBar_MainBar"
local HANDLER_NAME     = "EUIPageSwitch"

-------------------------------------------------------------------------------
--  Core Init — called once MainBar frame is confirmed to exist
-------------------------------------------------------------------------------
local function Init()
    local mainBar = _G[MAINBAR_FRAME]
    if not mainBar then return end

    if not _G["ActionButton1"] then return end

    ---------------------------------------------------------------------------
    --  1. Create a SecureHandlerClickTemplate button
    --     SetOverrideBindingClick maps Shift+Wheel to virtual clicks on this.
    ---------------------------------------------------------------------------
    local handler = CreateFrame("Button", HANDLER_NAME, UIParent,
                                "SecureHandlerClickTemplate")
    handler:SetSize(1, 1)
    handler:SetPoint("CENTER")
    handler:RegisterForClicks("AnyDown")
    handler:SetAttribute("shiftPage", 0)

    handler:SetFrameRef("mainbar", mainBar)

    ---------------------------------------------------------------------------
    --  2. Secure click handler
    --     Toggles shiftPage, then re-runs MainBar's UpdateOffset so the
    --     unified offset pipeline (including ChildUpdate) handles everything.
    ---------------------------------------------------------------------------
    handler:SetAttribute("_onclick", [[
        local mainbar = self:GetFrameRef("mainbar")

        -- Block switching during override/vehicle bar
        local overridePage = mainbar:GetAttribute("state-overridepage") or 0
        if overridePage > 0 and mainbar:GetAttribute("state-overridebar") then
            return
        end

        -- Block switching when not on default page (stance/form paging)
        local page = mainbar:GetAttribute("state-page") or 1
        if page ~= 1 then return end

        local shiftPage = self:GetAttribute("shiftPage") or 0
        local newShiftPage = shiftPage == 1 and 0 or 1
        self:SetAttribute("shiftPage", newShiftPage)

        mainbar:RunAttribute("UpdateOffset")
    ]])

    ---------------------------------------------------------------------------
    --  3. Override bindings — Shift+MouseWheel → virtual click on handler
    --     These persist through combat; cleared only if handler is hidden.
    ---------------------------------------------------------------------------
    SetOverrideBindingClick(handler, false,
        "SHIFT-MOUSEWHEELUP",   HANDLER_NAME, "LeftButton")
    SetOverrideBindingClick(handler, false,
        "SHIFT-MOUSEWHEELDOWN", HANDLER_NAME, "RightButton")

    ---------------------------------------------------------------------------
    --  4. Replace MainBar's UpdateOffset RunAttribute
    --     Preserves upstream's full offset pipeline (override bar detection,
    --     vehicle/possess fallback, slot-132 skip), then layers shiftPage
    --     override on top.  _onstate-page / _onstate-overridebar /
    --     _onstate-overridepage all still funnel into this single attribute.
    ---------------------------------------------------------------------------
    mainBar:SetFrameRef("pageSwitch", handler)

    mainBar:SetAttribute("UpdateOffset", [[
        local offset = 0

        local overridePage = self:GetAttribute("state-overridepage") or 0
        if overridePage > 0 and self:GetAttribute("state-overridebar") then
            offset = (overridePage - 1) * self:GetAttribute("overrideBarLength")
        else
            local page = self:GetAttribute("state-page") or 1

            if page == 11 then
                if HasVehicleActionBar() then
                    page = GetVehicleBarIndex()
                elseif HasOverrideActionBar() then
                    page = GetOverrideBarIndex()
                elseif HasTempShapeshiftActionBar() then
                    page = GetTempShapeshiftBarIndex()
                elseif HasBonusActionBar() then
                    page = GetBonusBarIndex()
                end
            end

            local barLen = self:GetAttribute("barLength")
            offset = (page - 1) * barLen

            if offset >= 132 then
                offset = offset + 12
            end
        end

        -- PageSwitch: read shift-page state from click handler
        local ps = self:GetFrameRef("pageSwitch")
        local shiftPage = ps and ps:GetAttribute("shiftPage") or 0

        -- Auto-reset shift page when a form/vehicle overrides paging
        if offset > 0 and shiftPage == 1 then
            if ps then ps:SetAttribute("shiftPage", 0) end
            shiftPage = 0
        end

        -- Apply Bar6 override when on default page
        if shiftPage == 1 and offset == 0 then
            offset = 144
        end

        self:SetAttribute("actionOffset", offset)
        control:ChildUpdate("offset", offset)
    ]])

    ---------------------------------------------------------------------------
    --  5. Page indicator (visual feedback below MainBar)
    ---------------------------------------------------------------------------
    local indicator = mainBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    indicator:SetPoint("TOP", mainBar, "BOTTOM", 0, -2)
    indicator:SetTextColor(0.8, 0.8, 0.2, 0.9)
    indicator:Hide()

    handler:SetScript("OnAttributeChanged", function(self, name, value)
        if name == "shiftPage" then
            if value == 1 then
                indicator:SetText("Bar 6")
                indicator:Show()
            else
                indicator:Hide()
            end
        end
    end)

    print("|cff0cd29f[EllesmereUI PageSwitch]|r Loaded — Shift+WheelUp=Bar6, Shift+WheelDown=Bar1")
end

-------------------------------------------------------------------------------
--  Bootstrap — wait for EllesmereUIActionBars to finish creating bars
--  EAB:OnEnable() → FinishSetup() runs at PLAYER_LOGIN.
--  We hook at PLAYER_ENTERING_WORLD + 1s delay to guarantee bars exist.
--  Combat-safe: defers Init() until out of combat if InCombatLockdown().
-------------------------------------------------------------------------------
local _initDone = false
local bootstrap = CreateFrame("Frame")
bootstrap:RegisterEvent("PLAYER_ENTERING_WORLD")
bootstrap:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        if not _initDone and _G[MAINBAR_FRAME] then
            _initDone = true
            Init()
        end
        return
    end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(1, function()
        if _initDone then return end
        if InCombatLockdown() then
            bootstrap:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end
        if _G[MAINBAR_FRAME] then
            _initDone = true
            Init()
        else
            C_Timer.After(2, function()
                if _initDone then return end
                if InCombatLockdown() then
                    bootstrap:RegisterEvent("PLAYER_REGEN_ENABLED")
                    return
                end
                if _G[MAINBAR_FRAME] then
                    _initDone = true
                    Init()
                end
            end)
        end
    end)
end)
