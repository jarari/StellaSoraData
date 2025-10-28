local StarTowerFastBattlePanel = class("StarTowerFastBattlePanel", BasePanel)
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"
StarTowerFastBattlePanel._tbDefine = {
    {sPrefabPath = "StarTowerFastBattle/StarTowerFastBattlePanel.prefab", sCtrlName = "Game.UI.StarTowerFastBattle.StarTowerFastBattleCtrl"},

    --潜能卡三选一
    {
        sPrefabPath = "StarTower/PotentialSelectPanel.prefab",
        sCtrlName = "Game.UI.StarTower.Potential.PotentialSelectCtrl"
    },
    --潜能卡升级
    {
        sPrefabPath = "StarTower/PotentialLevelUpPanel.prefab",
        sCtrlName = "Game.UI.StarTower.Potential.PotentialLevelUpCtrl"
    },
    --命运卡三选一
    {
        sPrefabPath = "StarTower/FateCardSelectPanel.prefab",
        sCtrlName = "Game.UI.StarTower.FateCard.FateCardSelectCtrl"
    },
    --音符技能激活弹窗
    {
        sPrefabPath = "StarTower/DiscSkillActivePanel.prefab",
        sCtrlName = "Game.UI.StarTower.DiscTips.DiscSkillActiveCtrl"
    },
    --音符
    {
        sPrefabPath = "StarTower/StarTowerNotePanel.prefab",
        sCtrlName = "Game.UI.StarTower.StarTowerNoteCtrl"
    },
    --背包界面
    {
        sPrefabPath = "StarTower/StarTowerDepotPanel.prefab", 
        sCtrlName = "Game.UI.StarTower.Depot.StarTowerDepotCtrl"
    },

}
--StarTowerFastBattlePanel._bAddToBackHistory = false
-------------------- local function --------------------

-------------------- base function --------------------
function StarTowerFastBattlePanel:Awake()
    self.trUIRoot = GameObject.Find("---- UI ----").transform
    local tbStarTowerInfo = self:GetPanelParam()[1]
    local luaClass = require "Game.Adventure.StarTower.StarTowerSweepData"
    self.LevelData = luaClass.new(tbStarTowerInfo.Meta.Id)
    self.LevelData:Init(tbStarTowerInfo.Meta, tbStarTowerInfo.Room, tbStarTowerInfo.Bag)

    self.tbTeam = self.LevelData.tbTeam
    self.tbDisc = self.LevelData.tbDisc
    self.mapCharData = self.LevelData.mapCharData
    self.mapDiscData = self.LevelData.mapDiscData
    self.mapPotentialAddLevel = self.LevelData.mapPotentialAddLevel
    self.nStarTowerId = self.LevelData.nTowerId
    --音符显示列表
    self.tbShowNote = {}
    local mapCfg = ConfigTable.GetData("StarTower", self.nStarTowerId)
    if mapCfg ~= nil then
        local nDropGroup = mapCfg.SubNoteSkillDropGroupId
        local tbNoteDrop = CacheTable.GetData("_SubNoteSkillDropGroup", nDropGroup)
        if tbNoteDrop ~= nil then
            for _, v in ipairs(tbNoteDrop) do
                table.insert(self.tbShowNote, v.SubNoteSkillId)
            end
        end
    end
    table.sort(self.tbShowNote, function(a, b)
        return a < b
    end)
    GamepadUIManager.EnterAdventure(true)
end

function StarTowerFastBattlePanel:SetTop(goCanvas)
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

--是否是主控角色
function StarTowerFastBattlePanel:CheckMainChar(nCharId)
    if self.tbTeam ~= nil then
        for k, v in ipairs(self.tbTeam) do
            if v == nCharId then
                return k == 1
            end
        end
    end
    return false
end

function StarTowerFastBattlePanel:GetSkillLevel(nCharId)
    local mapChar = self.mapCharData[nCharId]
    local tbList = {}
    tbList[GameEnum.skillSlotType.NORMAL] = mapChar and mapChar.tbSkillLvs[1] or 1
    tbList[GameEnum.skillSlotType.B] = mapChar and mapChar.tbSkillLvs[2] or 1
    tbList[GameEnum.skillSlotType.C] = mapChar and mapChar.tbSkillLvs[3] or 1
    tbList[GameEnum.skillSlotType.D] = mapChar and mapChar.tbSkillLvs[4] or 1
    return tbList
end

function StarTowerFastBattlePanel:OnEnable()
    PlayerData.State:SetStarTowerSweepState(true)
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormation)
        EventManager.Hit(EventId.ClosePanel, PanelId.MainlineFormationDisc)
        EventManager.Hit(EventId.ClosePanel, PanelId.RegionBossFormation)
    end
    cs_coroutine.start(wait)
end
function StarTowerFastBattlePanel:OnDisable()
    PlayerData.State:SetStarTowerSweepState(false)
    GamepadUIManager.QuitAdventure()
end
function StarTowerFastBattlePanel:OnDestroy()
    self.LevelData:UnBindEvent()
end
function StarTowerFastBattlePanel:OnRelease()
end
function StarTowerFastBattlePanel:OnAfterEnter()
end
-------------------- callback function --------------------
return StarTowerFastBattlePanel