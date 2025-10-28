local AutoBattleBalanceEditor = class("AutoBattleBalanceEditor")
local File = CS.System.IO.File
local RapidJson = require "rapidjson"
local mapEventConfig = {
    LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete",
    LevelStateChanged = "OnEvent_LevelStateChanged",
}

function AutoBattleBalanceEditor:Init(eetType)
    self:BindEvent()
    self.isConfigTeam = false
    self.configTeam = NovaAPI.GetAutoBattleBalanceConfigTeam()
    if self.configTeam ~= nil then
        self.isConfigTeam = true
        self.configTeamIndex = 0
        --printError(self.configTeam.Count)
        --printError(self.configTeam[0].charMain.Id)
    end
    self.tmpLevle =tonumber(ConfigTable.GetData("TestCharacterAtt", "Level").Value)
    self.tmpAdvanceLevel =tonumber(ConfigTable.GetData("TestCharacterAtt", "AdvanceLevel").Value)
    self.tmpTalentLevel =tonumber(ConfigTable.GetData("TestCharacterAtt", "TalentLevel").Value)
    self.tmpSkillLevel =tonumber(ConfigTable.GetData("TestCharacterAtt", "SkillLevel").Value)
    self.tmpPotentialLevel =tonumber(ConfigTable.GetData("TestCharacterAtt", "PotentialLevel").Value)
    self.tmpMainPlayerHP =tonumber(ConfigTable.GetData("TestCharacterAtt", "MainPlayerHP").Value)/100


    local tb = string.split(tostring(eetType), ":")
    self.EET = tonumber(tb[2])
    self:CreateLevelNeedMsg()
end

function AutoBattleBalanceEditor:ResetNeedData()
    self.tbCharId = {}
    self.tbPotentials = {}
    self.tbDisc = {}
    self.tbNotes = {}
    self.tbSecondarySkill = {}
end

function AutoBattleBalanceEditor:CreateLevelNeedMsg()
    self:ResetNeedData()
    local tmpIndex = 0
    if self.isConfigTeam == false then
        local sRootPath = NovaAPI.ApplicationDataPath .. "/../AutoBattleBCTeam/" .. self.EET .. "/TestingProgress.txt"
        local sJsonText = File.ReadAllText(sRootPath)
        self.progress = tonumber(sJsonText)
        self.progress = self.progress + 1
        --printError("AutoBattleYYY self.progress == " .. self.progress)
        local sTeamPath = NovaAPI.ApplicationDataPath .. "/../AutoBattleBCTeam/" .. self.EET .. "/Team/Limitedteam.json"

        local sJsonText = File.ReadAllText(sTeamPath)
        local map_Text = RapidJson.decode(sJsonText)
        local tmp = nil--map_Text[tostring(self.progress)]
        for i = self.progress, 99999 do
            if map_Text[tostring(i)] ~= nil then
                tmp = map_Text[tostring(i)]
                tmpIndex = i
                break
            end
        end
        --printError("tmpIndex === " .. tmpIndex)
        if tmp == nil then
            local InUnityEditor = NovaAPI.IsEditorPlatform()
            if InUnityEditor then
                CS.EditorApplication.ExitPlaymode() --没有队伍后，有意报错，卡主unity不继续后续流程
            end
            return
        end
        self:CreateCharInfo(tmp)
        self:CreateDiscNoteData(self.EET)

    else
        self.teamInfo = self.configTeam[self.configTeamIndex]
        if self.teamInfo == nil then

            return
        end
        self:CreateCharInfoConfig()
        self:CreateDiscNoteDataConfig()

        self.configTeamIndex = self.configTeamIndex + 1
        tmpIndex = self.configTeamIndex
    end

    CS.AdventureModuleHelper.EnterAutoBattleBalance(9999941,self.tbCharId,self.tmpMainPlayerHP,tmpIndex)
    if not self.isNext then
        NovaAPI.EnterModule("AdventureModuleScene", true)
    else
        self:OnEvent_AdventureModuleEnter()
    end
end

