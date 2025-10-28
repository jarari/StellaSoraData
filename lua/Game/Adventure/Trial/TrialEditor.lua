local TrialEditor = class("TrialEditor")

local mapEventConfig = {
    LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
    [EventId.AbandonBattle] = "OnEvent_AbandonBattle",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    TestBedNoteChange = "OnEvent_TestBedNoteChange",
}

function TrialEditor:Init(parent,floorId)
    self.parent = parent
    self.nLevelId = floorId

    self.mapLevelCfg = ConfigTable.GetData("TrialFloor", floorId)
    if not self.mapLevelCfg then
        return
    end

    self.mapBuildData = PlayerData.Build:GetTrialBuild(self.mapLevelCfg.TrialBuild)
    self.tbCharId, self.tbCharTrialId, self.mapCharData, self.mapTalentAddLevel = {}, {}, {}, {}
    for _,mapChar in ipairs(self.mapBuildData.tbChar) do
        table.insert(self.tbCharId, mapChar.nTid)
        self.tbCharTrialId[mapChar.nTid] = mapChar.nTrialId
        self.mapCharData[mapChar.nTid] = PlayerData.Char:GetTrialCharById(mapChar.nTrialId)
        self.mapTalentAddLevel[mapChar.nTid] = PlayerData.Talent:GetTrialEnhancedPotential(mapChar.nTrialId)
    end

    self.tbDiscId, self.mapDiscData = {}, {}
    for _, nDiscId in ipairs(self.mapBuildData.tbDisc) do
        if nDiscId > 0 then
            table.insert(self.tbDiscId, nDiscId)
            local mapCfg = ConfigTable.GetData("TrialDisc", nDiscId)
            if mapCfg then
                self.mapDiscData[mapCfg.DiscId] = PlayerData.Disc:GetTrialDiscById(nDiscId)
            end
        end
    end

    self:ParseDepotData()

    local params = NovaAPI.GetDynamicLevelParamsBootConfig()
    CS.AdventureModuleHelper.EnterDynamic(floorId, self.tbCharId, GameEnum.dynamicLevelType.Trial, params)
    NovaAPI.EnterModule("AdventureModuleScene", true)
end
function TrialEditor:ParseDepotData()
    self.tbDepotPotential = {}
    for nCharId, tbPerk in pairs(self.mapBuildData.tbPotentials) do
        if self.tbCharTrialId[nCharId] then
            if not self.tbDepotPotential[nCharId] then
                self.tbDepotPotential[nCharId] = {}
            end
            for _, v in ipairs(tbPerk) do
                self.tbDepotPotential[nCharId][v.nPotentialId] = v.nLevel
            end
        else
            printError("体验build内，有多余角色的潜能" .. nCharId)
        end
    end
end
function TrialEditor:OnEvent_LoadLevelRefresh()
    self:ChangeNote()
    self:ResetNoteInfo()
end
function TrialEditor:OnEvent_LevelResult(bSuccess)
    if bSuccess then
        self:PlaySuccessPerform({})
    else
        self.parent:LevelEnd()
    end
end
function TrialEditor:OnEvent_AbandonBattle()
    self:OnEvent_LevelResult(false)
end
function TrialEditor:OnEvent_AdventureModuleEnter()
    EventManager.Hit(EventId.OpenPanel, PanelId.TrialBattlePanel, self.tbCharId)
    for idx, nCharId in ipairs(self.tbCharId) do
        local stActorInfo = self:CalCharFixedEffect(self.tbCharTrialId[nCharId],idx == 1, self.tbDiscId)
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,stActorInfo)
    end
    self:ResetDiscInfo()
end
function TrialEditor:BindEvent()
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
function TrialEditor:UnBindEvent()
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
function TrialEditor:PlaySuccessPerform(FirstRewardItems,RewardItems,nStar)
    local function func_OpenResult(bSuccess)
        self.bSettle = false
        self.parent:LevelEnd()
    end

    local tbChar = self.tbCharId

    local function levelEndCallback()
        EventManager.Remove("ADVENTURE_LEVEL_UNLOAD_COMPLETE",self,levelEndCallback)
        local nType = self.mapLevelCfg.Theme
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

function TrialEditor:CalCharFixedEffect(nTrialId,bMainChar, tbDiscId)
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    PlayerData.Char:CalCharacterTrialAttrBattle(nTrialId,stActorInfo,bMainChar,tbDiscId, self.mapLevelCfg.TrialBuild)
    return stActorInfo
end

function TrialEditor:ResetDiscInfo()
    local tbDiscInfo = {}
    for k, nDiscId in ipairs(self.tbDiscId) do
        if k <= 3 then
            local discInfo = PlayerData.Disc:CalcTrialInfoInBuild(nDiscId, self.mapBuildData.tbSecondarySkill)
            table.insert(tbDiscInfo, discInfo)
        end
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetDiscInfo,tbDiscInfo)
end

function TrialEditor:ResetNoteInfo()
    local tbNoteInfo = {}
    for i, v in pairs(self.tbNote) do
        local noteInfo = CS.Lua2CSharpInfo_NoteInfo()
        noteInfo.noteId = i
        noteInfo.noteCount = v
        table.insert(tbNoteInfo, noteInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
end

function TrialEditor:ChangeNote()
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

function TrialEditor:OnEvent_TestBedNoteChange(noteList)
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

return TrialEditor