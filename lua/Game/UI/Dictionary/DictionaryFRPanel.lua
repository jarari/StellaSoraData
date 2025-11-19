local DictionaryFRPanel = class("DictionaryFRPanel", BasePanel)
DictionaryFRPanel._bIsMainPanel = false
DictionaryFRPanel._tbDefine = {
{sPrefabPath = "Dictionary/DictionaryPanel.prefab", sCtrlName = "Game.UI.Dictionary.DictionaryCtrl"}
}
DictionaryFRPanel.Awake = function(self)
  -- function num : 0_0
  self.bStarTowerFastBattle = (self:GetPanelParam())[1]
end

DictionaryFRPanel.OnEnable = function(self)
  -- function num : 0_1
end

DictionaryFRPanel.OnDisable = function(self)
  -- function num : 0_2
end

DictionaryFRPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DictionaryFRPanel

