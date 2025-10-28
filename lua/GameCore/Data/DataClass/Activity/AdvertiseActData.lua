--广告活动
local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local AdvertiseActData = class("AdvertiseActData", ActivityDataBase)

function AdvertiseActData:Init()
    self.nStatus = 0                    -- 活动状态
    self.jointDrillActCfg = nil

    self:InitConfig()
end


function AdvertiseActData:InitConfig()

end

--待定
function AdvertiseActData:RefreshInfinityTowerActData(msgData)

end

--活动开始时间
function AdvertiseActData:GetActOpenTime()
    return self.nOpenTime
end

--活动结束时间
function AdvertiseActData:GetActCloseTime()
    return self.nEndTime
end

return AdvertiseActData