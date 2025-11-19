local TransitionPanel = class("TransitionPanel", BasePanel)
TransitionPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
TransitionPanel._bAddToBackHistory = false
TransitionPanel._tbDefine = {
{sPrefabPath = "TransitionEx/TransitionPanel.prefab", sCtrlName = "Game.UI.TransitionEx.TransitionCtrl"}
}
TransitionPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.STATUS = (AllEnum.TransitionStatus).OutAnimDone
end

TransitionPanel.ChangeStatus = function(self, nStatus)
  -- function num : 0_1
  self.STATUS = nStatus
end

TransitionPanel.GetTransitionStatus = function(self)
  -- function num : 0_2
  return self.STATUS
end

return TransitionPanel

