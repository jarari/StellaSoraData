--选择看板娘界面

local ChooseHomePageRolePanel = class("ChooseHomePageRolePanel", BasePanel)

ChooseHomePageRolePanel._tbDefine = {
    {sPrefabPath = "MainViewBoard/ChooseHomePageRolePanel.prefab", sCtrlName = "Game.UI.MainViewBoard.ChooseHomePageRoleCtrl"},
}

-------------------- local function --------------------
-------------------- base function --------------------
function ChooseHomePageRolePanel:Awake()
    self.nSelectCharId = nil
    self.nSelectOutfitId = nil
    self.nSelectType = nil
    self.nSelectId = nil
end
function ChooseHomePageRolePanel:OnEnable()
end
function ChooseHomePageRolePanel:OnAfterEnter()
end
function ChooseHomePageRolePanel:OnDisable()
end
function ChooseHomePageRolePanel:OnDestroy()
    self.nSelectCharId = nil
    self.nSelectOutfitId = nil
    self.nSelectType = nil
    self.nSelectId = nil
end
function ChooseHomePageRolePanel:OnRelease()
end
-------------------- callback function --------------------


return ChooseHomePageRolePanel
