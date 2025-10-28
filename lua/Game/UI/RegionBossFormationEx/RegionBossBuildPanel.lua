
local RegionBossBuildPanel = class("RegionBossBuildPanel", BasePanel)

RegionBossBuildPanel._tbDefine = {
    {sPrefabPath = "RegionBossFormationEx/RegionBossBuildPanel.prefab", sCtrlName = "Game.UI.RegionBossFormationEx.RegionBossBuildCtrl"},
}

function RegionBossBuildPanel:Awake()
    EventManager.Add("EnterModule", self, self.OnEvent_EnterModule)
end
function RegionBossBuildPanel:OnEnable()
end
function RegionBossBuildPanel:OnDisable()
end
function RegionBossBuildPanel:OnDestroy()
    EventManager.Remove("EnterModule", self, self.OnEvent_EnterModule)
end
function RegionBossBuildPanel:OnRelease()
end

function RegionBossBuildPanel:OnEvent_EnterModule(moduleMgr, sExitModuleName, sEnterModuleName)
    if sEnterModuleName == "AdventureModuleScene" then
        self.bAddBuild = false
    end
end

return RegionBossBuildPanel