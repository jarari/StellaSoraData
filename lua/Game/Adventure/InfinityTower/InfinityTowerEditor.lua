local InfinityTowerEditor = class("InfinityTowerEditor")

local mapEventConfig = {
    LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
    InfinityTowerEnd = "OnEvent_InfinityTowerEnd",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    BattlePause = "OnEvnet_Pause",
    [EventId.AbandonBattle] = "OnEvent_AbandonBattle",
    Infinity_Tower_RunTime = "OnEvent_InfinityTowerRunTime",
    TestBedNoteChange = "OnEvent_TestBedNoteChange",
}

function InfinityTowerEditor:Init(parent,floorId,tbChar, tbDisc, tbNote)
    self.parent = parent
    self.floorId = floorId
    self.tbCharId = tbChar
    self.mapActorInfo = {}
    self.lvRunTime = 0
    self.tbDisc = tbDisc
    self.tbNote = tbNote

    PlayerData.nCurGameType = AllEnum.WorldMapNodeType.InfinityTower
    CS.AdventureModuleHelper.EnterInfinityTowerFloor(floorId,tbChar,false)
    NovaAPI.EnterModule("AdventureModuleScene", true)
    EventManager.Hit("Infinity_Refresh_Msg")
end

function InfinityTowerEditor:CalCharFixedEffect(nCharId,bMainChar)
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    local nHeartStoneLevel = PlayerData.Char:CalCharacterAttrBattle(nCharId,stActorInfo,bMainChar,self.tbDisc)
    return stActorInfo,nHeartStoneLevel
end

function InfinityTowerEditor:BindEvent()
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
function InfinityTowerEditor:UnBindEvent()
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

function InfinityTowerEditor:OnEvent_InfinityTowerEnd(state)
    --1失败 2成功
    if state == 1 then

    else

    end
    EventManager.Hit("Infinity_Hide_Time")
    self.parent:LevelEnd()
end

function InfinityTowerEditor:OnEvent_AdventureModuleEnter()
    EventManager.Hit(EventId.OpenPanel, PanelId.Hud)
    EventManager.Hit(EventId.OpenPanel, PanelId.InfinityTowerBattlePanel,self.tbCharId)
    for idx, nCharId in ipairs(self.tbCharId) do
        local stActorInfo,nHeartStoneLevel= self:CalCharFixedEffect(nCharId,idx == 1)
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,stActorInfo)
    end
    self:ResetDiscInfo()
end

function InfinityTowerEditor:OnEvent_LoadLevelRefresh()
    self:ChangeNote()
    self:ResetNoteInfo()
    local tabAddAffixBuff = PlayerData.InfinityTower:GetFloorAffixBuff(self.tbCharId,self.floorId)
    safe_call_cs_func(CS.AdventureModuleHelper.InfinityTowerFloorEffects,tabAddAffixBuff)
end

function InfinityTowerEditor:OnEvnet_Pause()
    EventManager.Hit("show_Infinity_Pause",self.lvRunTime)
end

function InfinityTowerEditor:OnEvent_AbandonBattle()
    self:OnEvent_InfinityTowerEnd(3)
end

function InfinityTowerEditor:OnEvent_InfinityTowerRunTime(rTime)
    self.lvRunTime = rTime
end

function InfinityTowerEditor:ResetDiscInfo()
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

function InfinityTowerEditor:ResetNoteInfo()
    local tbNoteInfo = {}
    for i, v in pairs(self.tbNote) do
        local noteInfo = CS.Lua2CSharpInfo_NoteInfo()
        noteInfo.noteId = i
        noteInfo.noteCount = v
        table.insert(tbNoteInfo, noteInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
end

function InfinityTowerEditor:ChangeNote()
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

function InfinityTowerEditor:OnEvent_TestBedNoteChange(noteList)
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

return InfinityTowerEditor