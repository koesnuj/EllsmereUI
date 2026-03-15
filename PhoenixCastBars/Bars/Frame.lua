-- PhoenixCastBars - Bars/Frame.lua
-- Creates and visually configures cast bar frames.
-- PCB.CreateCastBarFrame  — allocate a new bar
-- PCB.ApplyAppearance     — sync a bar to current db settings
--
-- Helpers: uses PCB.Try.* from Core/Util.lua.

local ADDON_NAME, PCB = ...

-- =====================================================================
-- Backdrop helper
-- =====================================================================
local function CreateBackdrop(parent)
    local bg = CreateFrame("Frame", nil, parent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    bg:SetPoint("TOPLEFT",     parent, "TOPLEFT",     -2,  2)
    bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT",  2, -2)
    bg:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    bg:SetBackdropColor(0.06, 0.06, 0.08, 0.85)
    bg:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.95)
    return bg
end

-- =====================================================================
-- Internal layout helpers
-- =====================================================================
local function UpdateVisualSizes(f)
    local h = f:GetHeight()
    local w = f:GetWidth()
    if type(h) ~= "number" or h <= 0 then h = 16 end
    if type(w) ~= "number" or w <= 0 then w = 260 end
    if f.container then f.container:SetSize(w, h) end
    -- Icon should always match the bar's thickness (short side), not its length
    local thickness = math.min(w, h)
    if f.icon  then f.icon:SetSize(thickness + 2, thickness + 2) end
    if f.spark then f.spark:SetHeight(h) end
end

local function ApplyIconOffsets(f)
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}
    local ox   = (type(bdb.iconOffsetX) == "number") and bdb.iconOffsetX or -6
    local oy   = (type(bdb.iconOffsetY) == "number") and bdb.iconOffsetY or 0
    local side = bdb.iconSide or "left"
    if f.icon then
        f.icon:ClearAllPoints()
        if side == "right" then
            f.icon:SetPoint("LEFT", f, "RIGHT", ox, oy)
        elseif side == "top" then
            -- Vertical mode: X=0 centred, Y offset drives the gap above the bar
            f.icon:SetPoint("BOTTOM", f, "TOP", 0, oy)
        elseif side == "bottom" then
            -- Vertical mode: X=0 centred, Y offset drives the gap below the bar
            f.icon:SetPoint("TOP", f, "BOTTOM", 0, oy)
        else  -- left (default)
            f.icon:SetPoint("RIGHT", f, "LEFT", ox, oy)
        end
    end
    if f.shield then
        f.shield:ClearAllPoints()
        f.shield:SetAllPoints(f.icon)
    end
end

local function ApplyLabelPosition(f)
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}

    if not f.spellText or not f.timeText or not f.bar then return end

    local legacy = bdb.labelPosition
    local spos = bdb.spellLabelPosition or (legacy == "split" and "left")  or legacy or "left"
    local tpos = bdb.timeLabelPosition  or (legacy == "split" and "right") or legacy or "right"

    f.spellText:ClearAllPoints()
    f.timeText:ClearAllPoints()

    local isVert = bdb.vertical == true

    if isVert then
        -- In vertical mode labels sit OUTSIDE the bar on the chosen side.
        -- spellLabelPosition / timeLabelPosition map to top / center / bottom along the bar.
        -- verticalLabelSide controls left vs right of the bar.
        local side = bdb.verticalLabelSide or "left"

        -- Along-bar anchor: "left"→top, "center"→middle, "right"→bottom
        local vanchors = {
            left   = { barAnchor = "TOP",    labelAnchor = "TOP",    oy =  0 },
            center = { barAnchor = "CENTER", labelAnchor = "CENTER", oy =  0 },
            right  = { barAnchor = "BOTTOM", labelAnchor = "BOTTOM", oy =  0 },
        }

        local function ApplyVertLabel(fs, pos)
            local va = vanchors[pos] or vanchors["left"]
            fs:SetWidth(150)
            if side == "right" then
                fs:SetJustifyH("LEFT")
                fs:SetPoint(va.labelAnchor .. "LEFT", f.bar, va.barAnchor .. "RIGHT", 6, va.oy)
            else
                fs:SetJustifyH("RIGHT")
                fs:SetPoint(va.labelAnchor .. "RIGHT", f.bar, va.barAnchor .. "LEFT", -6, va.oy)
            end
        end

        ApplyVertLabel(f.spellText, spos)
        ApplyVertLabel(f.timeText,  tpos)
    else
        -- Horizontal mode: labels inside the bar, left/center/right aligned
        f.spellText:SetWidth(0)  -- auto width
        f.timeText:SetWidth(0)

        local anchors = {
            left   = { justify = "LEFT",   point = "LEFT",   anchor = "LEFT",   ox =  6, oy = 0 },
            right  = { justify = "RIGHT",  point = "RIGHT",  anchor = "RIGHT",  ox = -6, oy = 0 },
            center = { justify = "CENTER", point = "CENTER", anchor = "CENTER", ox =  0, oy = 0 },
        }
        local sa = anchors[spos] or anchors["left"]
        local ta = anchors[tpos] or anchors["right"]

        f.spellText:SetJustifyH(sa.justify)
        f.spellText:SetPoint(sa.point, f.bar, sa.anchor, sa.ox, sa.oy)
        f.timeText:SetJustifyH(ta.justify)
        f.timeText:SetPoint(ta.point, f.bar, ta.anchor, ta.ox, ta.oy)
    end
