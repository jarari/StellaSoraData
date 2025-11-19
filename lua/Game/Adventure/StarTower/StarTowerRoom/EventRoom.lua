local BaseRoom = require("Game.Adventure.StarTower.StarTowerRoom.BaseRoom")
local EventRoom = class("EventRoom", BaseRoom)
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
EventRoom._mapEventConfig = {LevelStateChanged = "OnEvent_LevelStateChanged", InteractiveNpc = "OnEvent_InteractiveNpc"}
EventRoom.LevelStart = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self:HandleCases()
  ;
  (EventManager.Hit)("ShowStarTowerRoomInfo", true, (self.parent).nTeamLevel, (self.parent).nTeamExp, clone((self.parent)._mapNote), clone((self.parent)._mapFateCard))
  local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
  if nCoin == nil then
    nCoin = 0
  end
  local nBuildScore = (self.parent):CalBuildScore()
  ;
  (EventManager.Hit)("ShowStarTowerCoin", true, nCoin, nBuildScore)
  ;
  (EventManager.Hit)("PlayStarTowerDiscBgm")
end

EventRoom.OnEvent_InteractiveNpc = function(self, nNpcId, nNpcUid)
  -- function num : 0_1
  self:HandleNpc(nNpcId, nNpcUid)
end

EventRoom.OnLoadLevelRefresh = function(self)
  -- function num : 0_2
end

EventRoom.OnEvent_LevelStateChanged = function(self, nState)
  -- function num : 0_3 , upvalues : _ENV
  if nState == (GameEnum.levelState).Teleporter then
    if (self.mapCases)[(self.EnumCase).OpenDoor] == nil then
      printError("无传送门case 无法进入下一层")
      return 
    end
    local tbDoorCase = (self.mapCases)[(self.EnumCase).OpenDoor]
    ;
    (self.parent):EnterRoom(tbDoorCase[1], tbDoorCase[2])
    return 
  end
end

return EventRoom

