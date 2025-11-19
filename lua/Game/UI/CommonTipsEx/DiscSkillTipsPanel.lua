local DiscSkillTipsPanel = class("DiscSkillTipsPanel", BasePanel)
DiscSkillTipsPanel._bIsMainPanel = false
DiscSkillTipsPanel._bAddToBackHistory = false
DiscSkillTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
DiscSkillTipsPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/DiscSkillTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.DiscSkillTipsCtrl"}
}
DiscSkillTipsPanel.Awake = function(self)
  -- function num : 0_0
end

DiscSkillTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

DiscSkillTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

DiscSkillTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

DiscSkillTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return DiscSkillTipsPanel

