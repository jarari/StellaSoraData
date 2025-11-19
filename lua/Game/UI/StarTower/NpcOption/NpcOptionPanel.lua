local NpcOptionPanel = class("NpcOptionPanel", BasePanel)
NpcOptionPanel._bIsMainPanel = false
NpcOptionPanel._tbDefine = {
{sPrefabPath = "StarTower/NpcOptionPanel.prefab", sCtrlName = "Game.UI.StarTower.NpcOption.NpcOptionCtrl"}
}
NpcOptionPanel.Awake = function(self)
  -- function num : 0_0
end

NpcOptionPanel.OnEnable = function(self)
  -- function num : 0_1
end

NpcOptionPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

NpcOptionPanel.OnDisable = function(self)
  -- function num : 0_3
end

NpcOptionPanel.OnDestroy = function(self)
  -- function num : 0_4
end

NpcOptionPanel.OnRelease = function(self)
  -- function num : 0_5
end

return NpcOptionPanel

