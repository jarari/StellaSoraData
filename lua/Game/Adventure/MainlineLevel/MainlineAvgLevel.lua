local MainlineAvgLevel = class("MainlineAvgLevel")
local mapEventConfig = {LevelStateChanged = "OnEvent_SendMsgFinishBattle"}
MainlineAvgLevel.Init = function(self, parent, nMainlineId)
  -- function num : 0_0 , upvalues : _ENV
  self._nSelectId = nMainlineId
  self.parent = parent
  self.bSettle = false
  self:BindEvent()
  local mapMainline = (ConfigTable.GetData_Mainline)(nMainlineId)
  if mapMainline == nil then
    (self.parent):LevelEnd()
    return 
  end
  if mapMainline.AvgId == nil or mapMainline.AvgId == "" then
    (self.parent):LevelEnd()
    return 
  end
  self.parent = parent
  local mapData = {nType = (AllEnum.StoryAvgType).PureAvg, sAvgId = mapMainline.AvgId, nNodeId = nMainlineId, callback = nil}
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.PureAvgStory, mapData)
end

MainlineAvgLevel.BindEvent = function(self)
  -- function num : 0_1 , upvalues : _ENV, mapEventConfig
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

MainlineAvgLevel.UnBindEvent = function(self)
  -- function num : 0_2 , upvalues : _ENV, mapEventConfig
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

MainlineAvgLevel.OnEvent_SendMsgFinishBattle = function(self)
  -- function num : 0_3 , upvalues : _ENV
  if self.bSettle == true then
    print("已在结算流程中！")
    return 
  end
  self.bSettle = true
  print("OnEvent_SendMsgFinishBattle")
  local nStar = 7
  local func_cbFinishSucc = function(_, mapMainData)
    -- function num : 0_3_0 , upvalues : self, nStar, _ENV
    (self.parent):UpdateMainlineStar(self._nSelectId, nStar)
    ;
    (EventManager.Hit)(EventId.CloesCurPanel)
    local close = function()
      -- function num : 0_3_0_0 , upvalues : _ENV
      (PlayerData.Base):OnBackToMainMenuModule()
    end

    if mapMainData.FirstRewardItems and #mapMainData.FirstRewardItems > 0 then
      (UTILS.OpenReceiveByDisplayItem)(mapMainData.FirstRewardItems, mapMainData.Change, close)
    else
      close()
    end
    self:UnBindEvent()
    ;
    (self.parent):LevelEnd()
  end

  local mapSendMsg = {}
  mapSendMsg.Ok = true
  mapSendMsg.MinChests = {}
  mapSendMsg.MaxChests = {}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mainline_settle_req, mapSendMsg, nil, func_cbFinishSucc)
end

return MainlineAvgLevel

