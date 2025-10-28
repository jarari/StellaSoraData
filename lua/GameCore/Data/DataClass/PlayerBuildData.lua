--PlayerBuildData保存了玩家遗迹的build数据用于攻略世界boss
--角色结构 ：mapChar = {
--               nTid = 角色id,
--               nPotentialCount = int,  //潜能数量
--           }
--星盘技能（祝福）：  mapDiscSkills = {
--                      nId = int,    //技能Id
--                      nLevel = int,     //技能等级
--                   }
--星盘结构 ：mapDisc = {
-- CommonSkills
-- PassiveSkill
--           }
--潜能结构 ：mapPotential = {
--               nPotentialId = 1;  //潜能ID
--               nLevel = 2;  //潜能等级
--           }
--build结构：mapBuild = {
--              nBuildId = int,     //buildUid
--              sName = string ,    //build名字
--              tbChar = mapChar[], //角色结构数组
--              tbDisc = mapDisc,  //星盘数据
--              nScore = int,       //build评分
--              bLock  = bool,      //是否锁定
--              bDetail = bool,     //是否以获取详细信息
--              bPreference = bool, //是否偏好
--              tbPotentials = mapPotential[],       //潜能信息
--           }

local LocalData = require "GameCore.Data.LocalData"
local ConfigData = require "GameCore.Data.ConfigData"
local PlayerBuildData = class("PlayerBuildData")
local newDayTime = UTILS.GetDayRefreshTimeOffset()
function PlayerBuildData:Init()
    self._MapBuildData = {}
    self.hasData = false
    self:InitBuildRank()
end

function PlayerBuildData:InitBuildRank()
    self._tbBuildRank = {}
    local function foreach(line)
        self._tbBuildRank[line.Id] = line
    end
    ForEachTableLine(DataTable.StarTowerBuildRank, foreach)
    self._nBuildRankCount = #self._tbBuildRank
end

function PlayerBuildData:GetBuildRank()
    return self._tbBuildRank
end

function PlayerBuildData:CreateBuildBriefData(mapBuildBriefMsg)
    if nil ~= self._MapBuildData[mapBuildBriefMsg.Id] then
        printLog(string.format("编队信息重复！！！id= [%s]", mapBuildBriefMsg.Id))
    end
    local mapBuildData = {
        nBuildId       = mapBuildBriefMsg.Id,
        sName          = mapBuildBriefMsg.Name,
        tbChar         = {},
        nScore         = mapBuildBriefMsg.Score,
        mapRank        = self:CalBuildRank(mapBuildBriefMsg.Score),
        bLock          = mapBuildBriefMsg.Lock,
        bPreference    = mapBuildBriefMsg.Preference,
        bDetail        = false,
        tbDisc         = {},  -- 星盘星盘编队内容，从主位1号到副位3号，顺序排列6个，没装备的就是id0
        tbSecondarySkill    = {},  -- 协奏技能
        tbPotentials   = {},  -- 潜能信息
        tbNotes        = {},  -- 音符
        nTowerId       = mapBuildBriefMsg.StarTowerId,
    }

    for i = 1, 3 do
        table.insert(mapBuildData.tbChar, {
            nTid = mapBuildBriefMsg.Chars[i].CharId, nPotentialCount = mapBuildBriefMsg.Chars[i].PotentialCnt -- 潜能数量
        })
    end
    mapBuildData.tbDisc = mapBuildBriefMsg.DiscIds
    self._MapBuildData[mapBuildBriefMsg.Id] = mapBuildData
end

