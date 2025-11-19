local NormalFloor = {}
NormalFloor.Init = function(self)
  -- function num : 0_0
  self.touchPortal = false
end

NormalFloor.OnRoguelikeEnter = function(self, PlayerRoguelikeData)
  -- function num : 0_1
  PlayerRoguelikeData:SetActorEffects()
  PlayerRoguelikeData:SetActorAttribute(false)
  PlayerRoguelikeData:ResetBoxCount()
  PlayerRoguelikeData:ResetPerkEffect()
end

NormalFloor.OnTouchPortal = function(self, PlayerRoguelikeData)
  -- function num : 0_2
  if self.touchPortal then
    return 
  end
  self.touchPortal = true
  PlayerRoguelikeData:CacheCharAttr()
  PlayerRoguelikeData:SendSettleReq()
end

NormalFloor.SettleCallback = function(self, PlayerRoguelikeData)
  -- function num : 0_3
  PlayerRoguelikeData:FloorEnd()
end

NormalFloor.OnAbandon = function(self, PlayerRoguelikeData, bFailed)
  -- function num : 0_4
  PlayerRoguelikeData:AbandonRoguelike(bFailed)
end

return NormalFloor

