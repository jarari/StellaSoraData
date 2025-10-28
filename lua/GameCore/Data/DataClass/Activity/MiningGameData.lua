local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local LocalData = require("GameCore.Data.LocalData")
local MiningGameData = class("MiningGameData", ActivityDataBase)


--这里会重复监听事件！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
--所有服务端的cell 下面都是从0开始 都需要+1处理一下数据
function MiningGameData:Init()
    self.tbQuestDataList={}  --{nId,nStatus,progress} Progress {Cur,Max}
    self.bIsFirst=true
    self.nScore=0
    ---层数据
    self.tbGridDataList={} --{nId, nIndex,nStatus,bMark}
    self.nCurLevel=0   
    self.tbCurReward={}   --{nId=宝藏Id,tbPosIndex=宝藏所在的,bIsGet=是否获得} 
    self.bCanGoNext=false
    self.tbSupList={} --{nId}
    self.nAddAxeCount_Daliy=0 
    self.nAddAxeCount_LongTime=0

    --self.tbCurlevelEnterChange={}
    ---end
    self.tbConfig={}

    self.nConfigId=0

    self.tbCurDicGroupId={}  --{id}
    self.tbCurStoryGroupData={} --{id,bIsRead,bIsLock}
    self.tbCurStoryListData={} --{id,config}存放当前组的故事配置表ID  从小到大排序过   

    self.nAxeId=0
    self:AddListeners()
end

function MiningGameData:AddListeners()
    EventManager.Add(EventId.IsNewDay, self, self.OnEvent_NewDay)
    EventManager.Add("Mining_Daily_Reward",self,self.On_DailyReward_Update)
    EventManager.Add("Mining_Supplement_Reward",self,self.On_SupplementReward_Update)
    EventManager.Add("Mining_UpdateLevelData",self,self.OnEvent_Mining_UpdateLevelData)
    EventManager.Add("Mining_UpdateRigResult",self,self.OnEvent_Mining_UpdateDigResult)
end
function MiningGameData:OnEvent_NewDay()
    self.nAddAxeCount=0
end
-------------Quest
function MiningGameData:CacheAllQuestData(questListData)
    self.tbQuestDataList={}
    
    for _, v in pairs(questListData) do
        local questData={
            nId=v.Id,
            nStatus=self:QuestServer2Client(v.Status),
            progress=v.Progress,
        }
        table.insert(self.tbQuestDataList,questData)
    end
    self:RefreshQuestReddot()
end

function MiningGameData:GetAllQuestData()
    return self.tbQuestDataList
end
function MiningGameData:GetQuestData(nQuestId)
    local questData=nil
    for _, v in pairs(self.tbQuestDataList) do
        if v.nId==nQuestId then
            questData=v
        end
    end
    return questData
end
function MiningGameData:GetCompleteCount()
    local nCount=0
    for _, v in pairs(self.tbQuestDataList) do
        if v.nStatus==AllEnum.ActQuestStatus.Complete or v.nStatus==AllEnum.ActQuestStatus.Received then
            nCount=nCount+1
        end
    end
    return nCount
end

--更新任务
function MiningGameData:RefreshQuestData(questData)
    -- local oldQuestData=self:GetQuestData(questData.Id)
    -- oldQuestData.nStatus=questData.nStatus
    -- oldQuestData.progress=questData.progress

    -- self:RefreshQuestReddot()
    -- EventManager.Hit("MiningQuestUpdate")
end
function MiningGameData:RefreshQuestReddot()
    local bTabReddot=false
    if next(self.tbQuestDataList) ~=nil then
        for _, v in pairs(self.tbQuestDataList) do
            local bReddot=v.nStatus==AllEnum.ActQuestStatus.Complete
            RedDotManager.SetValid(RedDotDefine.Activity_Mining_Quest,v.nId,bReddot)
            bTabReddot=bTabReddot or bReddot
        end
    end
    RedDotManager.SetValid(RedDotDefine.Activity_Tab, self.nActId, bTabReddot or self.bIsFirst)
