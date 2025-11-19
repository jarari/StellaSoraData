local PlayerGuideData = class("PlayerGuideData")
PanelId = require("GameCore.UI.PanelId")
PlayerGuideData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.isProcessing = false
  self.openPanelId = 0
  ;
  (EventManager.Add)("OnEvent_PanelOnEnableById", self, self.OnEvent_PanelOnEnableById)
  ;
  (EventManager.Add)("Guide_CloseDisposablePanel", self, self.OnEvent_CloseDisposablePanel)
  ;
  (EventManager.Add)("Event_MainViewPopUpEnd", self, self.Event_PopUpEndCheckMainView)
  ;
  (EventManager.Add)("Guide_CloseWorldClassPopUp", self, self.OnEvent_UpdateWorldClass)
  ;
  (EventManager.Add)("Guide_PassiveCheck_Msg", self, self.Event_PassiveCheckMsg)
  self.runGroupId = 0
  self.runStepId = 0
  self._guideInitiativeTableData = {}
  self._guidePassiveTableData = {}
  self.tabGuideNewbie = {}
  self:HandleTableMsg()
end

PlayerGuideData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)("OnEvent_PanelOnEnableById", self, self.OnEvent_PanelOnEnableById)
  ;
  (EventManager.Remove)("Guide_CloseDisposablePanel", self, self.OnEvent_CloseDisposablePanel)
  ;
  (EventManager.Remove)("Event_MainViewPopUpEnd", self, self.Event_PopUpEndCheckMainView)
  ;
  (EventManager.Remove)("Guide_CloseWorldClassPopUp", self, self.OnEvent_UpdateWorldClass)
  ;
  (EventManager.Remove)("Guide_PassiveCheck_Msg", self, self.Event_PassiveCheckMsg)
end

PlayerGuideData.HandleTableMsg = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local foreach = function(guideData)
    -- function num : 0_2_0 , upvalues : _ENV, self
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if guideData.GuideDetectionType == (GameEnum.guideDetectionType).InitiativeCheck then
      (self._guideInitiativeTableData)[guideData.Id] = guideData
    else
      -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

      ;
      (self._guidePassiveTableData)[guideData.Id] = guideData
    end
  end

  if self._guideInitiativeTableData == nil then
    self._guideInitiativeTableData = {}
  end
  if self._guidePassiveTableData == nil then
    self._guidePassiveTableData = {}
  end
  ForEachTableLine(DataTable.GuideGroup, foreach)
end

PlayerGuideData.SetGuideNewbie = function(self, newbie)
  -- function num : 0_3 , upvalues : _ENV
  if newbie == nil then
    return 
  end
  for i,v in pairs(newbie) do
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R7 in 'UnsetPending'

    (self.tabGuideNewbie)[v.GroupId] = v.StepId
  end
end

PlayerGuideData.GetGuideNewbie = function(self, groupId)
  -- function num : 0_4
  if (self.tabGuideNewbie)[groupId] then
    return (self.tabGuideNewbie)[groupId]
  end
  return 0
end

PlayerGuideData.GetGuideState = function(self)
  -- function num : 0_5
  return self.isProcessing
end

PlayerGuideData.CheckInGuideGroup = function(self, nId)
  -- function num : 0_6
  do return not self.isProcessing or self.runGroupId == nId end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerGuideData.SetPlayerLearnReq = function(self, groupId, stepId)
  -- function num : 0_7 , upvalues : _ENV
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tabGuideNewbie)[groupId] = stepId
  if stepId == -1 then
    local callallback = function()
    -- function num : 0_7_0 , upvalues : stepId, self, groupId
    if stepId == -1 and not self.isProcessing and groupId ~= 1 then
      self:CheckHaveGuideData()
    end
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).player_learn_req, {GroupId = groupId, StepId = stepId}, nil, callallback)
  end
end

PlayerGuideData.OnEvent_PanelOnEnableById = function(self, _panelId)
  -- function num : 0_8 , upvalues : _ENV
  if EditorSettings and EditorSettings.bJumpGuide then
    return 
  end
  if _panelId == PanelId.MainView then
    return 
  end
  self.openPanelId = _panelId
  if self.isProcessing then
    return 
  end
  self:CheckHaveGuideData()
end

PlayerGuideData.OnEvent_CloseDisposablePanel = function(self, nPanelId)
  -- function num : 0_9 , upvalues : _ENV
  if self.openPanelId == nPanelId then
    self.openPanelId = (PanelManager.GetCurPanelId)()
  end
end