function PlayerBuildData:CreateBuildDetailData(nBuildId, mapBuildDetailMsg)
    if nil == mapBuildDetailMsg or nil == next(mapBuildDetailMsg) then
        return
    end

    if nil == self._MapBuildData[nBuildId] then
        printLog(string.format("找不到编队信息！！！id= [%s]", nBuildId))
        return
    end

    self._MapBuildData[nBuildId].tbSecondarySkill = mapBuildDetailMsg.ActiveSecondaryIds

    for _, v in ipairs(mapBuildDetailMsg.Potentials) do
        local potentialCfg = ConfigTable.GetData("Potential", v.PotentialId)
        if potentialCfg then
            local nCharId = potentialCfg.CharId
            if nil == self._MapBuildData[nBuildId].tbPotentials[nCharId] then
                self._MapBuildData[nBuildId].tbPotentials[nCharId] = {}
            end
            table.insert(self._MapBuildData[nBuildId].tbPotentials[nCharId], { nPotentialId = v.PotentialId, nLevel = v.Level })
        end
    end
    local tbNotes = {}
    for _, v in pairs(mapBuildDetailMsg.SubNoteSkills) do
        tbNotes[v.Tid] = v.Qty
    end
    self._MapBuildData[nBuildId].tbNotes = tbNotes
    self._MapBuildData[nBuildId].bDetail = true
end

function PlayerBuildData:GetAllBuildBriefData(callback)
    if not self.hasData then
        self:NetMsg_GetBuildBriefData(self.GetBuildBriefDataCallback, callback)
        return false
    end
    self:GetBuildBriefDataCallback(callback)
    return true
end

function PlayerBuildData:GetBuildCount(callback)
    if not self.hasData then
        self:NetMsg_GetBuildBriefData(self.GetBuildCountCallBack, callback)
        return false
    end
    self:GetBuildCountCallBack(callback)
    return true
end

function PlayerBuildData:GetBuildDetailData(callback, nBuildId)
    if self._MapBuildData[nBuildId] == nil then
        if self.hasData then
            printWarn("没有该id的build，大概率已被分解：" .. nBuildId)
            if callback then
                callback()
            end
            return false
        end
        local function callBack()
            self:GetBuildDetailData(callback, nBuildId)
        end
        self:NetMsg_GetBuildBriefData(self.GetBuildBriefDataCallback, callBack)
        return false
    end
    if not self._MapBuildData[nBuildId].bDetail then
        self:NetMsg_GetBuildDetailData(nBuildId, self.GetBuildDetailDataCallback, callback, nBuildId)
        return false
    end
    self:GetBuildDetailDataCallback(callback, nBuildId)
    return true
end

function PlayerBuildData:ChangeBuildName(nBuildId, sName, callback)
    self:NetMsg_ChangeBuildName(nBuildId, sName, callback)
end

function PlayerBuildData:ChangeBuildLock(nBuildId, bLock, callback)
    self:NetMsg_ChangeBuildLock(nBuildId, bLock, callback)
end

function PlayerBuildData:DeleteBuild(tbBuildId, callback, cbClose)
    self:NetMsg_BuildDelete(tbBuildId, callback, cbClose)
end

function PlayerBuildData:SetBuildPreference(tbCheckInIds, tbCheckOutIds, callback)
    self:NetMsg_BuildPreference(tbCheckInIds, tbCheckOutIds, callback)
end

function PlayerBuildData:SaveBuild(nBuildID, bDelete, bLock, bPreference, sName, callback)
    self:NetMsg_SaveBuild(nBuildID, bDelete, bLock, bPreference, sName, callback)
end

function PlayerBuildData:CheckHasBuild()
    return next(self._MapBuildData) ~= nil 
end

