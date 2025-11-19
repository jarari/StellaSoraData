local RegionBossFormationPanel = class("RegionBossFormationPanel", BasePanel)
RegionBossFormationPanel._tbDefine = {
{sPrefabPath = "RegionBossFormationEx/RegionBossFormationPanel.prefab", sCtrlName = "Game.UI.RegionBossFormationEx.RegionBossFormationCtrl"}
}
RegionBossFormationPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local nId = (PlayerData.RogueBoss):GetRegionBossId()
end

RegionBossFormationPanel.OnEnable = function(self, bPlayFadeIn)
  -- function num : 0_1
end

RegionBossFormationPanel.OnDisable = function(self)
  -- function num : 0_2
end

RegionBossFormationPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return RegionBossFormationPanel

