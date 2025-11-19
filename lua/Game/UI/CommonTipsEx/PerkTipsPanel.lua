local PerkTipsPanel = class("PerkTipsPanel", BasePanel)
PerkTipsPanel._bIsMainPanel = false
PerkTipsPanel._bAddToBackHistory = false
PerkTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
PerkTipsPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/PerkTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.PerkTipsCtrl"}
}
PerkTipsPanel.Awake = function(self)
  -- function num : 0_0
end

PerkTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

PerkTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

PerkTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

PerkTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return PerkTipsPanel

