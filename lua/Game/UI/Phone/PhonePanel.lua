local PhonePanel = class("PhonePanel", BasePanel)
PhonePanel._nSnapshotPrePanel = 4
PhonePanel._tbDefine = {
{sPrefabPath = "Phone/PhonePanel.prefab", sCtrlName = "Game.UI.Phone.PhoneCtrl"}
}
PhonePanel.GetAvgContactsData = function(self, sContactsId)
  -- function num : 0_0 , upvalues : _ENV
  local tbContacts = (PlayerData.Phone):GetAvgContactsData(sContactsId)
  if tbContacts == nil then
    return sContactsId
  else
    return tbContacts
  end
end

PhonePanel.Awake = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.nCurTog = nil
  self.nSelectCharId = nil
  self.sTxtLan = Settings.sCurrentTxtLanguage
  self.sVoLan = Settings.sCurrentVoLanguage
  self.bIsPlayerMale = (PlayerData.Base):GetPlayerSex() == true
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PhonePanel.OnEnable = function(self)
  -- function num : 0_2
end

PhonePanel.OnAfterEnter = function(self)
  -- function num : 0_3
end

PhonePanel.OnDisable = function(self)
  -- function num : 0_4
end

PhonePanel.OnDestroy = function(self)
  -- function num : 0_5
end

PhonePanel.OnRelease = function(self)
  -- function num : 0_6
end

return PhonePanel