--创建角色数据
function AutoBattleBalanceEditor:CreateCharInfo(tmp)
    --printError("AutoBattleYYY  " .. tmp["charMain"].Id .. "   " .. tmp["charSub1"].Id .. "  " .. tmp["charSub2"].Id)
    self.tbCharId = {tmp["charMain"].Id,tmp["charSub1"].Id,tmp["charSub2"].Id}

    ---构建关卡角色数据---
    local tmpTabChar = {}
    for i = 1, 3 do
        local tab = {}
        tab.Tid = self.tbCharId[i]
        tab.Exp = 0
        tab.DatingEventIds = {}
        tab.DatingEventRewardIds = {}
        tab.Favor = nil
        tab.Skin = self.tbCharId[i] * 100 + 1
        tab.EquipmentIds = {[1] = 0,[2] = 0,[3] = 0}
        tab.Level = self.tmpLevle
        tab.CreateTime = 0
        tab.Advance = self.tmpAdvanceLevel
        tab.TalentNodes = ""
        tab.SkillLvs = {[1] =self.tmpSkillLevel,[2] = self.tmpSkillLevel,[3] = self.tmpSkillLevel,[4] = self.tmpSkillLevel,[5] = self.tmpSkillLevel}
        tab.Plots = {}
        tab.AffinityExp = 0
        tab.AffinityLevel = 0
        tab.ArchiveRewardIds = {}
        tab.TalentBackground = 5
        tab.tmpTalentLevel = self.tmpTalentLevel
        tab.CharGemPresets = {
            InUsePresetIndex = 0,
            CharGemPresets = {},
        }
        tab.CharGemSlots = {}
        table.insert(tmpTabChar,tab)
    end
    PlayerData.Char:CacheCharacters(tmpTabChar)
    ---构建关卡角色数据---

    self:CacheTalentData(tmpTabChar,0)
    self:CreatePotentialsData(tmp)
end

function AutoBattleBalanceEditor:CreateCharInfoConfig()
    self.tbCharId = {self.teamInfo.charMain.Id,self.teamInfo.charSub1.Id,self.teamInfo.charSub2.Id}

    ---构建关卡角色数据---
    local tmpTabChar = {}

    local tabMain = {}
    local _mainSillLevel = self.teamInfo.charMain.SkillLv
    tabMain.Tid = self.tbCharId[1]
    tabMain.Exp = 0
    tabMain.DatingEventIds = {}
    tabMain.DatingEventRewardIds = {}
    tabMain.Favor = nil
    tabMain.Skin = self.tbCharId[1] * 100 + 1
    tabMain.EquipmentIds = {[1] = 0,[2] = 0,[3] = 0}
    tabMain.Level = self.teamInfo.charMain.Level
    tabMain.CreateTime = 0
    tabMain.Advance = self.teamInfo.charMain.Advance
    tabMain.TalentNodes = ""
    tabMain.SkillLvs = {[1] = _mainSillLevel,[2] = _mainSillLevel,[3] = _mainSillLevel,[4] = _mainSillLevel,[5] = _mainSillLevel}
    tabMain.Plots = {}
    tabMain.AffinityExp = 0
    tabMain.AffinityLevel = 0
    tabMain.ArchiveRewardIds = {}
    tabMain.TalentBackground = 5
    tabMain.tmpTalentLevel = self.teamInfo.charMain.talentLv
    tabMain.CharGemPresets = {
        InUsePresetIndex = 0,
        CharGemPresets = {},
    }
    tabMain.CharGemSlots = {}
    table.insert(tmpTabChar,tabMain)

    self.tmpMainPlayerHP = self.teamInfo.charMain.hpPre

    local tabSub1 = {}
    local _sub1SillLevel = self.teamInfo.charSub1.SkillLv
    tabSub1.Tid = self.tbCharId[2]
    tabSub1.Exp = 0
    tabSub1.DatingEventIds = {}
    tabSub1.DatingEventRewardIds = {}
    tabSub1.Favor = nil
    tabSub1.Skin = self.tbCharId[2] * 100 + 1
    tabSub1.EquipmentIds = {[1] = 0,[2] = 0,[3] = 0}
    tabSub1.Level = self.teamInfo.charSub1.Level
    tabSub1.CreateTime = 0
    tabSub1.Advance = self.teamInfo.charSub1.Advance
    tabSub1.TalentNodes = ""
    tabSub1.SkillLvs = {[1] = _sub1SillLevel,[2] = _sub1SillLevel,[3] = _sub1SillLevel,[4] = _sub1SillLevel,[5] = _sub1SillLevel}
    tabSub1.Plots = {}
    tabSub1.AffinityExp = 0
    tabSub1.AffinityLevel = 0
    tabSub1.ArchiveRewardIds = {}
    tabSub1.TalentBackground = 5
    tabSub1.tmpTalentLevel = self.teamInfo.charSub1.talentLv
    tabSub1.CharGemPresets = {
        InUsePresetIndex = 0,
        CharGemPresets = {},
    }
    tabSub1.CharGemSlots = {}
    table.insert(tmpTabChar,tabSub1)

    local tabSub2 = {}
    local _sub2SillLevel = self.teamInfo.charSub2.SkillLv
    tabSub2.Tid = self.tbCharId[3]
    tabSub2.Exp = 0
    tabSub2.DatingEventIds = {}
    tabSub2.DatingEventRewardIds = {}
    tabSub2.Favor = nil
    tabSub2.Skin = self.tbCharId[3] * 100 + 1
    tabSub2.EquipmentIds = {[1] = 0,[2] = 0,[3] = 0}
    tabSub2.Level = self.teamInfo.charSub2.Level
    tabSub2.CreateTime = 0
    tabSub2.Advance = self.teamInfo.charSub2.Advance
    tabSub2.TalentNodes = ""
    tabSub2.SkillLvs = {[1] = _sub2SillLevel,[2] = _sub2SillLevel,[3] = _sub2SillLevel,[4] = _sub2SillLevel,[5] = _sub2SillLevel}
    tabSub2.Plots = {}
    tabSub2.AffinityExp = 0
    tabSub2.AffinityLevel = 0
    tabSub2.ArchiveRewardIds = {}
    tabSub2.TalentBackground = 5
    tabSub2.tmpTalentLevel = self.teamInfo.charSub2.talentLv
    tabSub2.CharGemPresets = {
        InUsePresetIndex = 0,
        CharGemPresets = {},
    }
    tabSub2.CharGemSlots = {}
    table.insert(tmpTabChar,tabSub2)

    PlayerData.Char:CacheCharacters(tmpTabChar)
    self:CacheTalentData(tmpTabChar,0)
    self:CreatePotentialsData(self.teamInfo)

