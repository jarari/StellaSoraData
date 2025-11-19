local DiscPanel = class("DiscPanel", BasePanel)
DiscPanel._nFADEINTYPE = 2
DiscPanel._tbDefine = {
{sPrefabPath = "Disc/DiscPanel.prefab", sCtrlName = "Game.UI.Disc.DiscCtrl"}
}
DiscPanel.ChangeMatList = function(self, mapMat, bRemove)
  -- function num : 0_0
  -- DECOMPILER ERROR at PC4: Confused about usage of register: R3 in 'UnsetPending'

  if not bRemove then
    (self.tbMat)[mapMat.nIndex] = mapMat
  else
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self.tbMat)[mapMat.nIndex] = nil
  end
end

DiscPanel.ClearMatList = function(self)
  -- function num : 0_1
  self.tbMat = {}
end

DiscPanel.Awake = function(self)
  -- function num : 0_2 , upvalues : _ENV
  self.tbMat = {}
  self.nId = nil
  self.nCurTog = nil
  self.bPause = false
  self.bAvg = false
  self.bGetAvgReward = false
  self.mapAvgRewardData = {}
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nId = tbParam[1]
    self.tbId = tbParam[2]
    self.nCurTog = tbParam[3]
  end
end

DiscPanel.OnEnable = function(self)
  -- function num : 0_3
end

DiscPanel.OnDisable = function(self)
  -- function num : 0_4
end

DiscPanel.OnDestroy = function(self)
  -- function num : 0_5
end

return DiscPanel