end

local function ApplyOrientation(f)
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}
    local vert = bdb.vertical == true
    if f.bar and f.bar.SetOrientation then
        f.bar:SetOrientation(vert and "VERTICAL" or "HORIZONTAL")
    end
    -- Rotate spark texture for vertical bars
    if f.spark then
        if vert then
            f.spark:SetWidth(f:GetWidth())
            f.spark:SetHeight(4)
        else
            f.spark:SetWidth(4)
            f.spark:SetHeight(f:GetHeight())
        end
    end
end

-- =====================================================================
-- PCB.CreateCastBarFrame(key)
-- =====================================================================
function PCB.CreateCastBarFrame(key)
    local container = CreateFrame("Frame", "PhoenixCastBars_Container_" .. key, UIParent)
    container:SetSize(260, 32)
    container:Hide()

    local f = CreateFrame("Frame", "PhoenixCastBars_" .. key, container)
    f:SetPoint("CENTER", container, "CENTER", 0, 0)
    f.key       = key
    f.unit      = PCB.BAR_UNITS[key]
    f.container = container

    f._latency             = 0
    f._pollElapsed         = 0
    f._textElapsed         = 0
    f._effectiveUnit       = nil
    f._effectiveUnitActive = false
    f._endGraceUntil       = nil
    f._state               = nil
    f._stopCheckAt         = nil
    f._stopUnit            = nil
    f._localStartTime      = nil
    f._localEndTime        = nil
    f._localDuration       = nil
    f._flashTimer          = 0
    f._flashDuration       = 0

    f.bg  = CreateBackdrop(f)

    f.bar = CreateFrame("StatusBar", nil, f)
    f.bar:SetAllPoints(f)
    PCB.Try.SetMinMax(f.bar, 0, 1)
    PCB.Try.SetValue(f.bar, 0)

    f.bar.bgTex = f.bar:CreateTexture(nil, "BACKGROUND")
    f.bar.bgTex:SetAllPoints(f.bar)
    f.bar.bgTex:SetTexture("Interface\\Buttons\\WHITE8x8")
    f.bar.bgTex:SetVertexColor(0, 0, 0, 0.35)

    f.spark = f.bar:CreateTexture(nil, "OVERLAY")
    f.spark:SetTexture("Interface\\AddOns\\PhoenixCastBars\\Media\\phoenix_spark.blp")
    f.spark:SetWidth(4)
    f.spark:SetBlendMode("ADD")
    f.spark:SetAlpha(0.85)
    f.spark:Hide()

    f.safeZone = f.bar:CreateTexture(nil, "OVERLAY")
    f.safeZone:SetPoint("TOPRIGHT")
    f.safeZone:SetPoint("BOTTOMRIGHT")
    f.safeZone:Hide()

    f.flash = f.bar:CreateTexture(nil, "OVERLAY")
    f.flash:SetAllPoints(f.bar)
    f.flash:SetTexture("Interface\\Buttons\\WHITE8x8")
    f.flash:SetBlendMode("ADD")
    f.flash:SetAlpha(0)
    f.flash:Hide()

    f.icon = f:CreateTexture(nil, "OVERLAY")
    f.icon:SetPoint("RIGHT", f, "LEFT", -6, 0)
    f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    f.icon:Hide()

    f.shield = f:CreateTexture(nil, "OVERLAY")
    f.shield:SetAllPoints(f.icon)
    f.shield:SetDrawLayer("OVERLAY", 7)
    f.shield:SetAtlas("nameplates-InterruptShield")
    f.shield:Hide()

    f.empowerStages = {}
    for i = 1, 3 do
        local sf = CreateFrame("Frame", nil, f)
        sf:SetWidth(4)
        sf:SetHeight(24)
        sf:SetFrameStrata("HIGH")
        sf:SetFrameLevel(f:GetFrameLevel() + 10)
        local st = sf:CreateTexture(nil, "OVERLAY")
        st:SetAllPoints(sf)
        st:SetColorTexture(1, 1, 1, 1)
        sf:Hide()
        f.empowerStages[i] = sf
    end

    f.textOverlay = CreateFrame("Frame", nil, f)
    f.textOverlay:SetAllPoints(f)
    f.textOverlay:SetFrameLevel(f:GetFrameLevel() + 20)

    f.spellText = f.textOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.spellText:SetJustifyH("LEFT")
    f.spellText:SetPoint("LEFT", f.bar, "LEFT", 6, 0)

    f.timeText = f.textOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.timeText:SetJustifyH("RIGHT")
    f.timeText:SetPoint("RIGHT", f.bar, "RIGHT", -6, 0)

    f.dragText = f.textOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.dragText:SetPoint("RIGHT", f.bar, "RIGHT", -6, 0)
    f.dragText:SetJustifyH("RIGHT")
    f.dragText:SetTextColor(1, 1, 1, 0.8)
    f.dragText:Hide()

    f.unlockLabel = f.textOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.unlockLabel:SetPoint("LEFT", f, "LEFT", 2, 1)
    f.unlockLabel:SetJustifyH("LEFT")
    f.unlockLabel:SetTextColor(0.95, 0.45, 0.10, 1)
    f.unlockLabel:Hide()

    container:SetMovable(true)
    container:SetClampedToScreen(true)
    container:SetClampRectInsets(0, 0, 0, 0)
    container:EnableMouse(false)
    container:RegisterForDrag()

    return f