function PlayerBuildData:GetBuildAllEft(nBuildId)
    local ret = {}
    local mapBuildData = self._MapBuildData[nBuildId]
    if mapBuildData == nil or not mapBuildData.bDetail then
        print("没有对应build 或未获取该build详细数据")
        return ret
    end
    local mapCharEffect = {}
    local mapPotentialAddLevel = {}
    -- 天赋，好感度
    for _, mapChar in ipairs(mapBuildData.tbChar) do
        mapCharEffect[mapChar.nTid] = {}
        mapCharEffect[mapChar.nTid][AllEnum.EffectType.Affinity] = PlayerData.Char:CalcAffinityEffect(mapChar.nTid)
        mapCharEffect[mapChar.nTid][AllEnum.EffectType.Talent] = PlayerData.Char:CalcTalentEffect(mapChar.nTid)
        mapCharEffect[mapChar.nTid][AllEnum.EffectType.Equipment] = PlayerData.Equipment:GetCharEquipmentEffect(mapChar.nTid)
        -- 潜能附加是实时的，不存在build内
        mapPotentialAddLevel[mapChar.nTid] = PlayerData.Char:GetCharEnhancedPotential(mapChar.nTid)
    end
    -- 潜能
    for nCharId, tbPerk in pairs(mapBuildData.tbPotentials) do
        for _, mapPerkInfo in ipairs(tbPerk) do
            local nPotentialId = mapPerkInfo.nPotentialId
            local nPotentialCount = mapPerkInfo.nLevel

            if mapPotentialAddLevel[nCharId] ~= nil then
                if mapPotentialAddLevel[nCharId][nPotentialId] ~= nil then
                    nPotentialCount = nPotentialCount + mapPotentialAddLevel[nCharId][nPotentialId]
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
    for nIndex, nDiscId in ipairs(mapBuildData.tbDisc) do
        if nIndex <= 3 then -- 星盘技能有效的只有主位星盘
            local tbDiscEft = PlayerData.Disc:CalcDiscEffectInBuild(nDiscId, mapBuildData.tbSecondarySkill)
            mapDiscEffect[nDiscId] = tbDiscEft
        end
    end
    -- 音符数据
    local tbNoteInfo, mapNoteEffect = {}, {}
    for i, v in pairs(mapBuildData.tbNotes) do
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

function PlayerBuildData:GetBuildAttrBase(nBuildId, bTrial)
    local ret = {}
    local mapBuildData = bTrial and self:GetTrialBuild(nBuildId) or self._MapBuildData[nBuildId]
    if mapBuildData == nil or not mapBuildData.bDetail then
        print("没有对应build 或未获取该build详细数据")
        return ret
    end

    local tbAttrList = {}
    for _, v in ipairs(AllEnum.AttachAttr) do
        tbAttrList[v.sKey] = {
            Key = v.sKey,
            Value = 0,
            CfgValue = 0
        }
    end
    local mapRank = mapBuildData.mapRank
    local nAttrId = UTILS.GetBuildAttributeId(mapRank.AttrBaseGroupId, mapRank.Level)
    if nAttrId > 0 then
        local mapAttribute = ConfigTable.GetData_Attribute(tostring(nAttrId))
        if mapAttribute then
            for _, v in ipairs(AllEnum.AttachAttr) do
                local nParamValue = mapAttribute[v.sKey] or 0
                local nValue = v.bPercent and nParamValue * ConfigData.IntFloatPrecision * 100 or nParamValue
                tbAttrList[v.sKey] = {
                    Key = v.sKey,
                    Value = nValue,
                    CfgValue = nParamValue
                }
            end
        end
    end

    return tbAttrList
end

function PlayerBuildData:CalBuildRank(nScore)
    local nMin = 1
    local nMax = self._nBuildRankCount
    local mapRank = self._tbBuildRank[1]
    while nMin <= nMax do
        local nMiddle = math.floor((nMin + nMax) / 2)
        if nMiddle == self._nBuildRankCount or (nScore >= self._tbBuildRank[nMiddle].MinGrade and nScore < self._tbBuildRank[nMiddle + 1].MinGrade) then
            mapRank = self._tbBuildRank[nMiddle]
            break
        elseif nScore < self._tbBuildRank[nMiddle].MinGrade then
            nMax = nMiddle - 1
        else
            nMin = nMiddle + 1
        end
    end
    return mapRank
end

