-- Retail only
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  return
end

local addon = CreateFrame("Frame")
local LEADER_ICON = "Interface\\GroupFrame\\UI-Group-LeaderIcon"

local icons = {}

local function EnsureIcon(frame)
  if not frame then
    return nil
  end

  if icons[frame] then
    return icons[frame]
  end

  local icon = frame:CreateTexture(nil, "OVERLAY")
  icon:SetSize(16, 16)
  icon:SetTexture(LEADER_ICON)
  icon:SetPoint("CENTER", frame, "CENTER", 0, 0)
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

  if not IsInGroup() then
    return
  end

  local frames = CollectFrames()

  for _, frame in ipairs(frames) do
    local unit = frame.unit
    if unit and UnitExists(unit) and UnitIsGroupLeader(unit) then
      EnsureIcon(frame):Show()
      return
    end
  end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("GROUP_ROSTER_UPDATE")
addon:RegisterEvent("PARTY_LEADER_CHANGED")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")

addon:SetScript("OnEvent", function()
  UpdateAll()
end)