end

-- =====================================================================
-- PCB.ApplyAppearance(f)
-- =====================================================================
function PCB.ApplyAppearance(f)
    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}

    if f.container then
        f.container:ClearAllPoints()
        f.container:SetPoint(
            bdb.point    or "CENTER",
            UIParent,
            bdb.relPoint or "CENTER",
            bdb.x or 0,
            bdb.y or 0)
        f.container:SetAlpha(bdb.alpha or 1)
    end

    -- When vertical, swap the default width/height so the bar is tall and thin.
    local isVert = bdb.vertical == true
    local defaultW = isVert and 16  or 240
    local defaultH = isVert and 240 or 16
    f:SetSize(bdb.width or defaultW, bdb.height or defaultH)
    f:SetScale(bdb.scale or 1)

    UpdateVisualSizes(f)
    ApplyIconOffsets(f)
    ApplyLabelPosition(f)
    ApplyOrientation(f)

    local texPath, fontPath, fontSize, flags = PCB.ResolvePerBarOverrides(db, bdb)

    PCB.Try.SetStatusBarTexture(f.bar, texPath)
    PCB.Try.SetFont(f.spellText, fontPath, fontSize, flags)
    PCB.Try.SetFont(f.timeText,  fontPath, fontSize, flags)
    if f.dragText then
        PCB.Try.SetFont(f.dragText, fontPath, fontSize + 2, flags)
    end

    if f.safeZone then
        local szc = db.safeZoneColor or { r = 1.0, g = 0.2, b = 0.2, a = 0.35 }
        pcall(function()
            f.safeZone:SetColorTexture(szc.r or 1, szc.g or 0.2, szc.b or 0.2, szc.a or 0.35)
        end)
    end

    if f.bg then
        local bdc = bdb.backdropColor or { r = 0.06, g = 0.06, b = 0.08, a = 0.85 }
        local brc = bdb.borderColor   or { r = 0.20, g = 0.20, b = 0.25, a = 0.95 }
        pcall(function()
            f.bg:SetBackdropColor(
                bdc.r or 0.06, bdc.g or 0.06, bdc.b or 0.08, bdc.a or 0.85)
            f.bg:SetBackdropBorderColor(
                brc.r or 0.20, brc.g or 0.20, brc.b or 0.25, brc.a or 0.95)
        end)
    end
end
