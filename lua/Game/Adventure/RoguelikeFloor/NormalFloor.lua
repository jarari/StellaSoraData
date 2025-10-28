--Roguelike层数据处理：普通跑图层
--  普通跑图层没有特殊结算逻辑 正常过关后触摸传送门选择天赋
--  天赋选择结束后按照进行结算，结算后本层逻辑结束进入下一层
--  重连逻辑与正常进入逻辑相同，在roguelikeData cache数据完成后正常开始本层
local NormalFloor = {}

function NormalFloor:Init()
    self.touchPortal = false
end
function NormalFloor:OnRoguelikeEnter(PlayerRoguelikeData) --只会在重连时触发
    PlayerRoguelikeData:SetActorEffects()
    PlayerRoguelikeData:SetActorAttribute(false)
    PlayerRoguelikeData:ResetBoxCount()
    PlayerRoguelikeData:ResetPerkEffect()

end
function NormalFloor:OnTouchPortal(PlayerRoguelikeData)
    if self.touchPortal then
        return
    end
    self.touchPortal = true
    PlayerRoguelikeData:CacheCharAttr()
    PlayerRoguelikeData:SendSettleReq()
end
function NormalFloor:SettleCallback(PlayerRoguelikeData)
    PlayerRoguelikeData:FloorEnd()
end
function NormalFloor:OnAbandon(PlayerRoguelikeData,bFailed)
    PlayerRoguelikeData:AbandonRoguelike(bFailed)
end
return NormalFloor