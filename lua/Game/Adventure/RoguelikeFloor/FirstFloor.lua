--Roguelike层数据处理：第一层
--  第一层需要在开始时选择初始天赋，第一次选择天赋时不需要与服务器通信
--  在触摸传送门时进行第一层奖励天赋选择
--  天赋选择后进行层结算将两次天赋选择和该层击杀数据一起发给服务器
--  因为天赋选择消息无法区分第几次天赋选择，所以这里不可避免的使用了_bStart状态变量用来区分是否为第一次天赋选择
--  PlayerRoguelikeData中cache的层数据中第一层会有额外的开局天赋保存在_tbAdditionalTalent中，在第一次天赋选择时先在AdditionalTalent中选择
--  触摸传送门后按照一般流程选择该层的天赋（PlayerRoguelikeData中的_tbNextTalent）
--  重连逻辑与正常进入逻辑相同，在roguelikeData cache数据完成后正常开始本层
local FirstFloor = {}

function FirstFloor:Init()
    self._bStart = true
    self.touchPortal = false
end
function FirstFloor:OnRoguelikeEnter(PlayerRoguelikeData)
    PlayerRoguelikeData:SetActorEffects()
    PlayerRoguelikeData:SetActorAttribute(true)
    PlayerRoguelikeData:ResetBoxCount()
end
function FirstFloor:OnTouchPortal(PlayerRoguelikeData)
    if self.touchPortal then
        return
    end
    self.touchPortal = true
    PlayerRoguelikeData:CacheCharAttr()
    PlayerRoguelikeData:SendSettleReq()
end
function FirstFloor:SettleCallback(PlayerRoguelikeData)
    PlayerRoguelikeData:FloorEnd()
end
function FirstFloor:OnAbandon(PlayerRoguelikeData,bFailed)
    PlayerRoguelikeData:AbandonRoguelike(bFailed)
end
return FirstFloor