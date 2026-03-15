-- PhoenixCastBars - Core/Util.lua
-- Single source for every small helper that was previously copy-pasted
-- across Frame.lua, State.lua, Drag.lua, Test.lua, Update.lua, etc.
-- All other files use PCB.Try.* / PCB.DeepCopy / PCB.SafeNow instead of
-- declaring their own local versions.

local ADDON_NAME, PCB = ...

-- =====================================================================
-- PCB.Try  — safe-call wrappers for WoW widget methods
-- =====================================================================
PCB.Try = {}

function PCB.Try.SetValue(sb, v)
    if not sb then return end
    pcall(function() sb:SetValue(v) end)
end

function PCB.Try.SetMinMax(sb, a, b)
    if not sb then return end
    pcall(function() sb:SetMinMaxValues(a, b) end)
end

function PCB.Try.SetText(fs, s)
    if not fs then return end
    pcall(function() fs:SetText(s or "") end)
end

function PCB.Try.SetFont(fs, font, size, flags)
    if not fs then return end
    pcall(function() fs:SetFont(font, size, flags) end)
end

function PCB.Try.SetTexture(texObj, path)
    if not texObj then return end
    pcall(function() texObj:SetTexture(path) end)
end

function PCB.Try.SetStatusBarTexture(sb, tex)
    if not sb then return end
    pcall(function() sb:SetStatusBarTexture(tex) end)
end

-- Returns true if the SetTimerDuration call succeeded.
function PCB.Try.SetTimerDuration(sb, durationObj, interpolation, direction)
    if not sb or not sb.SetTimerDuration then return false end
    local ok = pcall(function()
        if interpolation ~= nil and direction ~= nil then
            sb:SetTimerDuration(durationObj, interpolation, direction)
        elseif interpolation ~= nil then
            sb:SetTimerDuration(durationObj, interpolation)
        else
            sb:SetTimerDuration(durationObj)
        end
    end)
    return ok
end

-- =====================================================================
-- General utilities
-- =====================================================================

-- Recursive deep copy. Works on plain data tables (no metatables).
function PCB.DeepCopy(src)
    if type(src) ~= "table" then return src end
    local out = {}
    for k, v in pairs(src) do out[k] = PCB.DeepCopy(v) end
    return out
end

-- Thin wrapper around GetTime() — keeps callers readable and lets us
-- swap the implementation in tests without touching every file.
function PCB.SafeNow()
    return GetTime()
end

-- Safely divide millisecond timestamps to seconds.
-- Returns nil rather than erroring if the value is tainted/secret.
function PCB.SafeDivMsToSec(ms)
    local ok, r = pcall(function() return ms / 1000 end)
    return (ok and type(r) == "number") and r or nil
end

-- Standard round-half-up.
function PCB.Round(n)
    if type(n) ~= "number" then return 0 end
    return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
end

-- Format a cast timer string. fmt: "remaining" (default) or "both".
function PCB.FormatTime(remaining, total, fmt)
    if fmt == "both" and total and total > 0 then
        return string.format("%.1f / %.1f", remaining, total)
    else
        return string.format("%.1f", remaining)
    end
end
