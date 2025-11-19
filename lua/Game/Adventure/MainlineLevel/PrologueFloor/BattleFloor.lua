local BaseFloor = require("Game.Adventure.MainlineLevel.PrologueFloor.BasePrologueFloor")
local BattleFloor = class("BattleFloor", BaseFloor)
BattleFloor._mapEventConfig = {InteractiveNpc = "OnEvent_InteractiveNpc", InteractiveBoxGet = "OnEvent_InteractiveBoxGet"}
BattleFloor.OnEvent_InteractiveNpc = function(self, nNpcId, nNpcUid)
  -- function num : 0_0 , upvalues : _ENV
  local mapNpc = (ConfigTable.GetData)("NPC", nNpcId)
  if mapNpc == nil then
    print("NPC不存在" .. nNpcId)
    return 
  end
  if mapNpc.type ~= (GameEnum.npcType).PrologueReward then
    return 
  end
  ;
  (self.parent):GetRewardNpc(nNpcId, nNpcUid)
end

BattleFloor.OnEvent_InteractiveBox = function(self, nBoxId, _, _, _)
  -- function num : 0_1
  (self.parent):GetRewardBox(nBoxId)
end

return BattleFloor

