--玩家基础数据

------------------------------ local ------------------------------



local PlayerBaseData = class("PlayerBaseData")
local TimerManager = require "GameCore.Timer.TimerManager"
local AvgManager = require "GameCore.Module.AvgManager"

local TimerScaleType = require "GameCore.Timer.TimerScaleType"
local ModuleManager = require "GameCore.Module.ModuleManager"
local localdata = require("GameCore.Data.LocalData")
local RapidJson = require "rapidjson"

-----日服PC埋点----
local PcEventUpWorldLv = {
    [5] = "pc_level_5",
    [10] = "pc_level_10",
    [15] = "pc_level_15",
    [20] = "pc_level_20",
    [25] = "pc_level_25",
    [30] = "pc_level_30",
    [35] = "pc_level_35",
    [40] = "pc_level_40",
    [45] = "pc_level_45",
    [50] = "pc_level_50",
    [55] = "pc_level_55",
    [60] = "pc_level_60",
}
-----日服PC埋点----
-------------------------------------------------------------------

------------------------------ public -----------------------------
function PlayerBaseData:Init()
    self._nPlayerId = nil       -- 玩家唯一Id
    self._sPlayerNickName = nil -- 玩家昵称
    self._bMale = false         -- 玩家建号时选择的主角是否为男性
    self._nNewbie = nil         -- 新手引导进度
    self._nCreateTime = nil     -- 创建玩家数据的时间戳
    self._nHeadIconId = nil     -- 玩家头像id
    self._nHashtag = nil        -- 玩家#识别码(这里没有#，显示的时候要自己拼#)
    self._sSignature = nil      -- 签名
    self._nShowSkinId = nil     -- 展示角色皮肤
    self._nTitlePrefix = nil    -- 前称号
    self._nTitleSuffix = nil    -- 后称号
    self._tbTitle = nil         -- 所有称号
    self._tbCoreTeam = nil      -- 核心队伍
    self._nWorldClass = 0       -- 当前世界等级
    self._nWorldExp = 0         -- 当前经验
    self._nWorldStage = 0       -- 当前突破阶段
    self._nCurWorldStageIndex = 0    -- 当前世界等级阶段
    self._nCurEnergy = 0        -- 当前体力值
    self._nCurEnergyBattery = 0 -- 当前体力储藏
    self._nEnergyTime = 0       -- 体力恢复时间
    self._nEnergyBatteryTime = 0-- 体力储藏恢复时间
    self._nBuyEnergyCount = 0   -- 今日已购买体力次数
    self._nBuyEnergyLimit = 0   -- 每日购买体力次数上限
    self._mapEnergyTimer = nil  -- 体力恢复计时器
    self._nOldWorldClass = 0    -- 世界等级变化前的世界等级
    self._nOldWorldExp = 0      -- 世界等级变化前的经验
    self._tbHonorTitle = nil    -- 玩家荣誉称号
    self._tbHonorTitleList = nil-- 玩家已经获得的荣誉称号
    self._nSendGiftCnt = 0      -- 当天已赠送礼物次数
    
    self._bWorldClassChange = false  -- 世界等级变化
    self.bNewDay = false
    self.bNeedHotfix=false
    self.bShowNewDayWind = false
    self.bInLoading = false
    self:ProcessTableData()

    EventManager.Add(EventId.TransAnimInClear, self, self.OnEvent_TransAnimInClear)
    EventManager.Add(EventId.TransAnimOutClear, self, self.OnEvent_TransAnimOutClear)
    EventManager.Add(EventId.UserEvent_CreateRole, self, self.Event_CreateRole)
    EventManager.Add("Prologue_EventUpload",self,self.PrologueEventUpload)
end

function PlayerBaseData:UnInit()
    if self.NextRefreshTimer ~= nil then
        self.NextRefreshTimer:Cancel()
        self.NextRefreshTimer = nil
    end
    if self._mapEnergyTimer ~= nil then
        self._mapEnergyTimer:Cancel(nil)
        self._mapEnergyTimer = nil
    end
end

