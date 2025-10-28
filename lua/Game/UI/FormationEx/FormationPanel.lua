
local FormationPanel = class("FormationPanel", BasePanel)




FormationPanel._tbDefine = {
    {sPrefabPath = "MainlineFormationEx/MainlineFormationScenePanel.prefab", sCtrlName = "Game.UI.FormationEx.FormationCtrl"},
}
-------------------- local function --------------------

-------------------- base function --------------------
function FormationPanel:Awake()
    --local nId = PlayerData.Mainline:GetSelectId()
    --CS.AdventureModuleHelper.EnterSelectTeam(AllEnum.WorldMapNodeType.Mainline, nId, nil, 0)
    EventManager.Add("EnterModule", self, self.OnEvent_EnterModule)
end
function FormationPanel:OnEnable(bPlayFadeIn)
end
function FormationPanel:OnDisable()
end
function FormationPanel:OnDestroy()
    EventManager.Remove("EnterModule", self, self.OnEvent_EnterModule)
end
-------------------- callback function --------------------
function FormationPanel:OnEvent_EnterModule(moduleMgr, sExitModuleName, sEnterModuleName)
    if sEnterModuleName == "AdventureModuleScene" then
        self.bAddBuild = false
    end
end
return FormationPanel