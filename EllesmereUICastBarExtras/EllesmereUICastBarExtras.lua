-------------------------------------------------------------------------------
--  EllesmereUICastBarExtras.lua
--
--  Hooks into EllesmereUIUnitFrames' oUF castbars and adds ElvUI-style
--  enhancements:  Spark, Latency (SafeZone), Smoothing, Channel Tick marks,
--  and Empowered Cast Pip styling.
--
--  This addon does NOT modify EllesmereUIUnitFrames — it only attaches extra
--  sub-widgets and hooks oUF callbacks that the base castbar already supports.
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
--  oUF frame names created by EllesmereUIUnitFrames
-------------------------------------------------------------------------------
local FRAME_UNITS = {
    { unit = "player", name = "EllesmereUIUnitFrames_Player" },
    { unit = "target", name = "EllesmereUIUnitFrames_Target" },
    { unit = "focus",  name = "EllesmereUIUnitFrames_Focus"  },
}

-------------------------------------------------------------------------------
--  Channel tick data  (spellID → base tick count)
--  The War Within Season 2 — common channeled spells
-------------------------------------------------------------------------------
local CHANNEL_TICKS = {
    -- Priest
    [15407]  = 4,    -- Mind Flay
    [391403] = 4,    -- Mind Flay: Insanity
    [263165] = 4,    -- Void Torrent
    [64843]  = 4,    -- Divine Hymn
    [47540]  = 3,    -- Penance
    [373129] = 3,    -- Dark Reprimand (Shadow Penance)
    -- Mage
    [5143]   = 5,    -- Arcane Missiles
    [12051]  = 3,    -- Evocation
    [205021] = 5,    -- Ray of Frost
    -- Warlock
    [198590] = 6,    -- Drain Soul
    [234153] = 5,    -- Drain Life
    [755]    = 5,    -- Health Funnel
    [384069] = 3,    -- Malefic Rapture (if channeled variant)
    -- Druid
    [740]    = 4,    -- Tranquility
    -- Monk
    [117952] = 4,    -- Crackling Jade Lightning
    [191837] = 3,    -- Essence Font
    -- Evoker
    [356995] = 3,    -- Disintegrate
    -- Hunter
    [120360] = 15,   -- Barrage
    [257620] = 10,   -- Multi-Shot (rapid fire)
    [257044] = 7,    -- Rapid Fire
    -- Demon Hunter
    [198013] = 9,    -- Eye Beam
    [211053] = 3,    -- Fel Barrage
    -- Death Knight
    [152279] = 3,    -- Breath of Sindragosa (tick-like)
    -- Shaman
    [188443] = 3,    -- Chain Lightning (if channeled)
    -- Warrior — none commonly channeled
}

-------------------------------------------------------------------------------
--  Helpers
-------------------------------------------------------------------------------
local function UnsnapTex(tex)
    if tex and tex.SetSnapToPixelGrid then
        tex:SetSnapToPixelGrid(false)
        tex:SetTexelSnappingBias(0)
    end
end

-------------------------------------------------------------------------------
--  1. Spark  (thin bright line at the fill edge)
--
--  oUF natively shows/hides castbar.Spark on cast start/stop/fail.
--  We just create the texture and assign it.
-------------------------------------------------------------------------------
local function AddSpark(castbar)
    if castbar._ecbe_spark then return end

    local barTex = castbar:GetStatusBarTexture()
    if not barTex then return end

    local spark = castbar:CreateTexture(nil, "OVERLAY", nil, 5)
    spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    spark:SetVertexColor(0.9, 0.9, 0.9, 0.6)
    spark:SetBlendMode("ADD")
    spark:SetWidth(2)
    spark:SetPoint("TOP", barTex, "TOPRIGHT", 0, 0)
    spark:SetPoint("BOTTOM", barTex, "BOTTOMRIGHT", 0, 0)
    UnsnapTex(spark)
    spark:Hide()

    castbar._ecbe_spark = spark
    castbar.Spark = spark   -- oUF reads this field
end

-------------------------------------------------------------------------------
--  2. SafeZone / Latency  (player castbar only)
--
--  oUF natively positions and sizes castbar.SafeZone based on latency.
--  We just create the texture and assign it.
-------------------------------------------------------------------------------
local function AddSafeZone(castbar)
    if castbar._ecbe_safeZone then return end

    local sz = castbar:CreateTexture(nil, "OVERLAY", nil, 3)
    sz:SetTexture("Interface\\Buttons\\WHITE8X8")
    sz:SetVertexColor(0.69, 0.31, 0.31, 0.75)
    UnsnapTex(sz)
    sz:Hide()

    castbar._ecbe_safeZone = sz
    castbar.SafeZone = sz   -- oUF reads this field
end

-------------------------------------------------------------------------------
--  3. Smoothing
--
--  oUF reads castbar.smoothing in its Enable function and passes it to
--  SetTimerDuration.
-------------------------------------------------------------------------------
local function SetSmoothing(castbar)
    if Enum and Enum.StatusBarInterpolation then
        castbar.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    end
end

-------------------------------------------------------------------------------
--  4. Channel Tick marks
--
--  Draws evenly-spaced vertical lines on the castbar to show tick intervals
--  for channeled spells.  Only shown for the player unit.
-------------------------------------------------------------------------------
local function HideTicks(castbar)
    if not castbar._ecbe_ticks then return end
    for _, tick in ipairs(castbar._ecbe_ticks) do
        tick:Hide()
    end
end