end

--构建天赋数据
function AutoBattleBalanceEditor:CacheTalentData(mapMsgData, nTalentResetTime)
    if PlayerData.Talent._tbCharTalentNode == nil then
        PlayerData.Talent._tbCharTalentNode = {}
    end
    if PlayerData.Talent._tbCharTalentGroup == nil then
        PlayerData.Talent._tbCharTalentGroup = {}
    end
    for _, mapCharInfo in ipairs(mapMsgData) do
        local nCharId = mapCharInfo.Tid
        local tbTalent = CacheTable.GetData("_TalentByIndex", nCharId)
        if tbTalent == nil then
            printError("Talent表找不到该角色" .. nCharId)
            tbTalent = {}
        end
        local tbActive = {}
        local tmpGroup = nCharId * 100 + mapCharInfo.tmpTalentLevel
        for nIndex, v in pairs(tbTalent) do
            if v.GroupId <= tmpGroup then
                table.insert(tbActive, v.Id)
            end
        end
        local talentData, groupData = PlayerData.Talent:CreateNewTalentData(nCharId, tbActive)
        PlayerData.Talent._tbCharTalentNode[nCharId] = talentData
        PlayerData.Talent._tbCharTalentGroup[nCharId] = groupData
        PlayerData.Talent._tbCharEnhancedSkill[nCharId] = PlayerData.Talent:CreateEnhancedSkill(nCharId, tbActive)
        PlayerData.Talent._tbCharEnhancedPotential[nCharId] = PlayerData.Talent:CreateEnhancedPotential(tbActive)
        PlayerData.Talent._tbCharFateTalent[nCharId] = PlayerData.Talent:CreateFateTalent(tbTalent)
        PlayerData.Talent._tbTalentBgIndex[nCharId] = mapCharInfo.TalentBackground
        PlayerData.Talent:UpdateTalentGroupLock(nCharId)
    end
end

