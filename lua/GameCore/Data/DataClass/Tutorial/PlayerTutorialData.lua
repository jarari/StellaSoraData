local PlayerTutorialData = class("PlayerTutorialData")

local LevelData = require "GameCore.Data.DataClass.Tutorial.TutorialLevelData"

function PlayerTutorialData:Init()
    self.curLevelId=0
    self.tbLevelData={}  --{[levelId]={nlevelId,LevelResultType}}
    self.LevelIdList={}
end
function PlayerTutorialData:CacheTutorialData(levelsData)
    local forEachTableFunc=function (config)    
        self:UpdateLevel({nlevelId=config.Id,LevelStatus=AllEnum.ActQuestStatus.UnComplete})
        table.insert(self.LevelIdList,config.Id)
    end
    ForEachTableLine(DataTable.TutorialLevel,forEachTableFunc)

    for _, level in pairs(levelsData) do
        self:UpdateLevel({nlevelId=level.LevelId,LevelStatus=self:QuestStateServer2Client(level.Passed,level.RewardReceived)}) 
    end
    --sort
    local sortFunc=function (a,b)
        return a<b
    end
    table.sort(self.LevelIdList,sortFunc)

    self.LevelData=LevelData.new()
end
function PlayerTutorialData:GetLevelLockType(levelId)
    local levelData=self:GetLevelData(levelId)
    if levelData.LevelStatus==AllEnum.ActQuestStatus.Complete or levelData.LevelStatus==AllEnum.ActQuestStatus.Received then
        return AllEnum.TutorialLevelLockType.None
    end
    local levelConfig=ConfigTable.GetData("TutorialLevel",levelId)
    if levelConfig == nil then
        return AllEnum.TutorialLevelLockType.None
    end
    if levelConfig.WorldClass>PlayerData.Base:GetWorldClass() then
        return AllEnum.TutorialLevelLockType.WorldClass
    end
    local preLevelData=self:GetLevelData(levelConfig.PreLevelId)
    if preLevelData==nil then
        return AllEnum.TutorialLevelLockType.None
    end
    if preLevelData.LevelStatus==AllEnum.ActQuestStatus.UnComplete then
        return AllEnum.TutorialLevelLockType.PreLevel
    end
    return AllEnum.TutorialLevelLockType.None
end
function PlayerTutorialData:GetLevelList()
    return self.LevelIdList
end
function PlayerTutorialData:UpdateLevel(levelData)
    self.tbLevelData[levelData.nlevelId]=levelData
end
function PlayerTutorialData:GetLevelData(levelId)
    return self.tbLevelData[levelId]
end
function  PlayerTutorialData:GetProgress()
    local nReceivedCount=0
    for _, data in pairs(self.tbLevelData) do
        if data.LevelStatus==AllEnum.ActQuestStatus.Received then
            nReceivedCount=nReceivedCount+1
        end
    end
    return #self.LevelIdList ,nReceivedCount
end
---@param levelId any
---@return integer   0就是没有下一关
function PlayerTutorialData:GetNextLevelId(levelId)
    local nNextlevelId=0
    local nIndex=table.indexof(self.LevelIdList,levelId)
    if nIndex >0 and nIndex+1<=#self.LevelIdList then
        for i = nIndex+1, #self.LevelIdList, 1 do
            if self:GetLevelLockType(self.LevelIdList[i]) ==AllEnum.TutorialLevelLockType.None then
                nNextlevelId=self.LevelIdList[i]
                break
            end
        end
    end
    return nNextlevelId
end
function PlayerTutorialData:GetLevelReward(levelId)
    local mapSendMsg={
        Value=levelId
    }
    local succ_cb = function(_, mapData)
        -- UTILS.OpenReceiveByChangeInfo(mapData)
        self:UpdateLevel({nlevelId=levelId,LevelStatus =AllEnum.ActQuestStatus.Received})
        EventManager.Hit(EventId.TutorialQuestReceived,mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.tutorial_level_reward_receive_req, mapSendMsg, nil, succ_cb)
end

function PlayerTutorialData:EnterLevel(levelId,callback)
    self.curLevelId=levelId
    local levelConfig= ConfigTable.GetData("TutorialLevel",self.curLevelId)
    if levelConfig == nil then
        return 
    end
    local buildData=ConfigTable.GetData("TrialBuild",levelConfig.TutorialBuild)
    if buildData==nil then
        return
    end
    local charIdList={}
    local discIdList={}
    for _, id in pairs(buildData.Char) do
        local charData=ConfigTable.GetData("TrialCharacter",id)
        if charData~=nil then
            table.insert(charIdList,charData.CharId) 
        end
    end
    for _, id in pairs(buildData.Disc) do
        local discData=ConfigTable.GetData("TrialDisc",id)
        if discData~=nil then
            table.insert(discIdList,discData.DiscId) 
        end
    end
    self.LevelData:InitLevelData(self.curLevelId,charIdList,discIdList)
    if callback ~=nil then
        callback()
    end
end
function PlayerTutorialData:FinishLevel(bResult)
    if not bResult then
        self.LevelData:FinishLevel(false)
        self.curLevelId=0
        --失败
    else
        local levelData=self:GetLevelData(self.curLevelId)
        if levelData~=nil then
            if levelData.LevelStatus ==AllEnum.ActQuestStatus.UnComplete then
                --未完成
                self.LevelData:FinishLevel(true)
                local mapSendMsg={
                    Value=self.curLevelId
                }
                local func_cb=function ()
                    self:UpdateLevel({nlevelId=self.curLevelId,LevelStatus =AllEnum.ActQuestStatus.Complete}) 
                    self.curLevelId=0
                end
                HttpNetHandler.SendMsg(NetMsgId.Id.tutorial_level_settle_req, mapSendMsg, nil, func_cb)
            else
                --已完成或者已领取
                self.LevelData:FinishLevel(true)
                self.curLevelId=0
            end
            
        end
    end
end

--关卡数据接口
function PlayerTutorialData:GetCurDicId()
    return self.LevelData:GetCurDicId()
end

--请求


function PlayerTutorialData:QuestStateServer2Client(Passed,RewardReceived)
    if not Passed then
        return AllEnum.ActQuestStatus.UnComplete
    elseif Passed and not RewardReceived then
        return AllEnum.ActQuestStatus.Complete
    else 
        return AllEnum.ActQuestStatus.Received
    end
end
return PlayerTutorialData