local function SetTicks(castbar, numTicks)
    HideTicks(castbar)
    if not numTicks or numTicks <= 0 then return end

    if not castbar._ecbe_ticks then
        castbar._ecbe_ticks = {}
    end

    local barWidth = castbar:GetWidth()
    if barWidth <= 0 then return end

    local spacing = barWidth / numTicks

    for i = 1, numTicks - 1 do
        local tick = castbar._ecbe_ticks[i]
        if not tick then
            tick = castbar:CreateTexture(nil, "OVERLAY", nil, 4)
            tick:SetTexture("Interface\\Buttons\\WHITE8X8")
            tick:SetVertexColor(0, 0, 0, 0.8)
            tick:SetWidth(1)
            UnsnapTex(tick)
            castbar._ecbe_ticks[i] = tick
        end

        tick:ClearAllPoints()
        tick:SetPoint("TOP")
        tick:SetPoint("BOTTOM")
        tick:SetPoint("RIGHT", castbar, "LEFT", spacing * i, 0)
        tick:Show()
    end
end

-------------------------------------------------------------------------------
--  5. Empowered Pip styling
--
--  oUF creates Pips for empowered casts via CastingBarFrameStagePipTemplate.
--  We override the visual appearance via PostUpdatePips to use flat colored
--  lines matching the ElvUI aesthetic.
-------------------------------------------------------------------------------
local function SetupPipStyling(castbar)
    if castbar._ecbe_pipsStyled then return end

    local origPostUpdatePips = castbar.PostUpdatePips
    castbar.PostUpdatePips = function(self, stages)
        if self.Pips then
            for _, pip in pairs(self.Pips) do
                -- Hide the default art
                if pip.BasePip then
                    pip.BasePip:SetAlpha(0)
                end
                -- Create our flat line texture once per pip
                if not pip._ecbe_styled then
                    local tex = pip:CreateTexture(nil, "ARTWORK", nil, 2)
                    tex:SetTexture("Interface\\Buttons\\WHITE8X8")
                    tex:SetVertexColor(1, 1, 1, 0.8)
                    tex:SetPoint("TOP")
                    tex:SetPoint("BOTTOM")
                    tex:SetWidth(2)
                    UnsnapTex(tex)
                    pip._ecbe_tex = tex
                    pip._ecbe_styled = true
                end
            end
        end
        if origPostUpdatePips then origPostUpdatePips(self, stages) end
    end

    castbar._ecbe_pipsStyled = true
end

-------------------------------------------------------------------------------
--  Hook PostCastStart / PostCastStop chains for tick marks
--
--  We wrap the existing callbacks set by EllesmereUIUnitFrames so original
--  behaviour (show/hide castbar bg, icon, color tinting) is preserved.
-------------------------------------------------------------------------------
local function HookTickCallbacks(castbar, unit)
    if castbar._ecbe_ticksHooked then return end

    -- Ticks are player-only; skip hook for other units
    if unit ~= "player" then
        castbar._ecbe_ticksHooked = true
        return
    end

    -- Save originals set by EllesmereUIUnitFrames' SetupShowOnCastBar
    local origPostCastStart   = castbar.PostCastStart
    local origPostCastStop    = castbar.PostCastStop
    local origPostChannelStop = castbar.PostChannelStop
    local origPostCastFail    = castbar.PostCastFail

    castbar.PostCastStart = function(self, u)
        -- Draw tick marks for known channeled spells
        if self.channeling and self.spellID then
            local ticks = CHANNEL_TICKS[self.spellID]
            if ticks then
                SetTicks(self, ticks)
            else
                HideTicks(self)
            end
        else
            HideTicks(self)
        end
        -- Call original (shows bg, castbar, icon, sets colors)
        if origPostCastStart then origPostCastStart(self, u) end
    end
    castbar.PostChannelStart = castbar.PostCastStart

    castbar.PostCastStop = function(self, u, ...)
        HideTicks(self)
        if origPostCastStop then origPostCastStop(self, u, ...) end
    end

    castbar.PostChannelStop = function(self, u, ...)
        HideTicks(self)
        if origPostChannelStop then origPostChannelStop(self, u, ...) end
    end

    castbar.PostCastFail = function(self, u, ...)
        HideTicks(self)
        if origPostCastFail then origPostCastFail(self, u, ...) end
    end

    castbar._ecbe_ticksHooked = true
end

-------------------------------------------------------------------------------
--  Main: find EllesmereUIUnitFrames frames and enhance their castbars
-------------------------------------------------------------------------------
local function EnhanceCastbars()
    for _, info in ipairs(FRAME_UNITS) do
        local frame = _G[info.name]
        if frame and frame.Castbar then
            local castbar = frame.Castbar

            -- 1. Spark
            AddSpark(castbar)

            -- 2. Latency (player only)
            if info.unit == "player" then
                AddSafeZone(castbar)
            end

            -- 3. Smoothing
            SetSmoothing(castbar)

            -- 4. Empowered Pip styling
            SetupPipStyling(castbar)

            -- 5. Channel tick marks (hooks PostCastStart chain)
            HookTickCallbacks(castbar, info.unit)
        end
    end
end

-------------------------------------------------------------------------------
--  Lifecycle
--
--  EllesmereUIUnitFrames spawns oUF frames during PLAYER_LOGIN.  We wait
--  a short delay to ensure all frames and castbars are fully created before
--  attaching our enhancements.
-------------------------------------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    C_Timer.After(1.0, EnhanceCastbars)
end)
