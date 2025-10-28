
local PrologueAdventurePanel = class("PrologueAdventurePanel", BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"



PrologueAdventurePanel.OpenMinMap = true
PrologueAdventurePanel._bAddToBackHistory = false
PrologueAdventurePanel._tbDefine = 
{
    {
        sPrefabPath = "RoguelikeItemTip/RoguelikeItemTipPanel.prefab",
        sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl",
    },
    { sPrefabPath = "Battle/BattleDashboard.prefab",sCtrlName = "Game.UI.Battle.BattleDashboardCtrl" }, -- { sPrefabPath = "Battle/VirtualJoystickUI/VirtualJoystickUI.prefab", sCtrlName = "Game.UI.Battle.VirtualJoystickCtrl" },
    {
        sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", 
        sCtrlName = "Game.UI.Battle.MainBattleCtrl",
    },
    {
        sPrefabPath = "GuideProloguel/GuideProloguelPanel.prefab",
        sCtrlName = "Game.UI.GuideProloguel.GuideProloguelCtrl"
    },
    {
        sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab",
        sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl",
    },
    { sPrefabPath = "Battle/SkillHintIndicators.prefab",                    sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators" },

    {
        sPrefabPath = "Battle/SubSkillDisplay.prefab", 
        sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"
    },
}

-------------------- base function --------------------

-------------------- callback function --------------------
function PrologueAdventurePanel:Awake()
    GamepadUIManager.EnterAdventure()
    GamepadUIManager.EnableGamepadUI("BattleMenu", {}) -- 菜单和AdventureMainUI ctrl在OnEnable的时候会添加节点
    self.BattleType = GameEnum.worldLevelType.PrologueBattleLevel
end
function PrologueAdventurePanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        --EventManager.Hit(EventId.OpenPanel, PanelId.Hud)
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormation)
        EventManager.Hit(EventId.ClosePanel, PanelId.RegionBossFormation)
    end
    cs_coroutine.start(wait)
end
function PrologueAdventurePanel:OnAfterEnter()
    EventManager.Hit(EventId.SubSkillDisplayInit,self._tbParam[1])
end

function PrologueAdventurePanel:OnDisable()
    GamepadUIManager.DisableGamepadUI("BattleMenu")
    GamepadUIManager.QuitAdventure()
end

return PrologueAdventurePanel