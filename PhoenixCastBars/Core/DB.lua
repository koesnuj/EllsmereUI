-- PhoenixCastBars - Core/DB.lua
-- Owns three things only:
--   PCB.DB_SCHEMA_VERSION  — bump when the schema changes
--   PCB.Defaults           — the canonical default settings table
--   PCB.MergeDefaults      — recursive nil-fill helper
--   PCB:InitDB()           — SavedVariables bootstrap + defaults merge
--
-- Profile CRUD and import/export live in Core/Profiles.lua.
-- Deep-copy lives in Core/Util.lua (PCB.DeepCopy).

local ADDON_NAME, PCB = ...

PCB.DB_SCHEMA_VERSION = 2

-- =====================================================================
-- Default settings
-- =====================================================================
PCB.Defaults = {
    locked = true,
    texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
    font    = "Fonts\\FRIZQT__.TTF",
    fontSize = 12,
    outline  = "OUTLINE",
    colorCast           = { r = 0.24, g = 0.56, b = 0.95, a = 1.0 },
    colorChannel        = { r = 0.35, g = 0.90, b = 0.55, a = 1.0 },
    colorFailed         = { r = 0.85, g = 0.25, b = 0.25, a = 1.0 },
    colorSuccess        = { r = 0.25, g = 0.90, b = 0.35, a = 1.0 },
    colorUninterruptible = { r = 0.85, g = 0.15, b = 0.15, a = 1.0 },
    safeZoneColor        = { r = 1.0,  g = 0.2,  b = 0.2,  a = 0.35 },
    uninterruptible = {
        enabled          = true,
        backdropColor    = { r = 0.18, g = 0.04, b = 0.04, a = 0.90 },
        borderColor      = { r = 0.80, g = 0.10, b = 0.10, a = 1.00 },
        useCustomTexture = false,
        textureKey       = nil,
    },
    empowerStage1Color = { r = 0.9,  g = 0.2,  b = 0.2,  a = 1.0 },
    empowerStage2Color = { r = 1.0,  g = 0.8,  b = 0.0,  a = 1.0 },
    empowerStage3Color = { r = 0.2,  g = 0.9,  b = 0.2,  a = 1.0 },
    empowerStage4Color = { r = 0.15, g = 0.45, b = 0.9,  a = 1.0 },
    timeFormat   = "remaining",
    fadeOnEnd    = false,          -- fade bars out on cast end/interrupt
    testModeType = "cast",
    minimapButton = { show = true, angle = 220 },
    bars = {
        player = {
            enabled = true,
            width = 260, height = 18,
            point = "CENTER", relPoint = "CENTER", x = 0, y = -180,
            alpha = 1.0, scale = 1.0,
            showIcon = true, iconOffsetX = -6, iconOffsetY = 0,
            showSpark = true, showTime = true,
            showSpellName = true, showLatency = true,
            timeFormat = nil,
            spellLabelPosition = "left",    -- "left" | "center" | "right"
            timeLabelPosition  = "right",   -- "left" | "center" | "right"
            iconSide      = "left",    -- "left" | "right"
            verticalLabelSide = "left", -- "left" | "right" (only used when vertical=true)
            colorOverride = nil,       -- {r,g,b,a} or nil to use global
            vertical      = false,
            backdropColor = { r = 0.06, g = 0.06, b = 0.08, a = 0.85 },
            borderColor   = { r = 0.20, g = 0.20, b = 0.25, a = 0.95 },
            appearance = {
                useGlobalTexture = true, useGlobalFont = true,
                useGlobalFontSize = true, useGlobalOutline = true,
                texture = nil, font = nil, fontSize = nil, outline = nil,
            },
        },
        target = {
            enabled = true,
            width = 240, height = 16,
            point = "CENTER", relPoint = "CENTER", x = 0, y = -140,
            alpha = 1.0, scale = 1.0,
            showIcon = true, iconOffsetX = -6, iconOffsetY = 0,
            showSpark = true, showTime = true, showSpellName = true,
            timeFormat = nil,
            spellLabelPosition = "left",
            timeLabelPosition  = "right",
            iconSide      = "left",
            verticalLabelSide = "left",
            colorOverride = nil,
            vertical      = false,
            backdropColor = { r = 0.06, g = 0.06, b = 0.08, a = 0.85 },
            borderColor   = { r = 0.20, g = 0.20, b = 0.25, a = 0.95 },
            appearance = {
                useGlobalTexture = true, useGlobalFont = true,
                useGlobalFontSize = true, useGlobalOutline = true,
                texture = nil, font = nil, fontSize = nil, outline = nil,
            },
        },
        focus = {
            enabled = false,
            width = 240, height = 16,
            point = "CENTER", relPoint = "CENTER", x = 0, y = -110,
            alpha = 1.0, scale = 1.0,
            showIcon = true, iconOffsetX = -6, iconOffsetY = 0,
            showSpark = true, showTime = true, showSpellName = true,
            timeFormat = nil,
            spellLabelPosition = "left",
            timeLabelPosition  = "right",
            iconSide      = "left",
            verticalLabelSide = "left",
            colorOverride = nil,
            vertical      = false,
            backdropColor = { r = 0.06, g = 0.06, b = 0.08, a = 0.85 },
            borderColor   = { r = 0.20, g = 0.20, b = 0.25, a = 0.95 },
            appearance = {
                useGlobalTexture = true, useGlobalFont = true,
                useGlobalFontSize = true, useGlobalOutline = true,
                texture = nil, font = nil, fontSize = nil, outline = nil,
            },
        },
        gcd = {
            enabled = true,
            width = 200, height = 8,
            point = "CENTER", relPoint = "CENTER", x = 0, y = -210,
            alpha = 1.0, scale = 1.0,
            showSpark = true, showTime = false,
            timeFormat = nil,
            colorOverride   = nil,
            vertical        = false,
            gcdReverseFill  = false,   -- true = starts full, drains right-to-left
            backdropColor = { r = 0.06, g = 0.06, b = 0.08, a = 0.85 },
            borderColor   = { r = 0.20, g = 0.20, b = 0.25, a = 0.95 },
            appearance = {
                useGlobalTexture = true, useGlobalFont = true,
                useGlobalFontSize = true, useGlobalOutline = true,
                texture = nil, font = nil, fontSize = nil, outline = nil,
            },
        },
        pet = {
            enabled = false,
            width = 220, height = 14,
            point = "CENTER", relPoint = "CENTER", x = 0, y = -230,
            alpha = 1.0, scale = 1.0,
            showIcon = true, iconOffsetX = -6, iconOffsetY = 0,
            showSpark = true, showTime = true, showSpellName = true,
            timeFormat = nil,
            spellLabelPosition = "left",
            timeLabelPosition  = "right",
            iconSide      = "left",
            verticalLabelSide = "left",
            colorOverride = nil,
            vertical      = false,
            backdropColor = { r = 0.06, g = 0.06, b = 0.08, a = 0.85 },
            borderColor   = { r = 0.20, g = 0.20, b = 0.25, a = 0.95 },
            appearance = {
                useGlobalTexture = true, useGlobalFont = true,
                useGlobalFontSize = true, useGlobalOutline = true,
                texture = nil, font = nil, fontSize = nil, outline = nil,
            },
        },
    },
}

