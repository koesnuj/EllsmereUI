-------------------------------------------------------------------------------
--  EllesmereUI_PageSwitch.lua
--
--  Adds Shift+MouseWheel page switching to EllesmereUIActionBars MainBar.
--  Shift+WheelUp  = switch to Bar6 slot range (145-156)
--  Shift+WheelDown = switch back to default Bar1 slots (1-12)
--
--  Uses SetOverrideBindingClick + SecureHandlerClickTemplate for reliable
--  combat-safe operation.
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

    -- Verify at least one MainBar button exists
    if not _G["ActionButton1"] then return end

    ---------------------------------------------------------------------------
    --  1. Create a SecureHandlerClickTemplate button
    --     SetOverrideBindingClick maps Shift+Wheel to virtual clicks on this.
    --     _onclick secure snippet handles the actual page switch.
    ---------------------------------------------------------------------------
    local handler = CreateFrame("Button", HANDLER_NAME, UIParent,
                                "SecureHandlerClickTemplate")
    handler:SetSize(1, 1)
    handler:SetPoint("CENTER")
    handler:RegisterForClicks("AnyDown")
    handler:SetAttribute("shiftPage", 0)

    -- Store frame refs so secure snippet can reach mainbar + buttons
    handler:SetFrameRef("mainbar", mainBar)
    for i = 1, NUM_BUTTONS do
        local btn = _G["ActionButton" .. i]
        if btn then
            handler:SetFrameRef("btn" .. i, btn)
        end
    end

    ---------------------------------------------------------------------------
    --  2. Secure click handler
    --     LeftButton  (Shift+WheelUp)   = switch to Bar6 slots (145-156)
    --     RightButton (Shift+WheelDown) = switch back to Bar1 slots (1-12)
    ---------------------------------------------------------------------------
    handler:SetAttribute("_onclick", [[
        local mainbar    = self:GetFrameRef("mainbar")
        local pageOffset = mainbar:GetAttribute("pageOffset") or 0

        -- Block switching while a form/vehicle page is active
        if pageOffset ~= 0 then return end

        -- Toggle: if already on Bar6 → back to Bar1, otherwise → Bar6
        local shiftPage = self:GetAttribute("shiftPage") or 0
        local newShiftPage = shiftPage == 1 and 0 or 1


        self:SetAttribute("shiftPage", newShiftPage)
        local offset = newShiftPage == 1 and 144 or 0
        mainbar:SetAttribute("actionOffset", offset)

        -- Directly update each button's action attribute
        for i = 1, 12 do
            local btn = self:GetFrameRef("btn" .. i)
            if btn then
                local idx = btn:GetAttribute("index")
                if idx then
                    btn:SetAttribute("action", idx + offset)
                end
            end
        end
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
    --  4. Replace MainBar _onstate-page
    --     Original only tracks actionOffset.  We add:
    --       • pageOffset  (raw page-based offset, before shift override)
    --       • shiftPage reset when entering a form/vehicle
    ---------------------------------------------------------------------------
    mainBar:SetFrameRef("pageSwitch", handler)
    mainBar:SetAttribute("pageOffset", 0)

    mainBar:SetAttribute("_onstate-page", [[
        local page = tonumber(newstate) or 1

        -- Vehicle / possess / bonus bar fallback (copied from original)
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

        local barLen     = self:GetAttribute("barLength")
        local pageOffset = (page - 1) * barLen
        self:SetAttribute("pageOffset", pageOffset)

        -- Read shift-page state from our click handler
        local ps        = self:GetFrameRef("pageSwitch")
        local shiftPage = ps and ps:GetAttribute("shiftPage") or 0

        -- Auto-reset shift page when a form/vehicle overrides paging
        if pageOffset > 0 and shiftPage == 1 then
            if ps then ps:SetAttribute("shiftPage", 0) end
            shiftPage = 0
        end

        -- Compute final offset
        local offset
        if shiftPage == 1 and pageOffset == 0 then
            offset = 144   -- Bar6 slots
        else
            offset = pageOffset
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

    local lastShiftPage = 0
    C_Timer.NewTicker(0.1, function()
        local sp = handler:GetAttribute("shiftPage") or 0
        if sp ~= lastShiftPage then
            lastShiftPage = sp
            if sp == 1 then
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
-------------------------------------------------------------------------------
local bootstrap = CreateFrame("Frame")
bootstrap:RegisterEvent("PLAYER_ENTERING_WORLD")
bootstrap:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(1, function()
        if _G[MAINBAR_FRAME] then
            Init()
        else
            -- Fallback: retry after another second (first-install path)
            C_Timer.After(2, function()
                if _G[MAINBAR_FRAME] then
                    Init()
                end
            end)
        end
    end)
end)
