local PlayerTrialData = class("PlayerTrialData")
local AdventureModuleHelper = CS.AdventureModuleHelper

function PlayerTrialData:Init()
    self.curLevel = nil
    self.bInSettlement = false --是否在结算状态(避免结算重复进入)
    self.nActId = nil
    self.nSelectTrialGroupId = nil
    self.sLevelTitle = nil
end

function PlayerTrialData:SetTrialAct(nActId)
    self.nActId = nActId
end

function PlayerTrialData:GetTrialAct()
    return self.nActId
end

function PlayerTrialData:SetSelectTrialGroup(nGroupId)
    self.nSelectTrialGroupId = nGroupId
end

function PlayerTrialData:GetSelectTrialGroup()
    return self.nSelectTrialGroupId
end

function PlayerTrialData:CheckGroupReceived()
    if not self.nActId or not self.nSelectTrialGroupId then
        return false
    end
    local actData = PlayerData.Activity:GetActivityDataById(self.nActId)
    if not actData then
        return false
    end
    return actData:CheckGroupReceived(self.nSelectTrialGroupId)
end

function PlayerTrialData:GetNextUnreceiveGroup()
    if not self.nActId then
        return
    end
    local actData = PlayerData.Activity:GetActivityDataById(self.nActId)
    if not actData then
        return
    end
    return actData:GetNextUnreceiveGroup()
end

function PlayerTrialData:SendReceiveTrialRewardReq(callback)
    if not self.nActId or not self.nSelectTrialGroupId then
        callback()
        return false
    end
    local actData = PlayerData.Activity:GetActivityDataById(self.nActId)
    if not actData then
        callback()
        return false
    end
    actData:SendActivityTrialRewardReceiveReq(self.nSelectTrialGroupId, callback)
end

------------------------------ 关卡 -----------------------------

function PlayerTrialData:EnterTrialEditor(nFloor)
    if self.curLevel ~= nil then
        printError("当前关卡level不为空1")
        return
    end
    local luaClass = require "Game.Adventure.Trial.TrialEditor"
    if luaClass == nil then
        return
    end
    self.curLevel = luaClass
    if type(self.curLevel.BindEvent) == "function" then
        self.curLevel:BindEvent()
    end
    if type(self.curLevel.Init) == "function" then
        self.curLevel:Init(self, nFloor)
    end
end

function PlayerTrialData:EnterTrial(nLevelId)
    if self.curLevel ~= nil then
        printError("当前关卡level不为空1")
        return
    end
    local luaClass = require "Game.Adventure.Trial.TrialLevel"
    if luaClass == nil then
        return
    end
    self.curLevel = luaClass
    if type(self.curLevel.BindEvent) == "function" then
        self.curLevel:BindEvent()
    end
    if type(self.curLevel.Init) == "function" then
        self.curLevel:Init(self, nLevelId)
    end
end

function PlayerTrialData:LevelEnd()
    PlayerData.Build:DeleteTrialBuild()
    if nil ~= self.curLevel and type(self.curLevel.UnBindEvent) == "function" then
        self.curLevel:UnBindEvent()
    end
    self.curLevel = nil
end

function PlayerTrialData:GetCurLevel()
    if self.curLevel == nil then
        return 0
    end
    return self.curLevel.nLevelId
end

function PlayerTrialData:SetLevelTitle(sTitle)
    self.sLevelTitle = sTitle
end

function PlayerTrialData:GetLevelTitle()
    return self.sLevelTitle or ""
end

function PlayerTrialData:SetSettlementState(bInSettlement)
    self.bInSettlement = bInSettlement
end

function PlayerTrialData:GetSettlementState()
    return self.bInSettlement
end

return PlayerTrialData