--构建潜能信息
function AutoBattleBalanceEditor:CreatePotentialsData(tmp)
    self.tbPotentials = {}

    if not self.isConfigTeam then
        --主控角色潜能
        local _mainId = self.tbCharId[1]
        if nil == self.tbPotentials[_mainId] then
            self.tbPotentials[_mainId] = {}
        end
        for i, v in pairs(tmp["charMain"].mainPotential) do
            table.insert(self.tbPotentials[_mainId], { nPotentialId = v, nLevel = 1 })
        end

        for i = 5, 13 do
            local tmpId = 500000 + _mainId * 100 + i;
            table.insert(self.tbPotentials[_mainId], { nPotentialId = tmpId, nLevel = self.tmpPotentialLevel })
        end
        table.insert(self.tbPotentials[_mainId], { nPotentialId = 500000 + _mainId * 100 + 41, nLevel = self.tmpPotentialLevel })
        table.insert(self.tbPotentials[_mainId], { nPotentialId = 500000 + _mainId * 100 + 42, nLevel = self.tmpPotentialLevel })
        table.insert(self.tbPotentials[_mainId], { nPotentialId = 500000 + _mainId * 100 + 43, nLevel = self.tmpPotentialLevel })

        --支援角色1潜能
        local _subId_1 = self.tbCharId[2]
        if nil == self.tbPotentials[_subId_1] then
            self.tbPotentials[_subId_1] = {}
        end
        for i, v in pairs(tmp["charSub1"].mainPotential) do
            table.insert(self.tbPotentials[_subId_1], { nPotentialId = v, nLevel = 1 })
        end

        for i = 25, 33 do
            local tmpId = 500000 + _subId_1 * 100 + i;
            table.insert(self.tbPotentials[_subId_1], { nPotentialId = tmpId, nLevel = self.tmpPotentialLevel })
        end
        table.insert(self.tbPotentials[_subId_1], { nPotentialId = 500000 + _subId_1 * 100 + 41, nLevel = self.tmpPotentialLevel })
        table.insert(self.tbPotentials[_subId_1], { nPotentialId = 500000 + _subId_1 * 100 + 42, nLevel = self.tmpPotentialLevel })
        table.insert(self.tbPotentials[_subId_1], { nPotentialId = 500000 + _subId_1 * 100 + 43, nLevel = self.tmpPotentialLevel })

        --支援角色2潜能
        local _subId_2 = self.tbCharId[3]
        if nil == self.tbPotentials[_subId_2] then
            self.tbPotentials[_subId_2] = {}
        end
        for i, v in pairs(tmp["charSub2"].mainPotential) do
            table.insert(self.tbPotentials[_subId_2], { nPotentialId = v, nLevel = 1 })
        end

        for i = 25, 33 do
            local tmpId = 500000 + _subId_2 * 100 + i;
            table.insert(self.tbPotentials[_subId_2], { nPotentialId = tmpId, nLevel = self.tmpPotentialLevel })
        end
        table.insert(self.tbPotentials[_subId_2], { nPotentialId = 500000 + _subId_2 * 100 + 41, nLevel = self.tmpPotentialLevel })
        table.insert(self.tbPotentials[_subId_2], { nPotentialId = 500000 + _subId_2 * 100 + 42, nLevel = self.tmpPotentialLevel })
        table.insert(self.tbPotentials[_subId_2], { nPotentialId = 500000 + _subId_2 * 100 + 43, nLevel = self.tmpPotentialLevel })
    else
        for i = 1, 3 do
            local tmpCharId = self.tbCharId[i]
            self.tbPotentials[tmpCharId] = {}

            if i == 1 then
                for j = 0, tmp.charMain.mainPotential.Count - 1 do
                    table.insert(self.tbPotentials[tmpCharId], { nPotentialId = tmp.charMain.mainPotential[j], nLevel = tmp.charMain.mainPotentialLv})
                end
                for j = 0, tmp.charMain.subPotential.Count - 1 do
                    table.insert(self.tbPotentials[tmpCharId], { nPotentialId = tmp.charMain.subPotential[j], nLevel = tmp.charMain.subPotentialLv})
                end
            elseif i == 2 then
                for j = 0, tmp.charSub1.mainPotential.Count - 1 do
                    table.insert(self.tbPotentials[tmpCharId], { nPotentialId = tmp.charSub1.mainPotential[j], nLevel = tmp.charSub1.mainPotentialLv})
                end
                for j = 0, tmp.charSub1.subPotential.Count - 1 do
                    table.insert(self.tbPotentials[tmpCharId], { nPotentialId = tmp.charSub1.subPotential[j], nLevel = tmp.charSub1.subPotentialLv})
                end
            elseif i == 3 then
                for j = 0, tmp.charSub2.mainPotential.Count - 1 do
                    table.insert(self.tbPotentials[tmpCharId], { nPotentialId = tmp.charSub2.mainPotential[j], nLevel = tmp.charSub2.mainPotentialLv})
                end
                for j = 0, tmp.charSub2.subPotential.Count - 1 do
                    table.insert(self.tbPotentials[tmpCharId], { nPotentialId = tmp.charSub2.subPotential[j], nLevel = tmp.charSub2.subPotentialLv})
                end
            end
        end
    end
