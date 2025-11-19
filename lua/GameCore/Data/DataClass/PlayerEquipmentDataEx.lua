local PlayerEquipmentData = class("PlayerEquipmentData")
local ConfigData = require("GameCore.Data.ConfigData")
local EquipmentData = require("GameCore.Data.DataClass.EquipmentDataEx")
PlayerEquipmentData.Init = function(self)
  -- function num : 0_0
  self.tbCharPreset = {}
  self.tbCharSelectPreset = {}
  self.tbCharEquipment = {}
  self.bRollWarning = true
  self:ProcessTableData()
end

PlayerEquipmentData.ProcessTableData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.nCharGemPresetNum = (ConfigTable.GetConfigNumber)("CharGemPresetNum")
  self.tbSlotControl = {}
  local func_ForEach_Slot = function(mapData)
    -- function num : 0_1_0 , upvalues : _ENV, self
    (table.insert)(self.tbSlotControl, {Id = mapData.Id, UnlockLevel = mapData.UnlockLevel})
  end

  ForEachTableLine(DataTable.CharGemSlotControl, func_ForEach_Slot)
  ;
  (table.sort)(self.tbSlotControl, function(a, b)
    -- function num : 0_1_1
    do return a.UnlockLevel < b.UnlockLevel end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
end

PlayerEquipmentData.CreateNewPresetData = function(self, tbPreset)
  -- function num : 0_2 , upvalues : _ENV
  local tbAllPreset = {}
  for i = 1, self.nCharGemPresetNum do
    tbAllPreset[i] = {sName = orderedFormat((ConfigTable.GetUIText)("Equipment_PresetDefaultName"), i), 
tbSlot = {}
}
  end
  for i,v in ipairs(tbPreset) do
    -- DECOMPILER ERROR at PC27: Confused about usage of register: R8 in 'UnsetPending'

    if v.Name ~= "" then
      (tbAllPreset[i]).sName = v.Name
    end
    for nSlotId,nGemIndex in pairs(v.SlotGem) do
      -- DECOMPILER ERROR at PC35: Confused about usage of register: R13 in 'UnsetPending'

      ((tbAllPreset[i]).tbSlot)[nSlotId] = nGemIndex + 1
    end
  end
  return tbAllPreset
end

PlayerEquipmentData.CreateNewEquipmentData = function(self, tbSlotData, nCharId)
  -- function num : 0_3 , upvalues : _ENV, EquipmentData
  local mapCharEquipment = {}
  for i,mapControl in ipairs(self.tbSlotControl) do
    mapCharEquipment[mapControl.Id] = {}
  end
  for _,mapSlot in ipairs(tbSlotData) do
    for i,mapInfo in ipairs(mapSlot.AlterGems) do
      local nGemId = self:GetGemIdBySlot(nCharId, mapSlot.Id)
      local equipmentData = (EquipmentData.new)(mapInfo, nCharId, nGemId)
      ;
      (table.insert)(mapCharEquipment[mapSlot.Id], equipmentData)
    end
  end
  return mapCharEquipment
end

PlayerEquipmentData.CacheEquipmentData = function(self, mapMsgData)
  -- function num : 0_4 , upvalues : _ENV
  if self.tbCharPreset == nil then
    self.tbCharPreset = {}
  end
  if self.tbCharSelectPreset == nil then
    self.tbCharSelectPreset = {}
  end
  if self.tbCharEquipment == nil then
    self.tbCharEquipment = {}
  end
  for _,mapCharInfo in ipairs(mapMsgData) do
    local nCharId = mapCharInfo.Tid
    local mapPresetList = mapCharInfo.CharGemPresets
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.tbCharSelectPreset)[nCharId] = mapPresetList.InUsePresetIndex + 1
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.tbCharPreset)[nCharId] = self:CreateNewPresetData(mapPresetList.CharGemPresets)
    -- DECOMPILER ERROR at PC35: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.tbCharEquipment)[nCharId] = self:CreateNewEquipmentData(mapCharInfo.CharGemSlots, nCharId)
  end
end

PlayerEquipmentData.GetSelectPreset = function(self, nCharId)
  -- function num : 0_5
  return (self.tbCharSelectPreset)[nCharId]
end

PlayerEquipmentData.GetEquipmentByGemIndex = function(self, nCharId, nSlotId, nGemIndex)
  -- function num : 0_6
  if nGemIndex == 0 then
    return 
  end
  return (((self.tbCharEquipment)[nCharId])[nSlotId])[nGemIndex]
