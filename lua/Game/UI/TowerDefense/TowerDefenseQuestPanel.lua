local TowerDefenseQuestPanel = class("TowerDefenseQuestPanel", BasePanel)
TowerDefenseQuestPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
TowerDefenseQuestPanel._bIsMainPanel = false
TowerDefenseQuestPanel._tbDefine = {
{sPrefabPath = "Play_TowerDefence/TowerDefenseQuest.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseQuestCtrl"}
}
TowerDefenseQuestPanel.Awake = function(self)
  -- function num : 0_0
end

TowerDefenseQuestPanel.OnEnable = function(self)
  -- function num : 0_1
end

TowerDefenseQuestPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

TowerDefenseQuestPanel.OnDisable = function(self)
  -- function num : 0_3
end

TowerDefenseQuestPanel.OnDestroy = function(self)
  -- function num : 0_4
end

TowerDefenseQuestPanel.OnRelease = function(self)
  -- function num : 0_5
end

return TowerDefenseQuestPanel

