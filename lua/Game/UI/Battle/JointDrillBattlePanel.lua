local JointDrillBattlePanel = class("JointDrillBattlePanel", BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"

JointDrillBattlePanel.OpenMinMap = true
JointDrillBattlePanel._bAddToBackHistory = false

JointDrillBattlePanel._tbDefine =
{   -- 定义当前 Panel 由哪些 prefab 组成，以及每个 prefab 分别由哪个 ctrl 关联控制
    { sPrefabPath = "Battle/BattleDashboard.prefab",                         sCtrlName = "Game.UI.Battle.BattleDashboardCtrl" },
    { sPrefabPath = "Play_JointDrill/JointDrillMenu.prefab",                      sCtrlName = "Game.UI.JointDrill.JointDrillMenuCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab",         sCtrlName = "Game.UI.Battle.MainBattleCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab",         sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl" },
    { sPrefabPath = "Battle/SkillHintIndicators.prefab",                     sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators" },
    { sPrefabPath = "Battle/SubSkillDisplay.prefab",                         sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl" },
    { sPrefabPath = "Battle/CommonMonsterWarning.prefab",                    sCtrlName = "Game.UI.Battle.CommonMonsterWarningCtrl" },
    { sPrefabPath = "Play_JointDrill/JointDrillBossTime.prefab",                sCtrlName = "Game.UI.JointDrill.JintDrillTimeCtrl" }, --临时,正式流程删除
    { sPrefabPath = "Play_JointDrill/JointDrillPausePanel.prefab",                sCtrlName = "Game.UI.JointDrill.JointDrillPauseCtrl" },
}

function JointDrillBattlePanel:Awake()
    self.BattleType = GameEnum.worldLevelType.Dynamic
    self.DynamicType = GameEnum.dynamicLevelType.JointDrill
    self.trUIRoot = GameObject.Find("---- UI ----").transform
    GamepadUIManager.EnterAdventure()
    GamepadUIManager.EnableGamepadUI("BattleMenu", {}) -- 菜单和AdventureMainUI ctrl在OnEnable的时候会添加节点
    self.tbTeam = self._tbParam[1]
    self.nLevelId = self._tbParam[2]
    self.mapCharData = {}
    for _, nCharId in ipairs(self.tbTeam) do
        self.mapCharData[nCharId] = clone(PlayerData.Char:GetCharDataByTid(nCharId))
    end
end

function JointDrillBattlePanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        EventManager.Hit(EventId.OpenPanel, PanelId.Hud, true, true)
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormation)
        EventManager.Hit(EventId.ClosePanel, PanelId.RegionBossFormation)
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
    end
    cs_coroutine.start(wait)
end

function JointDrillBattlePanel:OnAfterEnter()
    EventManager.Hit(EventId.SubSkillDisplayInit, self._tbParam[1])
end

function JointDrillBattlePanel:OnDisable()
    GamepadUIManager.DisableGamepadUI("BattleMenu")
    GamepadUIManager.QuitAdventure()
end

return JointDrillBattlePanel