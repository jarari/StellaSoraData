local PopupSkillPanel = class("PopupSkillPanel", BasePanel)
PopupSkillPanel._bIsMainPanel = false
PopupSkillPanel._bAddToBackHistory = false
PopupSkillPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
PopupSkillPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/PopupSkillPanel/PopupSkillPanel.prefab", sCtrlName = "Game.UI.CommonTipsEx.PopupSkillCtrl"}
}
PopupSkillPanel.Awake = function(self)
  -- function num : 0_0
end

PopupSkillPanel.OnEnable = function(self)
  -- function num : 0_1
end

PopupSkillPanel.OnDisable = function(self)
  -- function num : 0_2
end

PopupSkillPanel.OnDestroy = function(self)
  -- function num : 0_3
end

PopupSkillPanel.OnRelease = function(self)
  -- function num : 0_4
end

return PopupSkillPanel