PlayerGuideData.Event_PopUpEndCheckMainView = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if EditorSettings and EditorSettings.bJumpGuide then
    return 
  end
  if self.isProcessing then
    return 
  end
  if (PanelManager.GetCurPanelId)() == PanelId.MainView then
    if (PlayerData.State):CheckState() then
      return 
    end
    self.openPanelId = PanelId.MainView
    self:CheckHaveGuideData()
  end
end

PlayerGuideData.OnEvent_UpdateWorldClass = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if EditorSettings and EditorSettings.bJumpGuide then
    return 
  end
  if self.isProcessing then
    return 
  end
  self:CheckHaveGuideData()
end

PlayerGuideData.CheckHaveGuideData = function(self)
  -- function num : 0_12 , upvalues : _ENV
  for i,v in pairs(self._guideInitiativeTableData) do
    if ((self.tabGuideNewbie)[v.Id] == nil or (self.tabGuideNewbie)[v.Id] ~= -1) and v.IsActive then
      local bGuide = true
      if v.GuidePrepose ~= nil and bGuide then
        bGuide = self:CheckGuidePrePose(v.GuidePrepose, v.PreposeParams)
      end
      if v.GuidePrepose2 ~= nil and bGuide then
        bGuide = self:CheckGuidePrePose(v.GuidePrepose2, v.PreposeParams2)
      end
      if bGuide and self:CheckGuidePost(v) then
        bGuide = self:CheckGuidetrigger(v)
      end
      if bGuide then
        self.runGroupId = v.Id
        self.runStepId = (self.tabGuideNewbie)[v.Id] or 0
        self:OpenGuidePanel()
        break
      end
    end
  end
end

PlayerGuideData.CheckGuidePrePose = function(self, nPoseType, param)
  -- function num : 0_13 , upvalues : _ENV
  if nPoseType == (GameEnum.guideprepose).PreGuide then
    local _prepose = decodeJson(param)
    local _tmpGId = _prepose[1]
    if (self.tabGuideNewbie)[_tmpGId] and (self.tabGuideNewbie)[_tmpGId] == -1 then
      return true
    end
  else
    do
      if nPoseType == (GameEnum.guideprepose).FinishDungeon then
        local _prepose = decodeJson(param)
        local nStar = (PlayerData.Mainline):GetMianlineLevelStar(_prepose[1])
        if type(nStar) == "number" then
          return true
        end
      else
        do
          if nPoseType == (GameEnum.guideprepose).WorldClass then
            local _prepose = decodeJson(param)
            local nWorldClass = (PlayerData.Base):GetWorldClass()
            if _prepose[1] <= nWorldClass then
              return true
            end
          else
            do
              if nPoseType == (GameEnum.guideprepose).UnlockFunction then
                local _prepose = decodeJson(param)
                local funId = _prepose[1]
                if (PlayerData.Base):CheckFunctionUnlock(funId, false) then
                  return true
                end
              else
                do
                  if nPoseType == (GameEnum.guideprepose).HoldItem then
                    local _prepose = decodeJson(param)
                    local _itemId = _prepose[1]
                    local _itemCount = _prepose[2]
                    local hasCount = (PlayerData.Item):GetItemCountByID(_itemId)
                    if _itemCount <= hasCount then
                      return true
                    end
                  else
                    do
                      if nPoseType == (GameEnum.guideprepose).FinishStarTowerQuest then
                        local _prepose = decodeJson(param)
                        local _taskId = _prepose[1]
                        local tbCore, tbNormal = (PlayerData.Quest):GetStarTowerQuestData()
                        for i1,v1 in pairs(tbCore) do
                          if v1.nTid == _taskId and v1.nStatus > 0 then
                            return true
                          end
                        end
                        for i1,v1 in pairs(tbNormal) do
                          if v1.nTid == _taskId and v1.nStatus > 0 then
                            return true
                          end
                        end
                      else
                        do
                          if nPoseType == (GameEnum.guideprepose).UnFinishCharacterPlot then
                            local _prepose = decodeJson(param)
                            local data = (ConfigTable.GetData)("Plot", _prepose[1])
                            local charid = data.Char
                            local isFinish = (PlayerData.Char):IsCharPlotFinish(charid, _prepose[1])
                            if isFinish == false then
                              return true
                            end
                          else
                            do
                              do return true end
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
        end
      end
    end
  end
end