end

function AutoBattleBalanceEditor:CreateDiscNoteData(eet)
    local testTeamData = ConfigTable.GetData("TestTeamData", eet)

    self.tbNotes = {}
    local tbSubNoteList = decodeJson(testTeamData.SubNoteList)
    for k, v in pairs(tbSubNoteList) do
        local nNoteId = tonumber(k)
        local nNoteCount = tonumber(v)
        self.tbNotes[nNoteId] = nNoteCount
    end

    local discLevel = testTeamData.DiscLevel
    local discPromoteLevel = testTeamData.DiscPromoteLevel
    local discLimitBreakLevel = testTeamData.DiscLimitBreakLevel

    self.tbDisc = {}
    for i, v in pairs(testTeamData.DiscListMaster) do
        local _tmpDiscData = PlayerData.Disc:GenerateLocalDiscData(v,0,discLevel,discPromoteLevel,discLimitBreakLevel)
        PlayerData.Disc._mapDisc[v] = _tmpDiscData
        table.insert(self.tbDisc,v)
    end
    for i, v in pairs(testTeamData.DiscListSub) do
        local _tmpDiscData = PlayerData.Disc:GenerateLocalDiscData(v,0,discLevel,discPromoteLevel,discLimitBreakLevel)
        PlayerData.Disc._mapDisc[v] = _tmpDiscData
        table.insert(self.tbDisc,v)
    end

    self.tbSecondarySkill = {}
    for nIndex, nDiscId in pairs(self.tbDisc) do
        local tbSubSkillGroupId = {}
        local mapDiscCfgData = ConfigTable.GetData("Disc", nDiscId)
        if mapDiscCfgData.SecondarySkillGroupId1 > 0 then
            table.insert(tbSubSkillGroupId, mapDiscCfgData.SecondarySkillGroupId1)
        end
        if mapDiscCfgData.SecondarySkillGroupId2 > 0 then
            table.insert(tbSubSkillGroupId, mapDiscCfgData.SecondarySkillGroupId2)
        end

        for _, nSubSkillGroupId in pairs(tbSubSkillGroupId) do
            local tbGroup = CacheTable.GetData("_SecondarySkill", nSubSkillGroupId)
            if tbGroup then
                local nSubSkillId = tbGroup[1].Id
                local nMaxLayer = #tbGroup
                for i = nMaxLayer, 1, -1 do
                    if tbGroup[i] then
                        local bActive = self:CheckSubSkillActive(self.tbNotes, tbGroup[i])
                        if bActive then
                            nSubSkillId = tbGroup[i].Id
                            table.insert(self.tbSecondarySkill, nSubSkillId)
                            break
                        end
                    end
                end
            end
        end
    end
end