end
function MiningGameData:HasFinishQuest(...)
    local bHasFinish=false
    for _, v in pairs(self.tbQuestDataList) do
        if v.nStatus==AllEnum.ActQuestStatus.Complete then
            bHasFinish=true
            break
        end
    end
    return bHasFinish
end
function MiningGameData:QuestServer2Client(nStatus)
    if nStatus==0 then
        return AllEnum.ActQuestStatus.UnComplete
    elseif nStatus==1 then
        return AllEnum.ActQuestStatus.Complete
    else 
        return AllEnum.ActQuestStatus.Received
    end
end
-------------Quest 

-------------Dictionary
function MiningGameData:InitCurDicData()
    local function GetRewardsByGroupId(lineData)
        if lineData.ActivityId==self.nActId then
            table.insert( self.tbCurDicGroupId, lineData.Id)
        end
    end
    ForEachTableLine(DataTable.MiningTreasure,GetRewardsByGroupId)
end

--获取当前的宝藏组内所有宝藏配置数据Id
function MiningGameData:GetDicGroupId()
    return self.tbCurDicGroupId
end
 
-------------Dictionary
-------------Avg
function MiningGameData:InitStoryData(readStoryList)
    local function GetRewardsByGroupId(lineData)
        if lineData.ActivityId==self.nActId  then
            table.insert( self.tbCurStoryListData, {nId=lineData.Id,config=lineData})
            local function isRead(id)
                for _,v in ipairs(readStoryList) do
                    if v==id then
                        return true
                    end
                end
                return false
            end
            self.tbCurStoryGroupData[lineData.Id]={nId=lineData.Id,bIsRead=isRead(lineData.Id),self.nCurLevel<lineData.UnlockLayer}
        end
    end
    ForEachTableLine(DataTable.MiningStory,GetRewardsByGroupId)
    table.sort(self.tbCurStoryListData,function (a, b)
        return a.config.UnlockLayer<b.config.UnlockLayer
    end)
end
function MiningGameData:GetGroupStoryData()
    return self.tbCurStoryGroupData
end
function MiningGameData:GetStoryConfigIdList()
    return self.tbCurStoryListData
end
function MiningGameData:UpdateStoryLockState(...)
    for k, v in pairs(self.tbCurStoryGroupData) do
        if v.bIsLock then
            local config=DataTable.GetData("MiningStory",v.id)
            if self.nCurLevel>=config.UnlockLayer then
                v.bIsLock=false
            end
        end
    end
end
function MiningGameData:ChangeStoryState(storyId)
    if self.tbCurStoryGroupData[storyId]~=nil then
        self.tbCurStoryGroupData[storyId].bIsRead=true
    end
end

-------------Avg
-------------Sup

function MiningGameData:GetSupDataList()
    return self.tbSupList
end
-------------Sup
-------------Cell
function MiningGameData:GetCellData()
    return self.tbGridDataList
end
-------------Cell

--入口
---@param actId any
---@param msgData any
function MiningGameData:RefreshMiningGameActData(actId,msgData)
    self:Init()

    self.nActId=actId
    self.nCurLevel=msgData.Layer --关注一下服务器发来的是从0开始的还是从1开始的
    self.tbConfig= ConfigTable.GetData("MiningControl", self.nActId) 
    self.nAxeId=self.tbConfig.DigConsumeItemId

    local sKey=tostring(self.nActId).."IsFirst"
    self.bIsFirst=LocalData.GetPlayerLocalData(sKey)
    if self.bIsFirst == nil then
        self.bIsFirst=true
    end
    
    self:InitCurDicData()
    self.nScore=msgData.Score
    --self:CacheAllQuestData(msgData.Quests)
    --self:InitStoryData(msgData.StoryRewardIds)
end
function MiningGameData:GetIsFirstIn()
    return self.bIsFirst
end
function MiningGameData:SetIsFirstIn()
    self.bIsFirst=false
    local sKey=tostring(self.nActId).."IsFirst"
    LocalData.SetPlayerLocalData(sKey,self.bIsFirst)
end
function MiningGameData:GetLevel(...)
    return self.nCurLevel
end
function MiningGameData:GetCurLevelRewardData()
    return self.tbCurReward
end
function MiningGameData:GetCanGoNext(...)
    return self.bCanGoNext