function PlayerBaseData:ProcessTableData()
    -- PlayerHead表
    local _PlayerHead = {}
    local tbPlayerHead = {}

    local function func_ForEach_Head(mapLineData)
        tbPlayerHead = {
            Id = mapLineData.Id,
            Icon = mapLineData.Icon,
        }
        table.insert(_PlayerHead, tbPlayerHead)
    end
    ForEachTableLine(DataTable.PlayerHead, func_ForEach_Head)
    table.sort(_PlayerHead, function(a, b) return a.Id < b.Id end)
    CacheTable.Set("_PlayerHead", _PlayerHead)

    self._nMaxWorldClass = 0
    local function func_ForEach_WorldClass(mapLineData)
        self._nMaxWorldClass = self._nMaxWorldClass + 1
    end
    ForEachTableLine(DataTable.WorldClass, func_ForEach_WorldClass)
    
    local _EnergyBuy = {}
    local function func_ForEach_EnergyBuy(mapLineData)
        table.insert(_EnergyBuy, mapLineData)
    end
    ForEachTableLine(DataTable.EnergyBuy, func_ForEach_EnergyBuy)
    table.sort(_EnergyBuy, function(a, b) return a.Id < b.Id end)
    self._nBuyEnergyLimit = _EnergyBuy[#_EnergyBuy].Id
    CacheTable.Set("_EnergyBuy", _EnergyBuy)

    local _tbDemonAdvance = {}
    local function foreachTable(mapData)
        local levelMin = mapData.LevelRange[1]
        local levelMax = mapData.LevelRange[2]
        local nType = AllEnum.WorldClassType.LevelUp
        table.insert(_tbDemonAdvance, {nType = nType, nId = mapData.Id, nMinLevel = levelMin, nMaxLevel = levelMax})
        if mapData.AdvanceQuestGroup ~= 0 then
            local nType = AllEnum.WorldClassType.Advance
            table.insert(_tbDemonAdvance, {nType = nType, nId = mapData.Id, nMinLevel = levelMax, nMaxLevel = levelMax})
        end
    end
    ForEachTableLine(ConfigTable.Get("DemonAdvance"), foreachTable)
    CacheTable.Set("_DemonAdvance", _tbDemonAdvance)
end

function PlayerBaseData:CacheAccInfo(mapData)
    if mapData ~= nil then
        self._nPlayerId = mapData.Id
        self._sPlayerNickName = mapData.NickName
        self._nNewbie = mapData.Newbie
        self._nCreateTime = mapData.CreateTime
        self._nHeadIconId = mapData.HeadIcon
        self._nHashtag = mapData.Hashtag
        self._sSignature = mapData.Signature
        self._nShowSkinId = mapData.SkinId
        self._nTitlePrefix = mapData.TitlePrefix
        self._nTitleSuffix = mapData.TitleSuffix
        self._tbCoreTeam = {}
        for i, v in ipairs(mapData.Chars) do
            self._tbCoreTeam[i] = v.CharId
        end
        self._bMale = mapData.Gender == true -- true男 false女
        self._nSendGiftCnt = mapData.SendGiftCnt or 0
        --printLog("当前玩家性别：" .. (self._bMale == true and "男" or "女"))
        PlayerData.Roguelike:GetClientLocalRoguelikeData()
        PlayerData.Guide:SetGuideNewbie(mapData.Newbies)
        CS.AdventureModuleHelper.playerUid = mapData.Id
        CS.InputManager.Instance:LoadBindingOverrides(mapData.Id)

        EventManager.Hit("FinishCacheAccInfo")
    end
end

function PlayerBaseData:CacheEnergyInfo(mapData)
    if mapData ~= nil then
        self._nCurEnergy = mapData.Energy.Primary
        self._nCurEnergyBattery = mapData.Energy.Secondary
        local nServerTime = CS.ClientManager.Instance.serverTimeStamp
        self._nEnergyTime = mapData.Energy.IsPrimary == true and mapData.Energy.NextDuration + nServerTime or 0
        self._nEnergyBatteryTime = mapData.Energy.IsPrimary == true and 0 or mapData.Energy.NextDuration + nServerTime
        self._nBuyEnergyCount = mapData.Count
        if self._mapEnergyTimer ~= nil then
            self._mapEnergyTimer:Cancel(nil)
        end
        if mapData.Energy.NextDuration == 0 then
            return
        end
        if mapData.Energy.IsPrimary == false then
            self._mapEnergyBatteryTimer = TimerManager.Add(1, mapData.Energy.NextDuration, self, self["HandleEnergyBatteryTimer"], true, true, false)
        else
            self._mapEnergyTimer = TimerManager.Add(1, mapData.Energy.NextDuration, self, self["HandleEnergyTimer"], true, true, false)
        end
    end
end

function PlayerBaseData:CacheTitleInfo(mapData)
    if not mapData then
        return
    end

    if not self._tbTitle then
        self._tbTitle = {}
    end
    for _, v in pairs(mapData) do
        table.insert(self._tbTitle, v.TitleId)
    end
end

function PlayerBaseData:CacheHonorTitleInfo(mapData)
    if not mapData then
        return
    end

    self._tbHonorTitle = {}
    for _, v in pairs(mapData) do
        table.insert(self._tbHonorTitle, v)
    end
end

function PlayerBaseData:CacheHonorTitleList(mapData)
    if not mapData then
        return
    end

    if not self._tbHonorTitleList then
        self._tbHonorTitleList = {}
    end
    for _, v in pairs(mapData) do
        table.insert(self._tbHonorTitleList, v)
    end
    self:RefreshHonorTitleRedDot()
end

function PlayerBaseData:CacheWorldClassInfo(mapData)
    if mapData ~= nil then
        self._nWorldClass = mapData.Cur
        self._nWorldExp = mapData.LastExp
        self._nWorldStage = mapData.Stage
        self:RefreshCurWorldStageIndex()
    end
end

function PlayerBaseData:CacheSendGiftCount(nCount)
    self._nSendGiftCnt = nCount
end

function PlayerBaseData:RefreshEnergyBuyCount(nCount)
    self._nBuyEnergyCount = nCount
end

function PlayerBaseData:RefreshSendGiftCount(nCount)
    self._nSendGiftCnt = nCount
end



function PlayerBaseData:GetPlayerId()
    return self._nPlayerId
end

function PlayerBaseData:GetPlayerNickName()
    return self._sPlayerNickName or "SaiLa"
end

function PlayerBaseData:SetPlayerNickName(sPlayerName)
    if AVG_EDITOR == true then
        if type(sPlayerName) == "string" and sPlayerName ~= "" then
            self._sPlayerNickName = sPlayerName
        else
            self._sPlayerNickName = nil
        end
    end
end

function PlayerBaseData:GetPlayerHashtag()
    return self._nHashtag
end

function PlayerBaseData:GetPlayerCoreTeam()
    local tbTeam = {}
    for i = 1, 3 do
        if not self._tbCoreTeam[i] then
            tbTeam[i] = 0
        else
            tbTeam[i] = self._tbCoreTeam[i]
        end
    end
    return tbTeam
end

function PlayerBaseData:GetPlayerAllTitle()
    local tbPrefix, tbSuffix = {}, {}
    for _, v in pairs(self._tbTitle) do
        local mapCfg = ConfigTable.GetData("Title", v)
        if mapCfg.TitleType == GameEnum.TitleType.Prefix then
            table.insert(tbPrefix, {nId = v, sDesc = mapCfg.Desc, nSort = mapCfg.Sort})
        else
            table.insert(tbSuffix, {nId = v, sDesc = mapCfg.Desc, nSort = mapCfg.Sort})
        end
    end

    table.sort(tbPrefix, function (a, b) return a.nSort < b.nSort end)
    table.sort(tbSuffix, function (a, b) return a.nSort < b.nSort end)

    return tbPrefix, tbSuffix
end

function PlayerBaseData:GetPlayerTitle()
    return self._nTitlePrefix, self._nTitleSuffix
end

function PlayerBaseData:GetPlayerHonorTitle()
    return self._tbHonorTitle
end

function PlayerBaseData:GetPlayerHonorTitleList()
    return self._tbHonorTitleList
end

function PlayerBaseData:GetPlayerShowSkin()
    return self._nShowSkinId
end

function PlayerBaseData:GetPlayerSignature()
    return self._sSignature == "" and ConfigTable.GetUIText("Friend_DefaultSign") or self._sSignature
end

function PlayerBaseData:GetPlayerSex()
    return self._bMale
end

function PlayerBaseData:SetPlayerSex(bIsMale)
    self._bMale = bIsMale == true
end

function PlayerBaseData:IsDefaultHead(nId)
    if nId == 100101 or nId == 101001 then
        return true
    else
        return false
    end
end

function PlayerBaseData:ChangePlayerHeadId(nId)
    self._nHeadIconId = nId
end

function PlayerBaseData:GetPlayerHeadId()
    return self._nHeadIconId
end

function PlayerBaseData:GetPlayerCreatTime()
    return os.date("%Y.%m.%d", self._nCreateTime)
end

function PlayerBaseData:GetPlayerAvgId()
    -- 由于还没有头像功能，以及玩家性别功能，先暂时写死路径
    local sName = "avg0_1"
    return sName
end

function PlayerBaseData:HandleEnergyTimer()
    if self._nCurEnergy < ConfigTable.GetConfigNumber("EnergyMaxLimit") then
        self._nCurEnergy = self._nCurEnergy + 1
        local nEnergyGain = ConfigTable.GetConfigNumber("EnergyGain") * 60
        self._nEnergyTime = nEnergyGain + CS.ClientManager.Instance.serverTimeStamp
        if self._mapEnergyTimer ~= nil then
            self._mapEnergyTimer:Cancel(nil)
        end
        self._mapEnergyTimer = TimerManager.Add(1, nEnergyGain, self, self["HandleEnergyTimer"], true, true, false)
        EventManager.Hit(EventId.UpdateEnergy)
    else
        self._nEnergyTime = 0
        if self._mapEnergyTimer ~= nil then
            self._mapEnergyTimer:Cancel(nil)
        end
        
        --体力满了，开始恢复体力电池
        self:HandleEnergyBatteryTimer()
    end
end

function PlayerBaseData:HandleEnergyBatteryTimer()
    if self._nCurEnergyBattery < ConfigTable.GetConfigNumber("EnergyBatteryMax") then
        self._nCurEnergyBattery = self._nCurEnergyBattery + 1
        local nEnergyBatteryGain = ConfigTable.GetConfigNumber("EnergyBatteryGain") * 60
        self._nEnergyBatteryTime = nEnergyBatteryGain + CS.ClientManager.Instance.serverTimeStamp
        if self._mapEnergyBatteryTimer ~= nil then
            self._mapEnergyBatteryTimer:Cancel(nil)
        end
        self._mapEnergyBatteryTimer = TimerManager.Add(1, nEnergyBatteryGain, self, self["HandleEnergyBatteryTimer"], true, true, false)
        EventManager.Hit(EventId.UpdateEnergyBattery)
    else
        self._nEnergyBatteryTime = 0
        if self._mapEnergyBatteryTimer ~= nil then
            self._mapEnergyBatteryTimer:Cancel(nil)
        end
    end
end

function PlayerBaseData:ChangeEnergy(mapData)
    if mapData ~= nil then
        if self._mapEnergyTimer ~= nil then
            self._mapEnergyTimer:Cancel(nil)
        end
        if self._mapEnergyBatteryTimer ~= nil then
            self._mapEnergyBatteryTimer:Cancel(nil)
        end
        self._nCurEnergy = mapData[1].Primary
        self._nCurEnergyBattery = mapData[1].Secondary
        local nServerTime = CS.ClientManager.Instance.serverTimeStamp
        if mapData[1].IsPrimary == true then
            self._nEnergyTime = mapData[1].NextDuration + nServerTime
            if mapData[1].NextDuration ~= 0 then
                self._mapEnergyTimer = TimerManager.Add(1, mapData[1].NextDuration, self, self["HandleEnergyTimer"], true, true, false)
            end
        else
            self._nEnergyBatteryTime = mapData[1].NextDuration + nServerTime
            if mapData[1].NextDuration ~= 0 then
                self._mapEnergyBatteryTimer = TimerManager.Add(1, mapData[1].NextDuration, self, self["HandleEnergyBatteryTimer"], true, true, false)
            end
        end
        EventManager.Hit(EventId.UpdateEnergyBattery)
        EventManager.Hit(EventId.UpdateEnergy)
    end
end

function PlayerBaseData:ChangeTitle(mapData)
    if not mapData then
        return
    end

    if not self._tbTitle then
        self._tbTitle = {}
    end
    for _, v in pairs(mapData) do
        table.insert(self._tbTitle, v.TitleId)
        RedDotManager.SetValid(RedDotDefine.Friend_Title_Item, v.TitleId, true)
    end
end

function PlayerBaseData:ChangeHonorTitle(mapData)
    if not mapData then
        return
    end

    if not self._tbHonorTitleList then
        self._tbHonorTitleList = {}
    end
    local newData = {}
    local delData = {}
    for _, v in pairs(mapData) do
        table.insert(self._tbHonorTitleList, v.NewId)
        local honorData = ConfigTable.GetData("Honor", v.NewId)
        if honorData.TabType == GameEnum.honorTabType.Achieve then
            local function foreachHonor(mapData)
                if mapData.TabType == GameEnum.honorTabType.Achieve and mapData.Params[1] == honorData.Params[1] then
                    if mapData.Priotity < honorData.Priotity then
                        table.insert(delData, mapData.Id)
                        RedDotManager.SetValid(RedDotDefine.Friend_Honor_Title_Item, mapData.Id, true)
                    end
                end
            end
            ForEachTableLine(ConfigTable.Get("Honor"), foreachHonor)
        end
        RedDotManager.SetValid(RedDotDefine.Friend_Honor_Title_Item, v.NewId, true)
        table.insert(newData, v.NewId)
    end
    if #newData > 0 or delData > 0 then
        local sJson = localdata.GetPlayerLocalData("HonorTitle")
        local localHonorTilte =  decodeJson(sJson)
        if type(localHonorTilte) == "table" then
            if #newData > 0 then
                for k,v in ipairs(newData) do
                    table.insert(localHonorTilte, v)
                end
            end
            if #delData > 0 then
                for k,v in ipairs(delData) do
                    if table.indexof(localHonorTilte, delData) then
                        table.removebyvalue(localHonorTilte, v)     
                    end
                end
            end
        end
        localdata.SetPlayerLocalData("HonorTitle", RapidJson.encode(localHonorTilte))
    end
end

function PlayerBaseData:ChangeWorldClass(mapData)
    if mapData ~= nil then
        self._nOldWorldClass = self._nWorldClass
        self._nOldWorldExp = self._nWorldExp
        for _, v in ipairs(mapData) do
            self._nWorldClass = self._nWorldClass + v.AddClass
            self._nWorldExp = self._nWorldExp + v.ExpChange
        end
        self:SetWorldClassChange(self._nOldWorldClass ~= self._nWorldClass)
        self:CheckNewFuncUnlockWorldClass(self._nOldWorldClass,self._nWorldClass)
        EventManager.Hit(EventId.UpdateWorldClass)
        if self._nOldWorldClass ~= self._nWorldClass then
            self:RefreshCurWorldStageIndex()
            --刷新红点显示
            self:RefreshWorldClassRedDot()

            for i = self._nOldWorldClass + 1, self._nWorldClass do
                if i == 5 then
                    local tab = {}
                    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
                    NovaAPI.UserEventUpload("authorizationlevel_5",tab)
                elseif i == 10 then
                    local tab = {}
                    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
                    NovaAPI.UserEventUpload("authorizationlevel_10",tab)
                elseif i == 20 then
                    local tab = {}
                    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
                    NovaAPI.UserEventUpload("authorizationlevel_20",tab)
                end

                ---日服PC埋点---
                if PcEventUpWorldLv[i] then
                    self:UserEventUpload_PC(PcEventUpWorldLv[i])
                end
                ---日服PC埋点---
            end
        end
    end
end

function PlayerBaseData:ChangeWorldClassGM(mapData)
    if mapData ~= nil then
        self._nOldWorldClass = self._nWorldClass
        self._nOldWorldExp = self._nWorldExp
        self._nWorldClass = mapData.FinalClass
        self._nWorldExp = mapData.LastExp
        EventManager.Hit(EventId.UpdateWorldClass)
        self:CheckNewFuncUnlockWorldClass(self._nOldWorldClass,self._nWorldClass)
        if self._nOldWorldClass ~= self._nWorldClass then
            local wait = function()
                coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
                self:SetWorldClassChange(true)
                self:TryOpenWorldClassUpgrade()
            end
            cs_coroutine.start(wait)
            self:RefreshCurWorldStageIndex()
            --刷新红点显示
            self:RefreshWorldClassRedDot()

            for i = self._nOldWorldClass + 1, self._nWorldClass do
                if i == 5 then
                    local tab = {}
                    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
                    NovaAPI.UserEventUpload("authorizationlevel_5",tab)
                elseif i == 10 then
                    local tab = {}
                    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
                    NovaAPI.UserEventUpload("authorizationlevel_10",tab)
                elseif i == 20 then
                    local tab = {}
                    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
                    NovaAPI.UserEventUpload("authorizationlevel_20",tab)
                end

                ---日服PC埋点---
                if PcEventUpWorldLv[i] then
                    self:UserEventUpload_PC(PcEventUpWorldLv[i])
                end
                ---日服PC埋点---
            end
        end
    end
end

--刷新世界等级阶段
function PlayerBaseData:RefreshCurWorldStageIndex()
    self._nCurWorldStageIndex = 0
    local tbDemonAdvanceCfg = CacheTable.Get("_DemonAdvance")
    local bMax = self._nWorldClass >= tbDemonAdvanceCfg[#tbDemonAdvanceCfg].nMaxLevel
    if bMax then
        self._nCurWorldStageIndex = #tbDemonAdvanceCfg
    else
        for k, v in ipairs(tbDemonAdvanceCfg) do
            if v.nType == AllEnum.WorldClassType.LevelUp then
                if v.nMinLevel <= self._nWorldClass and v.nMaxLevel > self._nWorldClass then
                    self._nCurWorldStageIndex = k
                    break
                end
            elseif v.nType == AllEnum.WorldClassType.Advance then
                if v.nMinLevel <= self._nWorldClass and v.nMaxLevel >= self._nWorldClass then
                    self._nCurWorldStageIndex = v.nId == self._nWorldStage and (k + 1) or k
                    break
                end
            end
        end
    end
end

function PlayerBaseData:ChangeWorldStage(nStageId)
    self._nWorldStage = nStageId
    self:RefreshCurWorldStageIndex()
end

--打开世界等级弹窗都用这个接口
function PlayerBaseData:TryOpenWorldClassUpgrade(callback)
    if self._bWorldClassChange then
        local popUpCallback = function()
            EventManager.Hit("Guide_CloseWorldClassPopUp")
            if nil ~= callback then
                callback() 
            end
        end
        PopUpManager.OpenPopUpPanel({ GameEnum.PopUpSeqType.WorldClass, GameEnum.PopUpSeqType.FuncUnlock }, popUpCallback)
    end
    return self._bWorldClassChange
end

function PlayerBaseData:OnNextDayRefresh()
    if self.NextRefreshTimer ~= nil then
        self.NextRefreshTimer:Cancel()
        self.NextRefreshTimer = nil
    end
    
    local function callback(_, msgData)
        local curNextRefreshTime = self.NextRefreshTime
        self:SetNextRefreshTime(msgData.ServerTs)
        if msgData.ServerTs < curNextRefreshTime then
            return
        end
        --跨天
        self:OnNewDay()
        EventManager.Hit(EventId.IsNewDay)
        local bInAdventure = ModuleManager.GetIsAdventure()
        local bInStarTowerSweep = not bInAdventure and (PlayerData.State:GetStarTowerSweepState() or 
        PanelManager.GetCurPanelId() == PanelId.StarTowerResult or PanelManager.GetCurPanelId() == PanelId.StarTowerBuildSave)
        local bInAvg = AvgManager.CheckInAvg()
        if bInAdventure or bInStarTowerSweep or bInAvg then
            print("Inlevel")
            self.bNewDay = true
            if bInAvg then
                self.bShowNewDayWind = true
            end
            return
        end
        self:BackToHome()
    end
    HttpNetHandler.SendPingPong(HttpNetHandler, true, callback)
end
function PlayerBaseData:NeedHotfix()
    self.bNeedHotfix=true
    if NovaAPI.GetCurrentModuleName() == "MainMenuModuleScene" then
        PlayerData.Base:OnBackToMainMenuModule()
    end
end

function PlayerBaseData:SetNextRefreshTime(curTimeStamp)
    local serverTimeStamp = CS.ClientManager.Instance.serverTimeStamp
    --这里+1s是避免服务器繁忙时出现的计算延迟问题
    self.NextRefreshTime = CS.ClientManager.Instance:GetNextRefreshTime(curTimeStamp) + 1
    if self.NextRefreshTimer == nil then
        self.NextRefreshTimer = TimerManager.Add(-1, 2, self, self.CheckNewDay, true,
        true, true, nil)
    end
    print("下次刷新时间:" .. self.NextRefreshTime)
    print("距下次刷新时间:" .. self.NextRefreshTime - serverTimeStamp)
end
function PlayerBaseData:CheckNewDay()
    local serverTimeStamp = CS.ClientManager.Instance.serverTimeStamp
    if serverTimeStamp > self.NextRefreshTime then
        self:OnNextDayRefresh()
    end
end
function PlayerBaseData:SetWorldClassChange(bChange, nDemonId, callback)
    self._bWorldClassChange = bChange
    if bChange then
        nDemonId = nDemonId or 0
        local mapParam = {nDemonId = nDemonId, callback = callback}
        PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.WorldClass, mapParam)
    end
end

function PlayerBaseData:OnBackToMainMenuModule()
    print("New Day Check")
    if self.bNewDay == true then
        self:OnNextDayRefresh()
        self.bNewDay = false
        if self.bInLoading then
            self.bShowNewDayWind = true
        else
            self:BackToHome()
        end
    end
    if self.bNeedHotfix then
        self.bNeedHotfix=false
        local msg = {
            nType = AllEnum.MessageBox.Alert,
            sContent = ConfigTable.GetUIText("Hotfix_Tip"),
            callbackConfirm = function()
                NovaAPI.ExitGame()
            end,
        }
        EventManager.Hit(EventId.OpenMessageBox, msg)
    end
end

function PlayerBaseData:CheckNextDayForSweep()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForSeconds(0.1))
        self:OnBackToMainMenuModule()
    end
    cs_coroutine.start(wait)