function PlayerBuildData:CheckCoinMax(nCoin,confirmDelete)
    local nLimit = PlayerData.StarTower:GetStarTowerRewardLimit()
    local nCur = PlayerData.StarTower:GetStarTowerTicket()
    local function confirm()
        if confirmDelete ~= nil and type(confirmDelete) == "function" then
            confirmDelete()
        end
    end


    if nCoin + nCur > nLimit then
        local TipsTime = LocalData.GetPlayerLocalData("Build_Tips_Time")
        local _tipDay = 0
        if TipsTime ~= nil then
            _tipDay = tonumber(TipsTime)
        end
        local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
        local fixedTimeStamp = curTimeStamp + newDayTime * 3600
        local nYear = tonumber(os.date("!%Y", fixedTimeStamp))
        local nMonth = tonumber(os.date("!%m", fixedTimeStamp))
        local nDay = tonumber(os.date("!%d", fixedTimeStamp))
        local nowD = nYear * 366 + nMonth * 31 + nDay
        if nowD == _tipDay then
            confirm()
        else
            local isSelectAgain = false
            local function confirmCallback()
                if isSelectAgain then
                    local _curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
                    local _fixedTimeStamp = _curTimeStamp + newDayTime * 3600
                    local _nYear = tonumber(os.date("!%Y", _fixedTimeStamp))
                    local _nMonth = tonumber(os.date("!%m", _fixedTimeStamp))
                    local _nDay = tonumber(os.date("!%d", _fixedTimeStamp))
                    local _nowD = _nYear * 366 + _nMonth * 31 + _nDay
                    LocalData.SetPlayerLocalData("Build_Tips_Time",tostring(_nowD))
                end
                confirm()
            end
            local function againCallback(isSelect)
                isSelectAgain = isSelect
            end
            local msg = {
                nType = AllEnum.MessageBox.Confirm,
                sContent = ConfigTable.GetUIText("BUILD_11"),
                callbackConfirm = confirmCallback,
                callbackAgain = againCallback,
                bBlur = false
            }
            EventManager.Hit(EventId.OpenMessageBox, msg)
        end
    else
        confirm()
    end

end
--遗迹结算时如果有数据调用该方法保存build数据
function PlayerBuildData:CacheRogueBuild(mapBuildInfo)
    self:CreateBuildBriefData(mapBuildInfo.Brief)
    self:CreateBuildDetailData(mapBuildInfo.Brief.Id, mapBuildInfo.Detail)
end

--CallBack
function PlayerBuildData:GetBuildBriefDataCallback(callBack)
    local ret = {}
    for _, mapBuild in pairs(self._MapBuildData) do
        table.insert(ret, mapBuild)
    end
    callBack(ret, self._MapBuildData)
end

function PlayerBuildData:GetBuildDetailDataCallback(callBack, nBuildId)
    callBack(self._MapBuildData[nBuildId])
end

function PlayerBuildData:GetBuildCountCallBack(callBack)
    local ret = 0
    for _, _ in pairs(self._MapBuildData) do
        ret = ret + 1
    end
    callBack(ret)
end

--通信
function PlayerBuildData:NetMsg_GetBuildBriefData(func, ...)
    local arg = { ... }
    local function MsgCallBack(_, msgData)
        self.hasData = true
        for _, mapBuild in ipairs(msgData.Briefs) do
            self:CreateBuildBriefData(mapBuild)
        end
        func(self, table.unpack(arg))
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_build_brief_list_get_req, {}, nil, MsgCallBack)
end

function PlayerBuildData:NetMsg_GetBuildDetailData(nBuildId, func, ...)
    local arg = { ... }
    local function MsgCallBack(_, msgData)
        self._MapBuildData[nBuildId].tbSecondarySkill = msgData.Detail.ActiveSecondaryIds
        for _, v in ipairs(msgData.Detail.Potentials) do
            local potentialCfg = ConfigTable.GetData("Potential", v.PotentialId)
            if potentialCfg then
                local nCharId = potentialCfg.CharId
                if nil == self._MapBuildData[nBuildId].tbPotentials[nCharId] then
                    self._MapBuildData[nBuildId].tbPotentials[nCharId] = {}
                end
                table.insert(self._MapBuildData[nBuildId].tbPotentials[nCharId],
                    { nPotentialId = v.PotentialId, nLevel = v.Level })
            end
        end

        local tbNotes = {}
        for _, v in pairs(msgData.Detail.SubNoteSkills) do
            tbNotes[v.Tid] = v.Qty
        end
        self._MapBuildData[nBuildId].tbNotes = tbNotes
        self._MapBuildData[nBuildId].bDetail = true
        func(self, table.unpack(arg))
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_build_detail_get_req, { BuildId = nBuildId }, nil, MsgCallBack)
end

