local SkillTipsPanel = class("SkillTipsPanel", BasePanel)
SkillTipsPanel._bIsMainPanel = false
SkillTipsPanel._bAddToBackHistory = false
SkillTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
SkillTipsPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/SkillTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.SkillTipsCtrl"}
}
SkillTipsPanel.Awake = function(self)
  -- function num : 0_0
end

SkillTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

SkillTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

SkillTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

SkillTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return SkillTipsPanel