end

function PlayerBaseData:BackToHome()
    if PanelManager.GetCurPanelId() ~= PanelId.MainView then
        EventManager.Hit("NewDay_Clear_Guide")
        local msg = {
            nType = AllEnum.MessageBox.Alert,
            sContent = ConfigTable.GetUIText("Alert_NextDay"),
            callbackConfirm = function()
                PanelManager.Home()
            end,
        }
        EventManager.Hit(EventId.OpenMessageBox, msg)
    end
end

function PlayerBaseData:GetCurEnergy()
    local mapRet = {}
    mapRet.nEnergy = self._nCurEnergy
    mapRet.nEnergyTime = self._nEnergyTime
    return mapRet
end

function PlayerBaseData:GetCurEnergyBattery()
    local mapRet = {}
    mapRet.nEnergyBattery = self._nCurEnergyBattery
    mapRet.nEnergyBatteryTime = self._nEnergyBatteryTime
    return mapRet
end

function PlayerBaseData:GetMaxEnergyTime()
    local nMaxEnergy = ConfigTable.GetConfigNumber("EnergyMaxLimit") or 0
    local nEmptyEnergy = nMaxEnergy - self._nCurEnergy
    if nEmptyEnergy <= 0 then
        return 0
    end
    return ConfigTable.GetConfigNumber("EnergyGain") * 60 * nEmptyEnergy
