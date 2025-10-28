
local RegionBossFormationPanel = class("RegionBossFormationPanel", BasePanel)




RegionBossFormationPanel._tbDefine = {
    {sPrefabPath = "RegionBossFormationEx/RegionBossFormationPanel.prefab", sCtrlName = "Game.UI.RegionBossFormationEx.RegionBossFormationCtrl"},
}
-------------------- local function --------------------

-------------------- base function --------------------
function RegionBossFormationPanel:Awake()
    local nId = PlayerData.RogueBoss:GetRegionBossId()
   -- CS.AdventureModuleHelper.EnterSelectTeam(AllEnum.WorldMapNodeType.Rogueboss, nId, nil, 0)
end
function RegionBossFormationPanel:OnEnable(bPlayFadeIn)
end
function RegionBossFormationPanel:OnDisable()
end
function RegionBossFormationPanel:OnDestroy()
end
-------------------- callback function --------------------

return RegionBossFormationPanel