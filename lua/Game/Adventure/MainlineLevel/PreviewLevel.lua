local PreviewLevel = class("PreviewLevel")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", BattlePause = "OnEvent_AbandonBattle", LevelStateChanged = "OnEvent_LevelResult", AdventureModuleEnter = "OnEvent_AdventureModuleEnter"}
PreviewLevel.Init = function(self, nLevelType, nLevelId, bView, nStarTowerFloorSetId, nPrefabID, nPrefabExtension, nPlayType, nSceneMir, parent)
  -- function num : 0_0 , upvalues : _ENV
  self.parent = parent
  self.tbCharId = (PlayerData.Team):GetTeamCharId(1)
  self.nLevelType = nLevelType
  self.nLevelId = nLevelId
  self:BindEvent()
  ;
  ((CS.AdventureModuleHelper).EnterViewSceneLevel)(nLevelType, nLevelId, self.tbCharId, bView, nStarTowerFloorSetId, nPrefabID, nPrefabExtension, nPlayType, nSceneMir)
  ;
  (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
end

PreviewLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_1
end

PreviewLevel.OnEvent_LevelResult = function(self, nState)
  -- function num : 0_2
  self:PlaySuccessPerform({}, {}, 3)
end

PreviewLevel.OnEvent_AbandonBattle = function(self)
  -- function num : 0_3
  self:OnEvent_LevelResult(true, 0)
end

PreviewLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_4 , upvalues : _ENV
  (EventManager.Hit)(EventId.OpenPanel, PanelId.Adventure, self.tbCharId)
  self:SetTheme()
  for _,value in ipairs(self.tbCharId) do
    self:SetTempActorAttribute(value)
  end
end

PreviewLevel.BindEvent = function(self)
  -- function num : 0_5 , upvalues : _ENV, mapEventConfig
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

PreviewLevel.UnBindEvent = function(self)
  -- function num : 0_6 , upvalues : _ENV, mapEventConfig
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

PreviewLevel.PlaySuccessPerform = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local func_OpenResult = function(bSuccess)
    -- function num : 0_7_0
  end

  local tbChar = self.tbCharId
  local levelEndCallback = function()
    -- function num : 0_7_1 , upvalues : _ENV, self, levelEndCallback, tbChar, func_OpenResult
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local sName = ""
    if self.nLevelType == (GameEnum.worldLevelType).Mainline then
      local nType = ((ConfigTable.GetData)("MainlineFloor", self.nLevelId)).Theme
      sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
    else
      do
        if self.nLevelType == (GameEnum.worldLevelType).RegionBoss then
          local nType = ((ConfigTable.GetData)("RegionBossFloor", self.nLevelId)).Theme
          sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
        else
          do
            if self.nLevelType == (GameEnum.worldLevelType).TravelerDuel then
              local nType = ((ConfigTable.GetData)("TravelerDuelFloor", self.nLevelId)).Theme
              sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
            else
              do
                if self.nLevelType == (GameEnum.worldLevelType).DailyInstance then
                  local nType = ((ConfigTable.GetData)("DailyInstanceFloor", self.nLevelId)).Theme
                  sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
                else
                  do
                    do
                      local nType = ((ConfigTable.GetData)("StarTowerMap", self.nLevelId)).Theme
                      sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
                      local jumpPerform = function()
      -- function num : 0_7_1_0 , upvalues : _ENV
      (NovaAPI.DispatchEventWithData)("SKIP_SETTLEMENT_PERFORM")
    end

                      ;
                      (EventManager.Hit)(EventId.OpenPanel, PanelId.BtnTips, jumpPerform)
                      local openBattleResultPanel = function()
      -- function num : 0_7_1_1 , upvalues : _ENV, self, openBattleResultPanel
      (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
      local sLarge, sSmall = "", ""
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResult, true, 3, {}, {}, {}, 0, false, sLarge, sSmall, 13001, self.tbCharId)
      self.bSettle = false
      ;
      (self.parent):LevelEnd()
    end

                      ;
                      (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
                      local tbSkin = {}
                      for _,nCharId in ipairs(tbChar) do
                        local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
                        ;
                        (table.insert)(tbSkin, nSkinId)
                      end
                      ;
                      ((CS.AdventureModuleHelper).PlaySettlementPerform)(sName, "", tbSkin, func_OpenResult)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true)
end

PreviewLevel.SetTempActorAttribute = function(self, nCharId)
  -- function num : 0_8 , upvalues : _ENV
  local mapChar = {nLevel = 1, nAdvance = 0}
  local nLevel = mapChar.nLevel
  local nAdvance = mapChar.nAdvance
  local nAttrId = (UTILS.GetCharacterAttributeId)(nCharId, nAdvance, nLevel)
  local mapCharAttr = (ConfigTable.GetData_Attribute)(tostring(nAttrId))
  if mapCharAttr == nil then
    printError("属性配置不存在:" .. nAttrId)
    return {}
  end
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
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
  stActorInfo.SkillLevel = {1, 1, 1}
  stActorInfo.skinId = (PlayerData.Char):GetCharSkinId(nCharId)
  stActorInfo.attrId = mapCharAttr.sAttrId
  safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
end

PreviewLevel.SetCharFixedAttribute = function(self)
  -- function num : 0_9 , upvalues : _ENV
  for nCharId,mapInfo in pairs(self.mapActorInfo) do
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, mapInfo.stActorInfo)
  end
end

PreviewLevel.CalCharFixedEffect = function(nCharId, bMainChar)
  -- function num : 0_10
  local tbstInfo = {}
  local stActorInfo = {}
  local nHeartStoneLevel = 1
  return tbstInfo, stActorInfo, nHeartStoneLevel
end

PreviewLevel.SetTheme = function(self)
  -- function num : 0_11
end

return PreviewLevel

