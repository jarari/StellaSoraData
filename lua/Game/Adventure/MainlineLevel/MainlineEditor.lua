local MainlineEditor = class("MainlineEditor")


local RapidJson = require "rapidjson"




local Actor2DManager = require "Game.Actor2D.Actor2DManager"

local mapEventConfig = {
    LevelStateChanged = "OnEvent_SendMsgFinishBattle",
    [EventId.AbandonBattle] = "OnEvent_AbandonBattle",
    InteractiveBoxGet = "OnEvent_OpenChest",
    LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    TestBedNoteChange = "OnEvent_TestBedNoteChange",
}
local tbTheme = {1,2,3,4}
function MainlineEditor:Init(parent,nSelectId,nTeamIdx,tbChestS,tbChestL,tbDisc)
    self.bSettle = false
    self.parent = parent
    self:BindEvent()
    self._nSelectId = nSelectId
    self.nCurTeamIndex = nTeamIdx
    self.tbChar = PlayerData.Team:GetTeamCharId(nTeamIdx)
    self.nLargeTotalCount = 0
    self.nSmallTotalCount = 0
    self.curFloorIdx = 1
    self.curSmallCount = 0
    self.curLargeCount = 0
    self.bNewSmall = false
    self.bNewLarge = false
    self._tbBoxS = nil
    self._tbBoxL = nil
    self._tbOpendChestS = {} -- 在主线战斗中开启的宝箱索引
    self._tbOpendChestL = {} -- 在主线战斗中开启的宝箱索引
    local mapMainline = ConfigTable.GetData_Mainline(nSelectId)
    self:PrePorcessChestData(self._nSelectId)
    self.nSmallTotalCount = #self._tbBoxS
    self.nLargeTotalCount = #self._tbBoxL
    self.tbDisc = tbDisc

    CS.AdventureModuleHelper.EnterMainlineMap(mapMainline.FloorId[1], self.tbChar,tbChestS,tbChestL)
    self.curSmallCount = #tbChestS
    self.curLargeCount = #tbChestL
    NovaAPI.EnterModule("AdventureModuleScene", true)
end
function MainlineEditor:InitBootConfig(parent,nSelectId,tbTeam,tbChestS,tbChestL, tbTalentSkillAI,tbDisc,tbNote, tbSkinId)
    self.nMainLineId = nSelectId
    self.parent = parent
    self:BindEvent()
    self._nSelectId = 10101
    self.nCurTeamIndex = 0
    self.tbChar = tbTeam
    self.nLargeTotalCount = 0
    self.nSmallTotalCount = 0
    self.curSmallCount = 0
    self.curLargeCount = 0
    self.bNewSmall = false
    self.bNewLarge = false
    self._tbBoxS = {}
    self._tbBoxL = {}
    self._tbOpendChestS = {} -- 在主线战斗中开启的宝箱索引
    self._tbOpendChestL = {} -- 在主线战斗中开启的宝箱索引
    self.tbTalentSkillAI = tbTalentSkillAI
    self:PrePorcessChestData(self._nSelectId)
    self.nSmallTotalCount = #self._tbBoxS
    self.nLargeTotalCount = #self._tbBoxL
    self.tbDisc = tbDisc
    self.tbNote = tbNote
    self.tbSkinId = tbSkinId
    CS.AdventureModuleHelper.EnterMainlineMap(nSelectId, tbTeam,tbChestS,tbChestL)
    NovaAPI.EnterModule("AdventureModuleScene", true)
end
function MainlineEditor:SetTheme()
    safe_call_cs_func(CS.AdventureModuleHelper.SetRglTheme,self.tbTheme)
end
function MainlineEditor:BindEvent()
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Add(nEventId, self, callback)
        end
    end
end
function MainlineEditor:UnBindEvent()
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Remove(nEventId, self, callback)
        end
    end
