local StarTowerLevelSelectPanel = class("StarTowerLevelSelectPanel", BasePanel)
StarTowerLevelSelectPanel._tbDefine = {
{sPrefabPath = "StarTowerLevelSelect/StarTowerLevelSelect.prefab", sCtrlName = "Game.UI.StarTowerLevelSelect.StarTowerLevelSelectCtrl"}
}
StarTowerLevelSelectPanel.Awake = function(self)
  -- function num : 0_0
end

StarTowerLevelSelectPanel.OnEnable = function(self)
  -- function num : 0_1
end

StarTowerLevelSelectPanel.OnDisable = function(self)
  -- function num : 0_2
end

StarTowerLevelSelectPanel.OnDestroy = function(self)
  -- function num : 0_3
end

StarTowerLevelSelectPanel.OnRelease = function(self)
  -- function num : 0_4
end

StarTowerLevelSelectPanel.OnAfterEnter = function(self)
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

return StarTowerLevelSelectPanel