end

function PlayerBaseData:GetWorldClass()
    return self._nWorldClass
end

function PlayerBaseData:GetMaxWorldClass()
    return self._nMaxWorldClass
end

function PlayerBaseData:GetWorldClassState(nLv)
    local tbState = PlayerData.State:GetWorldClassRewardState()
    local nIndex = math.ceil(nLv / 8)
    if tbState[nIndex] then
        return ((1 << (nLv - (nIndex - 1) * 8 - 1)) & tbState[nIndex]) > 0
    else
        return false
    end
end

function PlayerBaseData:GetEnabledWorldClassLv()
    local bEnabled = false
    for i = 2, self._nMaxWorldClass do
        bEnabled = self:GetWorldClassState(i)
        if bEnabled then
            return i, bEnabled
        end
    end
    return self._nWorldClass + 1, false
end

function PlayerBaseData:GetWorldExp()
    return self._nWorldExp
end

function PlayerBaseData:GetCurWorldClassStageIndex()
    return self._nCurWorldStageIndex
end

function PlayerBaseData:GetCurWorldClassStageId()
    local mapCfg = CacheTable.Get("_DemonAdvance")[self._nCurWorldStageIndex]
    if mapCfg ~= nil then
        return mapCfg.nId
    end
    return 0
end

--获取上一次世界等级变化时的世界等级
function PlayerBaseData:GetOldWorldClass()
    return self._nOldWorldClass
