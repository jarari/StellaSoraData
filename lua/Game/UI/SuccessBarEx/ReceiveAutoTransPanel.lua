local ReceiveAutoTransPanel = class("ReceiveAutoTransPanel", BasePanel)
ReceiveAutoTransPanel._bIsMainPanel = false
ReceiveAutoTransPanel._tbDefine = {
{sPrefabPath = "SuccessBarEx/ReceiveAutoTransPanel.prefab", sCtrlName = "Game.UI.SuccessBarEx.ReceiveAutoTransCtrl"}
}
ReceiveAutoTransPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.tbSrc = tbParam[1]
    self.tbDst = tbParam[2]
    self.callback = tbParam[3]
    local sort = function(a, b)
    -- function num : 0_0_0 , upvalues : _ENV
    local cfgA = (ConfigTable.GetData_Item)(a.Tid)
    local cfgB = (ConfigTable.GetData_Item)(b.Tid)
    local rarityA = cfgA.Rarity
    local rarityB = cfgB.Rarity
    local typeA = cfgA.Type
    local typeB = cfgB.Type
    if rarityA >= rarityB then
      do return rarityA == rarityB end
      if typeA >= typeB then
        do return typeA == typeB end
        if b.Qty >= a.Qty then
          do return a.Qty == b.Qty end
          do return a.Tid < b.Tid end
          -- DECOMPILER ERROR: 8 unprocessed JMP targets
        end
      end
    end
  end

    ;
    (table.sort)(self.tbSrc, sort)
    ;
    (table.sort)(self.tbDst, sort)
  end
end

ReceiveAutoTransPanel.OnEnable = function(self)
  -- function num : 0_1
end

ReceiveAutoTransPanel.OnDisable = function(self)
  -- function num : 0_2
end

ReceiveAutoTransPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ReceiveAutoTransPanel

