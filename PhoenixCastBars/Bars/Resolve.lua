-- PhoenixCastBars - Bars/Resolve.lua
-- Resolves texture/font paths (global and per-bar overrides) and determines
-- the effective unit token for target/focus bars (nameplate fallback).

local ADDON_NAME, PCB = ...

-- =====================================================================
-- Duration API availability (cached at load time)
-- =====================================================================
PCB.HAS_DURATION_API =
    type(UnitCastingDuration) == "function" and
    type(UnitChannelDuration) == "function"

function PCB.GetDurationForUnit(unit, isChannel)
    if not PCB.HAS_DURATION_API then return nil end
    if isChannel then
        local ok, d = pcall(function() return UnitChannelDuration(unit) end)
        if ok then return d end
    else
        local ok, d = pcall(function() return UnitCastingDuration(unit) end)
        if ok then return d end
    end
    return nil
end

function PCB.DurationRemainingSeconds(durationObj)
    if not durationObj or not durationObj.EvaluateRemainingDuration then return nil end
    local ok, v = pcall(function() return durationObj:EvaluateRemainingDuration(nil) end)
    return (ok and type(v) == "number") and v or nil
end

-- =====================================================================
-- Internal helpers
-- =====================================================================
local function LSMFetch(mediatype, key)
    if not key or key == "" then return nil end
    if PCB.LSM and PCB.LSM.Fetch then
        local ok, path = pcall(function() return PCB.LSM:Fetch(mediatype, key) end)
        if ok and type(path) == "string" and path ~= "" then return path end
    end
    return nil
end

local function IsPath(s)
    return type(s) == "string" and (s:find("\\") or s:find("/"))
end

-- =====================================================================
-- Global texture / font resolution
-- =====================================================================
local function ResolveGlobalTexturePath(db)
    local key  = db.textureKey
    local path = db.texturePath
    if not key and type(db.texture) == "string" then
        if IsPath(db.texture) then key = "Custom"; path = db.texture
        else                       key = db.texture end
    end
    key = key or "Blizzard"
    if key == "Custom" and IsPath(path) then return path end
    local fetched = LSMFetch("statusbar", key)
    if fetched then return fetched end
    if IsPath(key) then return key end
    return "Interface\\TARGETINGFRAME\\UI-StatusBar"
end

local function ResolveGlobalFontPath(db)
    local key  = db.fontKey
    local path = db.fontPath
    if not key and type(db.font) == "string" then
        if IsPath(db.font) then key = "Custom"; path = db.font
        else                    key = db.font end
    end
    key = key or "Friz Quadrata TT"
    if key == "Custom" and IsPath(path) then return path end
    local fetched = LSMFetch("font", key)
    if fetched then return fetched end
    if IsPath(key) then return key end
    return "Fonts\\FRIZQT__.TTF"
end

-- =====================================================================
-- Per-bar texture/font override resolution
-- Returns: texPath, fontPath, fontSize, outlineFlags
-- =====================================================================
function PCB.ResolvePerBarOverrides(db, bdb)
    local tex     = ResolveGlobalTexturePath(db)
    local font    = ResolveGlobalFontPath(db)
    local size    = db.fontSize or 12
    local outline = db.outline  or "OUTLINE"

    if bdb then
        if bdb.enableTextureOverride and bdb.textureKey then
            if bdb.textureKey == "Custom" and IsPath(bdb.texturePath) then
                tex = bdb.texturePath
            else
                tex = LSMFetch("statusbar", bdb.textureKey) or tex
            end
        end

        if bdb.enableFontOverride and bdb.fontKey then
            if bdb.fontKey == "Custom" and IsPath(bdb.fontPath) then
                font = bdb.fontPath
            else
                font = LSMFetch("font", bdb.fontKey) or font
            end
        end

        if bdb.enableFontSizeOverride and type(bdb.fontSize) == "number" then
            size = bdb.fontSize
        end

        if bdb.enableOutlineOverride and type(bdb.outline) == "string" then
            outline = bdb.outline
        end

        local ap = bdb.appearance
        if type(ap) == "table" then
            if ap.useGlobalTexture == false then
                if IsPath(ap.texture) then tex = ap.texture
                elseif type(ap.texture) == "string" then
                    tex = LSMFetch("statusbar", ap.texture) or tex
                end
            end
            if ap.useGlobalFont == false then
                if IsPath(ap.font) then font = ap.font
                elseif type(ap.font) == "string" then
                    font = LSMFetch("font", ap.font) or font
                end
            end
            if ap.useGlobalFontSize == false and type(ap.fontSize) == "number" then
                size = ap.fontSize
            end
            if ap.useGlobalOutline == false and type(ap.outline) == "string" then
                outline = ap.outline
            end
        end
    end

    if outline == "NONE" then outline = "" end
    return tex, font, size, outline
end

-- =====================================================================
-- Unit / nameplate resolution
-- =====================================================================
local function ResolveNameplateForUnit(unitToken)
    if not UnitExists(unitToken) then return unitToken end
    if not UnitIsEnemy("player", unitToken) then return unitToken end
    for i = 1, PCB.NAMEPLATE_MAX do
        local u = "nameplate" .. i
        if UnitExists(u) and UnitIsUnit(u, unitToken) then return u end
    end
    return unitToken
end

-- Returns the best unit token for a given bar frame.
-- For target/focus bars, attempts nameplate resolution for enemies.
function PCB.GetEffectiveUnit(f, unitHint)
    if f.key == "target" then
        if f._effectiveUnit and f._effectiveUnitActive then
            if UnitExists(f._effectiveUnit) and UnitExists("target") and
               UnitIsUnit(f._effectiveUnit, "target") then
                return f._effectiveUnit
            end
        end
        local u = ResolveNameplateForUnit("target")
        f._effectiveUnit = u
        return u
    elseif f.key == "focus" then
        if f._effectiveUnit and f._effectiveUnitActive then
            if UnitExists(f._effectiveUnit) and UnitExists("focus") and
               UnitIsUnit(f._effectiveUnit, "focus") then
                return f._effectiveUnit
            end
        end
        local u = ResolveNameplateForUnit("focus")
        f._effectiveUnit = u
        return u
    end

    if type(unitHint) == "string" and unitHint ~= "" then return unitHint end
    return PCB.BAR_UNITS[f.key] or "player"
end