end

function PlayerBaseData:GetOldWorldExp()
    return self._nOldWorldExp
end

-- 侧边弹窗


--体力
function PlayerBaseData:CheckEnergyEnough(nId)
    local mapData = ConfigTable.GetData_Mainline(nId)
    if mapData ~= nil then
        return mapData.EnergyConsume <= self._nCurEnergy
    else
        return false
    end
end

function PlayerBaseData:GetEnergyBuyCount()
    return self._nBuyEnergyCount
end

function PlayerBaseData:GetEnergyBuyLimit()
    return self._nBuyEnergyLimit
end

function PlayerBaseData:GetCurEnergyBuyCfg(nBuyCount)
    local energyBuy = CacheTable.Get("_EnergyBuy") or {}
    for _, v in ipairs(energyBuy) do
        if v.Id == nBuyCount then
            return v
        end
    end
end

function PlayerBaseData:GetSendGiftCount()
    return self._nSendGiftCnt
end

-- 修改名称请求
function PlayerBaseData:SendPlayerNameEditReq(sName, callback)
    local msgData = {
        Name = sName,
    }
    local function successCallback(_, mapMainData)
        self._sPlayerNickName = sName
        self._nHashtag = mapMainData.Hashtag
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_name_edit_req, msgData, nil, successCallback)
end

