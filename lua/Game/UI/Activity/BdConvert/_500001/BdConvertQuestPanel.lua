local BdConvertQuestPanel = class("BdConvertQuestPanel", BasePanel)
BdConvertQuestPanel._bIsMainPanel = false
BdConvertQuestPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
BdConvertQuestPanel._sUIResRootPath = "UI_Activity/"
BdConvertQuestPanel._tbDefine = {
{sPrefabPath = "_500001/BdConvertQuestPanel.prefab", sCtrlName = "Game.UI.Activity.BdConvert._500001.BdConvertQuestCtrl"}
}
BdConvertQuestPanel.Awake = function(self)
  -- function num : 0_0
end

BdConvertQuestPanel.OnEnable = function(self)
  -- function num : 0_1
end

BdConvertQuestPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

BdConvertQuestPanel.OnDisable = function(self)
  -- function num : 0_3
end

BdConvertQuestPanel.OnDestroy = function(self)
  -- function num : 0_4
end

BdConvertQuestPanel.OnRelease = function(self)
  -- function num : 0_5
end

return BdConvertQuestPanel

