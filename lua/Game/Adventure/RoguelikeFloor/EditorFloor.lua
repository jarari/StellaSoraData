local TimerManager = require("GameCore.Timer.TimerManager")
local EditorFloor = {}
EditorFloor.Init = function(self)
  -- function num : 0_0
end

EditorFloor.OnRoguelikeEnter = function(self, PlayerRoguelikeData)
  -- function num : 0_1
  PlayerRoguelikeData:SetActorEffects()
  PlayerRoguelikeData:SetActorAttribute()
end

EditorFloor.OnTouchPortal = function(self, PlayerRoguelikeData)
  -- function num : 0_2
  PlayerRoguelikeData:CacheCharAttr()
  PlayerRoguelikeData:FloorEndEditor()
end

EditorFloor.SettleCallback = function(self, PlayerRoguelikeData)
  -- function num : 0_3
end

EditorFloor.OnBossDied = function(self, PlayerRoguelikeData)
  -- function num : 0_4 , upvalues : _ENV
  safe_call_cs_func((CS.AdventureModuleHelper).Lua2CSharp_RoguelikeOpenTeleporter)
end

EditorFloor.OnAbandon = function(self, PlayerRoguelikeData)
  -- function num : 0_5
  PlayerRoguelikeData:FloorEndEditor()
end

return EditorFloor

