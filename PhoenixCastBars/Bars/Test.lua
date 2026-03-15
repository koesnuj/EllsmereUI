-- PhoenixCastBars - Bars/Test.lua
-- PCB:SetTestMode(enabled)
-- Injects a fake cast state into every bar for appearance previewing.
-- Supports: "cast" | "channel" | "empower" via db.testModeType.
--
-- Helpers: uses PCB.Try.* from Core/Util.lua.

local ADDON_NAME, PCB = ...

function PCB:SetTestMode(enabled)
    self.testMode = enabled and true or false
    if not self.Bars then return end

    local db       = self.db or {}
    local testType = db.testModeType or "cast"

    for _, f in pairs(self.Bars) do
        local key = f and f.key
        if key and not PCB:IsBarEnabled(key) then
            PCB.ResetState(f, true)
        elseif self.testMode then
            local kind, name, duration, barValue

            if testType == "channel" then
                kind     = "channel"
                name     = "Test Channel"
                duration = 4.0
                barValue = duration
            elseif testType == "empower" then
                kind     = "cast"
                name     = "Fire Breath"
                duration = 3.0
                barValue = duration * 0.4
            else
                kind     = "cast"
                name     = "Test Cast"
                duration = 3.5
                barValue = duration * 0.5
            end

            f.test   = true
            f._state = {
                kind                = kind,
                name                = name,
                texture             = "Interface\\Icons\\INV_Misc_QuestionMark",
                notInterruptible    = false,
                notInterruptibleBool = false,
                durationObj         = nil,
                durationSec         = duration,
                startSec            = GetTime() - barValue,
                endSec              = GetTime() + (duration - barValue),
            }

            PCB.SetIcon(f, f._state.texture)
            PCB.ApplyAppearance(f)
            PCB.ApplyCastBarColor(f)
            PCB.EnsureVisible(f)
            PCB.Try.SetMinMax(f.bar, 0, duration)
            PCB.Try.SetValue(f.bar, barValue)
            PCB.SetTexts(f, f._state.name, duration - barValue)
            PCB.ApplySparkFromFillTexture(f)

            if testType == "empower" then
                PCB.UpdateEmpowerStages(f)
            end
        else
            f.test = nil
            PCB.ResetState(f, true)
        end
    end
end
