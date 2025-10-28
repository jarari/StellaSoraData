local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local CookieGameData = class("CookieGameData", ActivityDataBase)

local nLastPath = 0

function CookieGameData:GetCookieControlCfg(...)
    if not self.tbConfig then
        self.tbConfig = ConfigTable.GetData("CookieControl", self.nActId) 
    end
    return self.tbConfig
end

function CookieGameData:GetLevelCfg(nPlayGroupId)
    local mapConfig = ConfigTable.GetData("CookiePackNormalModel", nPlayGroupId)
    if mapConfig == nil then return nil end
    return mapConfig
end

function CookieGameData:Init()
    self.nTotalScore = 0
    self.nActCredit = 0
    self.nActId = 0
    self.nNightmareModeHighScore = 0
    self.tbLevelScore = {}      -- X关卡中达到Y分
    self.tbLevelBox = {}        -- X关卡中完成Y盒饼干
    self.tbModeComp = {}        -- X模式完成Y局游戏
    self.tbModeBox = {}         -- X模式下完成Y盒饼干
    self.tbModePerfect = {}     -- X模式下达成Y次Perfect
    self.tbModeExcellent = {}   -- X模式下达成Y次Excellent
    self.tbModeCookie = {}      -- X模式下包装Y个饼干
    self:AddListeners()
    
end

function CookieGameData:AddListeners()
    EventManager.Add("Cookie_Game_Complete", self, self.OnEvent_GameComplete)
    EventManager.Add("Cookie_Quest_Claim", self, self.OnEvent_QuestClaim)
end

-- 获取数据的总入口
function CookieGameData:RefreshCookieGameActData(actId, msgData)
    self:Init()
    
    self.nActId = actId
    if msgData ~= nil then
        self:CacheAllQuestData(msgData.Quests)
        self:CacheAllLevelData(msgData.Levels)
    end
end


---------------------------------------------------Quest------------------------------------------------------
function CookieGameData:CacheAllQuestData(questListData)
    self.tbQuestDataList = {}
    for _, v in pairs(questListData) do
        local questData = {
            nId = v.Id,
            nStatus = self:QuestServer2Client(v.Status),
            progress = v.Progress,
        }
        table.insert(self.tbQuestDataList,questData)
    end
    --self:RefreshQuestReddot()
end

function CookieGameData:GetQuestData()
    return self.tbQuestDataList
end

function CookieGameData:CacheAllLevelData(levelListData)
    self.tbLevelDataList = {}
    for _, v in pairs(levelListData) do
        local levelData = {
            nId = v.LevelId,
            nMaxScore = v.MaxScore,
            bFirstComplete = v.FirstComplete,
        }
        table.insert(self.tbLevelDataList,levelData)
    end
end

function CookieGameData:GetLevelData()
    return self.tbLevelDataList
end

function CookieGameData:GetQuestDataById(nId)
    local questData = nil
    for _, v in pairs(self.tbQuestDataList) do
        if v.nId == nId then
            questData = v
            break
        end
    end
    return questData
end

--更新任务
function CookieGameData:RefreshQuestData(questData)
    local oldQuestData = self:GetQuestDataById(questData.Id)
    oldQuestData.nStatus = questData.Status
    oldQuestData.progress = questData.Progress

    --self:RefreshQuestReddot()
    EventManager.Hit("CookieQuestUpdate")
end

function CookieGameData:RefreshQuestReddot()
    local bTabReddot = false
    if next(self.tbQuestDataList) ~= nil then
        for _, v in pairs(self.tbQuestDataList) do
            local bReddot = v.nStatus == AllEnum.ActQuestStatus.Complete
            RedDotManager.SetValid(RedDotDefine.Activity_Cookie_Quest,v.nId,bReddot)
            bTabReddot = bTabReddot or bReddot
        end
    end
    RedDotManager.SetValid(RedDotDefine.Activity_Tab, self.nActId, bTabReddot or self.bIsFirst)
end

--领取任务奖励 nQuestId = 0 表示一键领取)
function CookieGameData:SendQuestReceive(nQuestId)
    local callback = function (_, msgData)
        UTILS.OpenReceiveByChangeInfo(msgData, nil)
        if nQuestId == 0 then
            for _,v in pairs( self.tbQuestDataList) do
                if v.nStatus == AllEnum.ActQuestStatus.Complete then
                    v.nStatus = AllEnum.ActQuestStatus.Received
                end
            end
        else
            local questData = self:GetQuestDataById(nQuestId)
            if questData then
                questData.nStatus = AllEnum.ActQuestStatus.Received
            end
        end
        EventManager.Hit("CookieQuestUpdate")
        --self:RefreshQuestReddot()
    end

    HttpNetHandler.SendMsg(NetMsgId.Id.activity_cookie_quest_reward_receive_req,
    {ActivityId = self.nActId, QuestId = nQuestId},nil, callback)
end

function CookieGameData:QuestServer2Client(nStatus)
    if nStatus == 0 then
        return AllEnum.ActQuestStatus.UnComplete
    elseif nStatus == 1 then
        return AllEnum.ActQuestStatus.Complete
    else 
        return AllEnum.ActQuestStatus.Received
    end
end

--------------------------------------------------Levels-------------------------------------------------
function CookieGameData:RequestLevelResult(nLevelId, nScore, nBoxCount, nCookieCount, nPerfectCount, nExcellentCount, nMode, callback)
    local callbackFunc = function (_,msgData)
        self:ResponseLevelData(msgData, callback)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_cookie_settle_req, {ActivityId = self.nActId, LevelId = nLevelId, Score = nScore, PackageNum = nBoxCount, CookieNum = nCookieCount, PerfectNum = nPerfectCount, ExcellentNum = nExcellentCount},nil,callbackFunc)
end
function CookieGameData:ResponseLevelData(msgData, callback)
    if nil ~= msgData then
        UTILS.OpenReceiveByChangeInfo(msgData, nil)
    end
    
    EventManager.Hit("CookieQuestUpdate")
    EventManager.Hit("CookieLevelUpdate")
    if callback ~= nil then
        callback()
    end
end

function CookieGameData:RequestLevelData(nStatus, callback)
    local callbackFunc = function (_, msgData)
        self:ResponseLevelData(msgData, callback)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_mining_apply_req,{ActivityId=self.nActId},nil,callbackFunc)
end

function CookieGameData:OnEvent_GameComplete(nLevelId, nScore, nBoxCount, nCookieCount, nPerfectCount, nExcellentCount, nMode)
    self:RequestLevelResult(nLevelId, nScore, nBoxCount, nCookieCount, nPerfectCount, nExcellentCount, nMode, nil)
end

function CookieGameData:OnEvent_QuestClaim(nQuestId)
    self:SendQuestReceive(nQuestId)
end

return CookieGameData