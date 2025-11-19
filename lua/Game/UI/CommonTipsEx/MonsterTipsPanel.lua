local MonsterTipsPanel = class("MonsterTipsPanel", BasePanel)
MonsterTipsPanel._bIsMainPanel = false
MonsterTipsPanel._bAddToBackHistory = false
MonsterTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
MonsterTipsPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/MonsterTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.MonsterTipsCtrl"}
}
MonsterTipsPanel.Awake = function(self)
  -- function num : 0_0
end

MonsterTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

MonsterTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

MonsterTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

MonsterTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return MonsterTipsPanel

