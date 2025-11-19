local ChooseHomePageRolePanel = class("ChooseHomePageRolePanel", BasePanel)
ChooseHomePageRolePanel._tbDefine = {
{sPrefabPath = "MainViewBoard/ChooseHomePageRolePanel.prefab", sCtrlName = "Game.UI.MainViewBoard.ChooseHomePageRoleCtrl"}
}
ChooseHomePageRolePanel.Awake = function(self)
  -- function num : 0_0
  self.nSelectCharId = nil
  self.nSelectOutfitId = nil
  self.nSelectType = nil
  self.nSelectId = nil
end

ChooseHomePageRolePanel.OnEnable = function(self)
  -- function num : 0_1
end

ChooseHomePageRolePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

ChooseHomePageRolePanel.OnDisable = function(self)
  -- function num : 0_3
end

ChooseHomePageRolePanel.OnDestroy = function(self)
  -- function num : 0_4
  self.nSelectCharId = nil
  self.nSelectOutfitId = nil
  self.nSelectType = nil
  self.nSelectId = nil
end

ChooseHomePageRolePanel.OnRelease = function(self)
  -- function num : 0_5
end

return ChooseHomePageRolePanel

