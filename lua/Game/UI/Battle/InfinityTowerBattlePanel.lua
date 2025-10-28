local InfinityTowerBattlePanel = class("InfinityTowerBattlePanel",BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"

InfinityTowerBattlePanel.OpenMinMap = true
InfinityTowerBattlePanel._bAddToBackHistory = false
InfinityTowerBattlePanel._tbDefine =
{   -- 定义当前 Panel 由哪些 prefab 组成，以及每个 prefab 分别由哪个 ctrl 关联控制
    { sPrefabPath = "Battle/BattleDashboard.prefab",                        sCtrlName = "Game.UI.Battle.BattleDashboardCtrl" },
    { sPrefabPath = "Battle/MainBattleMenu.prefab",                         sCtrlName = "Game.UI.Battle.MainBattleMenuCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab",        sCtrlName = "Game.UI.Battle.MainBattleCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab",        sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl" },
    { sPrefabPath = "Battle/SkillHintIndicators.prefab",                    sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators" },
    { sPrefabPath = "InfinityTower/InfinityTowerBattleMsg.prefab",          sCtrlName = "Game.UI.InfinityTower.InfinityTowerBattleMsgCtrl" },
    { sPrefabPath = "Battle/SubSkillDisplay.prefab",                        sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl" },
    { sPrefabPath = "InfinityTower/InfinityTowerPause.prefab",              sCtrlName = "Game.UI.InfinityTower.InfinityTowerPauseCtrl" },
    { sPrefabPath = "InfinityTower/InfinityTowerBattleResultPanel.prefab",  sCtrlName = "Game.UI.InfinityTower.InfinityTowerBattleResultCtrl" },
    { sPrefabPath = "InfinityTower/InfinityTowerBountyUp.prefab",           sCtrlName = "Game.UI.InfinityTower.InfinityTowerBountyUp" },
}

function InfinityTowerBattlePanel:Awake()
    GamepadUIManager.EnterAdventure()
    GamepadUIManager.EnableGamepadUI("BattleMenu", {}) -- 菜单和AdventureMainUI ctrl在OnEnable的时候会添加节点
    self.BattleType = GameEnum.worldLevelType.InfinityTower
end
function InfinityTowerBattlePanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        --EventManager.Hit(EventId.OpenPanel, PanelId.Hud)
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormation)
        EventManager.Hit(EventId.ClosePanel, PanelId.RegionBossFormation)
    end
    cs_coroutine.start(wait)
end
function InfinityTowerBattlePanel:OnAfterEnter()
    EventManager.Hit(EventId.SubSkillDisplayInit,self._tbParam[1])
end

function InfinityTowerBattlePanel:OnDisable()
    GamepadUIManager.DisableGamepadUI("BattleMenu")
    GamepadUIManager.QuitAdventure()
end

return InfinityTowerBattlePanel