-- 请求领取世界等级奖励
function PlayerBaseData:SendPlayerWorldClassRewardReceiveReq(nLv, nStage, callback, nMinLevel)
    local msgData = {}
    if nLv ~= nil then
        msgData.Class = nLv
    end
    local tbReward = {}
    if nLv ~= nil then
        local mapCfg = ConfigTable.GetData("WorldClass", nLv)
        if mapCfg ~= nil then
            local tbRewardCfg = decodeJson(mapCfg.Reward)
            for sItem, nCount in pairs(tbRewardCfg) do
                local nItemId = tonumber(sItem)
                table.insert(tbReward, {Tid = nItemId, Qty = nCount})
            end
        end
    else
        local mapReward = {}
        nMinLevel = nMinLevel or 1
        for i = nMinLevel, self._nWorldClass do
            local bCanReceive = self:GetWorldClassState(i)
            if bCanReceive then
                local mapCfg = ConfigTable.GetData("WorldClass", i)
                if mapCfg ~= nil then
                    local tbRewardCfg = decodeJson(mapCfg.Reward)
                    for sItem, nCount in pairs(tbRewardCfg) do
                        local nItemId = tonumber(sItem)
                        if mapReward[nItemId] == nil then
                            mapReward[nItemId] = nCount
                        else
                            mapReward[nItemId] = mapReward[nItemId] + nCount
                        end
                    end
                end
            end
        end
        for nId, nCount in pairs(mapReward) do
            table.insert(tbReward, {Tid = nId, Qty = nCount})
        end
    end
    
    local function successCallback(_, mapMainData)
        UTILS.OpenReceiveByDisplayItem(tbReward, mapMainData, function()
            if PlayerData.Guide:GetGuideState() then
                EventManager.Hit("Guide_ReceiveWorldClassReward")
            end
        end)
        self:RefreshCurWorldStageIndex()
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_world_class_reward_receive_req, msgData, nil, successCallback)
end

-- 请求世界等级突破
function PlayerBaseData:SendPlayerWorldClassAdvanceReq(nStageId, callback)
    local function successCallback(_, msgData)
        local callback = function()
            self:ChangeWorldStage(nStageId)
            EventManager.Hit("DemonAdvanceSuccess")
        end
        self:SetWorldClassChange(true, nStageId, callback)
        self:TryOpenWorldClassUpgrade()
        if nil ~= callback then
            callback(msgData)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_world_class_advance_req, {}, nil, successCallback)
end

-- 请求展示角色
function PlayerBaseData:SendPlayerCharsShowReq(tbChar, callback)
    -- 一共三位，空的角色填0
    local msgData = {
        CharIds = tbChar,
    }
    local function successCallback(_, mapMainData)
        self._tbCoreTeam = tbChar
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_chars_show_req, msgData, nil, successCallback)
end

-- 请求修改签名
function PlayerBaseData:SendPlayerSignatureEditReq(sSignature, callback)
    local msgData = {
        Signature = sSignature,
    }
    local function successCallback(_, mapMainData)
        self._sSignature = sSignature
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_signature_edit_req, msgData, nil, successCallback)
end

-- 请求展示皮肤
function PlayerBaseData:SendPlayerSkinShowReq(nSkinId, callback)
    local msgData = {
        SkinId = nSkinId,
    }
    local function successCallback(_, mapMainData)
        self._nShowSkinId = nSkinId
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_skin_show_req, msgData, nil, successCallback)
end

-- 请求修改头衔
function PlayerBaseData:SendPlayerTitleEditReq(nTitlePrefix, nTitleSuffix, callback)
    -- 0取消设置
    local msgData = {
        TitlePrefix = nTitlePrefix,
        TitleSuffix = nTitleSuffix,
    }
    local function successCallback(_, mapMainData)
        self._nTitlePrefix = nTitlePrefix
        self._nTitleSuffix = nTitleSuffix
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_title_edit_req, msgData, nil, successCallback)
end

-- 请求购买体力
function PlayerBaseData:SendEnergyBuy(callback)
    HttpNetHandler.SendMsg(NetMsgId.Id.energy_buy_req, { }, nil, callback)