end
function MiningGameData:GetMiningCfg(...)
    if not  self.tbConfig then
        self.tbConfig=ConfigTable.GetData("MiningControl", self.nActId) 
    end
    return self.tbConfig
end
function MiningGameData:GetScore()
    return self.nScore
end
function MiningGameData:AddScore(addValue)
    self.nScore=self.nScore+addValue
    EventManager.Hit("MiningGameUpdateScore",self.nScore)
end
function MiningGameData:ResponseLevelData(msgData,callback)
    local layer=msgData.Layer
    self.nCurLevel=layer.Layer
    --self.bCanGoNext=layer.FindKey
    self.nMapId= layer.Map.Id

    --格子数据
    self.tbGridDataList={}
    for _, v in pairs(layer.Map.Grids) do
        local cellData={
            nId=v.Id,
            nIndex=v.PosIndex+1,
            nStatus=GameEnum.miningGridType[v.GridType],
            bMark=v.Marked
        }
        table.insert(self.tbGridDataList, v.PosIndex+1,cellData )
    end

    self.tbCurlevelEnterChange=msgData.MiningChangeInfo   

    --宝藏数据
    self.tbCurReward={}
    for _, v in pairs(layer.Map.Treasures) do
        local tbPosIndex={}
        for _, n in pairs(v.PosIndex) do
            table.insert( tbPosIndex,n+1 )
        end
        local rewardData={
            nId=v.Id,
            bIsGet=v.Received,
            tbPosIndex=tbPosIndex,
        }
        table.insert( self.tbCurReward,rewardData )
    end

    self.tbSupList={}
    for _, v in pairs(layer.Supports) do
        table.insert( self.tbSupList, {nId=v.Id} )    
    end

    --self:UpdateStoryLockState()
    
    EventManager.Hit("MiningUpdateLevel")
    if callback~=nil then
        callback()
    end
end
function MiningGameData:DoEnterResult()
    self:DoResult(self.tbCurlevelEnterChange)
end
function MiningGameData:DoResult(changeInfo)
    if changeInfo==nil then
        return 
    end
    -- self.bCanGoNext=self.bCanGoNext or changeInfo.FindKey
    -- EventManager.Hit("UpdateGoNext")
    local tbSkillData={}
    for k, v in pairs(changeInfo.Processes) do
        local tbUpdateGrid={}  
        --先更新Data的格子数据
        for _, m in pairs(v.EffectedGrids) do
            self.tbGridDataList[m.PosIndex+1].nStatus=GameEnum.miningGridType[m.GridType]
            self.tbGridDataList[m.PosIndex+1].bMark=m.Marked
            table.insert( tbUpdateGrid,{nIndex=m.PosIndex+1,nStatus=GameEnum.miningGridType[m.GridType],bMark=m.Marked} )
        end
        --把每次影响格子记录起来给界面去分批显示
        local skillData={
            nEffectType=v.EffectType,
            tbUpdateGrid=tbUpdateGrid,
        }
        table.insert( tbSkillData,skillData)
    end
    --宝藏的数据更新
    for k, v in pairs(changeInfo.ReceivedTreasures) do
        self:UpdateReward(v)
    end
    self:UpdateAxe()
    self:AddScore(changeInfo.Score)
    EventManager.Hit("MiningKnockResult",tbSkillData)
end
---@param nId any
---获得指定Id宝藏
function MiningGameData:UpdateReward(nId)
    for key, value in pairs(self.tbCurReward) do
        if nId==value.nId then
            value.bIsGet=true 
        end
    end
    EventManager.Hit("MiningUpdateReward",nId)
end
function MiningGameData:GetAxeId()
    return self.nAxeId
end
function MiningGameData:GetAxeCount(...)
    return PlayerData.Item:GetItemCountByID(self.nAxeId)
end

function MiningGameData:UpdateAxe(...)
    EventManager.Hit("MiningAxeUpdate",PlayerData.Item:GetItemCountByID(self.nAxeId))
end
function MiningGameData:GetPassAllLevelResult()
    local nMaxLevel=self.tbConfig.ConfigMaxLayer 
    if nMaxLevel> self.nCurLevel then
        return false
    end
    for _, data in pairs(self.tbCurReward) do
        if not data .bIsGet then
            return false
        end       
    end
    return true
