local ActivityLevelsBattlePanel = class("ActivityLevelsBattlePanel", BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"

ActivityLevelsBattlePanel._sUIResRootPath = ""
ActivityLevelsBattlePanel.OpenMinMap = true
ActivityLevelsBattlePanel._bAddToBackHistory = false
ActivityLevelsBattlePanel._tbDefine =
{   -- 定义当前 Panel 由哪些 prefab 组成，以及每个 prefab 分别由哪个 ctrl 关联控制
    { sPrefabPath = "UI/RoguelikeItemTip/RoguelikeItemTipPanel.prefab",        sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl" },
    { sPrefabPath = "UI/Battle/BattleDashboard.prefab",                        sCtrlName = "Game.UI.Battle.BattleDashboardCtrl" },
    { sPrefabPath = "UI/Battle/MainBattleMenu.prefab",                         sCtrlName = "Game.UI.Battle.MainBattleMenuCtrl" },
    -- { sPrefabPath = "Battle/VirtualJoystickUI/VirtualJoystickUI.prefab",    sCtrlName = "Game.UI.Battle.VirtualJoystickCtrl" },
    { sPrefabPath = "UI/Battle/AdventureMainUI/AdventureMainUI.prefab",        sCtrlName = "Game.UI.Battle.MainBattleCtrl" },
    { sPrefabPath = "UI/Battle/AdventureMainUI/BattlePopupTips.prefab",        sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl" },
    { sPrefabPath = "UI_Activity/Swim/ActivityLevels/ActivityLevelsInstanceInfo.prefab",        sCtrlName = "Game.UI.ActivityTheme.Swim.ActivityLevels.ActivityLevelsInstanceRoomInfo" },
    { sPrefabPath = "UI/Battle/SkillHintIndicators.prefab",                    sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators" },
    {
        sPrefabPath = "UI/Battle/CommonBattlePausePanel.prefab",
        sCtrlName = "Game.UI.ActivityTheme.Swim.ActivityLevels.ActivityLevelsInstancePauseCtrl",
    },
    {
        sPrefabPath = "UI/Battle/SubSkillDisplay.prefab",
        sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"
    },
}
function ActivityLevelsBattlePanel:Awake()
    GamepadUIManager.EnterAdventure()
    GamepadUIManager.EnableGamepadUI("BattleMenu", {}) -- 菜单和AdventureMainUI ctrl在OnEnable的时候会添加节点
    self.BattleType = GameEnum.worldLevelType.ActivityLevels
end
function ActivityLevelsBattlePanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        EventManager.Hit(EventId.OpenPanel, PanelId.Hud)
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormation)
        EventManager.Hit(EventId.ClosePanel, PanelId.RegionBossFormation)
    end
    cs_coroutine.start(wait)
end
function ActivityLevelsBattlePanel:OnAfterEnter()
    EventManager.Hit(EventId.SubSkillDisplayInit,self._tbParam[1])
end

function ActivityLevelsBattlePanel:OnDisable()
    GamepadUIManager.DisableGamepadUI("BattleMenu")
    GamepadUIManager.QuitAdventure()
end

return ActivityLevelsBattlePanel