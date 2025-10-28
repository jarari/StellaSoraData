-- Panel 模板

local BtnTipsPanel = class("BtnTipsPanel", BasePanel)
BtnTipsPanel._bIsMainPanel = false
BtnTipsPanel._bAddToBackHistory = false

BtnTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
BtnTipsPanel._tbDefine = {
    {sPrefabPath = "CommonTipsEx/ButtonTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.BtnTipsCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function BtnTipsPanel:Awake()
end
function BtnTipsPanel:OnEnable()
end
function BtnTipsPanel:OnDisable()
end
function BtnTipsPanel:OnDestroy()
end
function BtnTipsPanel:OnRelease()
end
-------------------- callback function --------------------
return BtnTipsPanel
