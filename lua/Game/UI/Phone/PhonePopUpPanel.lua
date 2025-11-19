local PhonePopUpPanel = class("PhonePopUpPanel", BasePanel)
PhonePopUpPanel._bIsMainPanel = false
PhonePopUpPanel._tbDefine = {
{sPrefabPath = "Phone/PhonePopUpPanel.prefab", sCtrlName = "Game.UI.Phone.PhonePopUpCtrl"}
}
PhonePopUpPanel.GetAvgContactsData = function(self, sContactsId)
  -- function num : 0_0 , upvalues : _ENV
  local tbContacts = (PlayerData.Phone):GetAvgContactsData(sContactsId)
  if tbContacts == nil then
    return sContactsId
  else
    return tbContacts
  end
end

PhonePopUpPanel.Awake = function(self)
  -- function num : 0_1
end

PhonePopUpPanel.OnEnable = function(self)
  -- function num : 0_2
end

PhonePopUpPanel.OnAfterEnter = function(self)
  -- function num : 0_3
end

PhonePopUpPanel.OnDisable = function(self)
  -- function num : 0_4
end

PhonePopUpPanel.OnDestroy = function(self)
  -- function num : 0_5
end

PhonePopUpPanel.OnRelease = function(self)
  -- function num : 0_6
end

return PhonePopUpPanel

