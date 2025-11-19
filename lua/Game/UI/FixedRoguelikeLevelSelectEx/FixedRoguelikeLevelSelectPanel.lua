local FixedRoguelikeLevelSelectPanel = class("FixedRoguelikeLevelSelectPanel", BasePanel)
FixedRoguelikeLevelSelectPanel._tbDefine = {
{sPrefabPath = "FRLevelSelectEx/RoguelikeLevelSelect.prefab", sCtrlName = "Game.UI.FixedRoguelikeLevelSelectEx.FixedRoguelikeLevelCtrl"}
}
FixedRoguelikeLevelSelectPanel.Awake = function(self)
  -- function num : 0_0
end

FixedRoguelikeLevelSelectPanel.OnEnable = function(self)
  -- function num : 0_1
end

FixedRoguelikeLevelSelectPanel.OnDisable = function(self)
  -- function num : 0_2
end

FixedRoguelikeLevelSelectPanel.OnDestroy = function(self)
  -- function num : 0_3
end

FixedRoguelikeLevelSelectPanel.OnRelease = function(self)
  -- function num : 0_4
end

FixedRoguelikeLevelSelectPanel.OnAfterEnter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local wait = function()
    -- function num : 0_5_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (PopUpManager.OpenPopUpPanelByType)((GameEnum.PopUpSeqType).FuncUnlock)
  end

  ;
  (cs_coroutine.start)(wait)
end

return FixedRoguelikeLevelSelectPanel