end


---@param msgData any
---每日发放镐子的计算
function MiningGameData:On_DailyReward_Update(msgData)
    local tbItemList= PlayerData.Item:ProcessRewardChangeInfo(msgData)
    for _,v in pairs(tbItemList) do
        if v.nId==self.nAxeId then
            self.nAddAxeCount_Daliy=v.nCount
            break
        end
    end
end
---@param msgData any
---中途参加活动的镐子补发
function MiningGameData:On_SupplementReward_Update(msgData)
    local tbItemList= PlayerData.Item:ProcessRewardChangeInfo(msgData)
    for _,v in pairs(tbItemList) do
        if v.nId==self.nAxeId then
            self.nAddAxeCount_LongTime=v.nCount
            break
        end
    end
end
function MiningGameData:GetAddAxeCount()
    return self.nAddAxeCount_Daliy+self.nAddAxeCount_LongTime
end
function MiningGameData:ResetAddAxeCount()
    self.nAddAxeCount_Daliy=0
    self.nAddAxeCount_LongTime=0
end

function MiningGameData:OnEvent_Mining_UpdateLevelData(mapMsgData)
    self:ResponseLevelData(mapMsgData)
end
function MiningGameData:OnEvent_Mining_UpdateDigResult(mapMsgData)
    self:DoResult(mapMsgData.MiningChangeInfo)
end
---请求
------@param nStatus 0是请求当前层数据，1是请求下一层的数据
function MiningGameData:RequestLevelData(nStatus,callback)
    if nStatus==0 then
        --请求当前层
        local callbackFunc=function (_,msgData)
            self:ResponseLevelData(msgData,callback)
        end
        HttpNetHandler.SendMsg(NetMsgId.Id.activity_mining_apply_req,{ActivityId=self.nActId},nil,callbackFunc)
    elseif nStatus==1 then
        --请求下一层 下一层不需要callback
        local callbackFunc=function (_,msgData)
            self:ResponseLevelData(msgData)
        end
        HttpNetHandler.SendMsg(NetMsgId.Id.activity_mining_move_to_next_layer_req,{ActivityId=self.nActId},nil,callbackFunc)
    end
end
function MiningGameData:RequestKnockCell(nId)
    local nAxeCount=PlayerData.Item:GetItemCountByID(self.nAxeId)
    if nAxeCount <=0 then
        return
    end
    -- local callback=function (_,magData)
    --     self:DoResult(magData.MiningChangeInfo)
    -- end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_mining_dig_req,{ActivityId=self.nActId,GridId=nId},nil,nil)
end
function MiningGameData:RequestFinishAvg(storyId,callback)
    local function msgCallback(_, mapMsgData)
        self:ChangeStoryState(storyId)
        EventManager.Hit(EventId.ClosePanel, PanelId.PureAvgStory)
        if callback ~= nil then
            callback(mapMsgData)
        end
        EventManager.Hit("MiningStoryFinish")
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_mining_story_reward_receive_req, { ActivityId=self.nActId,StoryId = storyId }, nil, msgCallback)
end
--领取任务奖励 nQuestId = 0 表示一键领取)
function MiningGameData:SendQuestReceive(nQuestId)
    local callback=function (_,msgData)
        UTILS.OpenReceiveByChangeInfo(msgData.ChangeInfo, nil)
        if nQuestId==0 then
            for _,v in pairs( self.tbQuestDataList) do
                if v.nStatus==AllEnum.ActQuestStatus.Complete then
                    v.nStatus=AllEnum.ActQuestStatus.Received
                end
            end
        else
            local questData=self:GetQuestData(nQuestId)
            if questData then
                questData.nStatus=AllEnum.ActQuestStatus.Received
            end
        end
        EventManager.Hit("MiningQuestUpdate")
        self:RefreshQuestReddot()
    end

    HttpNetHandler.SendMsg(NetMsgId.Id.activity_mining_quest_reward_receive_req,
    {ActivityId=self.nActId,QuestId=nQuestId},nil,callback)
end
return MiningGameData