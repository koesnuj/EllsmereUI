-- PhoenixCastBars - Core/Taint.lua
-- Proper handling of secret boolean values using C_CurveUtil APIs.
--
-- Key Pattern:
-- - Get secret boolean from API (don't test it)
-- - Convert to number via C_CurveUtil.EvaluateColorValueFromBoolean
-- - Pass that number directly to SetAlpha(), SetValue(), etc.
-- - Use C_CurveUtil.EvaluateColorFromBoolean for color selection

local ADDON_NAME, PCB = ...

-- =====================================================================
-- PCB.SecretBoolToAlpha(secretVal, alphaIfTrue, alphaIfFalse) → number
--
-- Converts a secret boolean to an alpha value (0-1) without testing it.
-- Works with both secret booleans from APIs and plain booleans from events.
-- =====================================================================
function PCB.SecretBoolToAlpha(secretVal, alphaIfTrue, alphaIfFalse)
    if alphaIfTrue == nil then alphaIfTrue = 1 end
    if alphaIfFalse == nil then alphaIfFalse = 0 end
    
    -- Don't test the value ourselves - let the API handle both secret and plain booleans
    local ok, result = pcall(function()
        return C_CurveUtil.EvaluateColorValueFromBoolean(secretVal, alphaIfTrue, alphaIfFalse)
    end)
    
    -- If API fails, return the "false" value (safe default)
    return (ok and result) or alphaIfFalse
end

-- =====================================================================
-- PCB.SecretBoolToColor(secretVal, colorIfTrue, colorIfFalse) → color
--
-- Converts a secret boolean to a color without testing it.
-- Returns a table with r, g, b, a or a ColorMixin object.
-- Works with both secret booleans from APIs and plain booleans from events.
-- =====================================================================
function PCB.SecretBoolToColor(secretVal, colorIfTrue, colorIfFalse)
    if colorIfTrue == nil then colorIfTrue = {r=1, g=0, b=0, a=1} end
    if colorIfFalse == nil then colorIfFalse = {r=0, g=0, b=1, a=1} end
    
    -- Don't test the value ourselves - let the API handle both secret and plain booleans
    local ok, result = pcall(function()
        return C_CurveUtil.EvaluateColorFromBoolean(secretVal, colorIfTrue, colorIfFalse)
    end)
    
    -- If API fails, return the "false" color
    return (ok and result) or colorIfFalse
end
