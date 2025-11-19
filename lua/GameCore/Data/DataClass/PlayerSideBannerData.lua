local PlayerSideBannerData = class("PlayerSideBannerData")
local ModuleManager = require("GameCore.Module.ModuleManager")
PlayerSideBannerData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.tbDictionaryEntry = {}
  self.tbAchievement = {}
  self.tbFavour = {}
  ;
  (EventManager.Add)("DispatchMsgDone", self, self.OnEvent_TryOpenSideBanner)
end

PlayerSideBannerData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)("DispatchMsgDone", self, self.OnEvent_TryOpenSideBanner)
end

PlayerSideBannerData.OnEvent_TryOpenSideBanner = function(self)
  -- function num : 0_2
  self:TryOpenSideBanner(true)
end

PlayerSideBannerData.TryOpenSideBanner = function(self, bLimit)
  -- function num : 0_3 , upvalues : ModuleManager, _ENV
  if bLimit and ((ModuleManager.GetIsAdventure)() or (PanelManager.GetCurPanelId)() == PanelId.Login or (PanelManager.GetCurPanelId)() == PanelId.GachaSpin or (PanelManager.CheckPanelOpen)(PanelId.DatingLandmark) or (PanelManager.CheckPanelOpen)(PanelId.Dating)) then
    return 
  end
  local mapData = {}
  if next(self.tbAchievement) ~= nil then
    local nAchievementCount = #self.tbAchievement
    if nAchievementCount == 1 then
      (table.insert)(mapData, {nType = (AllEnum.SideBaner).Achievement, nId = (self.tbAchievement)[1]})
    else
      local comp = function(a, b)
    -- function num : 0_3_0 , upvalues : _ENV
    local aRarity = ((ConfigTable.GetData)("Achievement", a)).Rarity
    local bRarity = ((ConfigTable.GetData)("Achievement", b)).Rarity
    if aRarity >= bRarity then
      do return aRarity == bRarity end
      if a >= b then
        do return a == b end
        -- DECOMPILER ERROR: 4 unprocessed JMP targets
      end
    end
  end

      ;
      (table.sort)(self.tbAchievement, comp)
      ;
      (table.insert)(mapData, {nType = (AllEnum.SideBaner).Achievement, nId = (self.tbAchievement)[1], nOtherCount = nAchievementCount - 1})
    end
  end
  do
    do
      if next(self.tbDictionaryEntry) ~= nil then
        local nEntryCount = #self.tbDictionaryEntry
        if nEntryCount == 1 then
          (table.insert)(mapData, {nType = (AllEnum.SideBaner).DictionaryEntry, nId = (self.tbDictionaryEntry)[1]})
        else
          ;
          (table.insert)(mapData, {nType = (AllEnum.SideBaner).DictionaryEntry, nId = (self.tbDictionaryEntry)[1], nOtherCount = nEntryCount - 1})
        end
      end
      if next(self.tbFavour) ~= nil then
        local tbChar = {}
        local nFavourCount = 0
        for _,v in ipairs(self.tbFavour) do
          if tbChar[v] == nil then
            tbChar[v] = 1
            nFavourCount = nFavourCount + 1
          end
        end
        if nFavourCount == 1 then
          (table.insert)(mapData, {nType = (AllEnum.SideBaner).Favour, nId = (self.tbFavour)[1]})
        else
          ;
          (table.insert)(mapData, {nType = (AllEnum.SideBaner).Favour, nId = (self.tbFavour)[1], nOtherCount = nFavourCount - 1})
        end
      end
      do
        if next(mapData) == nil then
          return 
        end
        self.tbDictionaryEntry = {}
        self.tbAchievement = {}
        self.tbFavour = {}
        ;
        (EventManager.Hit)("OpenSideBanner", mapData)
      end
    end
  end
end

PlayerSideBannerData.AddDictionaryEntry = function(self, nId)
  -- function num : 0_4 , upvalues : _ENV
  (table.insert)(self.tbDictionaryEntry, nId)
end

PlayerSideBannerData.AddAchievement = function(self, nId)
  -- function num : 0_5 , upvalues : _ENV
  (table.insert)(self.tbAchievement, nId)
end

PlayerSideBannerData.AddFavour = function(self, nId)
  -- function num : 0_6 , upvalues : _ENV
  (table.insert)(self.tbFavour, nId)
end

return PlayerSideBannerData

