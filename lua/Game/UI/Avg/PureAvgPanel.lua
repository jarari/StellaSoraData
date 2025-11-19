local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local PureAvgPanel = class("PureAvgPanel", BasePanel)
PureAvgPanel._bAddToBackHistory = false
PureAvgPanel._tbDefine = {
{sPrefabPath = "Avg/PureAvgUI.prefab", sCtrlName = "Game.UI.Avg.PureAvgCtrl"}
}
PureAvgPanel.LoadData = function(self, sType)
  -- function num : 0_0 , upvalues : LocalData, _ENV, RapidJson
  local sJson = (LocalData.GetPlayerLocalData)("PlayedAvgNodeId")
  local tb = decodeJson(sJson)
  if type(tb) == "table" then
    self.tbNodeId = tb
  end
  if (self.tbNodeId)[tostring((self.mapData).nNodeId)] or ({})[sType] then
    local callback = (self.mapData).callback
    if callback then
      callback()
    end
  else
    do
      ;
      (EventManager.Add)("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
      -- DECOMPILER ERROR at PC51: Confused about usage of register: R4 in 'UnsetPending'

      if not (self.tbNodeId)[tostring((self.mapData).nNodeId)] then
        (self.tbNodeId)[tostring((self.mapData).nNodeId)] = {}
      end
      -- DECOMPILER ERROR at PC58: Confused about usage of register: R4 in 'UnsetPending'

      ;
      ((self.tbNodeId)[tostring((self.mapData).nNodeId)])[sType] = true
      ;
      (LocalData.SetPlayerLocalData)("PlayedAvgNodeId", (RapidJson.encode)(self.tbNodeId))
      ;
      (EventManager.Hit)("StoryDialog_DialogStart", (self.mapData).sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, (self.mapData).sGroupId)
    end
  end
end

PureAvgPanel.Awake = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbNodeId = {}
  self.mapData = (self._tbParam)[1]
  if not self.mapData then
    local wait = function()
    -- function num : 0_1_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (PanelManager.Home)()
  end

    ;
    (cs_coroutine.start)(wait)
  else
    do
      -- DECOMPILER ERROR at PC21: Confused about usage of register: R1 in 'UnsetPending'

      if type((self.mapData).sGroupId) ~= "string" then
        (self.mapData).sGroupId = nil
      else
        -- DECOMPILER ERROR at PC28: Confused about usage of register: R1 in 'UnsetPending'

        if (self.mapData).sGroupId == "" then
          (self.mapData).sGroupId = nil
        end
      end
    end
  end
end

PureAvgPanel.OnEnable = function(self)
  -- function num : 0_2 , upvalues : _ENV
  if (self.mapData).nType == (AllEnum.StoryAvgType).Preview then
    (EventManager.Add)("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
    ;
    (EventManager.Hit)("StoryDialog_DialogStart", (self.mapData).sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, (self.mapData).sGroupId)
  else
    if (self.mapData).nType == (AllEnum.StoryAvgType).PureAvg then
      (EventManager.Add)("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
      ;
      (EventManager.Hit)("StoryDialog_DialogStart", (self.mapData).sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, (self.mapData).sGroupId)
    else
      if (self.mapData).nType == (AllEnum.StoryAvgType).BeforeBattle then
        self:LoadData("Before")
      else
        if (self.mapData).nType == (AllEnum.StoryAvgType).AfterBattle then
          self:LoadData("After")
        else
          if (self.mapData).nType == (AllEnum.StoryAvgType).Plot then
            (EventManager.Add)("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
            ;
            (EventManager.Hit)("StoryDialog_DialogStart", (self.mapData).sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, (self.mapData).sGroupId)
          end
        end
      end
    end
  end
end

PureAvgPanel.OnDisable = function(self)
  -- function num : 0_3
end

PureAvgPanel.OnDestroy = function(self)
  -- function num : 0_4
end

PureAvgPanel.OnEvent_StoryDialog_DialogEnd = function(self)
  -- function num : 0_5 , upvalues : _ENV
  if (self.mapData).nType == (AllEnum.StoryAvgType).PureAvg then
    (EventManager.Hit)("LevelStateChanged", true, true)
  else
    if (self.mapData).nType == (AllEnum.StoryAvgType).BeforeBattle or (self.mapData).nType == (AllEnum.StoryAvgType).AfterBattle then
      local callback = (self.mapData).callback
      if callback then
        callback()
      end
    else
      do
        if (self.mapData).nType == (AllEnum.StoryAvgType).Preview then
          (EventManager.Hit)(EventId.CloesCurPanel)
        else
          if (self.mapData).nType == (AllEnum.StoryAvgType).Plot then
            local callback = (self.mapData).callback
            if callback then
              callback()
            end
          end
        end
        do
          ;
          (EventManager.Remove)("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
        end
      end
    end
  end
end

return PureAvgPanel

