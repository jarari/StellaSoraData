local AvgData = class("AvgData")
local RapidJson = require "rapidjson"
local LocalData = require "GameCore.Data.LocalData"
local TimerManager = require "GameCore.Timer.TimerManager"
local File = CS.System.IO.File
function AvgData:Init()
    -- 配表数据：预处理
    self.CFG_ChapterStoryNumIds = {} -- key:chapter id(num), value:table story num ids
    self.CFG_Story = {} -- key:string id, value:int id
    self.CFG_StoryCondition = {} -- key:string id, value:int id
    self.CFG_StoryEvidence = {} -- key:string id, value:int id
    self.CFG_ConditionStoryNumIds = {} -- key:string condition id, value:table story num ids
    local forEachLine_Story = function(mapLineData)
        self.CFG_Story[mapLineData.StoryId] = mapLineData.Id
        if self.CFG_ChapterStoryNumIds[mapLineData.Chapter] == nil then
            self.CFG_ChapterStoryNumIds[mapLineData.Chapter] = {}
        end
        if mapLineData.ConditionId ~= "" then
            if self.CFG_ConditionStoryNumIds[mapLineData.ConditionId] == nil then
                self.CFG_ConditionStoryNumIds[mapLineData.ConditionId] = {}
            end
            table.insert(self.CFG_ConditionStoryNumIds[mapLineData.ConditionId], mapLineData.Id)
        end
        table.insert(self.CFG_ChapterStoryNumIds[mapLineData.Chapter], mapLineData.Id)
    end
    local forEachLine_StoryCondition = function(mapLineData) self.CFG_StoryCondition[mapLineData.ConditionId] = mapLineData.Id end
    local forEachLine_StoryEvidence = function(mapLineData) self.CFG_StoryEvidence[mapLineData.EvId] = mapLineData.Id end
    ForEachTableLine(DataTable.Story, forEachLine_Story)
    ForEachTableLine(DataTable.StoryCondition, forEachLine_StoryCondition)
    ForEachTableLine(DataTable.StoryEvidence, forEachLine_StoryEvidence)
    -- 记库数据：已通关关卡
    self.tbStoryIds = {} -- Story 表的 string Id，已通关关卡Id数组，没有三星通关概念，仅记录已通关的（有些关卡是战斗关卡，大多数是纯AVG演出关卡）。
    self.tbTempStoryIds = {} -- Story 表的 string Id，在 AVG 演出全部播完时，才与服务器通信，临时记录所有当前演出过程中，播过的关卡。
    -- 记库数据：已获得证据
    self.tbEvIds = {} -- StoryEvidence 表的 string Id，记录玩家在 AVG 演出中遇到重要选项时做出选择后，对应获得的证据。
    self.tbTempEvIds = {} -- StoryEvidence 表的 string Id，在 AVG 演出全部播完时，才与服务器通信，临时记录所有当前演出过程中，产出的证据。
    -- 记库数据：已选过的路线选项数据（记录最后一次所选、所有选过的）
    self.mapChosen = {} -- 所有选过的 {[sAvgId] = {[nGroupId] = n, [nGroupId] = n, ...}, [sAvgId] = {[nGroupId] = n, [nGroupId] = n, ...}, ...}  n 是 self.__data 表的 key 值。
    self.mapTempCL = {} -- 本局所选过的所有记录，最后一次记录移至数组末尾
        -- self.mapTempChosen = {}
    self.mapLatest = {} -- 最后一次选的 与 所有选过的 结构一样，合法值是 0 1 2 4 其中之一，在 IfTrue 指令中会用于条件判断。
        -- self.mapTempLatest = {}
    self.mapTempLatestCnt = {} -- 临时记录本次演出时，某avg id中的某个路径选项组里各选项分别选过几次。
    -- 记库数据：已选过的性格选项数据（只记最后一次所选的及用于计算性格三维的系数）
    self.mapPersonality = {} -- 最后一次选的 {[sAvgId] = {[nGroupId] = n, [nGroupId] = n, ...}, [sAvgId] = {[nGroupId] = n, [nGroupId] = n, ...}, ...} n 是 0 1 2 4 其中之一。
    self.mapPersonalityFactor = {} -- 性格三维系数 数据。
    self.mapTempPersonality = {} -- 结构与合法取值 同 最后一次选的 完全一致，在通关结算时，以 覆盖+新增 的方式合并入 最后一次选的 数据中。
    self.mapTempPersonalityFactor = {} -- 结构与合法取值 同 性格三维系数 完全一致，在通关结算时，以 覆盖+新增 的方式合并入 性格三维系数 数据中。
    self.mapTempPersonalityCnt = {} -- 临时记录本次演出时，某avg id中的某个性格选项组里各选项分别选过几次。
    local y, n = true, false
    self.__data = {
        --     A    B    C   -- 从左往右ABC是选项在UI上显示的顺序，实际数值上的描述是从右往左即CBA，详见每项具体描述。
        [0] = {n,   n,   n}, -- 0b 0000 一个都没选过
        [1] = {y,   n,   n}, -- 0b 0001 选过A
        [2] = {n,   y,   n}, -- 0b 0010 选过B
        [3] = {y,   y,   n}, -- 0b 0011 选过AB
        [4] = {n,   n,   y}, -- 0b 0100 选过C
        [5] = {y,   n,   y}, -- 0b 0101 选过AC
        [6] = {n,   y,   y}, -- 0b 0110 选过BC
        [7] = {y,   y,   y}, -- 0b 0111 选过ABC
    }
    self.CURRENT_STORY_ID = 0
    self:CacheEvData()
    EventManager.Add(EventId.UpdateWorldClass, self, self.CheckNewStoryRedDot)

    if AVG_EDITOR == true then
        EventManager.Add("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
    end
end
function AvgData:UnInit()
    EventManager.Remove(EventId.UpdateWorldClass, self, self.CheckNewStoryRedDot)
    if AVG_EDITOR == true then
        EventManager.Remove("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
    end
end
function AvgData:CacheAvgData(StoryInfo)
    self.tbStoryIds = {}
    self.tbTempStoryIds = {}
    self.tbEvIds = {}
    self.tbTempEvIds = {}
    self.mapChosen = {}
        -- self.mapTempChosen = {}
    self.mapLatest = {}
        -- self.mapTempLatest = {}
    self.mapTempLatestCnt = {}
    self.mapPersonality = {}
    self.mapTempPersonality = {}
    self.mapPersonalityFactor = {}
    self.mapTempPersonalityFactor = {}
    self.mapTempPersonalityCnt = {}
    if StoryInfo == nil then return end
    if StoryInfo.BuildId then
        self:SetSelBuildId(StoryInfo.BuildId)
    end
    -- a.所有已获得的证据
    for i, nEvId in ipairs(StoryInfo.Evidences) do
        local cfgData_Evidence = ConfigTable.GetData("StoryEvidence", nEvId)
        if cfgData_Evidence ~= nil then
            local sEvid = cfgData_Evidence.EvId
            if table.indexof(self.tbEvIds, sEvid) <= 0 then
                table.insert(self.tbEvIds, sEvid)
            end
        end
    end
    local func_Parse = function(uint32Value, nType)
        --[[
            四-2  四-1     三-2  三-1    二-2  二-1    一-2  一-1
            int4  int4    int4  int4    int4  int4    int4  int4
            二-1 表示 该选项的倍率系数。
            一-2 表示 三选一的选项，最后一次选择的。
            一-1 表示 三选一的选项，所有曾经选过的。
        ]]
        if nType == 1 then
            return (uint32Value & 15)
        elseif nType == 2 then
            return (uint32Value & 240) >> 4
        elseif nType == 3 then
            return (uint32Value & 3840) >> 8
        else
            return 0
        end
    end
    -- b.所有演出中路径、性格选项玩家做出的选择
    for _, Story in pairs(StoryInfo.Stories) do
        -- b.1 已通关的 id
        local mapCfgDataStory = ConfigTable.GetData_Story(Story.Idx)
        if mapCfgDataStory == nil then
            printError("Stroy Cfg Missing:"..Story.Idx)
        else
            table.insert(self.tbStoryIds, mapCfgDataStory.StoryId)
            -- b.2 路线选项
            local sAvgId = mapCfgDataStory.AvgLuaName
            for __, StoryChoice in pairs(Story.Major) do
                if self.mapChosen[sAvgId] == nil then self.mapChosen[sAvgId] = {} end
                if self.mapLatest[sAvgId] == nil then self.mapLatest[sAvgId] = {} end
                self.mapChosen[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 1)
                self.mapLatest[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 2)
            end
            -- b.2 性格选项
            for __, StoryChoice in pairs(Story.Personality) do
                if self.mapPersonality[sAvgId] == nil then self.mapPersonality[sAvgId] = {} end
                if self.mapPersonalityFactor[sAvgId] == nil then self.mapPersonalityFactor[sAvgId] = {} end
                self.mapPersonality[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 2)
                self.mapPersonalityFactor[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 3)
            end
        end
    end
    self.mapRecentStoryId = decodeJson(LocalData.GetPlayerLocalData("RecentStoryId")) or {}
    --[[
        printTable(self.tbStoryIds)
        printTable(self.tbEvIds)
        printTable(self.mapChosen)
        printTable(self.mapLatest)
        printTable(self.mapPersonality)
        printTable(self.mapPersonalityFactor)
        printTable(self.mapRecentStoryId)
    ]]
    self:CheckNewStoryRedDot()
end
function AvgData:GetChapterStoryNumIds(nChapterId)
    return self.CFG_ChapterStoryNumIds[nChapterId]
end
function AvgData:GetStoryCfgData(storyId)
    local nId = self.CFG_Story[storyId]
    return ConfigTable.GetData_Story(nId)
end
function AvgData:AvgLuaNameToStoryId(sAvgId)
    local nId, storyId
    for k, v in pairs(self.CFG_Story) do
        local data = ConfigTable.GetData_Story(v)
        if data.AvgLuaName == sAvgId then
            nId = data.Id
            storyId = data.StoryId
            break
        end
    end
    return nId, storyId
end
function AvgData:CheckIfTrue(bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
    local n, sCheckTarget = self:AvgLuaNameToStoryId(sAvgId)
    if table.indexof(self.tbTempStoryIds, sCheckTarget) > 0 then
        -- 判断的是当前在播的演出，则从本地临时数据中判断，能判断所选次数。
        return self:CheckIfTrue_Client(bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
    else
        -- 判断的并非当前在播的演出，则从记服务器数据中判断，只能判断最后一次所选，不能判断次数。
        return self:CheckIfTrue_Srv(bIsMajor, sAvgId, nGroupId, nIndex)
    end
end
function AvgData:CheckIfTrue_Srv(bIsMajor, sAvgId, nGroupId, nIndex)
    if AVG_EDITOR == true then
        if self.mapAvgEditorTempData_IsTrueData == nil then self.mapAvgEditorTempData_IsTrueData = {} end
        local mapA = self.mapAvgEditorTempData_IsTrueData[sAvgId]
        if mapA == nil then return false end
        local sKey = bIsMajor == true and "L" or "X" -- 路线L 性格X
        mapA = mapA[sKey]
        if mapA == nil then return false end
        local _nIndex = mapA[nGroupId]
        if _nIndex == nil then return false end
        return nIndex == _nIndex
    end
    local mapData = bIsMajor == true and self.mapLatest or self.mapPersonality
    local mapA = mapData[sAvgId]
    if mapA == nil then return false end -- 该 sAvgId 没看过
    local nLatestChosenIndex = mapA[nGroupId]
    if nLatestChosenIndex == nil then return false end -- 该 nGroupId 的选项没选过
    return nIndex == nLatestChosenIndex
end
function AvgData:CheckIfTrue_Client(bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
    -- 与 CheckIfTrue 的差异：判断当前演出中的临时数据，会临时记录“次数”，“次数”不记服务器。
    local mapData = bIsMajor == true and self.mapTempLatestCnt or self.mapTempPersonalityCnt
    local mapA = mapData[sAvgId]
    if mapA == nil then return false end -- 不是当前看的演出
    mapA = mapA[nGroupId]
    if mapA == nil then return false end  -- 改组从未选过
    local nCount = mapA[nIndex] or 0 -- 是0的话表示：该组选过，但该选项从未选过。
    return nCount >= nCheckount
end

function AvgData:IsUnlock(sConditionId)
    if type(sConditionId) == "string" and sConditionId == "" then return true end
    if AVG_EDITOR == true then 
        if self.tbAvgEditorTempData_Unlocked_sConditionIds == nil then self.tbAvgEditorTempData_Unlocked_sConditionIds = {} end
        return table.indexof(self.tbAvgEditorTempData_Unlocked_sConditionIds, sConditionId) > 0
    end
    local nConditionIntId = self.CFG_StoryCondition[sConditionId]
    if nConditionIntId == nil then
        printError("Avg数据判断是否解锁时，传了一个excel表里没有的 string id:" .. tostring(sConditionId))
        return false
    end
    local cfgData = ConfigTable.GetData("StoryCondition", nConditionIntId)
    if cfgData == nil then
        printError("Avg数据判断是否解锁时，传了一个excel表里没有的 number id:" .. tostring(nConditionIntId))
        return false
    end

    local func_Check = function(tbRequire, tbPlayerData, tbPlayerTempData, bMust)
        if tbRequire == nil then return true end
        if #tbRequire <= 0 then return true end
        local bCheckResult, bCheckTempResult, tbCheckResultInfo = bMust, bMust, {}
        for i, v in ipairs(tbRequire) do
            local _b = table.indexof(tbPlayerData, v) > 0
            if bMust == true then
                bCheckResult = (bCheckResult == true) and (_b == true)
            else
                bCheckResult = (bCheckResult == true) or (_b == true)
            end
            tbCheckResultInfo[v] = _b
        end
        if bCheckResult == false then -- 检查存库数据的结果是false时再检查一下临时数据
            for i, v in ipairs(tbRequire) do
                if tbCheckResultInfo[v] ~= true then
                    local _b = table.indexof(tbPlayerTempData, v) > 0
                    if bMust == true then
                        bCheckTempResult = (bCheckTempResult == true) and (_b == true)
                    else
                        bCheckTempResult = (bCheckTempResult == true) or (_b == true)
                    end
                    tbCheckResultInfo[v] = _b
                end
            end
            return bCheckTempResult, tbCheckResultInfo
        else
            return bCheckResult, tbCheckResultInfo
        end
    end

    local bMustEvIds, mapMustEvIds = func_Check(cfgData.EvIds_a, self.tbEvIds, self.tbTempEvIds, true)
    local bOneOfEvIds, mapOneOfEvIds = func_Check(cfgData.EvIds_b, self.tbEvIds, self.tbTempEvIds, false)
    local bMustStoryIds, mapMustStoryIds = func_Check(cfgData.StoryId_a, self.tbStoryIds, self.tbTempStoryIds, true)
    local bOneOfStoryIds, mapOneOfStoryIds = func_Check(cfgData.StoryId_b, self.tbStoryIds, self.tbTempStoryIds, false)
    local nNeedWorldLevel = (cfgData.PlayerWorldLevel or 0)
    
    local bNeedLv = PlayerData.Base:GetWorldClass() >= nNeedWorldLevel
    local bMustAchievementIds, mapAchieveInfo = PlayerData.Achievement:CheckAchieveIds(cfgData.AchieveIds)

    local tbResult = {
        {bMustStoryIds,         mapMustStoryIds},   --前置关卡id（all of）：是否满足，配置的前置关卡id通关情况，true通关过，false未通关过。
        {bOneOfStoryIds,        mapOneOfStoryIds},  --前置关卡id（one of）：是否满足，配置的前置关卡id通关情况，true通关过，false未通关过。
        {bMustEvIds,            mapMustEvIds},      --前置关卡id（all of）：是否满足，配置的线索id获得情况，true已获得，false未获得。
        {bOneOfEvIds,           mapOneOfEvIds},     --前置关卡id（one of）：是否满足，配置的线索id获得情况，true已获得，false未获得。
        {bNeedLv,               nNeedWorldLevel},   --世界等级：是否大于等于，所需等级。
        {bMustAchievementIds,   mapAchieveInfo},    --成就：是否达成所有配置的成就，配置的各成就达成情况，true达成，false未达成。
    }

    local bResult = bMustEvIds == true and bOneOfEvIds == true and bMustStoryIds == true and bOneOfStoryIds == true and bNeedLv == true and bMustAchievementIds == true
    return bResult, tbResult
end
function AvgData:MarkStoryId(sAvgId)
    if AVG_EDITOR ~= true and self.CURRENT_STORY_ID <= 0 then return end
    local nId, storyId = self:AvgLuaNameToStoryId(sAvgId)
    if storyId == nil then return end
    if table.indexof(self.tbTempStoryIds, storyId) <= 0 --[[ and table.indexof(self.tbStoryIds, storyId) <= 0 ]] then -- 重打关卡时仍然临时记录它们
        table.insert(self.tbTempStoryIds, storyId)
    end
end
function AvgData:MarkEvId(sId)
    if table.indexof(self.tbTempEvIds, sId) <= 0 and table.indexof(self.tbEvIds, sId) <= 0 then
        table.insert(self.tbTempEvIds, sId)
    end
end
function AvgData:IsChosen(sAvgId, nGroupId, nIndex)
    if self.mapChosen[sAvgId] == nil then return false end
    if self.mapChosen[sAvgId][nGroupId] == nil then return false end
    local nCurrent = self.mapChosen[sAvgId][nGroupId]
    local bIsChosen = self.__data[nCurrent][nIndex] -- 已结算的记库数据

    if self.mapTempCL[sAvgId] == nil then self.mapTempCL[sAvgId] = {} end
    if self.mapTempCL[sAvgId][nGroupId] == nil then self.mapTempCL[sAvgId][nGroupId] = {} end
    local bIsChosen_Temp = table.indexof(self.mapTempCL[sAvgId][nGroupId], nIndex) > 0 -- 本局临时数据
    
    return bIsChosen, bIsChosen_Temp
end
function AvgData:MarkChosen(sAvgId, nGroupId, nIndex)
    if self.mapTempCL[sAvgId] == nil then self.mapTempCL[sAvgId] = {} end
    if self.mapTempCL[sAvgId][nGroupId] == nil then self.mapTempCL[sAvgId][nGroupId] = {} end
    local nTableIndex = table.indexof(self.mapTempCL[sAvgId][nGroupId], nIndex)
    if nTableIndex > 0 then
        table.remove(self.mapTempCL[sAvgId][nGroupId], nTableIndex)
    end
    table.insert(self.mapTempCL[sAvgId][nGroupId], nIndex) -- 记录所有本局演出所选过的，最后一次所选的放在数组末尾。

    -- 临时记录选过次数（不记服务器）
    if self.mapTempLatestCnt[sAvgId] == nil then self.mapTempLatestCnt[sAvgId] = {} end
    if self.mapTempLatestCnt[sAvgId][nGroupId] == nil then self.mapTempLatestCnt[sAvgId][nGroupId] = {} end
    local nCurCnt = self.mapTempLatestCnt[sAvgId][nGroupId][nIndex] or 0
    nCurCnt = nCurCnt + 1
    self.mapTempLatestCnt[sAvgId][nGroupId][nIndex] = nCurCnt
end
function AvgData:IsEvidenceUnlock(evidenceId)
    for k,v in ipairs(self.tbEvIds) do
        if v == evidenceId then
            return true
        end
    end
    return false
end
function AvgData:IsStoryReaded(nStoryId)
    local cfgData = ConfigTable.GetData_Story(nStoryId)
    if cfgData == nil then return false end
    if table.indexof(self.tbStoryIds, cfgData.StoryId) > 0 or table.indexof(self.tbTempStoryIds, cfgData.StoryId) > 0 then
        return true
    end
    return false
end
-- 性格选项相关
function AvgData:GetHistoryChoosedPersonality(sAvgId, nGroupId)
    if self.mapPersonality[sAvgId] == nil then return nil end
    if self.mapPersonality[sAvgId][nGroupId] == nil then return nil end
    local nValue = self.mapPersonality[sAvgId][nGroupId]
    local tbData = self.__data[nValue]
    for i, v in ipairs(tbData) do
        if v == true then
            return i
        end
    end
    return 0
end
function AvgData:MarkChoosedPersonality(sAvgId, nGroupId, nIndex, nFactor)
    if self.mapTempPersonality[sAvgId] == nil then self.mapTempPersonality[sAvgId] = {} end
    if self.mapTempPersonalityFactor[sAvgId] == nil then self.mapTempPersonalityFactor[sAvgId] = {} end
    local n = 0
    if nIndex == 1 then n = 1
    elseif nIndex == 2 then n = 2
    elseif nIndex == 3 then n = 4 end
    self.mapTempPersonality[sAvgId][nGroupId] = n
    self.mapTempPersonalityFactor[sAvgId][nGroupId] = nFactor

    -- 临时记录选过次数（不记服务器）
    if self.mapTempPersonalityCnt[sAvgId] == nil then self.mapTempPersonalityCnt[sAvgId] = {} end
    if self.mapTempPersonalityCnt[sAvgId][nGroupId] == nil then self.mapTempPersonalityCnt[sAvgId][nGroupId] = {} end
    local nCurCnt = self.mapTempPersonalityCnt[sAvgId][nGroupId][nIndex] or 0
    nCurCnt = nCurCnt + 1
    self.mapTempPersonalityCnt[sAvgId][nGroupId][nIndex] = nCurCnt
end
function AvgData:CalcPersonality(nId) -- nId 是 StoryRolePersonality.xlsx 的 A 列
    -- a.计算性格三维（A性格百分比=选A的次数/总次数）
    local cfgData_SRP = ConfigTable.GetData("StoryRolePersonality", nId)
    local tbPersonalityBaseNum = cfgData_SRP.BaseValue
    local nTotalCount = tbPersonalityBaseNum[1] + tbPersonalityBaseNum[2] + tbPersonalityBaseNum[3]
    local tbPData = {
        {nIndex = 1, nCount = tbPersonalityBaseNum[1], nPercent = 0},
        {nIndex = 2, nCount = tbPersonalityBaseNum[2], nPercent = 0},
        {nIndex = 3, nCount = tbPersonalityBaseNum[3], nPercent = 0},
    }
    local tbPersonality = self.mapPersonality
    local tbPersonalityFactor = self.mapPersonalityFactor
    local nFactor = 1
    for sAvgId, v in pairs(tbPersonality) do
        for nGroupId, vv in pairs(v) do -- vv: 1直觉 2理性 3混沌（vv是4是按位运算记录的结果，此处强转3即可）
            nFactor = 1
            if tbPersonalityFactor[sAvgId] ~= nil then
                nFactor = tbPersonalityFactor[sAvgId][nGroupId] or 1
            end
            nTotalCount = nTotalCount + nFactor
            local _idx = vv
            if _idx == 4 then _idx = 3 end
            tbPData[_idx].nCount = tbPData[_idx].nCount + nFactor
        end
    end
    for i, v in ipairs(tbPData) do tbPData[i].nPercent = tbPData[i].nCount / nTotalCount end
    local tbRetPercent = {tbPData[1].nPercent, tbPData[2].nPercent, tbPData[3].nPercent}
    -- b.根据性格三维数值确定性格称号及立绘表情
    local sTitle,sFace,sHead
    table.sort(tbPData, function(a, b) return a.nCount > b.nCount end)
    local nMaxIndex = tbPData[1].nIndex
    local nMaxPercent = tbPData[1].nPercent
    if nMaxPercent >= 0.9 then -- 全红/蓝/紫
        local tbTitle = {cfgData_SRP.Amax,cfgData_SRP.Bmax,cfgData_SRP.Cmax}
        local tbFace = {cfgData_SRP.AmaxFace,cfgData_SRP.BmaxFace,cfgData_SRP.CmaxFace}
        local tbHead = {cfgData_SRP.AmaxHead,cfgData_SRP.BmaxHead,cfgData_SRP.CmaxHead}
        sTitle = tbTitle[nMaxIndex]
        sFace = tbFace[nMaxIndex]
        sHead = tbHead[nMaxIndex]
    elseif nMaxPercent >= 0.5 then -- 主红/蓝/紫
        local tbTitle = {cfgData_SRP.Aplus,cfgData_SRP.Bplus,cfgData_SRP.Cplus}
        local tbFace = {cfgData_SRP.AplusFace,cfgData_SRP.BplusFace,cfgData_SRP.CplusFace}
        local tbHead = {cfgData_SRP.AplusHead,cfgData_SRP.BplusHead,cfgData_SRP.CplusHead}
        sTitle = tbTitle[nMaxIndex]
        sFace = tbFace[nMaxIndex]
        sHead = tbHead[nMaxIndex]
    else -- 红蓝/红紫/蓝紫
        if math.abs(tbPData[2].nPercent - tbPData[3].nPercent) < 0.1 then -- 其余两值相差在10%以内即：均衡
            sTitle = cfgData_SRP.Normal
            sFace = cfgData_SRP.NormalFace
            sHead = cfgData_SRP.NormalHead
        else
            local tbTitleFace = {
                {tbIdxs = {1,2}, sTitle = cfgData_SRP.Ab, sFace = cfgData_SRP.AbFace, sHead = cfgData_SRP.AbHead},
                {tbIdxs = {1,3}, sTitle = cfgData_SRP.Ac, sFace = cfgData_SRP.AcFace, sHead = cfgData_SRP.AcHead},
                {tbIdxs = {2,3}, sTitle = cfgData_SRP.Bc, sFace = cfgData_SRP.BcFace, sHead = cfgData_SRP.BcHead},
            }
            local nBiggerIndex = tbPData[2].nIndex
            for i, v in ipairs(tbTitleFace) do
                if table.indexof(v.tbIdxs, nMaxIndex) > 0 and table.indexof(v.tbIdxs, nBiggerIndex) > 0 then
                    sTitle = v.sTitle
                    sFace = v.sFace
                    sHead = v.sHead
                    break
                end
            end
        end
    end
    return tbRetPercent,sTitle,sFace,tbPData,nTotalCount,sHead
end
function AvgData:SetSelBuildId(nBuildId)
    self.selBuildId = nBuildId
end
function AvgData:GetCachedBuildId()
    return self.selBuildId
end
function AvgData:GetChapterCount()
    local count = 0
    local data = {}
    local function forEachChapter(mapData)
        count = count + 1
        table.insert(data, mapData)
    end
    ForEachTableLine(DataTable.StoryChapter,forEachChapter)
    return count,data
end
function AvgData:IsStoryChapterUnlock(nChapterId)
    local mapStoryData = ConfigTable.GetData("StoryChapter", nChapterId)
    if mapStoryData == nil then
        return false
    end
    local nWorldClass = mapStoryData.WorldClass
    local nCurWorldClass = PlayerData.Base:GetWorldClass()
    if nCurWorldClass < nWorldClass then
        return false,orderedFormat(ConfigTable.GetUIText("Story_UnlockWorldLv") or "",nWorldClass)
    end
    local tbPrevId 
    tbPrevId = mapStoryData.PrevStories
    for __, nPrevId in ipairs(tbPrevId) do
        if not self:IsStoryReaded(self.CFG_Story[nPrevId]) then
            local cfgData = ConfigTable.GetData_Story(self.CFG_Story[nPrevId])
            return false,orderedFormat(ConfigTable.GetUIText("Story_UnlockPreId") or "",cfgData.Title)
        end
    end
    return true
end
-- 与服务器通信，将临时记录的 证据、路线、性格 存库，返回成功时合并本地数据。
function AvgData:SendMsg_STORY_ENTER(nStoryId, nBuildId, bNewestStory)
    if type(nStoryId) ~= "number" then nStoryId = self.CFG_Story[nStoryId] end
    if nBuildId == nil then nBuildId = 0 end
    local func_cb = function()
        if bNewestStory == true then
            self:SetRecentStoryId(nStoryId)
        end
        if nBuildId ~= 0 then
            self.selBuildId = nBuildId
        end
        self.CURRENT_STORY_ID = nStoryId
        local mapCfgData_Story = ConfigTable.GetData_Story(nStoryId)
        if mapCfgData_Story.IsBattle == true then -- 战斗关卡
            local luaClass =  require "Game.Adventure.Story.StoryLevel"
            if luaClass == nil then
                return
            end
            self.curLevel = luaClass
            if type(self.curLevel.BindEvent) == "function" then
                self.curLevel:BindEvent()
            end
            if type(self.curLevel.Init) == "function" then
                self.curLevel:Init(self,nStoryId,nBuildId)
            end
            printLog("进战斗关卡了") -- 应从选 build 界面中调用此接口
        else -- AVG演出关卡
            if NovaAPI.IsEditorPlatform() == true then
                local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
                local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/" -- 路径是：Game/UI/Avg/_cn/Config/
                local filePath = NovaAPI.ApplicationDataPath.."/../Lua/" .. sRequireRootPath .. mapCfgData_Story.AvgLuaName..".lua"
                if not File.Exists(filePath) then
                    EventManager.Hit(EventId.OpenMessageBox,"找不到AVG配置文件,请检查配置表！，Avg名：" .. mapCfgData_Story.AvgLuaName)
                    printError("找不到AVG配置文件,请检查配置表！，Avg名：" .. mapCfgData_Story.AvgLuaName)
                    return
                end
            end
            printLog("进AVG演出了 " .. mapCfgData_Story.AvgLuaName)
            EventManager.Add("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
            EventManager.Hit("StoryDialog_DialogStart", mapCfgData_Story.AvgLuaName)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.story_apply_req, {Idx = nStoryId, BuildId = nBuildId}, nil, func_cb)
end
function AvgData:SendMsg_STORY_DONE(callBack,tbBattleEvents)
    local mapSendMsgData = { List = {}, Evidences = {} ,Events = tbBattleEvents == nil and {List = {}} or tbBattleEvents}
    local mapStoryCfg = ConfigTable.GetData_Story(self.CURRENT_STORY_ID)
    local bBattle = mapStoryCfg.IsBattle
    if bBattle then -- 战斗关
        mapSendMsgData.List[1] = { Idx = self.CURRENT_STORY_ID }
        if table.indexof(self.tbTempStoryIds, mapStoryCfg.StoryId) <= 0 then
            table.insert(self.tbTempStoryIds, mapStoryCfg.StoryId)
        end
    else -- 演出关
        if #self.tbTempStoryIds > 0 then
            for i, sStoryId in ipairs(self.tbTempStoryIds) do
                local nStoryId = self.CFG_Story[sStoryId]
                mapSendMsgData.List[i] = {Idx = nStoryId, Major = {}, Personality = {}}
                local mapStoryCfg = ConfigTable.GetData_Story(nStoryId)
                if mapStoryCfg ~= nil then
                    local sAvgId = mapStoryCfg.AvgLuaName
                    -- 1.本局路线选项，所有选过的数据，最后一次所选的在数组末尾。
                    local mapGroupData = self.mapTempCL[sAvgId]
                    if mapGroupData ~= nil then
                        for nGroupId, tbChosen in pairs(mapGroupData) do
                            for _, nChoiceIndex in ipairs(tbChosen) do
                                local n = 0
                                if nChoiceIndex == 1 then n = 1
                                elseif nChoiceIndex == 2 then n = 2
                                elseif nChoiceIndex == 3 then n = 4 end
                                table.insert(mapSendMsgData.List[i].Major, {Group = nGroupId, Choice = n, Factor = 0})
                            end
                        end
                    end
                    --2.本局性格选项，最后一次所选数据
                    mapGroupData = self.mapTempPersonality[sAvgId]
                    if mapGroupData ~= nil then
                        for nGroupId, nLatest in pairs(mapGroupData) do
                            local nFactor = 0
                            if self.mapTempPersonalityFactor[sAvgId] ~= nil then
                                nFactor = self.mapTempPersonalityFactor[sAvgId][nGroupId] or 0
                            end
                            table.insert(mapSendMsgData.List[i].Personality, {Group = nGroupId, Choice = nLatest, Factor = nFactor})
                        end
                    end
                end
            end
        end
        if #self.tbTempEvIds > 0 then
            for _, sEvId in ipairs(self.tbTempEvIds) do
                table.insert(mapSendMsgData.Evidences, self.CFG_StoryEvidence[sEvId])
            end
        end
        self:CheckNewStoryRedDot()
        local tbPassId = {}
        for _, v in ipairs(mapSendMsgData.List) do
            table.insert(tbPassId, v.Idx)
        end
        PlayerData.Char:StoryPass(tbPassId)
    end

    local bCBTSpecialNotice = false
    local nStoryId, sNoticeTextId = nil, nil
    --[[
        -- CBT1特殊提示
        if self.CURRENT_STORY_ID == 102 or self.CURRENT_STORY_ID == 321 then
            nStoryId = self.CURRENT_STORY_ID
            sNoticeTextId = "CBT1SpecialNotice_" .. tostring(nStoryId)
        end
    ]]
    -- CBT2特殊提示
    if self.CURRENT_STORY_ID == 217 then
        nStoryId = self.CURRENT_STORY_ID
        sNoticeTextId = "CBT1SpecialNotice_321"
    end
    if nStoryId ~= nil then
        bCBTSpecialNotice = table.indexof(self.tbStoryIds, nStoryId) <= 0
    end

    -- 发送消息成功后回调
    local func_merge = function(tbSrc, tbTarget)
        for i, v in ipairs(tbSrc) do
            if table.indexof(tbTarget, v) <= 0 then
                table.insert(tbTarget, v)
            end
        end
    end
    local func_overwrite = function(tbSrc, tbTarget)
        for sAvgId, v in pairs(tbSrc) do
            if tbTarget[sAvgId] == nil then tbTarget[sAvgId] = {} end
            for nGroupId, vv in pairs(v) do
                tbTarget[sAvgId][nGroupId] = vv
            end
        end
    end
    local func_succ = function(_, mapChangeInfo)
        if mapStoryCfg.Chapter == 1 and mapStoryCfg.IsLast and mapChangeInfo and mapChangeInfo.Props and #mapChangeInfo.Props > 0 then
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_mainstory_1_clear")
            ---日服PC埋点---
        end
        if mapStoryCfg.Chapter == 2 and mapStoryCfg.IsLast and mapChangeInfo and mapChangeInfo.Props and #mapChangeInfo.Props > 0 then
            local tab = {}
            table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
            NovaAPI.UserEventUpload("chapter2_complete",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_mainstory_2_clear")
            ---日服PC埋点---
        end

        if #self.tbTempStoryIds > 1 then
            --合并通关的情况，最新通关章节取最新的
            local nRecentChapterId = self.CFG_Story[self.tbTempStoryIds[#self.tbTempStoryIds]]
            self:SetRecentStoryId(nRecentChapterId)
        end
        -- a.合并已通关的 StoryId
        func_merge(self.tbTempStoryIds, self.tbStoryIds)
        self.tbTempStoryIds = {}
        -- b.合并获得的 EvIds
        func_merge(self.tbTempEvIds, self.tbEvIds)
        self.tbTempEvIds = {}
        -- c.合并选过的选项
        --[[ func_overwrite(self.mapTempChosen, self.mapChosen)
        self.mapTempChosen = {}
        func_overwrite(self.mapTempLatest, self.mapLatest)
        self.mapTempLatest = {} ]]
        for sAvgId, mapGroupData in pairs(self.mapTempCL) do
            if self.mapChosen[sAvgId] == nil then self.mapChosen[sAvgId] = {} end
            for nGroupId, tbChosen in pairs(mapGroupData) do
                if self.mapChosen[sAvgId][nGroupId] == nil then self.mapChosen[sAvgId][nGroupId] = 0 end
                local nLen = #tbChosen
                for _, nChoiceIndex in ipairs(tbChosen) do
                    local n = 0
                    if nChoiceIndex == 1 then n = 1
                    elseif nChoiceIndex == 2 then n = 2
                    elseif nChoiceIndex == 3 then n = 4 end
                    local nCur = self.mapChosen[sAvgId][nGroupId]
                    self.mapChosen[sAvgId][nGroupId] = nCur | n
                    if _ == nLen then
                        if self.mapLatest[sAvgId] == nil then self.mapLatest[sAvgId] = {} end
                        self.mapLatest[sAvgId][nGroupId] = n
                    end
                end
            end
        end
        self.mapTempCL = {}
        self.mapTempLatestCnt = {}
        -- d.覆盖选过的性格并记录倍率系数
        func_overwrite(self.mapTempPersonality, self.mapPersonality)
        self.mapTempPersonality = {}
        self.mapTempPersonalityCnt = {}
        func_overwrite(self.mapTempPersonalityFactor, self.mapPersonalityFactor)
        self.mapTempPersonalityFactor = {}

        --处理外部callback
        if callBack ~= nil then
            callBack(mapChangeInfo) -- 战斗关的结算展示是在这里
        end
        --处理ChangeInfo
        local bHasReward = not bBattle and mapChangeInfo and mapChangeInfo.Props and #mapChangeInfo.Props > 0
        if bHasReward then -- 非战斗关的结算展示是在这里
            local tbItem = {}
            local tbRewardDisplay = UTILS.DecodeChangeInfo(mapChangeInfo)
            for _, v in pairs(tbRewardDisplay) do
                for k, value in pairs(v) do
                    table.insert(tbItem, {Tid = value.Tid, Qty = value.Qty, rewardType = AllEnum.RewardType.First})
                end
            end
            -- local function CBT_SpecialNotice()--CBT第一张第二节首次通关时弹CBT特别提示。
            --     if bCBTSpecialNotice ~= true then return end
            --     local msg = {
            --         nType = AllEnum.MessageBox.Desc,
            --         sContent = ConfigTable.GetUIText(sNoticeTextId),
            --         callbackConfirm = nil,
            --         bBlur = false,
            --     }
            --     EventManager.Hit(EventId.OpenMessageBox, msg)
            -- end
            local function AfterRewardDisplay()
                --CBT_SpecialNotice() --如果还需要该提示打开此函数注释即可。
                EventManager.Hit("Story_RewardClosed")
            end
            local function delayOpen()
                UTILS.OpenReceiveByDisplayItem(tbItem, mapChangeInfo, AfterRewardDisplay)
            end
            local nDelayTime = 1.5 -- story 系列的AVG 都是ST，有前后有通用转场，需在转场后弹结算。
            EventManager.Hit(EventId.TemporaryBlockInput, nDelayTime)
            TimerManager.Add(1, nDelayTime, self, delayOpen, true, true, true)
        end
        EventManager.Hit("Story_Done", bHasReward)
        --打开结算界面
        printLog("通关结算完成")
    end
    printLog("发送通关消息")
    -- 发送通关消息
    HttpNetHandler.SendMsg(NetMsgId.Id.story_settle_req, mapSendMsgData, nil, func_succ)
    self.CURRENT_STORY_ID = 0
end
function AvgData:OnEvent_AvgSTEnd()
    if AVG_EDITOR == true then
        self.tbTempStoryIds = {}
        self.tbTempEvIds = {}
        --[[ self.mapTempChosen = {}
        self.mapTempLatest = {} ]]
        self.mapTempLatestCnt = {}
        self.mapTempPersonality = {}
        self.mapTempPersonalityCnt = {}
        self.mapTempPersonalityFactor = {}
        return
    end
    self:SendMsg_STORY_DONE()
    EventManager.Remove("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
end

function AvgData:LevelEnd()
    PlayerData.Build:DeleteTrialBuild()
    if type(self.curLevel.UnBindEvent) == "function" then
        self.curLevel:UnBindEvent()
    end
    self.curLevel = nil
end

function AvgData:GetLastestStoryId()
    local nMax = 101
    for k, v in pairs(self.tbStoryIds) do
        local curIdx = self.CFG_Story[v]
        if curIdx > nMax then
            nMax = curIdx
        end
    end
    
    for k, v in pairs(self.tbTempStoryIds) do
        local curIdx = self.CFG_Story[v]
        if curIdx > nMax then
            nMax = curIdx
        end
    end
    
    return nMax
end

-- 每一章最近一次打的关卡
function AvgData:GetRecentStoryId(nChapterId)
    local nStoryId = self.mapRecentStoryId[tostring(nChapterId)]
    if nStoryId == nil then
        -- 补充逻辑：从“已通关”数据中（self.tbStoryIds）找出 nChapterId 该章节最新进度那一个关卡。
        local tbChapterList = self.CFG_ChapterStoryNumIds[nChapterId]
        if tbChapterList ~= nil then
           table.sort(tbChapterList, function(a, b) return a < b end) -- 按从小到大排序
           for i = #tbChapterList, 1, -1 do
                local v = tbChapterList[i]
                if self.tbStoryIds[v] then -- 判断是否通关
                    nStoryId = v
                    break
                end
           end
           local chapterConfig = ConfigTable.GetData("StoryChapter",nChapterId)
           nStoryId = chapterConfig.UnlockShowStoryId
        end
    end
    return nStoryId -- ConfigTable.GetData_Story(nStoryId).Title
end
function AvgData:SetRecentStoryId(nStoryId)
    local cfgData = ConfigTable.GetData_Story(nStoryId)
    if cfgData ~= nil then
        self.mapRecentStoryId[tostring(cfgData.Chapter)] = nStoryId
        local sJson = RapidJson.encode(self.mapRecentStoryId)
        printLog(sJson)
        LocalData.SetPlayerLocalData("RecentStoryId", sJson)
    end
end
--最新的章节
function AvgData:GetRecentChapterId()
    local nRecentChapterId = 1
    for k,v in pairs(self.mapRecentStoryId) do
        if tonumber(k) > nRecentChapterId then
            nRecentChapterId = tonumber(k)
        end
    end

    return nRecentChapterId
end

--检查红点（需要标高亮的节点）
function AvgData:CheckNewStoryRedDot()
    local _,data = self:GetChapterCount()
    for k,v in ipairs(data) do
        local bHasNew = false
        if self:IsStoryChapterUnlock(v.Id) then
            local tbStoryIds = self:CheckNewStory(v.Id)
            for k,v in pairs(tbStoryIds) do
                if v == true then
                    bHasNew = true
                    break
                end
            end
        end

        RedDotManager.SetValid(RedDotDefine.Map_MainLine_Chapter,v.Id,bHasNew)
    end
end
function AvgData:CheckNewStory(nChapterId)
    local tbNewUnlockStorys = {}
    for k,v in ipairs(self.CFG_ChapterStoryNumIds[nChapterId]) do
        local config = ConfigTable.GetData("Story", v)
        local bUnlock = self:IsUnlock(config.ConditionId)
        if bUnlock then
            local bReaded = self:IsStoryReaded(v)
            if not bReaded then
                tbNewUnlockStorys[v] = true
            end
        end
    end
    return tbNewUnlockStorys
end
function AvgData:SetNewLockChapterIndex(chapterIndex)
    self.nNewLockChapterIndex = chapterIndex
end
function AvgData:GetNewLockChapterIndex()
    if self.nNewLockChapterIndex == nil then 
        self.nNewLockChapterIndex = -1 
    end
    local tempIndex = self.nNewLockChapterIndex
    self.nNewLockChapterIndex = -1
    return tempIndex
end
-- Avg编辑器专用的临时数据
function AvgData:AvgEditorTempData(sConditionIds, bAdd)
    if self.tbAvgEditorTempData_Unlocked_sConditionIds == nil then self.tbAvgEditorTempData_Unlocked_sConditionIds = {} end
    if sConditionIds == "all" then
        if bAdd == false then self.tbAvgEditorTempData_Unlocked_sConditionIds = {} end
    else
        local tbIds = string.split(sConditionIds, ",")
        for i, v in ipairs(tbIds) do
            if bAdd == true then
                if table.indexof(self.tbAvgEditorTempData_Unlocked_sConditionIds, v) <= 0 then
                    table.insert(self.tbAvgEditorTempData_Unlocked_sConditionIds, v)
                end
            else
                local n = table.indexof(self.tbAvgEditorTempData_Unlocked_sConditionIds, v)
                if n > 0 then table.remove(self.tbAvgEditorTempData_Unlocked_sConditionIds, n) end
            end
        end
    end
end
function AvgData:AvgEditorTempIfTrueData(sData, bAdd)
    if self.mapAvgEditorTempData_IsTrueData == nil then self.mapAvgEditorTempData_IsTrueData = {} end
    if sData == "all" then
        if bAdd == false then self.mapAvgEditorTempData_IsTrueData = {} end
    else
        local tbCell = string.split(sData, ",")
        local tbChoice = {"A","B","C"}
        for i, v in ipairs(tbCell) do
            if v ~= nil and v ~= "" then
                local tbData = string.split(v, "-")
                if tbData ~= nil and #tbData == 4 then
                    local sAvgId = tbData[1]
                    local sKey = tbData[2] -- L路线 X性格
                    local nGroupId = tonumber(tbData[3])
                    local nIndex = table.indexof(tbChoice, tbData[4])
                    if self.mapAvgEditorTempData_IsTrueData[sAvgId] == nil then self.mapAvgEditorTempData_IsTrueData[sAvgId] = {} end
                    if self.mapAvgEditorTempData_IsTrueData[sAvgId][sKey] == nil then self.mapAvgEditorTempData_IsTrueData[sAvgId][sKey] = {} end
                    self.mapAvgEditorTempData_IsTrueData[sAvgId][sKey][nGroupId] = nIndex
                end
            end
        end
    end
end

function AvgData:CacheEvData()
    self.tbEvData={} --key  string:EvId list<string>:StoryIds  
    local function forEachLine_Story(storConfig)
        local sConditionId=storConfig.ConditionId
        if sConditionId==nil then
           return
        end
        if self.CFG_StoryCondition[sConditionId]==nil then
            return
        end
        local nConditionId=self.CFG_StoryCondition[sConditionId]
        local mapConditionData = ConfigTable.GetData("StoryCondition", nConditionId)
        local tbEvIds={}
        if #mapConditionData.EvIds_a > 0 then
            for k,v in ipairs(mapConditionData.EvIds_a) do
                table.insert(tbEvIds, v)
            end
        end
        if #mapConditionData.EvIds_b > 0 then
            for k,v in ipairs(mapConditionData.EvIds_b) do
                table.insert(tbEvIds, v)
            end
        end
        if #tbEvIds == 0 then
            return
        end
        for i,v in ipairs(tbEvIds) do
            if self.tbEvData[v]==nil then
                self.tbEvData[v]={}
            end
            table.insert( self.tbEvData[v],storConfig.StoryId)
        end
    end
    ForEachTableLine(DataTable.Story, forEachLine_Story)
end

return AvgData
