-- 纯Avg关卡





local LocalData = require "GameCore.Data.LocalData"
local RapidJson = require "rapidjson"


local PureAvgPanel = class("PureAvgPanel", BasePanel)

-- Panel 定义
PureAvgPanel._bAddToBackHistory = false
--[[
PureAvgPanel._bIsMainPanel = true
PureAvgPanel._nSnapshotPrePanel = 0

PureAvgPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
PureAvgPanel._tbDefine = {
    {sPrefabPath = "Avg/PureAvgUI.prefab", sCtrlName = "Game.UI.Avg.PureAvgCtrl"}
}
-------------------- local function --------------------
function PureAvgPanel:LoadData(sType)
    local sJson = LocalData.GetPlayerLocalData("PlayedAvgNodeId")
    local tb = decodeJson(sJson)
    if type(tb) == "table" then
        self.tbNodeId = tb
    end
    if (self.tbNodeId[tostring(self.mapData.nNodeId)] or {})[sType] then
        -- 已经播过了就直接执行播完avg之后会做的事情
        local callback = self.mapData.callback
        if callback then
            callback()
        end
    else
        EventManager.Add("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
        if not self.tbNodeId[tostring(self.mapData.nNodeId)] then
            self.tbNodeId[tostring(self.mapData.nNodeId)] = {}
        end
        self.tbNodeId[tostring(self.mapData.nNodeId)][sType] = true
        LocalData.SetPlayerLocalData("PlayedAvgNodeId", RapidJson.encode(self.tbNodeId))
        EventManager.Hit("StoryDialog_DialogStart", self.mapData.sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, self.mapData.sGroupId)
    end
end
-------------------- base function --------------------
function PureAvgPanel:Awake()
    self.tbNodeId = {}
    self.mapData = self._tbParam[1] -- nType,sAvgId,nNodeId,callback（后二不一定会有）
    if not self.mapData then
        -- 错误
        local wait = function()
            coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
            PanelManager.Home()
        end
        cs_coroutine.start(wait)
    else
        if type(self.mapData.sGroupId) ~= "string" then
            self.mapData.sGroupId = nil
        else
            if self.mapData.sGroupId == "" then
                self.mapData.sGroupId = nil
            end
        end
    end
end
function PureAvgPanel:OnEnable()
    if self.mapData.nType == AllEnum.StoryAvgType.Preview then
        EventManager.Add("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
        EventManager.Hit("StoryDialog_DialogStart", self.mapData.sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, self.mapData.sGroupId)
    elseif self.mapData.nType == AllEnum.StoryAvgType.PureAvg then
        EventManager.Add("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
        EventManager.Hit("StoryDialog_DialogStart", self.mapData.sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, self.mapData.sGroupId)
       -- EventManager.Hit(EventId.SendMsgEnterBattle, 0, self.mapData.sAvgId) -- 进纯 AVG 关卡发消息。
    elseif self.mapData.nType == AllEnum.StoryAvgType.BeforeBattle then
        self:LoadData("Before")
    elseif self.mapData.nType == AllEnum.StoryAvgType.AfterBattle then
        self:LoadData("After")
    elseif self.mapData.nType == AllEnum.StoryAvgType.Plot then
        EventManager.Add("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
        EventManager.Hit("StoryDialog_DialogStart", self.mapData.sAvgId, Settings.sCurrentTxtLanguage, Settings.sCurrentVoLanguage, self.mapData.sGroupId)
    end
end
function PureAvgPanel:OnDisable()
end
function PureAvgPanel:OnDestroy()
end
-------------------- callback function --------------------
function PureAvgPanel:OnEvent_StoryDialog_DialogEnd()
    if self.mapData.nType == AllEnum.StoryAvgType.PureAvg then
        EventManager.Hit("LevelStateChanged", true, true) -- 出纯 AVG 关卡发消息。
    elseif self.mapData.nType == AllEnum.StoryAvgType.BeforeBattle or self.mapData.nType == AllEnum.StoryAvgType.AfterBattle then
        local callback = self.mapData.callback
        if callback then
            callback()
        end
    elseif self.mapData.nType == AllEnum.StoryAvgType.Preview then
        EventManager.Hit(EventId.CloesCurPanel)
    elseif self.mapData.nType == AllEnum.StoryAvgType.Plot then
        local callback = self.mapData.callback
        if callback then
            callback()
        end
    end
    EventManager.Remove("StoryDialog_DialogEnd", self, self.OnEvent_StoryDialog_DialogEnd)
end

return PureAvgPanel
