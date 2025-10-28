local DynamicLevelEditor = class("DynamicLevelEditor")
local mapEventConfig = {
    LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
    [EventId.AbandonBattle] = "OnEvent_AbandonBattle",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    TestBedNoteChange = "OnEvent_TestBedNoteChange",
    BossRush_Spawn_Id = "OnEvent_BossRushSpawnId",
    ScoreBoss_BehaviorScore = "OnEvent_ControlScore",
}

function DynamicLevelEditor:Init(nLevelId, tbChar, tbDisc, tbNote, dynamicLevelType)
    self:BindEvent()

    self.tbCharId = tbChar
    self.mapActorInfo = {}
    self.tbDisc = tbDisc
    self.tbNote = tbNote
    self.dynamicType = dynamicLevelType
    print("ehre..." .. tostring(dynamicLevelType) .. tostring(GameEnum.dynamicLevelType.TowerDefense))
    local params = NovaAPI.GetDynamicLevelParamsBootConfig()
    if dynamicLevelType == GameEnum.dynamicLevelType.TowerDefense then
        print("here..." .. tostring(dynamicLevelType))
        CS.AdventureModuleHelper.EnterTowerDefenseLevel(nLevelId, params)
    else
        CS.AdventureModuleHelper.EnterDynamic(nLevelId, self.tbCharId, dynamicLevelType, params)
    end
    NovaAPI.EnterModule("AdventureModuleScene", true)
end

function DynamicLevelEditor:OnEvent_LoadLevelRefresh()
    self:ChangeNote()
    self:ResetNoteInfo()
end

function DynamicLevelEditor:OnEvent_AbandonBattle()
    --self:OnEvent_LevelResult(false,0)
end

function DynamicLevelEditor:OnEvent_BossRushMonsterBattleAttrChanged()
    self.isDontChangeHp = false
end

function DynamicLevelEditor:OnEvent_AdventureModuleEnter()
    --printError("OnEvent_AdventureModuleEnter")
    --根据不同活动类型加载UI
    if self.dynamicType == GameEnum.dynamicLevelType.JointDrill then
        --总力战临时处理
        EventManager.Hit(EventId.OpenPanel, PanelId.Adventure, self.tbCharId)
    end
    for idx, nCharId in ipairs(self.tbCharId) do
        local stActorInfo, nHeartStoneLevel = self:CalCharFixedEffect(nCharId, idx == 1)
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute, nCharId, stActorInfo)
    end
    self:SetTheme()
    self:ResetDiscInfo()
    --self:SetCharFixedAttribute()
end

function DynamicLevelEditor:SetCharFixedAttribute()
    for nCharId, mapInfo in pairs(self.mapActorInfo) do
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute, nCharId, mapInfo.stActorInfo)
    end
end

function DynamicLevelEditor:CalCharFixedEffect(nCharId, bMainChar)
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    local nHeartStoneLevel = PlayerData.Char:CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, self.tbDisc)
    return stActorInfo, nHeartStoneLevel
end
function DynamicLevelEditor:SetTheme()
    safe_call_cs_func(CS.AdventureModuleHelper.SetRglTheme, self.tbTheme)
end

function DynamicLevelEditor:ResetDiscInfo()
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
    safe_call_cs_func(CS.AdventureModuleHelper.SetDiscInfo, tbDiscInfo)
end

function DynamicLevelEditor:ResetNoteInfo()
    local tbNoteInfo = {}
    for i, v in pairs(self.tbNote) do
        local noteInfo = CS.Lua2CSharpInfo_NoteInfo()
        noteInfo.noteId = i
        noteInfo.noteCount = v
        table.insert(tbNoteInfo, noteInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
end

function DynamicLevelEditor:ChangeNote()
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
                            UTILS.RemoveEffect(tbEftData[1], tbEftData[2])
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
                            local nEftUid = UTILS.AddEffect(nCharId, mapEft[1], mapEft[2], 0)
                            table.insert(self.mapDiscEft[nDiscId][mapEft[1]], { nEftUid, nCharId })
                        end
                    end
                end
            else
                printError("星盘数据有误id:" .. nDiscId)
            end
        end
    end
end

function DynamicLevelEditor:OnEvent_TestBedNoteChange(noteList)
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

function DynamicLevelEditor:BindEvent()
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
function DynamicLevelEditor:UnBindEvent()
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
return DynamicLevelEditor