end
function MainlineEditor:CalCharFixedEffect(nCharId,bMainChar)
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    local nHeartStoneLevel = PlayerData.Char:CalCharacterAttrBattle(nCharId,stActorInfo,bMainChar,self.tbDisc)
    if self.tbSkinId and self.tbSkinId[nCharId] then
        stActorInfo.skinId = self.tbSkinId[nCharId]
    end
    return stActorInfo,nHeartStoneLevel
end
function MainlineEditor:PrePorcessChestData(nMainlineId) --预处理DataTable的宝箱数据
    if ConfigTable.GetData_Mainline(nMainlineId) == nil then
        printError("no level data："..nMainlineId)
        return
    end
    local tbChestS = decodeJson(ConfigTable.GetData_Mainline(nMainlineId).MinChestReward)
    local tbChestL = decodeJson(ConfigTable.GetData_Mainline(nMainlineId).MaxChestReward)
    self._tbBoxS = tbChestS
    self._tbBoxL = tbChestL
end
function MainlineEditor:PlaySuccessPerform(GenerRewardItems, FirstRewardItems, ChestRewardItems, nExp, nStar)
    local function func_OpenResult(bSuccess)
        EventManager.Hit(EventId.ClosePanel,PanelId.BtnTips)
        print("Perform"..tostring(bSuccess))
        local sLarge,sSmall = self:CalChestInfo()
        EventManager.Hit(EventId.OpenPanel, 
        PanelId.BattleResult,
        true,
        nStar,
        GenerRewardItems,
        FirstRewardItems,
        ChestRewardItems,
        nExp, 
        false,
        sLarge,
        sSmall,
        self._nSelectId)
        self.bSettle = false
    end
    local tbChar = self.tbChar
    local function levelEndCallback()
        EventManager.Remove("ADVENTURE_LEVEL_UNLOAD_COMPLETE",self,levelEndCallback)
        local nFloorCount = #ConfigTable.GetData_Mainline(self._nSelectId).FloorId
        local nMapId = ConfigTable.GetData_Mainline(self._nSelectId).FloorId[nFloorCount]
        local nType = ConfigTable.GetData("MainlineFloor", nMapId).Theme
        local sName = ConfigTable.GetData("EndSceneType", nType).EndSceneName
        local function jumpPerform()
            NovaAPI.DispatchEventWithData("SKIP_SETTLEMENT_PERFORM")
        end
        EventManager.Hit(EventId.OpenPanel,PanelId.BtnTips,jumpPerform)
        local tbSkin = {}
        for _, nCharId in ipairs(tbChar) do
            local nSkinId = PlayerData.Char:GetCharSkinId(nCharId)
            table.insert(tbSkin,nSkinId)
        end
        CS.AdventureModuleHelper.PlaySettlementPerform(sName, "", tbSkin, func_OpenResult)
    end
    EventManager.Add("ADVENTURE_LEVEL_UNLOAD_COMPLETE",self,levelEndCallback)
    CS.AdventureModuleHelper.LevelStateChanged(true)
end
function MainlineEditor:OnEvent_OpenChest(nIndex,nType)
    local mapChest
    if nType == 1 then -- 小寶箱
        if self._tbBoxS == nil then
            return
        end
        if self._tbBoxS[nIndex] == nil then
            return
        end
        mapChest = ConfigTable.GetData("Chest", self._tbBoxS[nIndex])
        table.insert(self._tbOpendChestS, nIndex)
        self.curSmallCount = self.curSmallCount + 1
        self.bNewSmall = true
    else
        if self._tbBoxL == nil then
            return
        end
        if self._tbBoxL[nIndex] == nil then
            return
        end
        self.curLargeCount = self.curLargeCount + 1
        self.bNewLarge = true
        mapChest = ConfigTable.GetData("Chest", self._tbBoxL[nIndex])
        table.insert(self._tbOpendChestL, nIndex)
    end
    local function ShowTips(nTid,nCount)
        if nTid == 0 or nCount == 0 then
            return
        end
        EventManager.Hit(EventId.ShowRoguelikeDrop,nTid,nCount)
    end
    ShowTips(mapChest.Item1,mapChest.Number1)
    ShowTips(mapChest.Item2,mapChest.Number2)
    ShowTips(mapChest.Item3,mapChest.Number3)
    ShowTips(mapChest.Item4,mapChest.Number4)
