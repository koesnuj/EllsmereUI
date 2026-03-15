-- PhoenixCastBars - Bars/Color.lua
-- Colour fallbacks, ApplyCastBarColor, and ApplyUninterruptibleStyling.
-- Helpers: uses PCB.Try.* from Core/Util.lua.

local ADDON_NAME, PCB = ...

local FALLBACK_CAST    = { r = 0.24, g = 0.56, b = 0.95, a = 1.0 }
local FALLBACK_CHANNEL = { r = 0.35, g = 0.90, b = 0.55, a = 1.0 }
local FALLBACK_UNINT   = { r = 0.85, g = 0.15, b = 0.15, a = 1.0 }

-- =====================================================================
-- PCB.NormalizeColor
-- Returns r,g,b,a from a color table, falling back gracefully.
-- =====================================================================
function PCB.NormalizeColor(c, fallback)
    if type(c) ~= "table" then c = fallback end
    local r = (type(c.r) == "number") and c.r or (fallback and fallback.r) or 1
    local g = (type(c.g) == "number") and c.g or (fallback and fallback.g) or 1
    local b = (type(c.b) == "number") and c.b or (fallback and fallback.b) or 1
    local a = (type(c.a) == "number") and c.a or (fallback and fallback.a) or 1
    return r, g, b, a
end

-- =====================================================================
-- PCB.ApplyCastBarColor(f)
-- Sets the bar fill colour:
--  • colorUninterruptible when cast is not interruptible (all bars)
--  • channel colour for channels
--  • cast colour otherwise
--
-- Interrupt state comes from f._state.notInterruptible (set by
-- UNIT_SPELLCAST_INTERRUPTIBLE / NOT_INTERRUPTIBLE events — no longer
-- polls TargetFrameSpellBar.showShield).
-- =====================================================================
function PCB.ApplyCastBarColor(f)
    if not f or not f.bar or not f.bar.SetStatusBarColor then return end

    local db  = PCB.db or {}
    local bdb = (db.bars and f.key and db.bars[f.key]) or {}
    local st  = f._state
    if not st then return end

    -- Per-bar colour override takes priority over all globals.
    if bdb.enableColorOverride and bdb.colorOverride then
        local oc = bdb.colorOverride
        local r  = type(oc.r) == "number" and oc.r or 1
        local g  = type(oc.g) == "number" and oc.g or 1
        local b  = type(oc.b) == "number" and oc.b or 1
        local a  = type(oc.a) == "number" and oc.a or 1
        pcall(function() f.bar:SetStatusBarColor(r, g, b, a) end)
        return
    end

    -- Resolve normal colour (cast or channel) and uninterruptible colour.
    -- Use C_CurveUtil.EvaluateColorFromBoolean to select between them —
    -- this accepts secret boolean values and returns a colour object whose
    -- GetRGBA() values are plain numbers safe to pass to SetStatusBarColor.
    local kind_col  = (st.kind == "channel")
                      and (db.colorChannel or FALLBACK_CHANNEL)
                      or  (db.colorCast    or FALLBACK_CAST)
    local unint_col = db.colorUninterruptible or FALLBACK_UNINT

    local r_n, g_n, b_n, a_n = PCB.NormalizeColor(kind_col,  FALLBACK_CAST)
    local r_u, g_u, b_u, a_u = PCB.NormalizeColor(unint_col, FALLBACK_UNINT)

    local result = C_CurveUtil.EvaluateColorFromBoolean(
        st.notInterruptible,
        CreateColor(r_u, g_u, b_u, a_u),   -- true  → uninterruptible
        CreateColor(r_n, g_n, b_n, a_n))   -- false/nil → normal

    local r, g, b, a = result:GetRGBA()
    pcall(function()
        f.bar:SetStatusBarColor(r, g, b, a)
    end)
end

-- Legacy alias for GCD.lua
PCB.ApplyCastBarColor = PCB.ApplyCastBarColor

-- =====================================================================
-- Local helper (texture swap without going through the full appearance pass)
-- =====================================================================

-- =====================================================================
-- PCB.ApplyUninterruptibleStyling(f, isUnint)
-- Overrides backdrop, border, and optionally fill texture when a cast is
-- not interruptible. Restores normal per-bar values when it becomes
-- interruptible again. Also syncs the shield / spell-icon visibility so
-- every callsite gets consistent behaviour without a one-frame lag.
--
-- isUnint must be a plain Lua boolean (use PCB.SafeBool first
-- when the value comes from UnitCastingInfo / ReadUnitCast).
-- =====================================================================
function PCB.ApplyUninterruptibleStyling(f, isUnint)
    if not f then return end
    -- Skip if isUnint is nil (haven't received interruptible event yet)
    if isUnint == nil then return end
    
    local db = PCB.db or {}
    local ub = db.uninterruptible or {}

    if isUnint and ub.enabled ~= false then
        -- ── Override backdrop & border ───────────────────────────────
        if f.bg then
            local bdc = ub.backdropColor or { r = 0.18, g = 0.04, b = 0.04, a = 0.90 }
            local brc = ub.borderColor   or { r = 0.80, g = 0.10, b = 0.10, a = 1.00 }
            pcall(function()
                f.bg:SetBackdropColor(
                    bdc.r or 0.18, bdc.g or 0.04, bdc.b or 0.04, bdc.a or 0.90)
                f.bg:SetBackdropBorderColor(
                    brc.r or 0.80, brc.g or 0.10, brc.b or 0.10, brc.a or 1.00)
            end)
        end
        -- ── Override fill texture (optional) ─────────────────────────
        if ub.useCustomTexture and ub.textureKey then
            local lsm     = PCB.LSM
            local texPath = (lsm and lsm.Fetch) and lsm:Fetch("statusbar", ub.textureKey)
                         or (type(ub.textureKey) == "string" and ub.textureKey)
                         or nil
            if texPath then
                PCB.Try.SetStatusBarTexture(f.bar, texPath)
            end
        end
        -- ── Shield icon: hide spell icon, show shield ─────────────────
        if f.shield and f.icon then
            pcall(function()
                f.icon:Hide()
                f.shield:Show()
            end)
        end
    else
        -- ── Restore normal per-bar backdrop & border ─────────────────
        if f.bg then
            local bdb = (db.bars and db.bars[f.key]) or {}
            local bdc = bdb.backdropColor or { r = 0.06, g = 0.06, b = 0.08, a = 0.85 }
            local brc = bdb.borderColor   or { r = 0.20, g = 0.20, b = 0.25, a = 0.95 }
            pcall(function()
                f.bg:SetBackdropColor(
                    bdc.r or 0.06, bdc.g or 0.06, bdc.b or 0.08, bdc.a or 0.85)
                f.bg:SetBackdropBorderColor(
                    brc.r or 0.20, brc.g or 0.20, brc.b or 0.25, brc.a or 0.95)
            end)
        end
        -- ── Restore normal fill texture (only if we overrode it) ─────
        if ub.useCustomTexture then
            local bdb     = (db.bars and db.bars[f.key]) or {}
            local texPath = PCB.ResolvePerBarOverrides(db, bdb)
            if texPath then
                PCB.Try.SetStatusBarTexture(f.bar, texPath)
            end
        end
        -- ── Shield icon: hide shield, show spell icon if we have one ──
        if f.shield and f.icon then
            pcall(function()
                f.shield:Hide()
                local st = f._state
                if st and st.texture then f.icon:Show() end
            end)
        end
    end
end