PlayerGuideData.CheckGuidePost = function(self, data)
  -- function num : 0_14 , upvalues : _ENV
  if data.GuidePost == (GameEnum.guidepost).UnDoneGuide then
    local _prepose = decodeJson(data.PostParams)
    local _tmpGId = _prepose[1]
    if (self.tabGuideNewbie)[_tmpGId] == nil or (self.tabGuideNewbie)[_tmpGId] ~= -1 then
      return true
    end
    return false
  else
    do
      do return true end
    end
  end
end

PlayerGuideData.CheckGuidetrigger = function(self, data)
  -- function num : 0_15 , upvalues : _ENV
  -- DECOMPILER ERROR at PC16: Unhandled construct in 'MakeBoolean' P1

  if (PlayerData.State).mapStarTowerState and ((PlayerData.State).mapStarTowerState).Id == 0 then
    do
      local bState = not data.TowerState
      if bState then
        return false
      end
      if data.GuideTrigger == (GameEnum.guidetrigger).PreGuide then
        local _triggerParams = decodeJson(data.TriggerParams)
        if (self.tabGuideNewbie)[_triggerParams[1]] and (self.tabGuideNewbie)[_triggerParams[1]] == -1 then
          return true
        end
      elseif data.GuideTrigger == (GameEnum.guidetrigger).WorldClass then
        local _triggerParams = decodeJson(data.TriggerParams)
        local nWorldClass = (PlayerData.Base):GetWorldClass()
        if _triggerParams[1] <= nWorldClass then
          return true
        end
      elseif data.GuideTrigger == (GameEnum.guidetrigger).OpenInterface then
        local _triggerParams = decodeJson(data.TriggerParams)
        if _triggerParams[1] == self.openPanelId then
          return true
        end
      elseif data.GuideTrigger == (GameEnum.guidetrigger).FinishLastStep then
        return true
      elseif data.GuideTrigger == (GameEnum.guidetrigger).FinishDungeon then
        local _triggerParams = decodeJson(data.TriggerParams)
        local nStar = (PlayerData.Mainline):GetMianlineLevelStar(_triggerParams[1])
        if type(nStar) == "number" then
          return true
        end
      elseif data.GuideTrigger == (GameEnum.guidetrigger).UnlockFunction then
        local _triggerParams = decodeJson(data.TriggerParams)
        local funId = _triggerParams[1]
        if (PlayerData.Base):CheckFunctionUnlock(funId, false) then
          return true
        end
      else
        return true
      end
      -- DECOMPILER ERROR: 10 unprocessed JMP targets
    end
  end
end

PlayerGuideData.OpenGuidePanel = function(self)
  -- function num : 0_16 , upvalues : _ENV
  print("[新手引导]当前触发的引导组Id:" .. tostring(self.runGroupId))
  self.isProcessing = true
  ;
  (EventManager.Hit)("Event_ActiveGuidePanel")
end

PlayerGuideData.FinishCurrentGroup = function(self, isCheck)
  -- function num : 0_17 , upvalues : _ENV
  print("[新手引导]引导结束，引导组Id:" .. tostring(self.runGroupId))
  self.isProcessing = false
  if isCheck then
    self:CheckHaveGuideData()
  end
  if (PanelManager.GetCurPanelId)() == PanelId.MainView then
  end
end

PlayerGuideData.Event_PassiveCheckMsg = function(self, msg)
  -- function num : 0_18 , upvalues : _ENV
  if EditorSettings and EditorSettings.bJumpGuide then
    return 
  end
  if self.isProcessing then
    return 
  end
  for i,v in pairs(self._guidePassiveTableData) do
    if ((self.tabGuideNewbie)[v.Id] == nil or (self.tabGuideNewbie)[v.Id] ~= -1) and v.IsActive and v.PassiveMsg == msg then
      local bGuide = true
      if v.GuidePrepose ~= nil and bGuide then
        bGuide = self:CheckGuidePrePose(v.GuidePrepose, v.PreposeParams)
      end
      if v.GuidePrepose2 ~= nil and bGuide then
        bGuide = self:CheckGuidePrePose(v.GuidePrepose2, v.PreposeParams2)
      end
      if bGuide and self:CheckGuidePost(v) then
        bGuide = self:CheckGuidetrigger(v)
      end
      if bGuide then
        self.runGroupId = v.Id
        self.runStepId = (self.tabGuideNewbie)[v.Id] or 0
        self:OpenGuidePanel()
        break
      end
    end
  end
end

PlayerGuideData.CheckGuideFinishById = function(self, id)
  -- function num : 0_19
  if (self.tabGuideNewbie)[id] == nil or (self.tabGuideNewbie)[id] ~= -1 then
    return false
  end
  return true
end

return PlayerGuideData