end

PlayerEquipmentData.GetEquipmentBySlot = function(self, nCharId, nSlotId)
  -- function num : 0_7
  return ((self.tbCharEquipment)[nCharId])[nSlotId]
end

PlayerEquipmentData.GetSlotWithIndex = function(self, nCharId, nPresetIndex)
  -- function num : 0_8 , upvalues : _ENV
  local mapPreset = ((self.tbCharPreset)[nCharId])[nPresetIndex]
  local nCharLevel = (PlayerData.Char):GetCharLv(nCharId)
  local tbSlot = {}
  for i,mapControl in ipairs(self.tbSlotControl) do
    tbSlot[i] = {nSlotId = mapControl.Id, nLevel = mapControl.UnlockLevel, bUnlock = mapControl.UnlockLevel <= nCharLevel, nGemIndex = (mapPreset.tbSlot)[mapControl.Id]}
  end
  do return tbSlot end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerEquipmentData.GetSlotCfgWithIndex = function(self)
  -- function num : 0_9 , upvalues : _ENV
  local tbSlot = {}
  for i,mapControl in ipairs(self.tbSlotControl) do
    tbSlot[i] = {nSlotId = mapControl.Id, nLevel = mapControl.UnlockLevel}
  end
  return tbSlot
end

PlayerEquipmentData.GetAllPresetName = function(self, nCharId)
  -- function num : 0_10 , upvalues : _ENV
  local tbName = {}
  for _,v in ipairs((self.tbCharPreset)[nCharId]) do
    (table.insert)(tbName, v.sName)
  end
  return tbName
end

PlayerEquipmentData.GetGemIdBySlot = function(self, nCharId, nSlotId)
  -- function num : 0_11 , upvalues : _ENV
  local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
  if not mapCharCfg then
    return 0
  end
  local nSlotIndex = 1
  for i,mapControl in ipairs(self.tbSlotControl) do
    if nSlotId == mapControl.Id then
      nSlotIndex = i
      break
    end
  end
  do
    local nGemId = (mapCharCfg.GemSlots)[nSlotIndex]
    return nGemId
  end
end

PlayerEquipmentData.GetEquipedGem = function(self, nCharId)
  -- function num : 0_12 , upvalues : _ENV
  local nSelectPreset = (self.tbCharSelectPreset)[nCharId]
  if not nSelectPreset or not (self.tbCharPreset)[nCharId] then
    return {}
  end
  local mapPreset = ((self.tbCharPreset)[nCharId])[nSelectPreset]
  local tbEquipedGem, mapSlotData = {}, {}
  for _,mapControl in ipairs(self.tbSlotControl) do
    local nSlotId = mapControl.Id
    local nGemIndex = (mapPreset.tbSlot)[nSlotId]
    local mapEquipment = (((self.tbCharEquipment)[nCharId])[nSlotId])[nGemIndex]
    if mapEquipment then
      (table.insert)(tbEquipedGem, mapEquipment)
      ;
      (table.insert)(mapSlotData, {nSlotId = nSlotId, nGemIndex = nGemIndex})
    end
  end
  return tbEquipedGem, mapSlotData
end

PlayerEquipmentData.GetEnhancedPotential = function(self, nCharId)
  -- function num : 0_13 , upvalues : _ENV
  local tbEnhancedPotential = {}
  local tbEquipedGem = self:GetEquipedGem(nCharId)
  for _,v in pairs(tbEquipedGem) do
    local tbPotential = v:GetEnhancedPotential()
    for nPotentialId,nAdd in pairs(tbPotential) do
      if not tbEnhancedPotential[nPotentialId] then
        tbEnhancedPotential[nPotentialId] = 0
      end
      tbEnhancedPotential[nPotentialId] = tbEnhancedPotential[nPotentialId] + nAdd
    end
  end
  return tbEnhancedPotential
end

