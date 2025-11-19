local BasePanel = require("GameCore.UI.BasePanel")
local NPCFavorLevelUpPanel = class("NPCFavorLevelUpPanel", BasePanel)
NPCFavorLevelUpPanel._bIsMainPanel = false
NPCFavorLevelUpPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
NPCFavorLevelUpPanel._tbDefine = {
{sPrefabPath = "StarTower/NPCFavourLevelUpPanel.prefab", sCtrlName = "Game.UI.StarTower.NpcAffinityLevelUp.NPCFavorLevelUpCtrl"}
}
NPCFavorLevelUpPanel.Awake = function(self)
  -- function num : 0_0
end

NPCFavorLevelUpPanel.OnEnable = function(self)
  -- function num : 0_1
end

NPCFavorLevelUpPanel.OnDisable = function(self)
  -- function num : 0_2
end

NPCFavorLevelUpPanel.OnDestroy = function(self)
  -- function num : 0_3
end

NPCFavorLevelUpPanel.OnRelease = function(self)
  -- function num : 0_4
end

return NPCFavorLevelUpPanel

