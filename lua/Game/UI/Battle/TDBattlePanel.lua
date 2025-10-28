
local TDBattlePanel = class("TDBattlePanel", BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"


TDBattlePanel.OpenMinMap = true
TDBattlePanel._bAddToBackHistory = false
TDBattlePanel._tbDefine = 
{   -- 定义当前 Panel 由哪些 prefab 组成，以及每个 prefab 分别由哪个 ctrl 关联控制
    { sPrefabPath = "RoguelikeItemTip/RoguelikeItemTipPanel.prefab",        sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl" },
    { sPrefabPath = "Battle/BattleDashboard.prefab",                        sCtrlName = "Game.UI.Battle.BattleDashboardCtrl" },
    { sPrefabPath = "Battle/MainBattleMenu.prefab",                         sCtrlName = "Game.UI.Battle.MainBattleMenuCtrl" },
    -- { sPrefabPath = "Battle/VirtualJoystickUI/VirtualJoystickUI.prefab",    sCtrlName = "Game.UI.Battle.VirtualJoystickCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab",        sCtrlName = "Game.UI.Battle.MainBattleCtrl" },
    --{ sPrefabPath = "GuideProloguel/GuideProloguelPanel.prefab",            sCtrlName = "Game.UI.GuideProloguel.GuideProloguelCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab",        sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl" },
    { sPrefabPath = "TDRoomInfo/TDRoomInfo.prefab",                         sCtrlName = "Game.UI.TravelerDuelRoomInfo.TDRoomInfoCtrl" },
    { sPrefabPath = "Battle/SkillHintIndicators.prefab",                    sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators" },
    {
        sPrefabPath = "Battle/CommonBattlePausePanel.prefab",
        sCtrlName = "Game.UI.TravelerDuelRoomInfo.TDPauseCtrl",
    },
    { sPrefabPath = "Battle/SubSkillDisplay.prefab",                        sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl" },
    --{ sPrefabPath = "Battle/AdventureMainUI/JumpOverTimeLine.prefab",        sCtrlName = "Game.UI.Battle.JumpOverTimeLineCtrl" },
}
function TDBattlePanel:Awake()
    GamepadUIManager.EnterAdventure()
    GamepadUIManager.EnableGamepadUI("BattleMenu", {}) -- 菜单和AdventureMainUI ctrl在OnEnable的时候会添加节点
    self.BattleType = GameEnum.worldLevelType.TravelerDuel
end
function TDBattlePanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        local mapLevel = ConfigTable.GetData("TravelerDuelBossLevel", PlayerData.TravelerDuel.entryLevelId)
        if mapLevel then
            local FloorId = mapLevel.FloorId
            local floorData = ConfigTable.GetData("TravelerDuelFloor", FloorId)
            if floorData and floorData.IntroCutscene ~= "" then
                EventManager.Hit(EventId.BattleDashboardVisible, false)
            end
        end
        EventManager.Hit(EventId.OpenPanel, PanelId.Hud)
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormation)
        EventManager.Hit(EventId.ClosePanel, PanelId.RegionBossFormation)
    end
    cs_coroutine.start(wait)
end
function TDBattlePanel:OnAfterEnter()
    EventManager.Hit(EventId.SubSkillDisplayInit,self._tbParam[1])
end

function TDBattlePanel:OnDisable()
    GamepadUIManager.DisableGamepadUI("BattleMenu")
    GamepadUIManager.QuitAdventure()
end

return TDBattlePanel

