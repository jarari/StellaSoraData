--活动：登录奖励
local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local LoginRewardActData = class("LoginRewardActData", ActivityDataBase)

function LoginRewardActData:Init()
    self.nCanReceives = 0               -- 可以领取的奖励进度
    self.nActual = 0                    -- 实际领取的奖励进度
    self.tbRewardList = {}              -- 奖励列表
    self.loginRewardActCfg = nil        -- 登录奖励表

    self:InitRewardList()
end

function LoginRewardActData:InitRewardList()
    local mapActCfg = ConfigTable.GetData("LoginRewardControl", self.nActId)
    if nil == mapActCfg then
        return
    end
    self.loginRewardActCfg = mapActCfg
    local tbRewardList = CacheTable.GetData("_LoginRewardGroup", mapActCfg.RewardsGroup)
    if tbRewardList == nil then
        printError(string.format("LoginRewardGroup表中不存在奖励组id为 %s 的配置！！！", mapActCfg.RewardsGroup))
        return
    end
    table.sort(tbRewardList, function(a, b)
        return a.Order < b.Order
    end)
    self.tbRewardList = tbRewardList
end

function LoginRewardActData:RefreshLoginData(nReceive, nActual)
    self.nCanReceives = nReceive
    self.nActual = nActual
    for k, v in ipairs(self.tbRewardList) do
        v.Status = 0        -- 不可领取
        if nReceive >= k then
            v.Status = 1        -- 可领取
        end
        if nActual >= k then
            v.Status = 2        -- 已领取
        end
    end
end

function LoginRewardActData:ReceiveRewardSuc()
    self:RefreshLoginData(self.nCanReceives, self.nCanReceives)
end

function LoginRewardActData:GetActLoginRewardList()
    return self.tbRewardList
end

function LoginRewardActData:GetCanReceive()
    return self.nCanReceives
end

function LoginRewardActData:GetReceived()
    return self.nActual
end

function LoginRewardActData:CheckCanReceive()
    return self.nCanReceives > self.nActual
end

function LoginRewardActData:GetLoginRewardControlCfg()
    return self.loginRewardActCfg
end


return LoginRewardActData
