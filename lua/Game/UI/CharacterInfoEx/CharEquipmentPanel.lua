local BasePanel = require("GameCore.UI.BasePanel")
local CharEquipmentPanel = class("CharEquipmentPanel", BasePanel)
CharEquipmentPanel._tbDefine = {
{sPrefabPath = "CharacterInfoEx/CharEquipmentPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharEquipmentCtrl"}
}
CharEquipmentPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nCharId = tbParam[1]
  end
end

CharEquipmentPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharEquipmentPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharEquipmentPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharEquipmentPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharEquipmentPanel

