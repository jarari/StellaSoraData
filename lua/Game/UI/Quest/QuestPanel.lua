local QuestPanel = class("QuestPanel", BasePanel)
QuestPanel._tbDefine = {
{sPrefabPath = "Quest/QuestPanel.prefab", sCtrlName = "Game.UI.Quest.QuestCtrl"}
}
QuestPanel.Awake = function(self)
  -- function num : 0_0
  self.nCurTab = nil
end

QuestPanel.OnEnable = function(self)
  -- function num : 0_1
end

QuestPanel.OnDisable = function(self)
  -- function num : 0_2
end

QuestPanel.OnDestroy = function(self)
  -- function num : 0_3
end

QuestPanel.OnRelease = function(self)
  -- function num : 0_4
end

return QuestPanel