end
function MainlineEditor:OnEvent_LoadLevelRefresh()
    self:ChangeNote()
    self:ResetNoteInfo()
end
function MainlineEditor:OnEvent_AdventureModuleEnter()
    print("OnEvent_AdventureModuleEnter")
    self:ResetDiscInfo()
    for idx, nCharId in ipairs(self.tbChar) do
        local stActorInfo,nHeartStoneLevel= self:CalCharFixedEffect(nCharId,idx == 1)
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,stActorInfo)
    end
    self:SetTheme()
    EventManager.Hit(EventId.OpenPanel, PanelId.Adventure,self.tbChar)
    if self.nMainLineId and self.nMainLineId == 9999901 then
        safe_call_cs_func(CS.AdventureModuleHelper.ResetBTalentAndStoneHeart)
    end
end
function MainlineEditor:OnEvent_SendMsgFinishBattle(LevelResult)
    if self.bSettle == true then
        print("已在结算流程中！")
        return
    end
    self.bSettle = true
    print("OnEvent_SendMsgFinishBattle")


    if LevelResult == AllEnum.LevelResult.Failed then --角色全部死亡
        self:OnEvent_AbandonBattle()
        return
    end
    local mapMainline = ConfigTable.GetData_Mainline(self._nSelectId)
    if self.curFloorIdx < #mapMainline.FloorId then
        self:ChangeFloor()
        return
    end
    local nStar = 1
    local nMainlineId = self._nSelectId
    if #self._tbBoxS == self.curSmallCount then
        nStar = nStar+1
    end
    if #self._tbBoxL == self.nLargeTotalCount then
        nStar = nStar+1
    end
    local function func_cbFinishSucc(_,mapMainData)
        local function func_AvgEnd()
            EventManager.Remove("StoryDialog_DialogEnd",self,func_AvgEnd)
            local sLarge,sSmall = self:CalChestInfo()
            EventManager.Hit(EventId.OpenPanel, 
                            PanelId.BattleResult,
                            true,
                            nStar,
                            mapMainData.GenerRewardItems,
                            mapMainData.FirstRewardItems,
                            mapMainData.ChestRewardItems,
                            mapMainData.Exp, 
                            false,
                            sLarge,
                            sSmall,
                            nMainlineId)
        end
        local sAvgId = PlayerData.Mainline:GetAfterBattleAvg()
        if sAvgId then
            EventManager.Add("StoryDialog_DialogEnd",self,func_AvgEnd)
            EventManager.Hit("StoryDialog_DialogStart", sAvgId)
        else
            self:PlaySuccessPerform(mapMainData.GenerRewardItems, mapMainData.FirstRewardItems, mapMainData.ChestRewardItems,mapMainData.Exp, nStar)
        end
    end
    func_cbFinishSucc(nil,{GenerRewardItems = {},FirstRewardItems = {},ChestRewardItems = {}})
end
function MainlineEditor:OnEvent_AbandonBattle()
    if  self.GMTest == true then
        self.GMTest = false
        self:PlaySuccessPerform({},3)
        self._tbOpendChest = {} --清空本关中开启的宝箱列表
        return
    end
    if self._nSelectId > 0 then
        local function func_cbExitSucc(_, mapMainData)
            local nMainlineId = self._nSelectId
            EventManager.Hit(EventId.OpenPanel, PanelId.BattleResult, false, 0,{},{},{},0,false,sLarge,sSmall,nMainlineId,{103})
        end
        func_cbExitSucc(nil,{})
    end
end
function MainlineEditor:ChangeFloor()
    local mapMainline = ConfigTable.GetData_Mainline(self._nSelectId)
    self.curFloorIdx = self.curFloorIdx + 1
    local function levelUnloadCallback()
        for idx, nCharId in ipairs(self.tbChar) do
            local stActorInfo,nHeartStoneLevel= self:CalCharFixedEffect(nCharId,idx == 1)
            safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,stActorInfo)
        end
        self:SetTheme()
    end
    EventManager.Add("ADVENTURE_LEVEL_UNLOAD_COMPLETE",self,levelUnloadCallback)
    CS.AdventureModuleHelper.EnterMainlineMap(mapMainline.FloorId[self.curFloorIdx], self.tbChar,self.tbOpenedChestId)
    CS.AdventureModuleHelper.LevelStateChanged(false)
    self.bSettle = false
