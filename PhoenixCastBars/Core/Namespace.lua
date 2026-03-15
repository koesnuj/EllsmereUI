-- PhoenixCastBars - Core/Namespace.lua
-- Establishes the PCB addon table, version info, and the Print helper.
-- This file must load first. Everything else hangs off the PCB table.

local ADDON_NAME, PCB = ...

PCB.name    = ADDON_NAME
PCB.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "0.0.0"
PCB.LSM     = LibStub and LibStub("LibSharedMedia-3.0", true) or nil
PCB.LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true) or nil

-- PCB.Bars holds the live cast bar frame instances (player, target, focus, gcd).
PCB.Bars = PCB.Bars or {}

-- =====================================================================
-- PCB:Print - coloured addon messages to the default chat frame
-- =====================================================================
function PCB:Print(msg)
    msg = tostring(msg or "")
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99PhoenixCastBars:|r " .. msg)
    else
        print("PhoenixCastBars: " .. msg)
    end
end 