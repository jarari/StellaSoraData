local VampireSurvivorBattlePanel = class("VampireSurvivorBattlePanel",BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"

VampireSurvivorBattlePanel.OpenMinMap = true
VampireSurvivorBattlePanel._bAddToBackHistory = false
VampireSurvivorBattlePanel._tbDefine =
{   -- 定义当前 Panel 由哪些 prefab 组成，以及每个 prefab 分别由哪个 ctrl 关联控制
    { sPrefabPath = "Battle/BattleDashboard.prefab",                         sCtrlName = "Game.UI.Battle.BattleDashboardCtrl" },
    { sPrefabPath = "VampireBattle/VampireMenu.prefab",                      sCtrlName = "Game.UI.VampireSurvivor.VampireMenuCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab",         sCtrlName = "Game.UI.Battle.MainBattleCtrl" },
    { sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab",         sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl" },
    { sPrefabPath = "Battle/SkillHintIndicators.prefab",                     sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators" },
    { sPrefabPath = "Battle/CommonMonsterWarning.prefab",                    sCtrlName = "Game.UI.Battle.CommonMonsterWarningCtrl" },
    { sPrefabPath = "RegionBossTimeEx/RegionBossTime.prefab",                sCtrlName = "Game.UI.VampireSurvivor.VampireSurvivorTimeCtrl" }, --临时,正式流程删除
    { sPrefabPath = "VampireBattle/VampireFateCardSelectPanel.prefab",        sCtrlName = "Game.UI.VampireSurvivor.VampireFateCardSelect"},
    { sPrefabPath = "VampireBattle/VampireRoomInfo.prefab",                   sCtrlName = "Game.UI.VampireSurvivor.VampireSurvivorRoomInfo"},
    { sPrefabPath = "VampireBattle/VampirePausePanel.prefab",                 sCtrlName = "Game.UI.VampireSurvivor.VampireSurvivorPauseCtrl"},
    { sPrefabPath = "VampireBattle/VampireDepotPanel.prefab",                 sCtrlName = "Game.UI.VampireSurvivor.VampireDepotCtrl"},
    { sPrefabPath = "Battle/SubSkillDisplay.prefab",                         sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl" },
}
function VampireSurvivorBattlePanel:Awake()
    self.BattleType = GameEnum.worldLevelType.VampireInstance
    self.trUIRoot = GameObject.Find("---- UI ----").transform
    EventManager.Add("VampireSurvivorChangeArea", self, self.OnEvent_ChangeArea)
    GamepadUIManager.EnterAdventure()
    GamepadUIManager.EnableGamepadUI("BattleMenu", {}) -- 菜单和AdventureMainUI ctrl在OnEnable的时候会添加节点
    self.tbTeam = self._tbParam[1]
    self.nLevelId = self._tbParam[2]
    self.mapCharData = {} 
    for _, nCharId in ipairs(self.tbTeam) do
        self.mapCharData[nCharId] = clone(PlayerData.Char:GetCharDataByTid(nCharId))
    end
end
function VampireSurvivorBattlePanel:SetTop(goCanvas)
    local nTopLayer = 0
    if nil ~= self.trUIRoot then
        local nChildCount = self.trUIRoot.childCount
        local trChild
        for i = 1, nChildCount do
            trChild =  self.trUIRoot:GetChild(i - 1)
            nTopLayer =  math.max(nTopLayer, NovaAPI.GetCanvasSortingOrder(trChild:GetComponent("Canvas")))
        end
    end
    if nTopLayer > 0 then
        NovaAPI.SetCanvasSortingOrder(goCanvas, nTopLayer + 1)
    end
end
function VampireSurvivorBattlePanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        EventManager.Hit(EventId.OpenPanel, PanelId.Hud,true,true)
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormation)
        EventManager.Hit(EventId.ClosePanel, PanelId.RegionBossFormation)
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
    end
    cs_coroutine.start(wait)
end
function VampireSurvivorBattlePanel:OnAfterEnter()
    EventManager.Hit(EventId.SubSkillDisplayInit,self._tbParam[1])
end
function VampireSurvivorBattlePanel:OnDisable()
    EventManager.Remove("VampireSurvivorChangeArea", self, self.OnEvent_ChangeArea)
    GamepadUIManager.DisableGamepadUI("BattleMenu")
    GamepadUIManager.QuitAdventure()
end
function VampireSurvivorBattlePanel:OnEvent_ChangeArea(tbTeam)
    self.tbTeam = tbTeam
    self.mapCharData = {} 
    for _, nCharId in ipairs(self.tbTeam) do
        self.mapCharData[nCharId] = clone(PlayerData.Char:GetCharDataByTid(nCharId))
    end
end
return VampireSurvivorBattlePanel