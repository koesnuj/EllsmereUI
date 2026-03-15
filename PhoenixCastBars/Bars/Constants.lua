-- PhoenixCastBars - Bars/Constants.lua
-- Shared constants used across all cast bar modules.
-- Loaded first so every other Bars/ file can reference these globals.

local ADDON_NAME, PCB = ...

-- pet added for Hunter/Warlock/etc. companion cast bars (disabled by default in DB)
PCB.BAR_UNITS = { player = "player", target = "target", focus = "focus", pet = "pet" }

PCB.NAMEPLATE_MAX        = 40
PCB.POLL_INTERVAL        = 0.10
PCB.END_GRACE_SECONDS    = 0.05
PCB.TEXT_UPDATE_INTERVAL = 0.05

PCB.DEFAULT_INTERPOLATION =
    (Enum and Enum.StatusBarTimerInterpolation and
     Enum.StatusBarTimerInterpolation.Linear) or nil

PCB.DIR_ELAPSED =
    (Enum and Enum.StatusBarTimerDirection and
     Enum.StatusBarTimerDirection.ElapsedTime) or nil

PCB.DIR_REMAINING =
    (Enum and Enum.StatusBarTimerDirection and
     Enum.StatusBarTimerDirection.RemainingTime) or nil

-- Events the cast-bar event frame subscribes to
PCB.BAR_EVENTS = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_SENT",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_UPDATE",
    "UNIT_SPELLCAST_EMPOWER_STOP",
    -- Independent interrupt detection (no longer polls TargetFrameSpellBar)
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "PLAYER_TARGET_CHANGED",
    "PLAYER_FOCUS_CHANGED",
    "PLAYER_ENTERING_WORLD",
    "UNIT_PET",       -- pet bar: reset/refresh on companion change
    "VEHICLE_UPDATE", -- refresh player + pet on vehicle transitions
}

-- Events that should trigger a stop-check rather than a start
PCB.STOP_EVENTS = {
    UNIT_SPELLCAST_STOP         = true,
    UNIT_SPELLCAST_FAILED       = true,
    UNIT_SPELLCAST_INTERRUPTED  = true,
    UNIT_SPELLCAST_CHANNEL_STOP = true,
    UNIT_SPELLCAST_EMPOWER_STOP = true,
}
