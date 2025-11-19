local BdConvertPanel = class("BdConvertPanel", BasePanel)
BdConvertPanel._bIsMainPanel = true
BdConvertPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
BdConvertPanel._sUIResRootPath = "UI_Activity/"
BdConvertPanel._tbDefine = {
{sPrefabPath = "_500001/BdConvertPanel.prefab", sCtrlName = "Game.UI.Activity.BdConvert._500001.BdConvertCtrl"}
}
BdConvertPanel.Awake = function(self)
  -- function num : 0_0
end

BdConvertPanel.OnEnable = function(self)
  -- function num : 0_1
end

BdConvertPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

BdConvertPanel.OnDisable = function(self)
  -- function num : 0_3
end

BdConvertPanel.OnDestroy = function(self)
  -- function num : 0_4
end

BdConvertPanel.OnRelease = function(self)
  -- function num : 0_5
end

return BdConvertPanel