-- =====================================================================
-- PCB.MergeDefaults(dst, src)
-- Recursively fills nil keys in dst from src. Never overwrites set values.
-- =====================================================================
function PCB.MergeDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            PCB.MergeDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

-- =====================================================================
-- PCB:InitDB()
-- =====================================================================
function PCB:InitDB()
    if self._initDB then return end
    self._initDB = true

    if type(PhoenixCastBarsDB) ~= "table" then
        PhoenixCastBarsDB = {
            schema         = PCB.DB_SCHEMA_VERSION,
            profileMode    = "character",
            defaultProfile = nil,   -- set by user; applied for any char with no explicit profile
            profiles       = { Default = PCB.DeepCopy(PCB.Defaults) },
            chars          = {},
        }
    end

    PhoenixCastBarsDB.schema        = PhoenixCastBarsDB.schema   or PCB.DB_SCHEMA_VERSION
    PhoenixCastBarsDB.defaultProfile = PhoenixCastBarsDB.defaultProfile or nil
    PhoenixCastBarsDB.profiles = PhoenixCastBarsDB.profiles or
        { Default = PCB.DeepCopy(PCB.Defaults) }
    PhoenixCastBarsDB.chars    = PhoenixCastBarsDB.chars    or {}

    PhoenixCastBarsDB.profiles.Default = PhoenixCastBarsDB.profiles.Default
        or PCB.DeepCopy(PCB.Defaults)

    -- Apply defaults to every profile so new fields are backfilled into existing saves.
    for _, profileData in pairs(PhoenixCastBarsDB.profiles) do
        PCB.MergeDefaults(profileData, PCB.Defaults)
    end

    self.dbRoot = PhoenixCastBarsDB

    -- Defined in Profiles.lua (loads after this file; safe to call at runtime).
    self:SelectActiveProfile()

    -- Migrate legacy path-based texture/font keys
    local db = self.db
    if db.texture and not db.textureKey then
        if type(db.texture) == "string" and
           (db.texture:find("\\") or db.texture:find("/")) then
            db.textureKey = "Custom"; db.texturePath = db.texture
        else
            db.textureKey = db.texture
        end
    end
    if db.font and not db.fontKey then
        if type(db.font) == "string" and
           (db.font:find("\\") or db.font:find("/")) then
            db.fontKey = "Custom"; db.fontPath = db.font
        else
            db.fontKey = db.font
        end
    end
    db.textureKey  = db.textureKey  or "Blizzard"
    db.fontKey     = db.fontKey     or "Friz Quadrata (Default)"
    db.texturePath = db.texturePath or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    db.fontPath    = db.fontPath    or "Fonts\\FRIZQT__.TTF"
    db.texture     = (db.textureKey == "Custom") and db.texturePath or db.textureKey
    db.font        = (db.fontKey    == "Custom") and db.fontPath    or db.fontKey

    self._initDB = false
end

-- =====================================================================
-- Misc helpers
-- =====================================================================
function PCB:ColorFromTable(t)
    return t.r or 1, t.g or 1, t.b or 1, t.a or 1
end

function PCB:ApplyFont(fs)
    if not fs then return end
    local db    = self.db
    local flags = db.outline or "OUTLINE"
    if flags == "NONE" then flags = "" end
    fs:SetFont(db.font, db.fontSize, flags)
end
