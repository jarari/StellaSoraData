local BossFloor = {}
BossFloor.Init = function(self)
  -- function num : 0_0
  self.touchPortal = false
end

BossFloor.OnRoguelikeEnter = function(self, PlayerRoguelikeData)
  -- function num : 0_1
  PlayerRoguelikeData:SetActorEffects()
  PlayerRoguelikeData:ResetBoxCount()
  PlayerRoguelikeData:ResetPerkEffect()
  PlayerRoguelikeData:SetActorAttribute(false)
end

BossFloor.OnTouchPortal = function(self, PlayerRoguelikeData)
  -- function num : 0_2
  if self.touchPortal then
    return 
  end
  self.touchPortal = true
  PlayerRoguelikeData:CacheCharAttr()
  PlayerRoguelikeData:SendSettleReq()
end

BossFloor.SettleCallback = function(self, PlayerRoguelikeData)
  -- function num : 0_3
  PlayerRoguelikeData:FloorEnd()
end

BossFloor.OnBossDied = function(self, PlayerRoguelikeData)
  -- function num : 0_4 , upvalues : _ENV
  PlayerRoguelikeData:SyncKillBoss()
  safe_call_cs_func((CS.AdventureModuleHelper).Lua2CSharp_RoguelikeOpenTeleporter)
end

BossFloor.OnAbandon = function(self, PlayerRoguelikeData, bFailed)
  -- function num : 0_5
  PlayerRoguelikeData:AbandonRoguelike(bFailed)
end

return BossFloor

