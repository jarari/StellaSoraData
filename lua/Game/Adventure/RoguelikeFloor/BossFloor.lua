--Roguelike层数据处理：Boss层
--  Boss层的结算逻辑比较特殊
--  击杀Boss后会立即进行本层的结算,结算后不会直接进入下一关，而是打开该层的传送门
--  因为结算后Roguelikedata中的天赋数据会被下一层覆盖，所以会将boss层天赋暂时存在_tbAdditionalTalent中
--  在打开天赋选择时参数应为_tbAdditionalTalent
--  触摸传送门后进行本层的天赋选择，选择后向服务器发送选择结果
--  成功后本层结束进入下一层
--  重连：boss没有打完时走boss层逻辑 与正常进入相同
local BossFloor = {}

function BossFloor:Init()
    self.touchPortal = false
end
function BossFloor:OnRoguelikeEnter(PlayerRoguelikeData) --只会在重连时触发
    PlayerRoguelikeData:SetActorEffects()
    PlayerRoguelikeData:ResetBoxCount()
    PlayerRoguelikeData:ResetPerkEffect()
    PlayerRoguelikeData:SetActorAttribute(false)
end
function BossFloor:OnTouchPortal(PlayerRoguelikeData)
    if self.touchPortal then
        return
    end
    self.touchPortal = true
    PlayerRoguelikeData:CacheCharAttr()
    PlayerRoguelikeData:SendSettleReq()
end
function BossFloor:SettleCallback(PlayerRoguelikeData)
    PlayerRoguelikeData:FloorEnd()
end
function BossFloor:OnBossDied(PlayerRoguelikeData) 
    PlayerRoguelikeData:SyncKillBoss()
    safe_call_cs_func(CS.AdventureModuleHelper.Lua2CSharp_RoguelikeOpenTeleporter)
end

function BossFloor:OnAbandon(PlayerRoguelikeData,bFailed)
    PlayerRoguelikeData:AbandonRoguelike(bFailed)
end

return BossFloor