PlayerEquipmentData.GetEnhancedSkill = function(self, nCharId)
  -- function num : 0_14 , upvalues : _ENV
  local charCfgData = (ConfigTable.GetData_Character)(nCharId)
  if not charCfgData then
    printError("Character表找不到该角色" .. nCharId)
    return {}
  end
  local tbEnhancedSkill = {[charCfgData.NormalAtkId] = 0, [charCfgData.SkillId] = 0, [charCfgData.AssistSkillId] = 0, [charCfgData.UltimateId] = 0}
  local tbEquipedGem = self:GetEquipedGem(nCharId)
  for _,v in pairs(tbEquipedGem) do
    local tbSkill = v:GetEnhancedSkill()
    for nSkillId,nAdd in pairs(tbSkill) do
      if not tbEnhancedSkill[nSkillId] then
        tbEnhancedSkill[nSkillId] = 0
      end
      tbEnhancedSkill[nSkillId] = tbEnhancedSkill[nSkillId] + nAdd
    end
  end
  return tbEnhancedSkill
end

PlayerEquipmentData.GetCharEquipmentRandomAttr = function(self, nCharId)
  -- function num : 0_15 , upvalues : _ENV
  local tbEquipedGem = self:GetEquipedGem(nCharId)
  if not tbEquipedGem or #tbEquipedGem == 0 then
    return {}
  end
  local tbRandomAttrList = {}
  for _,mapEquipment in pairs(tbEquipedGem) do
    local mapRandomAttr = mapEquipment:GetRandomAttr()
    for k,v in ipairs(mapRandomAttr) do
      local nAttrId = v.AttrId
      if nAttrId ~= nil then
        local nCfgValue = v.CfgValue
        local nValue = v.Value
        if tbRandomAttrList[nAttrId] == nil then
          tbRandomAttrList[nAttrId] = {CfgValue = nCfgValue, Value = nValue}
        else
          -- DECOMPILER ERROR at PC38: Confused about usage of register: R18 in 'UnsetPending'

          ;
          (tbRandomAttrList[nAttrId]).CfgValue = (tbRandomAttrList[nAttrId]).CfgValue + nCfgValue
          -- DECOMPILER ERROR at PC43: Confused about usage of register: R18 in 'UnsetPending'

          ;
          (tbRandomAttrList[nAttrId]).Value = (tbRandomAttrList[nAttrId]).Value + nValue
        end
      end
    end
  end
  for _,v in pairs(tbRandomAttrList) do
    v.CfgValue = clearFloat(v.CfgValue)
  end
  return tbRandomAttrList
end

PlayerEquipmentData.GetCharEquipmentEffect = function(self, nCharId)
  -- function num : 0_16 , upvalues : _ENV
  local tbEquipedGem = self:GetEquipedGem(nCharId)
  if not tbEquipedGem or #tbEquipedGem == 0 then
    return {}
  end
  local tbAllEffect = {}
  for _,mapEquipment in pairs(tbEquipedGem) do
    local tbEffect = mapEquipment:GetEffect()
    for _,v in pairs(tbEffect) do
      (table.insert)(tbAllEffect, v)
    end
  end
  return tbAllEffect
end

PlayerEquipmentData.GetRollWarning = function(self)
  -- function num : 0_17
  return self.bRollWarning
end

PlayerEquipmentData.SetRollWarning = function(self, bAble)
  -- function num : 0_18
  self.bRollWarning = bAble
end

PlayerEquipmentData.UpdateRedDot = function(self)
  -- function num : 0_19
end

PlayerEquipmentData.SendCharGemEquipGemReq = function(self, nCharId, nSlotId, nGemIndex, nPresetId, callback)
  -- function num : 0_20 , upvalues : _ENV
  local msgData = {CharId = nCharId, SlotId = nSlotId, GemIndex = nGemIndex - 1, PresetId = nPresetId - 1}
  local successCallback = function(_, mapMainData)
    -- function num : 0_20_0 , upvalues : self, nCharId, nPresetId, nSlotId, nGemIndex, callback
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

    ((((self.tbCharPreset)[nCharId])[nPresetId]).tbSlot)[nSlotId] = nGemIndex
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_equip_gem_req, msgData, nil, successCallback)
end

PlayerEquipmentData.SendCharGemRenamePresetReq = function(self, nCharId, nPresetId, sNewName, callback)
  -- function num : 0_21 , upvalues : _ENV
  local msgData = {CharId = nCharId, PresetId = nPresetId - 1, NewName = sNewName}
  local successCallback = function(_, mapMainData)
    -- function num : 0_21_0 , upvalues : self, nCharId, nPresetId, sNewName, callback
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

    (((self.tbCharPreset)[nCharId])[nPresetId]).sName = sNewName
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_rename_preset_req, msgData, nil, successCallback)
end

