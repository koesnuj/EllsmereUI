-- PhoenixCastBars - Core/Profiles.lua
-- Profile CRUD, spec-profile mapping, and import/export serialization.
-- Extracted from DB.lua so that DB.lua is pure data + schema init.
-- Depends on: Core/Util.lua (PCB.DeepCopy), Core/DB.lua (PCB.Defaults,
--             PCB.DB_SCHEMA_VERSION, PCB.dbRoot).

local ADDON_NAME, PCB = ...

-- =====================================================================
-- Internal helpers
-- =====================================================================
local function GetCharKey()
    local name  = UnitName("player") or "Unknown"
    local realm = GetRealmName() or "Realm"
    realm = realm:gsub("%s+", "")
    return name .. "-" .. realm
end

local function GetCurrentSpecID()
    local specIndex = GetSpecialization and GetSpecialization()
    if not specIndex or specIndex == 0 then return nil end
    return select(1, GetSpecializationInfo(specIndex))
end

-- =====================================================================
-- Serialization
-- Custom binary-ish format (no loadstring).
-- Tokens: n=nil  b0/b1=bool  d<num>;=number  s<len>:<str>=string  t...e=table
-- =====================================================================
local function SerializeValue(v, out)
    local t = type(v)
    if     t == "nil"     then out[#out+1] = "n"
    elseif t == "boolean" then out[#out+1] = v and "b1" or "b0"
    elseif t == "number"  then
        out[#out+1] = "d"; out[#out+1] = tostring(v); out[#out+1] = ";"
    elseif t == "string"  then
        out[#out+1] = "s"
        out[#out+1] = tostring(#v)
        out[#out+1] = ":"
        out[#out+1] = v
    elseif t == "table"   then
        out[#out+1] = "t"
        local keys = {}
        for k in pairs(v) do keys[#keys+1] = k end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for i = 1, #keys do
            local k = keys[i]
            SerializeValue(k,    out)
            SerializeValue(v[k], out)
        end
        out[#out+1] = "e"
    else
        out[#out+1] = "n"
    end
end

local function SerializeTable(tbl)
    local out = {}
    SerializeValue(tbl, out)
    return table.concat(out)
end

local function DeserializeValue(s, i)
    local tag = s:sub(i, i)
    if tag == "n" then
        return nil, i + 1
    elseif tag == "b" then
        return s:sub(i+1, i+1) == "1", i + 2
    elseif tag == "d" then
        local j = s:find(";", i+1, true)
        if not j then return nil, #s+1 end
        return tonumber(s:sub(i+1, j-1)), j + 1
    elseif tag == "s" then
        local colon = s:find(":", i+1, true)
        if not colon then return "", #s+1 end
        local len   = tonumber(s:sub(i+1, colon-1)) or 0
        local start = colon + 1
        return s:sub(start, start + len - 1), start + len
    elseif tag == "t" then
        local tbl = {}
        i = i + 1
        while i <= #s do
            if s:sub(i, i) == "e" then return tbl, i + 1 end
            local k; k, i = DeserializeValue(s, i)
            local v; v, i = DeserializeValue(s, i)
            if k ~= nil then tbl[k] = v end
        end
        return tbl, #s + 1
    end
    return nil, #s + 1
end

local function DeserializeTable(s)
    if type(s) ~= "string" or s == "" then return nil end
    local v, _ = DeserializeValue(s, 1)
    if type(v) ~= "table" then return nil end
    return v
end

-- =====================================================================
-- Default profile (applies to any alt that has not chosen a profile)
-- =====================================================================
function PCB:SetDefaultProfile(name)
    if not self.dbRoot then return end
    if name and not self.dbRoot.profiles[name] then return end
    self.dbRoot.defaultProfile = name or nil
end

function PCB:GetDefaultProfile()
    return self.dbRoot and self.dbRoot.defaultProfile or nil
end

-- =====================================================================
-- Profile CRUD
-- =====================================================================
function PCB:EnsureProfile(name)
    self.dbRoot.profiles[name] = self.dbRoot.profiles[name]
        or PCB.DeepCopy(PCB.Defaults)
end

function PCB:GetActiveProfileName()
    return self.dbRoot and self.dbRoot._activeProfile or "Default"
end

function PCB:SetActiveProfileName(name)
    if not self.dbRoot or not self.dbRoot.profiles[name] then return end
    local charKey = GetCharKey()
    self.dbRoot.chars[charKey] = self.dbRoot.chars[charKey]
        or { profile = "Default", specProfiles = {} }
    local c = self.dbRoot.chars[charKey]
    if self:GetProfileMode() == "spec" then
        local specID = GetCurrentSpecID()
        if specID then c.specProfiles[specID] = name
        else           c.profile = name end
    else
        c.profile = name
    end
    self:SelectActiveProfile()
end

function PCB:ResetProfile()
    local profileName = self:GetActiveProfileName()
    if profileName then
        self.dbRoot.profiles[profileName] = PCB.DeepCopy(PCB.Defaults)
        self:SelectActiveProfile()
        if self.ApplyAll then self:ApplyAll() end
    end
end

function PCB:SelectActiveProfile()
    local charKey = GetCharKey()
    self.dbRoot.chars[charKey] = self.dbRoot.chars[charKey]
        or { profile = "Default", specProfiles = {} }
    local c = self.dbRoot.chars[charKey]
    local profileName = c.profile or self:GetDefaultProfile() or "Default"
    if self:GetProfileMode() == "spec" then
        local specID = GetCurrentSpecID()
        if specID and c.specProfiles and c.specProfiles[specID] then
            profileName = c.specProfiles[specID]
        end
    end
    if not self.dbRoot.profiles[profileName] then
        profileName = "Default"
        self:EnsureProfile(profileName)
    end
    self.dbRoot._activeProfile = profileName
    self.db = self.dbRoot.profiles[profileName]
end

-- =====================================================================
-- Profile mode (character vs spec)
-- =====================================================================
function PCB:SetProfileMode(mode)
    if mode ~= "character" and mode ~= "spec" then return end
    self.dbRoot.profileMode = mode
    self:SelectActiveProfile()
end

function PCB:GetProfileMode()
    return (self.dbRoot and self.dbRoot.profileMode) or "character"
end

-- =====================================================================
-- Import / export
-- =====================================================================
function PCB:ExportProfile(profileName)
    local name = profileName or self:GetActiveProfileName()
    if not self.dbRoot or not self.dbRoot.profiles or
       not self.dbRoot.profiles[name] then return nil end
    local payload = {
        schema  = PCB.DB_SCHEMA_VERSION,
        profile = name,
        data    = self.dbRoot.profiles[name],
    }
    return "PCBPROFILE1|" .. SerializeTable(payload)
end

function PCB:ImportProfile(str, newName)
    if type(str) ~= "string" then return false, "Invalid import string." end
    local _, body = str:match("^(PCBPROFILE1|PCBPROFILE0)%|(.*)$")
    if not body then return false, "Invalid import string." end
    local payload = DeserializeTable(body)
    if not payload or type(payload.data) ~= "table" then
        return false, "Import data could not be parsed."
    end
    local name = tostring(newName or payload.profile or "Imported"):sub(1, 32)
    self.dbRoot.profiles[name] = payload.data
    return true, name
end
