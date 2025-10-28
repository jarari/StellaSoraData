-- DiscPanel Panel
local DiscPanel = class("DiscPanel", BasePanel)
-- Panel 定义
DiscPanel._nFADEINTYPE = 2 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
DiscPanel._tbDefine = {
    {sPrefabPath = "Disc/DiscPanel.prefab", sCtrlName = "Game.UI.Disc.DiscCtrl"},
}
-------------------- local function --------------------
function DiscPanel:ChangeMatList(mapMat, bRemove)
    if not bRemove then
        self.tbMat[mapMat.nIndex] = mapMat
    else
        self.tbMat[mapMat.nIndex] = nil
    end
end
function DiscPanel:ClearMatList()
    self.tbMat = {}
end
-------------------- base function --------------------
function DiscPanel:Awake()
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
function DiscPanel:OnEnable()
end
function DiscPanel:OnDisable()
end
function DiscPanel:OnDestroy()
end
-------------------- callback function --------------------
return DiscPanel
