-- PhoenixCastBars - Bars/Events.lua
-- Owns the cast bar event frame and top-level bar management:
--   PCB:IsBarEnabled    — check whether a bar key is active in db
--   PCB:CreateBars      — allocate bars and wire up spell events
--   PCB:DestroyBars     — tear down all bars and the event frame
--   PCB:ApplyAll        — re-apply db settings to every bar

local ADDON_NAME, PCB = ...

-- =====================================================================
-- PCB:IsBarEnabled(key)
-- =====================================================================
function PCB:IsBarEnabled(key)
    local db  = PCB.db
    local bdb = db and db.bars and db.bars[key]
    return not (bdb and bdb.enabled == false)
end

-- =====================================================================
-- PCB:CreateBars
-- Allocates bar frames and registers the spell event frame.
-- Safe to call multiple times — subsequent calls are no-ops.
-- =====================================================================
function PCB:CreateBars()
    -- Allocate unit bars
    for key in pairs(PCB.BAR_UNITS) do
        if not self.Bars[key] then
            self.Bars[key] = PCB.CreateCastBarFrame(key)
            PCB.ApplyAppearance(self.Bars[key])
        end
    end

    -- Allocate GCD bar
    if not self.Bars.gcd then
        self.Bars.gcd = PCB.CreateCastBarFrame("gcd")
        PCB.ApplyAppearance(self.Bars.gcd)
    end

    if self.eventFrame then return end  -- Already wired

    local ef = CreateFrame("Frame")
    for _, e in ipairs(PCB.BAR_EVENTS) do ef:RegisterEvent(e) end
    ef:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    -- Explicitly register interrupt events for tracked units with all potential unit tokens
    for _, unitToken in ipairs({"player", "target", "focus", "pet", "vehicle", "override"}) do
        ef:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unitToken)
        ef:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unitToken)
    end
    -- Also register for nameplate units (nameplate1 through nameplate40)
    for i = 1, 40 do
        ef:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "nameplate" .. i)
        ef:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "nameplate" .. i)
    end

    local function RefreshAllMatching(unitEvent)
        if not unitEvent then return end
        for key, f in pairs(self.Bars) do
            if f then
                local eff = PCB.GetEffectiveUnit(f, key)
                if unitEvent == f.unit or unitEvent == eff
                   or unitEvent == f._effectiveUnit then
                    PCB.RefreshFrame(f, key)
                end
            end
        end
    end

    ef:SetScript("OnEvent", function(_, event, unit, ...)
        -- Target / focus change: reset cached effective unit and refresh
        if event == "PLAYER_TARGET_CHANGED" then
            local f = self.Bars.target
            if f then
                f._effectiveUnit      = nil
                f._effectiveUnitActive = false
                f._endGraceUntil      = nil
                PCB.ArmStopCheck(f, "target")
                PCB.RefreshFrame(f, "target")
            end
            return
        end

        if event == "PLAYER_FOCUS_CHANGED" then
            local f = self.Bars.focus
            if f then
                f._effectiveUnit      = nil
                f._effectiveUnitActive = false
                f._endGraceUntil      = nil
                PCB.ArmStopCheck(f, "focus")
                PCB.RefreshFrame(f, "focus")
            end
            return
        end

        if event == "PLAYER_ENTERING_WORLD" or event == "VEHICLE_UPDATE" then
            local fp = self.Bars.player
            if fp then PCB.ArmStopCheck(fp, "player"); PCB.RefreshFrame(fp, "player") end
            local fpt = self.Bars.pet
            if fpt then PCB.ArmStopCheck(fpt, "pet");   PCB.RefreshFrame(fpt, "pet")   end
            return
        end

        -- Pet bar: reset and refresh when companion changes
        if event == "UNIT_PET" and unit == "player" then
            local fpt = self.Bars.pet
            if fpt then
                fpt._effectiveUnit       = nil
                fpt._effectiveUnitActive = false
                fpt._endGraceUntil       = nil
                PCB.ArmStopCheck(fpt, "pet")
                PCB.RefreshFrame(fpt, "pet")
            end
            return
        end

        -- Trigger GCD bar on any player spell completion
        if event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" then
            local fgcd = self.Bars.gcd
            if fgcd and PCB.GCD and PCB.GCD.StartGCDBar then
                PCB.GCD.StartGCDBar(fgcd)
            end
        end

        -- Latency tracking: read world latency directly from WoW on each cast start.
        -- Event-timing (SENT -> START delta) always returns 0ms because both events
        -- fire in the same frame. GetNetStats() gives the real network latency.
        if event == "UNIT_SPELLCAST_START" and unit == "player" then
            local fp = self.Bars.player
            if fp then
                local ok, _, _, _, worldLatencyMs = pcall(GetNetStats)
                if ok and type(worldLatencyMs) == "number" and worldLatencyMs > 0 then
                    fp._latency = worldLatencyMs / 1000  -- convert ms -> seconds
                end
            end
        end

        -- Cast success flash
        if event == "UNIT_SPELLCAST_SUCCEEDED" and unit then
            for _, f in pairs(self.Bars) do
                if f and f._state then
                    local eff = PCB.GetEffectiveUnit(f, f.key)
                    if unit == f.unit or unit == eff or unit == f._effectiveUnit then
                        PCB.TriggerFlash(f, "success")
                    end
                end
            end
        end

        -- Cast fail / interrupt flash
        if (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and unit then
            for _, f in pairs(self.Bars) do
                if f and f._state then
                    local eff = PCB.GetEffectiveUnit(f, f.key)
                    if unit == f.unit or unit == eff or unit == f._effectiveUnit then
                        PCB.TriggerFlash(f, "failed")
                    end
                end
            end
        end

        -- Independent interrupt detection: update notInterruptible on relevant bars
        if (event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
           and unit then
            local notInterruptible = (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
            for _, f in pairs(self.Bars) do
                if f and f._state then
                    local eff = PCB.GetEffectiveUnit(f, f.key)
                    if unit == f.unit or unit == eff or unit == f._effectiveUnit then
                        -- Update interrupt status and re-apply colors
                        f._state.notInterruptible = notInterruptible
                        PCB.ApplyCastBarColor(f)
                    end
                end
            end
            -- DON'T call RefreshAllMatching here - it would overwrite notInterruptible!
            -- The color is updated above, and the shield/icon will update on next frame.
        elseif unit then
            RefreshAllMatching(unit)
        end
    end)

    self.eventFrame = ef

    -- Initial refresh of all bars
    for key, f in pairs(self.Bars) do
        if f and key ~= "gcd" then
            PCB.ArmStopCheck(f, key)
            PCB.RefreshFrame(f, key)
        end
    end
end

-- =====================================================================
-- PCB:DestroyBars
-- =====================================================================
function PCB:DestroyBars()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end

    for key, f in pairs(self.Bars) do
        if f and f.Hide then f:Hide() end
        self.Bars[key] = nil
    end
end

-- =====================================================================
-- PCB:ApplyAll
-- Re-syncs every bar to the current db: appearance, colour, visibility.
-- =====================================================================
function PCB:ApplyAll()
    if not self.Bars then return end

    for _, f in pairs(self.Bars) do
        local key = f and f.key
        if key and not PCB:IsBarEnabled(key) then
            PCB.ResetState(f, true)
        else
            PCB.ApplyAppearance(f)
            PCB.ApplyCastBarColor(f)

            if key == "gcd" and not (self.db and self.db.bars and
                                     self.db.bars.gcd and
                                     self.db.bars.gcd.enabled) then
                if f.container then f.container:Hide() end
                f:Hide()
            elseif self.db and self.db.locked
                   and not f._state and not f.test and not f.isMover then
                if f.container then f.container:Hide() end
                f:Hide()
            end
        end
    end

    if not self.testMode and self.SetMoverMode then
        self:SetMoverMode(self.db and (not self.db.locked))
    end

    if PCB.UpdateBlizzardCastBars then
        PCB:UpdateBlizzardCastBars()
    end
end