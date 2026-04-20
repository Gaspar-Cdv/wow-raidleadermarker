local addonName, addon = ...

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  -- Retail only
  return
end

local AddonFrame = CreateFrame("Frame")
local LEADER_ICON = "Interface\\GroupFrame\\UI-Group-LeaderIcon"

local icons = {}

local function UpdateIcon(icon, frame)
  if not icon or not frame then
    return
  end

  local anchor = RaidLeaderMarkerDB.leaderIcon.anchor or "CENTER"
  local size = RaidLeaderMarkerDB.leaderIcon.size or 16
  local offsetX = RaidLeaderMarkerDB.leaderIcon.offsetX or 0
  local offsetY = RaidLeaderMarkerDB.leaderIcon.offsetY or 0

  icon:SetSize(size, size)
  icon:ClearAllPoints()
  icon:SetPoint("CENTER", frame, anchor, offsetX, offsetY)
end

local function EnsureIcon(frame)
  if not frame then
    return nil
  end

  if icons[frame] then
    return icons[frame]
  end

  local icon = frame:CreateTexture(nil, "OVERLAY")
  icon:SetTexture(LEADER_ICON)
  icon:Hide()

  icons[frame] = icon
  return icon
end

local function ClearAllIcons()
  for _, icon in pairs(icons) do
    icon:Hide()
  end
end

local function CollectFrames()
  local frames = {}

  if IsInRaid() then
    for groupIndex = 1, 8 do
      local group = _G["CompactRaidGroup" .. groupIndex]

      if group then
        local children = { group:GetChildren() }

        for i, frame in ipairs(children) do
          frames[#frames + 1] = frame
        end
      end
    end

    return frames
  end

  if IsInGroup() then
    for i = 1, GetNumGroupMembers() do
      local frame = _G["CompactPartyFrameMember" .. i]
        frames[#frames + 1] = frame
    end

    return frames
  end
end

local function UpdateAll()
  ClearAllIcons()

  if RaidLeaderMarkerDB.leaderIcon.enabled == false then
    return
  end

  if not IsInGroup() then
    return
  end

  local frames = CollectFrames()

  for _, frame in ipairs(frames) do
    local unit = frame.unit
    if unit and UnitExists(unit) and UnitIsGroupLeader(unit) then
      local icon = EnsureIcon(frame)
      if icon then
        icon:Show()
        UpdateIcon(icon, frame)
      end
      return
    end
  end
end

addon.UpdateAll = UpdateAll

AddonFrame:RegisterEvent("ADDON_LOADED")
AddonFrame:RegisterEvent("PLAYER_LOGIN")
AddonFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
AddonFrame:RegisterEvent("PARTY_LEADER_CHANGED")
AddonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

AddonFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" and ... == addonName then
    addon.InitializeDB()
    addon.InitializeSettings()
  end

  UpdateAll()
end)