function AutoBattleBalanceEditor:CreateDiscNoteDataConfig()
    self.tbNotes = {}
    for i = 0, self.teamInfo.noteData.Count - 1 do
        local nNoteId = tonumber(self.teamInfo.noteData[i].noteId)
        local nNoteCount = tonumber(self.teamInfo.noteData[i].noteCount)
        self.tbNotes[nNoteId] = nNoteCount
    end

    self.tbDisc = {}
    for i = 0, self.teamInfo.discData.Count - 1 do
        local tmpDiscInfo = self.teamInfo.discData[i]
        local _tmpDiscData = PlayerData.Disc:GenerateLocalDiscData(tmpDiscInfo.Id,0,tmpDiscInfo.Level,tmpDiscInfo.Phase,tmpDiscInfo.Star)
        PlayerData.Disc._mapDisc[tmpDiscInfo.Id] = _tmpDiscData
        table.insert(self.tbDisc,tmpDiscInfo.Id)
    end

    self.tbSecondarySkill = {}
    for nIndex, nDiscId in pairs(self.tbDisc) do
        local tbSubSkillGroupId = {}
        local mapDiscCfgData = ConfigTable.GetData("Disc", nDiscId)
        if mapDiscCfgData.SecondarySkillGroupId1 > 0 then
            table.insert(tbSubSkillGroupId, mapDiscCfgData.SecondarySkillGroupId1)
        end
        if mapDiscCfgData.SecondarySkillGroupId2 > 0 then
            table.insert(tbSubSkillGroupId, mapDiscCfgData.SecondarySkillGroupId2)
        end

        for _, nSubSkillGroupId in pairs(tbSubSkillGroupId) do
            local tbGroup = CacheTable.GetData("_SecondarySkill", nSubSkillGroupId)
            if tbGroup then
                local nSubSkillId = tbGroup[1].Id
                local nMaxLayer = #tbGroup
                for i = nMaxLayer, 1, -1 do
                    if tbGroup[i] then
                        local bActive = self:CheckSubSkillActive(self.tbNotes, tbGroup[i])
                        if bActive then
                            nSubSkillId = tbGroup[i].Id
                            table.insert(self.tbSecondarySkill, nSubSkillId)
                            break
                        end
                    end
                end
            end
        end
    end
end

function AutoBattleBalanceEditor:CheckSubSkillActive(tbNote, mapCfg)
    local tbActiveNote = decodeJson(mapCfg.NeedSubNoteSkills)
    local tbNoteAble = {}
    for k, v in pairs(tbActiveNote) do
        local nNoteId = tonumber(k)
        local nNoteCount = tonumber(v)
        if nNoteId then
            tbNoteAble[nNoteId] = false
            local nHas = tbNote[nNoteId]
            if nHas and nHas >= nNoteCount then
                tbNoteAble[nNoteId] = true
            end
        end
    end
    local bActive = true
    for _, v in pairs(tbNoteAble) do
        if v == false then
            bActive = false
            break
        end
    end
    if bActive and next(tbNoteAble) ~= nil then
        return true
    end
    return false
end

function AutoBattleBalanceEditor:OnEvent_LoadLevelRefresh()
    local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = self:GetBuildAllEft()
    safe_call_cs_func(CS.AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
    self.mapEftData = UTILS.AddBuildEffect(mapAllEft, mapDiscEft, mapNoteEffect)
end

function AutoBattleBalanceEditor:OnEvent_AdventureModuleEnter()
    EventManager.Hit(EventId.OpenPanel, PanelId.Adventure,self.tbCharId)
    self:SetPersonalPerk()
    self:SetDiscInfo()
    for idx, nCharId in ipairs(self.tbCharId) do
        local stActorInfo = self:CalCharFixedEffect(nCharId,idx == 1, self.tbDiscId)
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,stActorInfo)
    end
end

function AutoBattleBalanceEditor:CalCharFixedEffect(nCharId,bMainChar,tbDiscId)
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    PlayerData.Char:CalCharacterAttrBattle(nCharId,stActorInfo,bMainChar,tbDiscId)

    return stActorInfo
end

function AutoBattleBalanceEditor:SetPersonalPerk()
    for nCharId, tbPerk in pairs(self.tbPotentials) do
        local mapAddLevel = PlayerData.Char:GetCharEnhancedPotential(nCharId)
        local tbPerkInfo = {}
        for _, mapPerkInfo in ipairs(tbPerk) do
            local nAddLv = mapAddLevel[mapPerkInfo.nPotentialId] or 0
            local stPerkInfo = CS.Lua2CSharpInfo_TPPerkInfo()
            stPerkInfo.perkId = mapPerkInfo.nPotentialId
            stPerkInfo.nCount = mapPerkInfo.nLevel + nAddLv
            table.insert(tbPerkInfo, stPerkInfo)
        end
        safe_call_cs_func(CS.AdventureModuleHelper.ChangePersonalPerkIds,tbPerkInfo,nCharId)
    end
end

function AutoBattleBalanceEditor:SetDiscInfo()
    local tbDiscInfo = {}
    for k, nDiscId in ipairs(self.tbDisc) do
        if k <= 3 then
            local discInfo = PlayerData.Disc:CalcDiscInfoInBuild(nDiscId, self.tbSecondarySkill)
            table.insert(tbDiscInfo, discInfo)
        end
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetDiscInfo,tbDiscInfo)
end

