local addonName, addon = ...

-- Utility functions

local function CreateCheckbox(category, name, label, tooltip, onChange)
  local setting = Settings.RegisterAddOnSetting(category, "RaidLeaderMarker_"..name, name, RaidLeaderMarkerDB.leaderIcon, "boolean", label, RaidLeaderMarkerDB.leaderIcon[name] or false)

  if onChange then
    setting:SetValueChangedCallback(onChange)
  end

  Settings.CreateCheckbox(category, setting, tooltip)
end

local function CreateDropdown(category, name, label, tooltip, items, onChange)
  local setting = Settings.RegisterAddOnSetting(category, "RaidLeaderMarker_"..name, name, RaidLeaderMarkerDB.leaderIcon, "string", label, RaidLeaderMarkerDB.leaderIcon[name] or items[1].value)

  if onChange then
    setting:SetValueChangedCallback(onChange)
  end

  local function GetOptions()
    local container = Settings.CreateControlTextContainer()
    for _, item in ipairs(items) do
      container:Add(item.value, item.label)
    end
    return container:GetData()
  end

  Settings.CreateDropdown(category, setting, GetOptions, tooltip)
end

local function CreateSlider(category, name, label, tooltip, minValue, maxValue, step, onChange)
  local setting = Settings.RegisterAddOnSetting(category, "RaidLeaderMarker_"..name, name, RaidLeaderMarkerDB.leaderIcon, "number", label, RaidLeaderMarkerDB.leaderIcon[name] or minValue)

  if onChange then
    setting:SetValueChangedCallback(onChange)
  end

  local options = Settings.CreateSliderOptions(minValue, maxValue, step)
  options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
  Settings.CreateSlider(category, setting, options, tooltip)
end

-- Initialization of the settings panel

local anchorOptions = {
  { value = "TOPLEFT", label = "Top Left" },
  { value = "TOP", label = "Top" },
  { value = "TOPRIGHT", label = "Top Right" },
  { value = "LEFT", label = "Left" },
  { value = "CENTER", label = "Center" },
  { value = "RIGHT", label = "Right" },
  { value = "BOTTOMLEFT", label = "Bottom Left" },
  { value = "BOTTOM", label = "Bottom" },
  { value = "BOTTOMRIGHT", label = "Bottom Right" },
}

local function InitializeSettings()
  local settingsCategory, settingsLayout = Settings.RegisterVerticalLayoutCategory("Raid Leader Marker")
  settingsLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Leader icon", "Configure the leader icon's position and size."))

  -- Checkbox to enable/disable the leader icon
  CreateCheckbox(settingsCategory, "enabled", "Enable Leader Icon", "Toggle the display of the leader icon.", function(setting, value)
    RaidLeaderMarkerDB.leaderIcon.enabled = value
    addon.UpdateAll()
  end)

  -- Dropdown for anchor point
  CreateDropdown(settingsCategory, "anchor", "Anchor Point", "Choose the anchor point for the icon.", anchorOptions, function(setting, value)
    RaidLeaderMarkerDB.leaderIcon.anchor = value
    RaidLeaderMarkerDB.leaderIcon.offsetX = 0
    RaidLeaderMarkerDB.leaderIcon.offsetY = 0
    addon.UpdateAll()
  end)

  -- Slider for offsetX
  CreateSlider(settingsCategory, "offsetX", "Offset X", "Horizontal offset from the anchor.", -50, 50, 1, function(setting, value)
    RaidLeaderMarkerDB.leaderIcon.offsetX = value
    addon.UpdateAll()
  end)

  -- Slider for offsetY
  CreateSlider(settingsCategory, "offsetY", "Offset Y", "Vertical offset from the anchor.", -50, 50, 1, function(setting, value)
    RaidLeaderMarkerDB.leaderIcon.offsetY = value
    addon.UpdateAll()
  end)

  -- Slider for size
  CreateSlider(settingsCategory, "size", "Icon Size", "Size of the leader icon.", 16, 32, 1, function(setting, value)
    RaidLeaderMarkerDB.leaderIcon.size = value
    addon.UpdateAll()
  end)

  Settings.RegisterAddOnCategory(settingsCategory)
end

addon.InitializeSettings = InitializeSettings
