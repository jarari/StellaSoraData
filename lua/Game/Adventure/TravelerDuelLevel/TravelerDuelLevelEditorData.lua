local TravelerDuelLevelEditorData = class("TravelerDuelLevelEditorData")

local Actor2DManager = require "Game.Actor2D.Actor2DManager"



local mapEventConfig = {
    LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
    [EventId.AbandonBattle] = "OnEvent_AbandonBattle",
    TravelerDuel_Result = "OnEvent_LevelResult",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    TestBedNoteChange = "OnEvent_TestBedNoteChange",
}

function TravelerDuelLevelEditorData:Init(parent,nLevel,tbAffixes,tbChar, tbDisc, tbNote)
    self.parent = parent
    self.tbCharId = tbChar
    self.tbDisc = tbDisc
    self.tbNote = tbNote
    self.mapActorInfo = {}
    for idx, nTid in ipairs(tbChar) do
        local stActorInfo,nHeartStoneLevel = self:CalCharFixedEffect(nTid,idx == 1)
        local nWeaponId = ConfigTable.GetData_Character(nTid).Weapons[1]
        self.mapActorInfo[nTid] = {nHp = -1, stActorInfo = stActorInfo,nHeartStoneLevel = nHeartStoneLevel,nWeaponId = nWeaponId}
end
    local mapLevel = ConfigTable.GetData("TravelerDuelBossLevel", nLevel)
    if mapLevel == nil then
        printError("TravelerDuelBossLevel missing:"..nLevel)
        return
    end
    CS.AdventureModuleHelper.EnterTravelerDuel(nLevel,mapLevel.FloorId,self.tbCharId,tbAffixes)
    NovaAPI.EnterModule("AdventureModuleScene", true)
end
function TravelerDuelLevelEditorData:OnEvent_LoadLevelRefresh()
    self:ChangeNote()
    self:ResetNoteInfo()
end
function TravelerDuelLevelEditorData:OnEvent_LevelResult(bSuccess,nTime)
    if bSuccess then
        self:PlaySuccessPerform({},{},3)
    else
        self.parent:LevelEnd()
    end
end
function TravelerDuelLevelEditorData:OnEvent_AbandonBattle()
    self:OnEvent_LevelResult(false,0)
end
function TravelerDuelLevelEditorData:OnEvent_AdventureModuleEnter()
    EventManager.Hit(EventId.OpenPanel, PanelId.Adventure,self.tbCharId)
    self:ResetDiscInfo()
    self:SetTheme()
    self:SetCharFixedAttribute()
end
function TravelerDuelLevelEditorData:BindEvent()
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
function TravelerDuelLevelEditorData:UnBindEvent()
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
function TravelerDuelLevelEditorData:PlaySuccessPerform(FirstRewardItems,RewardItems,nStar)
    local function func_OpenResult(bSuccess)
        -- EventManager.Hit(EventId.ClosePanel,PanelId.BtnTips)
        -- print("Perform"..tostring(bSuccess))
        -- local sLarge,sSmall = self:CalChestInfo()
        -- EventManager.Hit(EventId.OpenPanel, 
        -- PanelId.BattleResult,
        -- true,
        -- nStar,
        -- GenerRewardItems or {},
        -- FirstRewardItems or {},
        -- ChestRewardItems or {},
        -- false,
        -- sLarge,
        -- sSmall,
        -- self._nSelectId,self.tbChar)
        self.bSettle = false
        self.parent:LevelEnd()
    end

    local tbChar = self.tbCharId

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

function TravelerDuelLevelEditorData:SetTempActorAttribute(nCharId)
    local mapChar = {nLevel = 1,nAdvance = 0}
    local nLevel = mapChar.nLevel
    local nAdvance = mapChar.nAdvance
    local nAttrId = UTILS.GetCharacterAttributeId(nCharId,nAdvance,nLevel)
    local mapCharAttr = ConfigTable.GetData_Attribute(tostring(nAttrId))
    if mapCharAttr == nil then
        printError("属性配置不存在:"..nAttrId)
        return {}
    end
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    stActorInfo.Atk = mapCharAttr.Atk
    stActorInfo.Def = mapCharAttr.Def
    stActorInfo.MDef = mapCharAttr.Mdef
    stActorInfo.ShieldBonus = mapCharAttr.ShieldBonus
    stActorInfo.IncomingShieldBonus = mapCharAttr.IncomingShieldBonus
    stActorInfo.Evd = mapCharAttr.Evd
    stActorInfo.CritRate = mapCharAttr.CritRate
    stActorInfo.CritResistance = mapCharAttr.CritResistance
    stActorInfo.CritPower = mapCharAttr.CritPower
    stActorInfo.HitRate = mapCharAttr.HitRate
    stActorInfo.DefPierce = mapCharAttr.DefPierce
    stActorInfo.WEE = mapCharAttr.WEE
    stActorInfo.FEE = mapCharAttr.FEE
    stActorInfo.SEE = mapCharAttr.SEE
    stActorInfo.AEE = mapCharAttr.AEE
    stActorInfo.LEE = mapCharAttr.LEE
    stActorInfo.DEE = mapCharAttr.DEE
    stActorInfo.WEP = mapCharAttr.WEP
    stActorInfo.FEP = mapCharAttr.FEP
    stActorInfo.AEP = mapCharAttr.AEP
    stActorInfo.SEP = mapCharAttr.SEP
    stActorInfo.LEP = mapCharAttr.LEP
    stActorInfo.DEP = mapCharAttr.DEP
    stActorInfo.WER = mapCharAttr.WER
    stActorInfo.FER = mapCharAttr.FER
    stActorInfo.AER = mapCharAttr.AER
    stActorInfo.SER = mapCharAttr.SER
    stActorInfo.LER = mapCharAttr.LER
    stActorInfo.DER = mapCharAttr.DER
    stActorInfo.Hp = mapCharAttr.Hp
    stActorInfo.Suppress = mapCharAttr.Suppress
    stActorInfo.SkillLevel = {1,1,1}
    stActorInfo.skinId = PlayerData.Char:GetCharSkinId(nCharId)
    stActorInfo.attrId = mapCharAttr.sAttrId
    safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,stActorInfo)
end
function TravelerDuelLevelEditorData:SetCharFixedAttribute()
    for nCharId,mapInfo in pairs(self.mapActorInfo) do
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,mapInfo.stActorInfo)
    end
end
function TravelerDuelLevelEditorData:CalCharFixedEffect(nCharId,bMainChar)
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    local nHeartStoneLevel = PlayerData.Char:CalCharacterAttrBattle(nCharId,stActorInfo,bMainChar,self.tbDisc)
    return stActorInfo,nHeartStoneLevel
end
function TravelerDuelLevelEditorData:SetTheme()
    safe_call_cs_func(CS.AdventureModuleHelper.SetRglTheme,self.tbTheme)
end

function TravelerDuelLevelEditorData:ResetDiscInfo()
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

function TravelerDuelLevelEditorData:ResetNoteInfo()
    local tbNoteInfo = {}
    for i, v in pairs(self.tbNote) do
        local noteInfo = CS.Lua2CSharpInfo_NoteInfo()
        noteInfo.noteId = i
        noteInfo.noteCount = v
        table.insert(tbNoteInfo, noteInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
end

function TravelerDuelLevelEditorData:ChangeNote()
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

function TravelerDuelLevelEditorData:OnEvent_TestBedNoteChange(noteList)
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


return TravelerDuelLevelEditorData