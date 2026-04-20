local addonName, addon = ...

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  -- Retail only
  return
end

local AddonFrame = CreateFrame("Frame")
local LEADER_ICON = "Interface\\GroupFrame\\UI-Group-LeaderIcon"

local leaderIcons = {}
local markerIcons = {}

local function UpdateLeaderIcon(icon, frame)
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

local function UpdateMarkerIcon(icon, frame)
  if not icon or not frame then
    return
  end

  local anchor = RaidLeaderMarkerDB.targetMarker.anchor or "LEFT"
  local size = RaidLeaderMarkerDB.targetMarker.size or 16
  local offsetX = RaidLeaderMarkerDB.targetMarker.offsetX or -16
  local offsetY = RaidLeaderMarkerDB.targetMarker.offsetY or 0

  icon:SetSize(size, size)
  icon:ClearAllPoints()
  icon:SetPoint("CENTER", frame, anchor, offsetX, offsetY)
end

local function EnsureLeaderIcon(frame)
  if not frame then
    return nil
  end

  if leaderIcons[frame] then
    return leaderIcons[frame]
  end

  local icon = frame:CreateTexture(nil, "OVERLAY")
  icon:SetTexture(LEADER_ICON)
  icon:Hide()

  leaderIcons[frame] = icon
  return icon
end

local function EnsureMarkerIcon(frame)
  if not frame then
    return nil
  end

  if markerIcons[frame] then
    return markerIcons[frame]
  end

  local icon = frame:CreateTexture(nil, "OVERLAY")
  icon:Hide()

  markerIcons[frame] = icon
  return icon
end

local function ClearAllIcons()
  for _, icon in pairs(leaderIcons) do
    icon:Hide()
  end
  for _, icon in pairs(markerIcons) do
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

  if not IsInGroup() then
    return
  end

  local frames = CollectFrames()

  for _, frame in ipairs(frames) do
    local unit = frame.unit
    if unit and UnitExists(unit) then
      -- Leader icon
      if RaidLeaderMarkerDB.leaderIcon.enabled and UnitIsGroupLeader(unit) then
        local leaderIcon = EnsureLeaderIcon(frame)
        if leaderIcon then
          leaderIcon:Show()
          UpdateLeaderIcon(leaderIcon, frame)
        end
      end
      -- Target marker icon
      if RaidLeaderMarkerDB.targetMarker.enabled then
        local markerIcon = EnsureMarkerIcon(frame)
				if markerIcon then
				local markerIndex = GetRaidTargetIndex(unit)
					if markerIndex then
						markerIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
						SetRaidTargetIconTexture(markerIcon, markerIndex);
						markerIcon:Show()
						UpdateMarkerIcon(markerIcon, frame)
					else
						markerIcon:Hide()
					end
				end
      end
    end
  end
end

addon.UpdateAll = UpdateAll

AddonFrame:RegisterEvent("ADDON_LOADED")
AddonFrame:RegisterEvent("PLAYER_LOGIN")
AddonFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
AddonFrame:RegisterEvent("PARTY_LEADER_CHANGED")
AddonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
AddonFrame:RegisterEvent("RAID_TARGET_UPDATE")

AddonFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" and ... == addonName then
    addon.InitializeDB()
    addon.InitializeSettings()
  end

  UpdateAll()
end)