end
function MainlineEditor:CalChestInfo()
    local sSmall
    local sLarge

    if self.bNewSmall then
        sSmall = string.format("<color=#4ee5d1>%d</color>/%d",self.curSmallCount,self.nSmallTotalCount)
    else
        sSmall = string.format("%d/%d",self.curSmallCount,self.nSmallTotalCount)
    end
    if self.bNewLarge then
        sLarge = string.format("<color=#4ee5d1>%d</color>/%d",self.curLargeCount,self.nLargeTotalCount)
    else
        sLarge = string.format("%d/%d",self.curLargeCount,self.nLargeTotalCount)
    end
    if self.nSmallTotalCount == 0 then
        sSmall = "无"
    end
    if self.nLargeTotalCount == 0 then
        sLarge = "无"
    end
    return sLarge,sSmall
end

function MainlineEditor:ResetDiscInfo()
    local tbDiscInfo = {}
    for k, nDiscId in ipairs(self.tbDisc) do
        if k <= 3 then
            local mapDiscData = PlayerData.Disc:GetDiscById(nDiscId)
            if mapDiscData and mapDiscData.sName then
                local discInfo = mapDiscData:GetDiscInfo(self.tbNote)
                table.insert(tbDiscInfo, discInfo)
            else
                printError("星盘数据有误id:" .. nDiscId)
            end
        end
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetDiscInfo,tbDiscInfo)
end

function MainlineEditor:ResetNoteInfo()
    local tbNoteInfo = {}
    for i, v in pairs(self.tbNote) do
        local noteInfo = CS.Lua2CSharpInfo_NoteInfo()
        noteInfo.noteId = i
        noteInfo.noteCount = v
        table.insert(tbNoteInfo, noteInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
end

function MainlineEditor:ChangeNote()
    if not self.mapDiscEft then
        self.mapDiscEft = {}
    end
    for k, nDiscId in ipairs(self.tbDisc) do
        if k <= 3 then
            local mapDiscData = PlayerData.Disc:GetDiscById(nDiscId)
            if mapDiscData and mapDiscData.sName then
                if self.mapDiscEft[nDiscId] == nil then
                    self.mapDiscEft[nDiscId] = {}
                else
                    --移除老效果
                    for _, tbEft in pairs(self.mapDiscEft[nDiscId]) do
                        for _, tbEftData in ipairs(tbEft) do
                            UTILS.RemoveEffect(tbEftData[1],tbEftData[2])
                        end
                    end
                    self.mapDiscEft[nDiscId] = {}
                end
                --添加新效果
                local tbDiscEft = mapDiscData:GetSkillEffect(self.tbNote)
                for _, mapEft in ipairs(tbDiscEft) do
                    if self.mapDiscEft[nDiscId][mapEft[1]] == nil then
                        self.mapDiscEft[nDiscId][mapEft[1]] = {}
                        for _, nCharId in ipairs(self.tbChar) do
                            local nEftUid = UTILS.AddEffect(nCharId,mapEft[1],mapEft[2],0)
                            table.insert(self.mapDiscEft[nDiscId][mapEft[1]],{nEftUid,nCharId})
                        end
                    end
                end
            else
                printError("星盘数据有误id:" .. nDiscId)
            end
        end
    end
end

function MainlineEditor:OnEvent_TestBedNoteChange(noteList)
    if noteList then
        self.tbNote = {}
        for i = 0, noteList.Count - 1 do
            self.tbNote[noteList[i].Id] = noteList[i].count
        end
        self:ResetNoteInfo()
        self:ResetDiscInfo()
        self:ChangeNote()
    end
end


return MainlineEditor