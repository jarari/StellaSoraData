local PlayerVoiceData = class("PlayerVoiceData")
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local TimerManager = require "GameCore.Timer.TimerManager"
local Actor2DManager = require "Game.Actor2D.Actor2DManager"
local ClientManager = CS.ClientManager.Instance
local LocalData = require "GameCore.Data.LocalData"

local TN = AllEnum.Actor2DType.Normal
local TF = AllEnum.Actor2DType.FullScreen

local board_click_time = ConfigTable.GetConfigNumber("HFCtimer")
local board_click_max_count = ConfigTable.GetConfigNumber("HFCcounter")
local board_click_free_time = ConfigTable.GetConfigNumber("Hangtimer")

local npc_board_click_time = ConfigTable.GetConfigNumber("NpcHFCtimer")
local npc_board_click_max_count = ConfigTable.GetConfigNumber("NpcHFCcounter")
local npc_board_click_free_time = ConfigTable.GetConfigNumber("NpcHangtimer")


local board_free_trigger_none = 0
local board_free_trigger_hang = 1
local board_free_trigger_ex_hang = 2

local charFavorLevelClickVoice = {
    [1] = {nLevel = 10, sClickVoiceKey = "affchat1"},
    [2] = {nLevel = 15, sClickVoiceKey = "affchat2"},
    [3] = {nLevel = 20, sClickVoiceKey = "affchat3"},
    [4] = {nLevel = 25, sClickVoiceKey = "affchat4"}, 
    [5] = {nLevel = 30, sClickVoiceKey = "affchat5"},
}

local charFavorLevelUnlockVoice = {
    {nLevel = 10, sUnlockVoiceKey = "afflv1"},
    {nLevel = 15, sUnlockVoiceKey = "afflv2"},
    {nLevel = 25, sUnlockVoiceKey = "afflv3"},
    {nLevel = 30, sUnlockVoiceKey = "afflv4"},
}

local voiceRandomSkinLimit = {
    "posterchat"
}

function PlayerVoiceData:Init()
    self.bFirstEnterGame = true  --初次登录
    self.bNpc = false
    self.nNpcId = 0
    self.bStartBoardClickTimer = false
    self.nContinuousClickCount = 0  --看板连续点击次数
    self.nBoardClickTime = 0  --看板连点触发时间
    self.nBoardFreeTime = 0  --空闲时间
    self.nVoiceDuration = 0 --当前播放语音持续时长
    self.nCurVoiceId = nil
    self.nTriggerFreeVoiceState = board_free_trigger_none  --是否触发过长时间放置语音（触发过一次后不再触发）
    self.boardClickTimer = nil  --连点计时器
    self.boardFreeTimer = nil  --空闲计时器
    self.boardPlayTimer = nil  --语音播放计时器
    
    --特定日期触发的语音
    self.tbHolidayVoice = {}   
    self.tbHolidayVoiceKey = {}

    EventManager.Add(EventId.UIOperate, self, self.OnEvent_UIOperate)
    EventManager.Add(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration)
    EventManager.Add(EventId.IsNewDay, self, self.OnEvent_NewDay)
    self:InitConfig()
end