function PlayerBuildData:NetMsg_ChangeBuildName(nBuildId, sName, callback)
    local msg = {
        BuildId = nBuildId,
        Name = sName
    }
    local function callBack()
        self._MapBuildData[nBuildId].sName = sName
        if callback ~= nil then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_build_name_set_req, msg, nil, callBack)
end

function PlayerBuildData:NetMsg_ChangeBuildLock(nBuildId, bLock, callback)
    local msg = {
        BuildId = nBuildId,
        Lock = bLock
    }
    local function callBack()
        self._MapBuildData[nBuildId].bLock = bLock
        if callback ~= nil then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_build_lock_unlock_req, msg, nil, callBack)
end

function PlayerBuildData:NetMsg_BuildDelete(tbBuildId, callback, cbClose)
    local msg = {
        BuildIds = tbBuildId
    }
    local function callBack(_, mapMainData)
        for _, bBuildId in ipairs(tbBuildId) do
            self._MapBuildData[bBuildId] = nil
        end
        UTILS.OpenReceiveByChangeInfo(mapMainData.Change, cbClose)
        if callback ~= nil then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_build_delete_req, msg, nil, callBack)
end

function PlayerBuildData:NetMsg_BuildPreference(tbCheckInIds, tbCheckOutIds, callback)
    local msg = {
        CheckInIds = tbCheckInIds,
        CheckOutIds = tbCheckOutIds
    }
    local function callBack()
        for _, bBuildId in ipairs(tbCheckInIds) do
            self._MapBuildData[bBuildId].bPreference = true
        end
        for _, bBuildId in ipairs(tbCheckOutIds) do
            self._MapBuildData[bBuildId].bPreference = false
        end
        if callback ~= nil then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_build_preference_set_req, msg, nil, callBack)
end

function PlayerBuildData:NetMsg_SaveBuild(nBuildID, bDelete, bLock, bPreference, sName, callback)
    local msg = {}
    msg.Delete = bDelete
    msg.Lock = bLock
    msg.Preference = bPreference
    msg.BuildName = sName
    local function callBack(_, mapMainData)
        if callback ~= nil then
            if bDelete then
                self._MapBuildData[nBuildID] = nil
            else
                self._MapBuildData[nBuildID].bLock = bLock
                self._MapBuildData[nBuildID].bPreference = bPreference
                self._MapBuildData[nBuildID].sName = sName
            end
            callback(mapMainData.Change)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_build_whether_save_req, msg, nil, callBack)
end