PlayerEquipmentData.SendCharGemReplaceAttributeReq = function(self, nCharId, nSlotId, nGemIndex, callback)
  -- function num : 0_22 , upvalues : _ENV
  local msgData = {CharId = nCharId, SlotId = nSlotId, GemIndex = nGemIndex - 1}
  local successCallback = function(_, mapMainData)
    -- function num : 0_22_0 , upvalues : self, nCharId, nSlotId, nGemIndex, callback
    ((((self.tbCharEquipment)[nCharId])[nSlotId])[nGemIndex]):ReplaceRandomAttr()
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_replace_attribute_req, msgData, nil, successCallback)
end

PlayerEquipmentData.SendCharGemUpdateGemLockStatusReq = function(self, nCharId, nSlotId, nGemIndex, bLock, callback)
  -- function num : 0_23 , upvalues : _ENV
  local msgData = {CharId = nCharId, SlotId = nSlotId, GemIndex = nGemIndex - 1, Lock = bLock}
  local successCallback = function(_, mapMainData)
    -- function num : 0_23_0 , upvalues : self, nCharId, nSlotId, nGemIndex, bLock, callback
    ((((self.tbCharEquipment)[nCharId])[nSlotId])[nGemIndex]):UpdateLockState(bLock)
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_update_gem_lock_status_req, msgData, nil, successCallback)
end

PlayerEquipmentData.SendCharGemUsePresetReq = function(self, nCharId, nPresetId, callback)
  -- function num : 0_24 , upvalues : _ENV
  local msgData = {CharId = nCharId, PresetId = nPresetId - 1}
  local successCallback = function(_, mapMainData)
    -- function num : 0_24_0 , upvalues : self, nCharId, nPresetId, callback
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R2 in 'UnsetPending'

    (self.tbCharSelectPreset)[nCharId] = nPresetId
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_use_preset_req, msgData, nil, successCallback)
end

PlayerEquipmentData.SendCharGemRefreshReq = function(self, nCharId, nSlotId, nGemIndex, tbLockAttrs, callback)
  -- function num : 0_25 , upvalues : _ENV
  local msgData = {CharId = nCharId, SlotId = nSlotId, GemIndex = nGemIndex - 1, LockAttrs = tbLockAttrs}
  local successCallback = function(_, mapMainData)
    -- function num : 0_25_0 , upvalues : self, nCharId, nSlotId, nGemIndex, callback
    ((((self.tbCharEquipment)[nCharId])[nSlotId])[nGemIndex]):UpdateAlterAffix(mapMainData.Attributes)
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_refresh_req, msgData, nil, successCallback)
end

PlayerEquipmentData.SendCharGemGenerateReq = function(self, nCharId, nSlotId, callback)
  -- function num : 0_26 , upvalues : EquipmentData, _ENV
  local msgData = {CharId = nCharId, SlotId = nSlotId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_26_0 , upvalues : self, nCharId, nSlotId, EquipmentData, _ENV, callback
    local nGemId = self:GetGemIdBySlot(nCharId, nSlotId)
    local equipmentData = (EquipmentData.new)(mapMainData.CharGem, nCharId, nGemId)
    ;
    (table.insert)(((self.tbCharEquipment)[nCharId])[nSlotId], equipmentData)
    local nNewIndex = #((self.tbCharEquipment)[nCharId])[nSlotId]
    if callback then
      callback(nNewIndex)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_generate_req, msgData, nil, successCallback)
end

PlayerEquipmentData.CacheEquipmentDataForChar = function(self, mapMsgData)
  -- function num : 0_27
  if self.tbCharPreset == nil then
    self.tbCharPreset = {}
  end
  if self.tbCharSelectPreset == nil then
    self.tbCharSelectPreset = {}
  end
  if self.tbCharEquipment == nil then
    self.tbCharEquipment = {}
  end
  local nCharId = mapMsgData.CharId
  local mapPresetList = mapMsgData.CharGemPresets
  -- DECOMPILER ERROR at PC20: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbCharSelectPreset)[nCharId] = mapPresetList.InUsePresetIndex + 1
  -- DECOMPILER ERROR at PC25: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbCharPreset)[nCharId] = self:CreateNewPresetData(mapPresetList.CharGemPresets)
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbCharEquipment)[nCharId] = self:CreateNewEquipmentData(mapMsgData.CharGemSlots, nCharId)
end

return PlayerEquipmentData

