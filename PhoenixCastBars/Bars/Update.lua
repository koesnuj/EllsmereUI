-- PhoenixCastBars - Bars/Update.lua
-- PCB.FrameOnUpdate: the per-frame ticker attached to every active cast bar.
-- Handles progress tracking, spark, safe-zone, time text, flash, shield.
--
-- Helpers: uses PCB.Try.*, PCB.SafeNow, PCB.FormatTime from Core/Util.lua.

local ADDON_NAME, PCB = ...

-- =====================================================================
-- PCB.FrameOnUpdate(f, elapsed)
-- =====================================================================
function PCB.FrameOnUpdate(f, elapsed)
    if not f then return end

    local st = f._state

    -- GCD bars: simple expiry check then fall through to shared rendering
    if st and st.kind == "gcd" then
        local now = PCB.SafeNow()
        if st.endSec and now >= st.endSec then
            if f.container then f.container:Hide() end
            f:Hide()
            f._state = nil
            f:SetScript("OnUpdate", nil)
            return
        end
        if f.bar and st.startSec then
            local bdb    = (PCB.db and PCB.db.bars and PCB.db.bars["gcd"]) or {}
            local reverse = bdb.gcdReverseFill == true
            -- Reverse (drain): value goes from duration→0, bar shrinks from right.
            -- Normal (fill):   value goes from 0→duration, bar grows to right.
            local val = reverse and (st.endSec - now) or (now - st.startSec)
            PCB.Try.SetValue(f.bar, val)
        end
    else
        PCB.VerifyAndStopIfInactive(f)
    end

    if not f._state then
        f:SetScript("OnUpdate", nil)
        return
    end

    st  = f._state
    local now = PCB.SafeNow()

    -- ----------------------------------------------------------------
    -- Interrupt status fallback detection
    -- If we still don't have interrupt status after a brief delay,
    -- try to detect it another way (for target/focus only)
    -- ----------------------------------------------------------------
    if st.notInterruptible == nil and st.durationSec then
        if not f._interruptCheckTime then
            f._interruptCheckTime = now
        elseif (now - f._interruptCheckTime) > 0.2 then
            f._interruptCheckTime = nil
            -- No event fired in 200 ms — assume interruptible as a safe default.
            if st.notInterruptible == nil and f.key ~= "player" then
                st.notInterruptible = false
            end
        end
    end

    -- ----------------------------------------------------------------
    -- Periodic poll (non-GCD)
    -- ----------------------------------------------------------------
    if st.kind ~= "gcd" then
        f._pollElapsed = (f._pollElapsed or 0) + (elapsed or 0)
        if f._pollElapsed >= PCB.POLL_INTERVAL then
            f._pollElapsed = 0

            if f.key == "target" then
                local u = PCB.GetEffectiveUnit(f, "target")
                if u ~= st.unit then PCB.StartOrRefreshFromUnit(f, u); return end
            elseif f.key == "focus" then
                local u = PCB.GetEffectiveUnit(f, "focus")
                if u ~= st.unit then PCB.StartOrRefreshFromUnit(f, u); return end
            end

            PCB.StopIfReallyStopped(f, st.unit)
        end
    end

    -- ----------------------------------------------------------------
    -- Compute remaining / elapsed  (UCB pattern — durationObj only)
    -- durationObject:GetRemainingDuration() and :GetElapsedDuration() return
    -- plain non-secret numbers, exactly as UltimateCastbars CastBar_OnUpdate:
    --   remaining   = durationObject:GetRemainingDuration()
    --   elapsedTime = durationObject:GetElapsedDuration()
    -- No arithmetic on secret timestamps; no _localStartTime tracking needed.
    -- ----------------------------------------------------------------
    local remaining, elapsedSec

    if st.kind == "gcd" then
        -- GCD timestamps come from GetTime() directly — always plain numbers.
        remaining  = math.max(0, st.endSec - now)
        elapsedSec = math.max(0, now - st.startSec)
    elseif st.durationObj and st.durationObj.GetRemainingDuration then
        -- All non-GCD bars: use the durationObject exclusively.
        remaining  = st.durationObj:GetRemainingDuration()
        elapsedSec = st.durationObj.GetElapsedDuration and
                     st.durationObj:GetElapsedDuration() or 0
        if type(remaining)  ~= "number" then remaining  = 0 end
        if type(elapsedSec) ~= "number" then elapsedSec = 0 end
    else
        -- No durationObj — cannot drive timing safely. Stop the bar.
        PCB.StopIfReallyStopped(f, st.unit)
        return
    end

    -- No clamping: remaining/elapsedSec are secret for enemy units.
    -- math.max/math.min do comparisons and will crash. Pass directly to
    -- SetValue/SetText — widget APIs and string.format accept secret values.

    -- ----------------------------------------------------------------
    -- Bar fill (manual path — skipped only if native timer was activated)
    -- ----------------------------------------------------------------
    if st.kind ~= "gcd" and not st.nativeTimerActive then
        -- Pass secret values directly — SetValue accepts them. No clamping.
        PCB.Try.SetValue(f.bar, (st.kind == "channel") and remaining or elapsedSec)
    end

    local db  = PCB.db or {}
    local bdb = (db.bars and db.bars[f.key]) or {}

    -- ----------------------------------------------------------------
    -- Safe-zone / latency indicator (player bar only)
    -- ----------------------------------------------------------------
    if f.key == "player" and f._latency and f._latency > 0
       and st.durationSec and st.durationSec > 0 then
        if bdb.showLatency ~= false then
            local szc     = db.safeZoneColor or { r = 1.0, g = 0.2, b = 0.2, a = 0.35 }
            local latency = math.min(f._latency, st.durationSec)
            local ratio   = latency / st.durationSec
            local width   = f.bar:GetWidth()
            pcall(function()
                f.safeZone:SetColorTexture(
                    szc.r or 1, szc.g or 0.2, szc.b or 0.2, szc.a or 0.35)
                f.safeZone:SetWidth(width * ratio)
                f.safeZone:Show()
            end)
        else
            f.safeZone:Hide()
        end
    else
        if f.safeZone then f.safeZone:Hide() end
    end

    -- ----------------------------------------------------------------
    -- Empower stage markers
    -- ----------------------------------------------------------------
    if st.kind == "cast" then
        PCB.UpdateEmpowerStages(f)
    end

    -- ----------------------------------------------------------------
    -- Interrupt shield / icon swap
    -- EvaluateColorValueFromBoolean accepts a secret bool and returns a
    -- secret number that SetAlpha accepts directly — no Lua branch needed.
    -- Shield alpha: 1 when notInterruptible is true, 0 otherwise.
    -- Icon  alpha: 0 when notInterruptible is true, 1 otherwise (inverse).
    -- ----------------------------------------------------------------
    if f.shield and f.icon then
        f.shield:Show()
        f.icon:Show()
        f.shield:SetAlpha(C_CurveUtil.EvaluateColorValueFromBoolean(st.notInterruptible, 1, 0))
        f.icon:SetAlpha(  C_CurveUtil.EvaluateColorValueFromBoolean(st.notInterruptible, 0, 1))
    end

    -- ----------------------------------------------------------------
    -- Spark
    -- ----------------------------------------------------------------
    if f.spark and f.bar and f.bar.GetStatusBarTexture then
        if bdb.showSpark ~= false then
            local tex = f.bar:GetStatusBarTexture()
            if tex then
                f.spark:ClearAllPoints()
                if bdb.vertical then
                    f.spark:SetPoint("CENTER", tex, "TOP", 0, 0)
                else
                    f.spark:SetPoint("CENTER", tex, "RIGHT", 0, 0)
                end
                f.spark:Show()
            end
        else
            f.spark:Hide()
        end
    end

    -- ----------------------------------------------------------------
    -- Time text (throttled)
    -- ----------------------------------------------------------------
    f._textElapsed = (f._textElapsed or 0) + (elapsed or 0)
    if f._textElapsed >= PCB.TEXT_UPDATE_INTERVAL then
        f._textElapsed = 0
        if f.timeText then
            if bdb.showTime == true then
                local fmt   = bdb.timeFormat or db.timeFormat or "remaining"
                local total = st.durationSec
                
                -- Ensure remaining is a plain number before formatting
                local displayRemaining = remaining
                if type(remaining) ~= "number" then
                    displayRemaining = 0
                end
                
                local ok, s = pcall(PCB.FormatTime, displayRemaining, total, fmt)
                f.timeText:SetText((ok and s) and s or "")
            else
                f.timeText:SetText("")
            end
        end
    end

    -- ----------------------------------------------------------------
    -- Flash animation
    -- ----------------------------------------------------------------
    if f._flashDuration and f._flashDuration > 0 and f.flash then
        f._flashTimer = (f._flashTimer or 0) + (elapsed or 0)
        if f._flashTimer >= f._flashDuration then
            f.flash:Hide()
            f.flash:SetAlpha(0)
            f._flashTimer    = 0
            f._flashDuration = 0
        else
            local alpha = 0.65 * (1 - f._flashTimer / f._flashDuration)
            pcall(function() f.flash:SetAlpha(alpha) end)
        end
    end
end
