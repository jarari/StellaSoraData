local RoguelikeResultPanel = class("RoguelikeResultPanel", BasePanel)
RoguelikeResultPanel._bAddToBackHistory = false
RoguelikeResultPanel._tbDefine = {
{sPrefabPath = "RoguelikeResultPanel/RoguelikeResult.prefab", sCtrlName = "Game.UI.RoguelikeResultPanel.RoguelikeResultCtrl"}
}
RoguelikeResultPanel.Awake = function(self)
  -- function num : 0_0
end

RoguelikeResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

RoguelikeResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

RoguelikeResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return RoguelikeResultPanel

