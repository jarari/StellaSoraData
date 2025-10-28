--Roguelike层数据处理：打完boss后重连
local RenterBossDiedFloor = {}

function RenterBossDiedFloor:Init()
    self._bBossTalent = true
    self.touchPortal = false
end
function RenterBossDiedFloor:OnRoguelikeEnter(PlayerRoguelikeData) --只会在重连时触发
    PlayerRoguelikeData:SetActorEffects()
    PlayerRoguelikeData:SetActorAttribute(false)
    PlayerRoguelikeData:ResetBoxCount()
    PlayerRoguelikeData:ResetPerkEffect()

end
function RenterBossDiedFloor:OnTouchPortal(PlayerRoguelikeData)
    if self.touchPortal then
        return
    end
    self.touchPortal = true
    PlayerRoguelikeData:CacheCharAttr()
    PlayerRoguelikeData:SendSettleReq()
end
function RenterBossDiedFloor:SettleCallback(PlayerRoguelikeData)
    PlayerRoguelikeData:FloorEnd()
end

function RenterBossDiedFloor:OnAbandon(PlayerRoguelikeData,bFailed)
    PlayerRoguelikeData:AbandonRoguelike(bFailed)
end
return RenterBossDiedFloor