------------------------------ Trial -----------------------------
function PlayerBuildData:CreateTrialBuild(nTrialId)
    self._mapTrialBuild = {}
    local mapTrialData = ConfigTable.GetData("TrialBuild", nTrialId)
    if mapTrialData == nil then
        printError("试用编组数据没有找到：" .. nTrialId)
        return
    end

    self._mapTrialBuild = {
        nBuildId       = nTrialId,
        sName          = mapTrialData.Name,
        tbChar         = {},
        nScore         = mapTrialData.Score,
        mapRank        = self:CalBuildRank(mapTrialData.Score),
        bLock          = false,
        bPreference    = false,
        bDetail        = true,
        tbDisc         = {},  -- 星盘星盘编队内容，从主位1号到副位3号，顺序排列6个，没装备的就是id0
        tbSecondarySkill    = {},  -- 协奏技能
        tbPotentials   = {},  -- 潜能信息
        tbNotes        = {},  -- 音符
        nTowerId       = 0,
    }

    local tbCharTrialId = {}
    for _, v in ipairs(mapTrialData.Char) do
        table.insert(self._mapTrialBuild.tbChar, { nTrialId = v, nTid = 0, nPotentialCount = 0 })
        table.insert(tbCharTrialId, v)
    end

    self._mapTrialBuild.tbDisc = mapTrialData.Disc
    self._mapTrialBuild.tbSecondarySkill = mapTrialData.ActiveSecondaryIds

    local tbPotentials = decodeJson(mapTrialData.Potential)
    for _, v in pairs(tbPotentials) do
        local potentialCfg = ConfigTable.GetData("Potential", v.Tid)
        if potentialCfg then
            local nCharId = potentialCfg.CharId
            if not self._mapTrialBuild.tbPotentials[nCharId] then
                self._mapTrialBuild.tbPotentials[nCharId] = {}
            end
            table.insert(self._mapTrialBuild.tbPotentials[nCharId], { nPotentialId = v.Tid, nLevel = v.Level })
        end
    end

    local tbNoteJson = decodeJson(mapTrialData.Note)
    local tbNotes = {}
    for _, v in pairs(tbNoteJson) do
        tbNotes[v.Id] = v.Qty
    end
    self._mapTrialBuild.tbNotes = tbNotes


    PlayerData.Char:CreateTrialChar(tbCharTrialId)
    PlayerData.Disc:CreateTrialDisc(mapTrialData.Disc)

    for k, v in pairs(self._mapTrialBuild.tbChar) do
        local mapTrialChar = PlayerData.Char:GetTrialCharById(v.nTrialId)
        self._mapTrialBuild.tbChar[k].nTid = mapTrialChar ~= nil and mapTrialChar.nId or 0
    end

    return self._mapTrialBuild
end

function PlayerBuildData:DeleteTrialBuild()
    self._mapTrialBuild = {}
    PlayerData.Char:DeleteTrialChar()
    PlayerData.Disc:DeleteTrialDisc()
end

function PlayerBuildData:GetTrialBuild(nTrialId)
    if self._mapTrialBuild then
        if self._mapTrialBuild.nBuildId == nTrialId then
            return self._mapTrialBuild
        else
            self:DeleteTrialBuild()
        end
    end
    return self:CreateTrialBuild(nTrialId)
end

function PlayerBuildData:GetTrialBuildAllEft()
    local ret = {}
    local mapBuildData = self._mapTrialBuild
    if mapBuildData == nil or not mapBuildData.bDetail then
        print("没有对应build 或未获取该build详细数据")
        return ret
    end
    local mapCharEffect = {}
    local mapTalentAddLevel = {}
    -- 天赋
    for _, mapChar in ipairs(mapBuildData.tbChar) do
        mapCharEffect[mapChar.nTid] = {}
        mapCharEffect[mapChar.nTid][AllEnum.EffectType.Talent] = PlayerData.Talent:GetTrialTalentEffect(mapChar.nTrialId)
        -- 天赋的潜能附加是实时的，不存在build内，体验build没装备
        mapTalentAddLevel[mapChar.nTid] = PlayerData.Talent:GetTrialEnhancedPotential(mapChar.nTrialId)
    end
    -- 潜能
    local tbCharIdToTrial = {}
    for _, mapChar in ipairs(mapBuildData.tbChar) do
        tbCharIdToTrial[mapChar.nTid] = mapChar.nTrialId
    end
    for nCharId, tbPerk in pairs(mapBuildData.tbPotentials) do
        if tbCharIdToTrial[nCharId] then
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
        else
            printError("体验build内，有多余角色的潜能" .. nCharId)
        end
    end
    -- 星盘，协奏技能的effect取build内的，主旋律技能的effect按当前养成取最新的
    local mapDiscEffect = {}
    for nIndex, nTrialDiscId in ipairs(mapBuildData.tbDisc) do
        if nIndex <= 3 then -- 星盘技能有效的只有主位星盘
            local tbDiscEft = PlayerData.Disc:CalcTrialEffectInBuild(nTrialDiscId, mapBuildData.tbSecondarySkill)
            mapDiscEffect[nTrialDiscId] = tbDiscEft
        end
    end
    -- 音符数据
    local tbNoteInfo, mapNoteEffect = {}, {}
    for i, v in pairs(mapBuildData.tbNotes) do
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

return PlayerBuildData