function PlayerVoiceData:UnInit()
    EventManager.Remove(EventId.UIOperate, self, self.OnEvent_UIOperate)
    EventManager.Remove(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration)
    EventManager.Remove(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

function PlayerVoiceData:InitConfig()
    local function foreachVoiceControl(line)
        if line.dateTrigger and line.date ~= "" then
            local tbParam = string.split(line.date, ".")
            local year, month, day = 0
            if #tbParam == 3 then
                year = tonumber(tbParam[1])
                month = tonumber(tbParam[2])
                day = tonumber(tbParam[3])
            else
                month = tonumber(tbParam[1])
                day = tonumber(tbParam[2])
            end
            table.insert(self.tbHolidayVoice, {voiceKey = line.Id, date = { year = year, month = month, day = day}})
        end
    end
    ForEachTableLine(ConfigTable.Get("CharacterVoiceControl"), foreachVoiceControl)
end

--播放角色语音
function PlayerVoiceData:PlayCharVoice(voiceKey, nCharId, nSkinId, bNpc)
    if nil ~= voiceKey then
        local tbVoiceKey = {}
        if type(voiceKey) ~= "table" then
            table.insert(tbVoiceKey, voiceKey)
        else
            tbVoiceKey = voiceKey
        end
        nSkinId = nSkinId or 0
        -- nCharId == 0 一般是战斗内需要在C#里随机选择队伍角色播放语音
        if nCharId ~= 0 then
            if nSkinId == 0 then
                if bNpc then
                    local mapNpcCfg = ConfigTable.GetData("BoardNPC", nCharId)
                    if mapNpcCfg ~= nil then
                        nSkinId = mapNpcCfg.DefaultSkinId
                    end
                else
                    nSkinId = PlayerData.Char:GetCharSkinId(nCharId)
                end
            end
        else
            nSkinId = 0
        end
        
        --local nVoiceId = WwiseAudioMgr:WwiseVoice_Play(nCharId, tbVoiceKey, nil, nSkinId, voiceRandomSkinLimit)
        local nVoiceId = WwiseAudioMgr:WwiseVoice_Play(nCharId, tbVoiceKey, nil, nSkinId)
        if nil ~= nVoiceId and nVoiceId ~= 0 then
            self.nCurVoiceId = nVoiceId
        end
        return nVoiceId
    end
end

function PlayerVoiceData:StopCharVoice()
    if nil ~= self.nCurVoiceId and self.nCurVoiceId ~= 0 then
        local mapVoDirectoryData = ConfigTable.GetData("VoDirectory", self.nCurVoiceId)
        if mapVoDirectoryData ~= nil then
            local tbCfg = ConfigTable.GetData("CharacterVoiceControl", mapVoDirectoryData.votype)
            if nil ~= tbCfg then
                WwiseAudioMgr:WwiseVoice_Stop(tbCfg.voPlayer - 1)
            end
        end
        self.nCurVoiceId = 0
    end
end

function PlayerVoiceData:CheckHoliday()
    self.tbHolidayVoiceKey = {}
    local nServerTimeStamp = ClientManager.serverTimeStamp
    local nYear = tonumber(os.date("%Y", nServerTimeStamp))
    local nMonth = tonumber(os.date("%m", nServerTimeStamp))
    local nDay = tonumber(os.date("%d", nServerTimeStamp))
    for _, v in ipairs(self.tbHolidayVoice) do
        if v.date.year ~= 0 then
            if v.date.year == nYear and v.date.month == nMonth and v.date.day == nDay then
                table.insert(self.tbHolidayVoiceKey, v.voiceKey)
            end
        else
            if v.date.month == nMonth and v.date.day == nDay then
                table.insert(self.tbHolidayVoiceKey, v.voiceKey)
            end
        end
    end
end

function PlayerVoiceData:CheckBirthday()
    local nServerTimeStamp = ClientManager.serverTimeStamp
    local nYear = tonumber(os.date("%Y", nServerTimeStamp))
    local nMonth = tonumber(os.date("%m", nServerTimeStamp))
    local nDay = tonumber(os.date("%d", nServerTimeStamp))
    local curBoardCharId = PlayerData.Board:GetCurBoardCharID()
    local mapCharDesc = ConfigTable.GetData("CharacterDes", curBoardCharId)
    if nil ~= mapCharDesc and mapCharDesc.Birthday ~= "" then
        local tbParam = string.split(mapCharDesc.Birthday, ".")
        if #tbParam == 3 then
            if nYear == tonumber(tbParam[1]) and nMonth == tonumber(tbParam[2]) and nDay == tonumber(tbParam[3]) then
                return true
            end
        else
            if nMonth == tonumber(tbParam[1]) and nDay == tonumber(tbParam[2]) then
                return true
            end
        end
    end
    return false
end

-------------------------------- 看板语音相关 ---------------------
local function getBoardClickTime(bNpc)
    return bNpc and npc_board_click_time or board_click_time
end

local function getBoardClickMaxCount(bNpc)
    return bNpc and npc_board_click_max_count or board_click_max_count
end

local function getBoardClickFreeTime(bNpc)
    return bNpc and npc_board_click_free_time or board_click_free_time
end

function PlayerVoiceData:StartBoardFreeTimer(nNpcId)
    if nNpcId ~= nil or self.bNpc then
        self.bNpc = true
        if nNpcId ~= nil then
            self.nNpcId = nNpcId or 0
        end
    else
        self.bNpc = false
        self.nNpcId = 0
    end
    self.bStartBoardClickTimer = true
    if nil == self.boardFreeTimer and self.nTriggerFreeVoiceState ~= board_free_trigger_ex_hang then
        self.boardFreeTimer = TimerManager.Add(0, 0.1, self, self.CheckBoardFree, true, true, false)
    end
end

function PlayerVoiceData:CheckBoardFree()
    self.nBoardFreeTime = self.nBoardFreeTime + 0.1
    if self.nBoardFreeTime >= getBoardClickFreeTime(self.bNpc) then
        self:ResetBoardFreeTimer()
        if self.nTriggerFreeVoiceState == board_free_trigger_none then
            self.nTriggerFreeVoiceState = board_free_trigger_hang
            self:PlayBoardFreeVoice()
        elseif self.nTriggerFreeVoiceState == board_free_trigger_hang then
            self.nTriggerFreeVoiceState = board_free_trigger_ex_hang
            self:PlayBoardFreeLongTimeVoice()
        end
    end
end

function PlayerVoiceData:ResetBoardFreeTimer()
    if nil ~= self.boardFreeTimer then
        TimerManager.Remove(self.boardFreeTimer, false)
    end
    self.boardFreeTimer = nil
    self.nBoardFreeTime = 0
end

function PlayerVoiceData:StartBoardPlayTimer()
    if nil == self.boardPlayTimer then
        self.boardPlayTimer = TimerManager.Add(1, self.nVoiceDuration, nil, function()
            self:StartBoardFreeTimer()
        end, true, true, false)
    end
end

function PlayerVoiceData:ResetBoardPlayTimer()
    if nil ~= self.boardPlayTimer then
        TimerManager.Remove(self.boardPlayTimer, false)
    end
    self.boardPlayTimer = nil
    self.nVoiceDuration = 0
end

--选择看板娘
function PlayerVoiceData:PlayBoardSelectVoice(nCharId)
    local sVoiceKey = "greet"
    self:PlayCharVoice(sVoiceKey, nCharId)
end

--返回主界面播放语音（首次登录根据当前所在的时间段播放语音）
function PlayerVoiceData:PlayMainViewOpenVoice()
    local curBoardCharId = PlayerData.Board:GetCurBoardCharID()
    self:CheckHoliday()
    local bPlayFirst = false
    local tbVoiceKey = {}
    if nil ~= curBoardCharId then
        local nServerTimeStamp = ClientManager.serverTimeStamp
        local nLastPlayTime = LocalData.GetPlayerLocalData("BoardVoiceTime") or 0
        local nLastDay = tonumber(os.date("%d", tonumber(nLastPlayTime)))
        local nDay = tonumber(os.date("%d", nServerTimeStamp))
        local nLastHour = tonumber(os.date("%H", tonumber(nLastPlayTime)))
        local nHour = tonumber(os.date("%H", nServerTimeStamp))
        local function getIndex(nHour)
            if nHour >= 6 and nHour < 12 then
                return 1, "greetmorn"
            elseif nHour >= 12 and nHour < 18 then
                return 2, "greetnoon"
            else
                return 3, "greetnight"
            end
        end
        local nIndex, sKey = getIndex(nHour)
        local nLastIndex = getIndex(nLastHour)
        
        if true == self.bFirstEnterGame then
            bPlayFirst = nIndex ~= getIndex(nLastHour)
            if nLastDay ~= nDay or (nLastDay == nDay and nIndex ~= nLastIndex) then
                bPlayFirst = true
                LocalData.SetPlayerLocalData("BoardVoiceTime", nServerTimeStamp)
            end
            self.bFirstEnterGame = false
        end
        if bPlayFirst then
            tbVoiceKey = { sKey }
        else
            tbVoiceKey = { sKey, "greet" }
        end
        if #self.tbHolidayVoiceKey > 0 then
            for _, v in ipairs(self.tbHolidayVoiceKey) do
                table.insert(tbVoiceKey, v)
            end
        end
        if self:CheckBirthday() then
            table.insert(tbVoiceKey, "birth")
        end
        self:PlayCharVoice(tbVoiceKey, curBoardCharId)
    end
end

function PlayerVoiceData:CheckContinuousClick()
    self.nBoardClickTime = self.nBoardClickTime + 0.1
    local nTime = getBoardClickTime(self.bNpc)
    if self.nBoardClickTime > nTime then
        self:ResetBoardClickTimer()
    end
end

function PlayerVoiceData:ResetBoardClickTimer()
    if nil ~= self.boardClickTimer then
        TimerManager.Remove(self.boardClickTimer, false)
    end
    self.boardClickTimer = nil
    self.nBoardClickTime = 0
    self.nContinuousClickCount = 0
end

--点击互动（需筛选池子）
function PlayerVoiceData:PlayBoardClickVoice()
    self.bNpc = false
    self.nNpcId = 0
    if 0 == self.nBoardClickTime and nil == self.boardClickTimer then
        self.boardClickTimer = TimerManager.Add(0, 0.1, self, self.CheckContinuousClick, true , true, false)
    end
    self.nContinuousClickCount = self.nContinuousClickCount + 1

    local curBoardCharId = PlayerData.Board:GetCurBoardCharID()
    if nil ~= curBoardCharId then
        local tbVoiceKey = {}
        if self.nContinuousClickCount > getBoardClickMaxCount(self.bNpc) then
            table.insert(tbVoiceKey, "hfc")
            self:ResetBoardClickTimer()
        else
            table.insert(tbVoiceKey, "posterchat")
            local curActor2DType = Actor2DManager.GetCurrentActor2DType()
            if curActor2DType == TN then
                table.insert(tbVoiceKey, "standee")
            elseif curActor2DType == TF then
                table.insert(tbVoiceKey, "fullscreen")
            end

            local mapData = PlayerData.Char:GetCharAffinityData(curBoardCharId)
            if nil ~= mapData then
                local nLevel = mapData.Level
                for _, v in ipairs(charFavorLevelClickVoice) do
                    if nLevel >= v.nLevel then
                        table.insert(tbVoiceKey, v.sClickVoiceKey)
                    end
                end
            end
        end
        if #self.tbHolidayVoiceKey > 0 then
            for _, v in ipairs(self.tbHolidayVoiceKey) do
                table.insert(tbVoiceKey, v)
            end
        end
        if self:CheckBirthday() then
            table.insert(tbVoiceKey, "birth")
        end

        local nVoiceId = self:PlayCharVoice(tbVoiceKey, curBoardCharId)
        if nil ~= nVoiceId and 0 ~= nVoiceId then
            --任务事件埋点(传任务id，后续新增任务需补充)
            PlayerData.Quest:SendClientEvent(GameEnum.questCompleteCondClient.InteractL2D)
        end
    end
end

--点击互动(NPC)
function PlayerVoiceData:PlayBoardNPCClickVoice(nNpcId)
    self.bNpc = true
    self.nNpcId = nNpcId
    if 0 == self.nBoardClickTime and nil == self.boardClickTimer then
        self.boardClickTimer = TimerManager.Add(0, 0.1, self, self.CheckContinuousClick, true , true, false)
    end
    self.nContinuousClickCount = self.nContinuousClickCount + 1

    local curBoardCharId = nNpcId
    if nil ~= curBoardCharId then
        local tbVoiceKey = {}
        if self.nContinuousClickCount > getBoardClickMaxCount(self.bNpc) then
            table.insert(tbVoiceKey, "hfc_npc")
            self:ResetBoardClickTimer()
        else
            table.insert(tbVoiceKey, "posterchat_npc")
        end
        self:PlayCharVoice(tbVoiceKey, curBoardCharId, nil, true)
    end
end

--放置
function PlayerVoiceData:PlayBoardFreeVoice()
    local curBoardCharId, sVoiceKey
    if not self.bNpc then
        curBoardCharId = PlayerData.Board:GetCurBoardCharID()
        sVoiceKey = "hang"
    else
        curBoardCharId = self.nNpcId
        sVoiceKey = "hang_npc"
    end
    if nil ~= curBoardCharId then
        self:PlayCharVoice(sVoiceKey, curBoardCharId)
    end
end

--长时间放置
function PlayerVoiceData:PlayBoardFreeLongTimeVoice()
    local curBoardCharId, sVoiceKey
    if not self.bNpc then
        curBoardCharId = PlayerData.Board:GetCurBoardCharID()
        sVoiceKey = "exhang"
    else
        curBoardCharId = self.nNpcId
        sVoiceKey = "exhang_npc"
    end
    if nil ~= curBoardCharId then
        self:PlayCharVoice(sVoiceKey, curBoardCharId)
    end
end

--------------------------------------- 其他语音 ---------------------------------------
function PlayerVoiceData:PlayBattleResultVoice(tbChar, bWin)
    local nIndex = math.random(1, #tbChar)
    local nCharId = tbChar[nIndex]
    local sVoiceKey = bWin and "win" or "lose"
    self:PlayCharVoice(sVoiceKey, nCharId)
end

function PlayerVoiceData:CheckPlayGiftVoice(nLevel, nLastLevel)
    local bPlay = true
    if nLastLevel ~= nLevel then
        for i = 1, #charFavorLevelUnlockVoice do
            if charFavorLevelUnlockVoice[i] ~= nil then
                if nLastLevel < charFavorLevelUnlockVoice[i].nLevel and nLevel >= charFavorLevelUnlockVoice[i].nLevel then
                    bPlay = false
                    break
                end
            end
        end
    end
    return bPlay
end

function PlayerVoiceData:PlayCharFavourUpVoice(nCharId, nLastFavourLevel)
    local nVoiceId
    local mapData = PlayerData.Char:GetCharAffinityData(nCharId)
    if nil ~= mapData then
        local nLevel = mapData.Level
        local sVoiceKey = ""
        for i = 1, #charFavorLevelUnlockVoice do
            if charFavorLevelUnlockVoice[i] ~= nil then
                if charFavorLevelUnlockVoice[i].nLevel > nLastFavourLevel and charFavorLevelUnlockVoice[i].nLevel <= nLevel then
                    sVoiceKey = charFavorLevelUnlockVoice[i].sUnlockVoiceKey
                end 
            end
        end
        if sVoiceKey ~= "" then
            nVoiceId = self:PlayCharVoice(sVoiceKey, nCharId)
        end
    end
    return nVoiceId
end


function PlayerVoiceData:ClearTimer()
    self:ResetBoardPlayTimer()
    self:ResetBoardFreeTimer()
    self:ResetBoardClickTimer()
    self.bStartBoardClickTimer = false
    self.bNpc = false
    self.nNpcId = 0
end

function PlayerVoiceData:OnEvent_UIOperate()
    self.nBoardFreeTime = 0
    self.nTriggerFreeVoiceState = board_free_trigger_none
    if self.bStartBoardClickTimer and self.nVoiceDuration == 0 then
        self:StartBoardFreeTimer()
    end
end

function PlayerVoiceData:OnEvent_AvgVoiceDuration(nDuration)
    self:ResetBoardPlayTimer()
    self.nVoiceDuration = nDuration
    if self.bStartBoardClickTimer then
        if self.nTriggerFreeVoiceState ~= board_free_trigger_ex_hang then
            self:ResetBoardFreeTimer()
            self:StartBoardPlayTimer()
        end
    end
end

function PlayerVoiceData:OnEvent_NewDay()
    self:CheckHoliday()
end

return PlayerVoiceData