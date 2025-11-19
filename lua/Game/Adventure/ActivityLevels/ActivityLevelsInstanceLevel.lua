local ActivityLevelsInstanceLevel = class("ActivityLevelsInstanceLevel")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local AdventureModuleHelper = CS.AdventureModuleHelper
local TimerManager = require("GameCore.Timer.TimerManager")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", [EventId.AbandonBattle] = "OnEvent_AbandonBattle", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause", ActivityInstance_Result = "LevelResultChange", ActivityLevelSettle_Failed = "OnEvent_ActivityLevelSettleFailed"}
ActivityLevelsInstanceLevel.Init = function(self, parent, nActivityId, nLevelId, nBuildId)
  -- function num : 0_0 , upvalues : _ENV
  self.parent = parent
  self.nLevelId = nLevelId
  self.nActivityId = nActivityId
  self.isSettlement = false
  local GetBuildCallback = function(mapBuildData)
    -- function num : 0_0_0 , upvalues : self, _ENV, nLevelId
    self.mapBuildData = mapBuildData
    self.tbCharId = {}
    for _,mapChar in ipairs((self.mapBuildData).tbChar) do
      (table.insert)(self.tbCharId, mapChar.nTid)
    end
    self.tbDiscId = {}
    for _,nDiscId in ipairs((self.mapBuildData).tbDisc) do
      if nDiscId > 0 then
        (table.insert)(self.tbDiscId, nDiscId)
      end
    end
    self.mapActorInfo = {}
    for idx,nTid in ipairs(self.tbCharId) do
      local stActorInfo = self:CalCharFixedEffect(nTid, idx == 1, self.tbDiscId)
      -- DECOMPILER ERROR at PC47: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (self.mapActorInfo)[nTid] = stActorInfo
    end
    -- DECOMPILER ERROR at PC54: Confused about usage of register: R1 in 'UnsetPending'

    PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).EquipmentInstance
    ;
    ((CS.AdventureModuleHelper).EnterActivityLevelsInstance)(nLevelId, self.tbCharId)
    ;
    (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  ;
  (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
end

ActivityLevelsInstanceLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  ;
  (EventManager.Hit)("OpenActivityLevelsInstanceRoomInfo", self.nLevelId)
end

ActivityLevelsInstanceLevel.OnEvent_LevelResult = function(self, tbStar, bAbandon)
  -- function num : 0_2
end

ActivityLevelsInstanceLevel.OnEvent_AbandonBattle = function(self)
  -- function num : 0_3
  self:LevelResultChange(false, 0)
end

ActivityLevelsInstanceLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_4 , upvalues : _ENV
  (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).ActivityLevels)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.ActivityLevelsBattlePanel, self.tbCharId)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect(nCharId, idx == 1, self.tbDiscId)
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

ActivityLevelsInstanceLevel.LevelResultChange = function(self, isWin, totalTime)
  -- function num : 0_5 , upvalues : _ENV
  (EventManager.Hit)("ActivityLevelsInstanceBattleEnd")
  self:SettleLevelsInstance(isWin, totalTime)
end

ActivityLevelsInstanceLevel.RefreshCharDamageData = function(self)
  -- function num : 0_6 , upvalues : _ENV
  self.tbCharDamage = (UTILS.GetCharDamageResult)(self.tbCharId)
end

ActivityLevelsInstanceLevel.SettleLevelsInstance = function(self, isWin, totalTime)
  -- function num : 0_7 , upvalues : _ENV
  if self.isSettlement then
    return 
  end
  self.isSettlement = true
  local starCount = 0
  self:RefreshCharDamageData()
  do
    if isWin then
      local mapCfg = (ConfigTable.GetData)("ActivityLevelsLevel", self.nLevelId)
      if totalTime <= (mapCfg.ThreeStarCondition)[1] then
        starCount = 3
      else
        if totalTime <= (mapCfg.TwoStarCondition)[1] then
          starCount = 2
        else
          starCount = 1
        end
      end
    end
    local callback = function(taFixed, tbFirstReward, nExp, mapChangeInfo)
    -- function num : 0_7_0 , upvalues : _ENV, self, starCount, isWin
    (NovaAPI.InputEnable)()
    ;
    (EventManager.Hit)("ActivityLevelsInstanceLevelEnd")
    self.passStar = starCount
    if isWin then
      self:PlaySuccessPerform(taFixed, tbFirstReward, nExp, starCount, mapChangeInfo)
    else
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.BtnTips)
      local sLarge, sSmall = "", ""
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.ActivityLevelsInstanceResultPanel, false, 0, {}, {}, {}, 0, false, sLarge, sSmall, self.nLevelId, self.tbCharId, mapChangeInfo, self.tbCharDamage)
    end
    do
      self:UnBindEvent()
      ;
      (self.parent):LevelEnd()
    end
  end

    ;
    (NovaAPI.InputDisable)()
    ;
    (self.parent):SendActivityLevelSettleReq(self.nActivityId, starCount, callback)
  end
