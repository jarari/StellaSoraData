local DictionaryPanel = class("DictionaryPanel", BasePanel)
DictionaryPanel._tbDefine = {
{sPrefabPath = "Dictionary/DictionaryPanel.prefab", sCtrlName = "Game.UI.Dictionary.DictionaryCtrl"}
}
DictionaryPanel.Awake = function(self)
  -- function num : 0_0
  self.bStarTowerFastBattle = (self:GetPanelParam())[1]
end

DictionaryPanel.OnEnable = function(self)
  -- function num : 0_1
end

DictionaryPanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)("CloseSideBanner")
end

DictionaryPanel.OnDisable = function(self)
  -- function num : 0_3
end

DictionaryPanel.OnDestroy = function(self)
  -- function num : 0_4
end

return DictionaryPanel

