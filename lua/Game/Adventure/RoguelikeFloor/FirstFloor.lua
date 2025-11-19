local FirstFloor = {}
FirstFloor.Init = function(self)
  -- function num : 0_0
  self._bStart = true
  self.touchPortal = false
end

FirstFloor.OnRoguelikeEnter = function(self, PlayerRoguelikeData)
  -- function num : 0_1
  PlayerRoguelikeData:SetActorEffects()
  PlayerRoguelikeData:SetActorAttribute(true)
  PlayerRoguelikeData:ResetBoxCount()
end

FirstFloor.OnTouchPortal = function(self, PlayerRoguelikeData)
  -- function num : 0_2
  if self.touchPortal then
    return 
  end
  self.touchPortal = true
  PlayerRoguelikeData:CacheCharAttr()
  PlayerRoguelikeData:SendSettleReq()
end

FirstFloor.SettleCallback = function(self, PlayerRoguelikeData)
  -- function num : 0_3
  PlayerRoguelikeData:FloorEnd()
end

FirstFloor.OnAbandon = function(self, PlayerRoguelikeData, bFailed)
  -- function num : 0_4
  PlayerRoguelikeData:AbandonRoguelike(bFailed)
end

return FirstFloor