end

-- 请求提取体力储藏
function PlayerBaseData:SendEnergyBatteryExtract(nAmount, callback)
    HttpNetHandler.SendMsg(NetMsgId.Id.energy_extract_req, {Value = nAmount}, nil, callback)
end

--世界等级奖励领取成功
function PlayerBaseData:PlayerWorldClassRewardReceiveSuc(mapMainData)
end

--世界等级突破成功
function PlayerBaseData:PlayerWorldClassAdvanceSuc(mapMainData)
    UTILS.OpenReceiveByChangeInfo(mapMainData.Change)
   local nCurId = self:GetCurWorldClassStageId()
   local mapCfg = ConfigTable.GetData("DemonAdvance", nCurId)
   if mapCfg ~= nil then
       local nGroupId = mapCfg.AdvanceQuestGroup
       PlayerData.Quest:ReceiveDemonQuest(nGroupId)
   end
    self:RefreshWorldClassRedDot()
end

--请求修改荣誉称号
function PlayerBaseData:SendPlayerHonorTitleEditReq(tbhonorTitle, callback)
    local msgData = {
        List = tbhonorTitle
    }
    local successCallback = function ()
        if callback ~= nil then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_honor_edit_req, msgData, nil, successCallback)
end
-------------------------------------------------------------------

function PlayerBaseData:OnNewDay()
    --刷新体力购买次数
    self._nBuyEnergyCount = 0
    --好感度赠礼次数刷新
    self._nSendGiftCnt = 0
end

-------------------------------- 红点相关 -------------------------
--世界等级奖励红点 有奖励可领取时显示红点
function PlayerBaseData:RefreshWorldClassRedDot()
    local nWorldClass = self:GetWorldClass()
    local nCurStageId = PlayerData.Base:GetCurWorldClassStageId()
    local tbDemonAdvanceCfg = CacheTable.Get("_DemonAdvance")
    for _, v in ipairs(tbDemonAdvanceCfg) do
        local bRedDot = false
        if v.nType == AllEnum.WorldClassType.LevelUp then
            --升级
            for lv = v.nMinLevel, v.nMaxLevel do
                local bAble = self:GetWorldClassState(lv)
                if lv <= nWorldClass and bAble then
                    bRedDot = true
                    break
                end
            end
            RedDotManager.SetValid(RedDotDefine.WorldClass_LevelUp, v.nId, bRedDot)
        elseif v.nType == AllEnum.WorldClassType.Advance then
            --突破（只判断当前阶段）
            if nCurStageId == v.nId and nWorldClass == v.nMinLevel then
                local mapCfg = ConfigTable.GetData("DemonAdvance", v.nId)
                if mapCfg ~= nil then
                    local tbQuestList = PlayerData.Quest:GetDemonQuestData(mapCfg.AdvanceQuestGroup, v.nId)
                    local nAllProgress = #tbQuestList
                    local nCurProgress = 0
                    for _, v in ipairs(tbQuestList) do
                        if v.nStatus == 1 then
                            nCurProgress = nCurProgress + 1
                        end
                    end
                    bRedDot = nCurProgress >= nAllProgress 
                end
            end
            RedDotManager.SetValid(RedDotDefine.WorldClass_Advance, v.nId, bRedDot)
        end
    end
end
--荣誉称号红点
function PlayerBaseData:RefreshHonorTitleRedDot()
    local sJson = localdata.GetPlayerLocalData("HonorTitle")
    local localHonorTilte =  decodeJson(sJson)
    if type(localHonorTilte) ~= "table" then
        return
    end
    for k,v in pairs(localHonorTilte) do
        RedDotManager.SetValid(RedDotDefine.Friend_Honor_Title_Item, tonumber(v),true)
    end
end
--兑换码
function PlayerBaseData:SendPlayerRedeemCodeReq(sCode,callback)
     local msgData = {
        Value = sCode
    }
    local successCallback = function (_,msgData)
        if callback ~= nil then
            callback(msgData.Change)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.redeem_code_req, msgData, nil, successCallback)
end
-------------------------------- 功能解锁相关 -------------------------
--如果已解锁直接在PassCallback中打开对应方法 sSound为需要播放的音效
function PlayerBaseData:CheckFunctionBtn(nFuncId,PassCallback,sSound)
    if sSound == nil then
        sSound = "ui_common_feedback_error"
    end
    local mapFuncCfgData = ConfigTable.GetData("OpenFunc", nFuncId)
    if mapFuncCfgData == nil then
        printError("OpenFunc Data Missing:".. nFuncId)
        return true
    end
    if mapFuncCfgData.NeedWorldClass > 0 then
        if self._nWorldClass < mapFuncCfgData.NeedWorldClass then
            EventManager.Hit(EventId.OpenMessageBox, {nType = AllEnum.MessageBox.Tips, sSound = sSound, sContent = UTILS.ParseParamDesc(mapFuncCfgData.Tips, mapFuncCfgData)})
            return false
        end
    end
    if mapFuncCfgData.NeedConditions > 0 then
        local nLevelStar = PlayerData.Mainline:GetMianlineLevelStar(mapFuncCfgData.NeedConditions)
        if nLevelStar < 1 then
            EventManager.Hit(EventId.OpenMessageBox, {nType = AllEnum.MessageBox.Tips, sSound = sSound, sContent = UTILS.ParseParamDesc(mapFuncCfgData.Tips, mapFuncCfgData)})            return false
        end
    end
    if type(PassCallback) == "function" then
        PassCallback()
    end 