end

ActivityLevelsInstanceLevel.OnEvent_ActivityLevelSettleFailed = function(self)
  -- function num : 0_8 , upvalues : _ENV
  (NovaAPI.InputEnable)()
  ;
  (EventManager.Hit)("ActivityLevelsInstanceLevelEnd")
  self.passStar = 0
  ;
  (EventManager.Hit)(EventId.ClosePanel, PanelId.BtnTips)
  local sLarge, sSmall = "", ""
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.ActivityLevelsInstanceResultPanel, false, 0, {}, {}, {}, 0, false, sLarge, sSmall, self.nLevelId, self.tbCharId, nil, self.tbCharDamage)
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  local nEndTime = (self.parent).nEndTime
  if nEndTime < nCurTime then
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Activity_End_Notice"))
  end
  self:UnBindEvent()
  ;
  (self.parent):LevelEnd()
end

ActivityLevelsInstanceLevel.PlaySuccessPerform = function(self, FixedRewardItems, FirstRewardItems, nExp, starCount, mapChangeInfo)
  -- function num : 0_9 , upvalues : _ENV
  local func_SettlementFinish = function(bSuccess)
    -- function num : 0_9_0
  end

  local tbChar = self.tbCharId
  local levelEndCallback = function()
    -- function num : 0_9_1 , upvalues : _ENV, self, levelEndCallback, tbChar, func_SettlementFinish
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local nType = ((ConfigTable.GetData)("ActivityLevelsFloor", ((ConfigTable.GetData)("ActivityLevelsLevel", self.nLevelId)).FloorId)).Theme
    local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
    local tbSkin = {}
    for _,nCharId in ipairs(tbChar) do
      local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
      ;
      (table.insert)(tbSkin, nSkinId)
    end
    ;
    ((CS.AdventureModuleHelper).PlaySettlementPerform)(sName, "", tbSkin, func_SettlementFinish)
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  local openBattleResultPanel = function()
    -- function num : 0_9_2 , upvalues : _ENV, self, openBattleResultPanel, starCount, FixedRewardItems, FirstRewardItems, nExp, mapChangeInfo
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    local sLarge, sSmall = "", ""
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ActivityLevelsInstanceResultPanel, true, starCount, {}, {}, {}, (FixedRewardItems or not FirstRewardItems) and nExp or 0, false, sLarge, sSmall, self.nLevelId, self.tbCharId, mapChangeInfo, self.tbCharDamage)
    self.bSettle = false
    ;
    (self.parent):LevelEnd()
    self:UnBindEvent()
  end

  ;
  (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
end

ActivityLevelsInstanceLevel.BindEvent = function(self)
  -- function num : 0_10 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
end

ActivityLevelsInstanceLevel.UnBindEvent = function(self)
  -- function num : 0_11 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
end

ActivityLevelsInstanceLevel.SetCharFixedAttribute = function(self)
  -- function num : 0_12 , upvalues : _ENV
  for nCharId,stActorInfo in pairs(self.mapActorInfo) do
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
end

ActivityLevelsInstanceLevel.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_13 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

ActivityLevelsInstanceLevel.SetPersonalPerk = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if self.mapBuildData ~= nil then
    for nCharId,tbPerk in pairs((self.mapBuildData).tbPotentials) do
      local mapAddLevel = (PlayerData.Char):GetCharEnhancedPotential(nCharId)
      local tbPerkInfo = {}
      for _,mapPerkInfo in ipairs(tbPerk) do
        local nAddLv = mapAddLevel[mapPerkInfo.nPotentialId] or 0
        local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
        stPerkInfo.perkId = mapPerkInfo.nPotentialId
        stPerkInfo.nCount = mapPerkInfo.nLevel + nAddLv
        ;
        (table.insert)(tbPerkInfo, stPerkInfo)
      end
      safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, tbPerkInfo, nCharId)
    end
  end
end

ActivityLevelsInstanceLevel.SetDiscInfo = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local tbDiscInfo = {}
  for k,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if k <= 3 then
      local discInfo = (PlayerData.Disc):CalcDiscInfoInBuild(nDiscId, (self.mapBuildData).tbSecondarySkill)
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

ActivityLevelsInstanceLevel.OnEvent_Pause = function(self)
  -- function num : 0_16 , upvalues : _ENV
  (EventManager.Hit)("OpenActivityLevelsInstancePause", self.nActivityId, self.nLevelId, self.tbCharId)
end

return ActivityLevelsInstanceLevel

