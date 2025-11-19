local BdConvertBuildPanel = class("BdConvertBuildPanel", BasePanel)
BdConvertBuildPanel._bIsMainPanel = true
BdConvertBuildPanel._bAddToBackHistory = true
BdConvertBuildPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
BdConvertBuildPanel._sUIResRootPath = "UI_Activity/"
BdConvertBuildPanel._tbDefine = {
{sPrefabPath = "_500001/BdConvertBuildPanel.prefab", sCtrlName = "Game.UI.Activity.BdConvert._500001.BdConvertBuildCtrl"}
}
BdConvertBuildPanel.Awake = function(self)
  -- function num : 0_0
end

BdConvertBuildPanel.OnEnable = function(self)
  -- function num : 0_1
end

BdConvertBuildPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

BdConvertBuildPanel.OnDisable = function(self)
  -- function num : 0_3
end

BdConvertBuildPanel.OnDestroy = function(self)
  -- function num : 0_4
end

BdConvertBuildPanel.OnRelease = function(self)
  -- function num : 0_5
end

return BdConvertBuildPanel