end
--仅返回是否解锁 如果bShowTips为true则在未解锁时弹出tips说明
function PlayerBaseData:CheckFunctionUnlock(nFuncId,bShowTips)
    local mapFuncCfgData = ConfigTable.GetData("OpenFunc", nFuncId)
    if mapFuncCfgData == nil then
        printError("OpenFunc Data Missing:".. nFuncId)
        return true
    end
    if mapFuncCfgData.NeedWorldClass > 0 then
        if self._nWorldClass < mapFuncCfgData.NeedWorldClass then
            if bShowTips then
                EventManager.Hit(EventId.OpenMessageBox, UTILS.ParseParamDesc(mapFuncCfgData.Tips, mapFuncCfgData))
            end
            return false
        end
    end
    if mapFuncCfgData.NeedConditions > 0 then
        local nLevelStar = PlayerData.Mainline:GetMianlineLevelStar(mapFuncCfgData.NeedConditions)
        if nLevelStar < 1 then
            if bShowTips then
                EventManager.Hit(EventId.OpenMessageBox, UTILS.ParseParamDesc(mapFuncCfgData.Tips, mapFuncCfgData))
            end
            return false
        end
    end
    return true
end
function PlayerBaseData:CheckNewFuncUnlockWorldClass(nBefore,nNew)
    local function ForEachOpenFucn(mapData)
        if mapData.NeedWorldClass > nBefore and mapData.NeedWorldClass <= nNew then
            if mapData.NeedConditions > 0 then
                local nLevelStar = PlayerData.Mainline:GetMianlineLevelStar(mapData.NeedConditions)
                if nLevelStar < 1 then
                    return
                end
            end
            if mapData.PopWindows then
                if self.tbFuncNeedShow == nil then
                    self.tbFuncNeedShow = {}
                end
                table.insert(self.tbFuncNeedShow, mapData.Id)
                PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.FuncUnlock, self.tbFuncNeedShow)
            end
            EventManager.Hit(EventId.NewFuncUnlockWorldClass, mapData.Id)
        end
    end
    ForEachTableLine(DataTable.OpenFunc,ForEachOpenFucn)
end
function PlayerBaseData:CheckNewFuncUnlockMainlinePass(nMainlineId)
    local function ForEachOpenFucn(mapData)
        if mapData.NeedConditions == nMainlineId then
            if mapData.NeedWorldClass > 0 then
                if self._nWorldClass < mapData.NeedWorldClass then
                    return
                end
            end
            if mapData.PopWindows then
                if self.tbFuncNeedShow == nil then
                    self.tbFuncNeedShow = {}
                end
                table.insert(self.tbFuncNeedShow,mapData.Id)
                PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.FuncUnlock, self.tbFuncNeedShow)
            end
        end
    end
    ForEachTableLine(DataTable.OpenFunc,ForEachOpenFucn)
end
function PlayerBaseData:CheckNewFuncUnlockFixedRoguelike(nFRId)
    local function ForEachOpenFunc(mapData)
        if mapData.NeedRoguelike == nFRId then
            if mapData.NeedWorldClass > 0 then
                if self._nWorldClass < mapData.NeedWorldClass then
                    return
                end
            end
            if mapData.NeedConditions > 0 then
                local nLevelStar = PlayerData.Mainline:GetMianlineLevelStar(mapData.NeedConditions)
                if nLevelStar < 1 then
                    return
                end
            end
            if mapData.PopWindows then
                if self.tbFuncNeedShow == nil then
                    self.tbFuncNeedShow = {}
                end
                print("tbFuncNeedShow:"..mapData.Id)
                table.insert(self.tbFuncNeedShow,mapData.Id)
                PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.FuncUnlock, self.tbFuncNeedShow)
            end
        end
    end
    ForEachTableLine(DataTable.OpenFunc, ForEachOpenFunc)
end

function PlayerBaseData:OnEvent_TransAnimInClear()
    self.bInLoading = true
end

function PlayerBaseData:OnEvent_TransAnimOutClear()
    if self.bShowNewDayWind and self.bInLoading then
        self.bShowNewDayWind = false
        self:BackToHome()
    end
    self.bInLoading = false
end

function PlayerBaseData:Event_CreateRole()
    local tab = {}
    table.insert(tab,{"role_id",tostring(self._nPlayerId)})
    NovaAPI.UserEventUpload("role_create",tab)
    -- CN SDK 加急修改的
    CS.SDKManager.Instance:CreateRole(tostring(self._nPlayerId), self._sPlayerNickName, self._nCreateTime)

    local tab_1 = {}
    table.insert(tab_1,{"role_id",tostring(self._nPlayerId)})
    NovaAPI.UserEventUpload("role_login",tab_1)
end

function PlayerBaseData:PrologueEventUpload(index)
    --printError(index .. "   " .. self._nPlayerId)
    --local tmpSkip = isSkip and "1" or "0"
    local tab = {}
    table.insert(tab,{"role_id",tostring(self._nPlayerId)})
    --table.insert(tab,{"is_skip",tostring(tmpSkip)})
    table.insert(tab,{"newbie_tutorial_id",index})
    NovaAPI.UserEventUpload("newbie_tutorial",tab)--1 - 5

    if index == "1" then -- 序章第一步(播片时)开启按键操作
        EventManager.Hit("FirstInputEnable")
    end
end

function PlayerBaseData:UserEventUpload_PC(eventName)
    local clientPublishRegion=CS.ClientConfig.ClientPublishRegion
    local curPlatform = CS.ClientManager.Instance.Platform
    --printError("clientPublishRegion === " .. tostring(clientPublishRegion) .. "   " .. curPlatform)
    if clientPublishRegion == CS.ClientPublishRegion.JP then
        if curPlatform == "windows" then
            local tab = {}
            table.insert(tab,{"role_id",tostring(self._nPlayerId)})
            NovaAPI.UserEventUpload(eventName,tab)
        else
            local tmpEventName = string.gsub(eventName, "pc_", "move_")
            local tab = {}
            table.insert(tab,{"role_id",tostring(self._nPlayerId)})
            NovaAPI.UserEventUpload(tmpEventName,tab)
        end
    end
end
return PlayerBaseData
