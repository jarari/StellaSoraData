local LevelMenuPanel = class("LevelMenuPanel", BasePanel)
LevelMenuPanel._tbDefine = {
{sPrefabPath = "LevelMenuEx/LevelMenuPanel.prefab", sCtrlName = "Game.UI.LevelMenuEx.LevelMenuCtrl"}
}
LevelMenuPanel.Awake = function(self)
  -- function num : 0_0
  self.nCurStarTowerGroupId = nil
end

LevelMenuPanel.OnEnable = function(self)
  -- function num : 0_1
end

LevelMenuPanel.OnDisable = function(self)
  -- function num : 0_2
end

LevelMenuPanel.OnDestroy = function(self)
  -- function num : 0_3
end

LevelMenuPanel.GetAniState = function(self)
  -- function num : 0_4
end

LevelMenuPanel.SetAniState = function(self, bPlay)
  -- function num : 0_5
end

return LevelMenuPanel

