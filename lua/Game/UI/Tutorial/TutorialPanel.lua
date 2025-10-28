-- Panel 模板

local TutorialPanel = class("TutorialPanel", BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"
TutorialPanel._bAddToBackHistory = false
TutorialPanel.OpenMinMap = false
TutorialPanel._tbDefine = {
    { 
        sPrefabPath = "Battle/BattleDashboard.prefab",
        sCtrlName = "Game.UI.Battle.BattleDashboardCtrl" 
    },  
        --菜单显示
    {
        sPrefabPath = "Tutorial/TutorialMenu.prefab",
        sCtrlName = "Game.UI.Tutorial.TutorialMenuCtrl"
    },
    {
        sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab",
        sCtrlName = "Game.UI.Battle.MainBattleCtrl",
    }, 
    {
        sPrefabPath = "Battle/SkillHintIndicators.prefab",
        sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"
    },
    {
        sPrefabPath = "FixedRoguelikeEx/FRIndicators.prefab",
        sCtrlName = "Game.UI.FixedRoguelikeEx.FRIndicators",
    },
    --潜能卡三选一
    {
        sPrefabPath = "StarTower/PotentialSelectPanel.prefab",
        sCtrlName = "Game.UI.Tutorial.TutorialPotentialSelectCtrl"
    },
     --音符技能激活弹窗
    {
        sPrefabPath = "StarTower/DiscSkillActivePanel.prefab",
        sCtrlName = "Game.UI.Tutorial.TutorialDiscSkillActiveCtrl"
    },
    --音符
    {
        sPrefabPath = "StarTower/StarTowerNotePanel.prefab",
        sCtrlName = "Game.UI.Tutorial.TutorialNoteCtrl"
    },
    --任务显示
    {
        sPrefabPath = "Tutorial/TutorialInfo.prefab",
        sCtrlName = "Game.UI.Tutorial.TutorialInfoCtrl"
    },
    --暂停
    {
        sPrefabPath = "Tutorial/TutorialPause.prefab",
        sCtrlName = "Game.UI.Tutorial.TutorialPauseCtrl"
    },
    --新手引导
    {
        sPrefabPath = "GuideProloguel/GuideProloguelPanel.prefab",            
        sCtrlName = "Game.UI.GuideProloguel.GuideProloguelCtrl" 
    },
    --支援技能展示
    {
        sPrefabPath = "Battle/SubSkillDisplay.prefab",
        sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"
    },
}
-------------------- local function --------------------

-------------------- base function --------------------
function TutorialPanel:Awake()
    self.trUIRoot = GameObject.Find("---- UI ----").transform
    self.tbTeam = self._tbParam[1]
    self.tbDisc = self._tbParam[2]
    self.mapCharData = self._tbParam[3]
    self.mapDiscData = self._tbParam[4]
    self.BattleType = GameEnum.worldLevelType.Dynamic
    self.DynamicType = GameEnum.dynamicLevelType.Tutorial
    GamepadUIManager.EnterAdventure()
    GamepadUIManager.EnableGamepadUI("BattleMenu", {}) -- 菜单和AdventureMainUI ctrl在OnEnable的时候会添加节点
end
function TutorialPanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        EventManager.Hit(EventId.OpenPanel, PanelId.Hud,false,true)
    end
    cs_coroutine.start(wait)
end
function TutorialPanel:OnAfterEnter()
    EventManager.Hit(EventId.SubSkillDisplayInit, self._tbParam[1])
end
function TutorialPanel:OnDisable()
    GamepadUIManager.DisableGamepadUI("BattleMenu")
    GamepadUIManager.QuitAdventure()
end
function TutorialPanel:OnDestroy()
end
function TutorialPanel:OnRelease()
end

function TutorialPanel:SetTop(goCanvas)
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

function TutorialPanel:GetSkillLevel(nCharId)
    local mapChar = self.mapCharData[nCharId]
    local tbList = {}
    tbList[GameEnum.skillSlotType.NORMAL] = mapChar and mapChar.tbSkillLvs[1] or 1
    tbList[GameEnum.skillSlotType.B] = mapChar and mapChar.tbSkillLvs[2] or 1
    tbList[GameEnum.skillSlotType.C] = mapChar and mapChar.tbSkillLvs[3] or 1
    tbList[GameEnum.skillSlotType.D] = mapChar and mapChar.tbSkillLvs[4] or 1
    return tbList
end
-------------------- callback function --------------------
return TutorialPanel