function AutoBattleBalanceEditor:GetBuildAllEft()

    local mapCharEffect = {}
    local mapTalentAddLevel = {}
    -- 天赋，好感度
    for _, charId in ipairs(self.tbCharId) do
        mapCharEffect[charId] = {}
        mapCharEffect[charId][AllEnum.EffectType.Affinity] = PlayerData.Char:CalcAffinityEffect(charId)
        mapCharEffect[charId][AllEnum.EffectType.Talent] = PlayerData.Char:CalcTalentEffect(charId)
        mapCharEffect[charId][AllEnum.EffectType.Equipment] = PlayerData.Equipment:GetCharEquipmentEffect(charId)
        -- 天赋的潜能附加是实时的，不存在build内（这块预设的还没装备数据，就只取天赋的附加了）
        mapTalentAddLevel[charId] = PlayerData.Talent:GetEnhancedPotential(charId)
    end
    -- 潜能
    for nCharId, tbPerk in pairs(self.tbPotentials) do
        for _, mapPerkInfo in ipairs(tbPerk) do
            local nPotentialId = mapPerkInfo.nPotentialId
            local nPotentialCount = mapPerkInfo.nLevel

            if mapTalentAddLevel[nCharId] ~= nil then
                if mapTalentAddLevel[nCharId][nPotentialId] ~= nil then
                    nPotentialCount = nPotentialCount + mapTalentAddLevel[nCharId][nPotentialId]
                end
            end
            if mapCharEffect[nCharId][AllEnum.EffectType.Potential] == nil then
                mapCharEffect[nCharId][AllEnum.EffectType.Potential] = {}
            end
            local mapPotentialCfgData = ConfigTable.GetData("Potential", nPotentialId)
            if mapPotentialCfgData == nil then
                printError("Potential CfgData Missing:" .. nPotentialId)
            else
                mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId] = { {}, nPotentialCount }
                if mapPotentialCfgData.EffectId1 ~= 0 then
                    table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],
                            mapPotentialCfgData.EffectId1)
                end
                if mapPotentialCfgData.EffectId2 ~= 0 then
                    table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],
                            mapPotentialCfgData.EffectId2)
                end
                if mapPotentialCfgData.EffectId3 ~= 0 then
                    table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],
                            mapPotentialCfgData.EffectId3)
                end
                if mapPotentialCfgData.EffectId4 ~= 0 then
                    table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],
                            mapPotentialCfgData.EffectId4)
                end
            end
        end
    end
    -- 星盘，协奏技能的effect取build内的，主旋律技能的effect按当前养成取最新的
    local mapDiscEffect = {}
    for nIndex, nDiscId in ipairs(self.tbDisc) do
        if nIndex <= 3 then -- 星盘技能有效的只有主位星盘
            local tbDiscEft = PlayerData.Disc:CalcDiscEffectInBuild(nDiscId, self.tbSecondarySkill)
            mapDiscEffect[nDiscId] = tbDiscEft
        end
    end
    -- 音符数据
    local tbNoteInfo, mapNoteEffect = {}, {}
    for i, v in pairs(self.tbNotes) do
        local noteInfo = CS.Lua2CSharpInfo_NoteInfo()
        noteInfo.noteId = i
        noteInfo.noteCount = v
        table.insert(tbNoteInfo, noteInfo)

        local mapCfg = ConfigTable.GetData("SubNoteSkill", i)
        if mapCfg then
            local tbEft = {}
            for _, nEftId in pairs(mapCfg.EffectId) do
                table.insert(tbEft, {nEftId, v})
            end
            mapNoteEffect[i] = tbEft
        end
    end
    return mapCharEffect, mapDiscEffect, mapNoteEffect, tbNoteInfo
end

function AutoBattleBalanceEditor:OnEvent_UnloadComplete()
    --进入新的关卡
    CS.AdventureModuleHelper.EnterAutoBattleClearPlayer()
    self.isNext = true
    self:CreateLevelNeedMsg()
end

function AutoBattleBalanceEditor:OnEvent_LevelStateChanged()

    --printError("AutoBattleYYY 111111111")
    CS.AdventureModuleHelper.LevelStateChanged(false)
end

function AutoBattleBalanceEditor:BindEvent()
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

return AutoBattleBalanceEditor