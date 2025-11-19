local RenterBossDiedFloor = {}
RenterBossDiedFloor.Init = function(self)
  -- function num : 0_0
  self._bBossTalent = true
  self.touchPortal = false
end

RenterBossDiedFloor.OnRoguelikeEnter = function(self, PlayerRoguelikeData)
  -- function num : 0_1
  PlayerRoguelikeData:SetActorEffects()
  PlayerRoguelikeData:SetActorAttribute(false)
  PlayerRoguelikeData:ResetBoxCount()
  PlayerRoguelikeData:ResetPerkEffect()
end

RenterBossDiedFloor.OnTouchPortal = function(self, PlayerRoguelikeData)
  -- function num : 0_2
  if self.touchPortal then
    return 
  end
  self.touchPortal = true
  PlayerRoguelikeData:CacheCharAttr()
  PlayerRoguelikeData:SendSettleReq()
end

RenterBossDiedFloor.SettleCallback = function(self, PlayerRoguelikeData)
  -- function num : 0_3
  PlayerRoguelikeData:FloorEnd()
end

RenterBossDiedFloor.OnAbandon = function(self, PlayerRoguelikeData, bFailed)
  -- function num : 0_4
  PlayerRoguelikeData:AbandonRoguelike(bFailed)
end

return RenterBossDiedFloor

