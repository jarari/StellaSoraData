------------------------------ local ------------------------------
local PlayerSideBannerData = class("PlayerSideBannerData")
local ModuleManager = require "GameCore.Module.ModuleManager"
-------------------------------------------------------------------
--[[ 样例
    顺序，成就-词条阅读奖励-词条收录-信任度提升
    EventManager.Hit("OpenSideBanner", {
        [1] = {nType = AllEnum.SideBaner.DictionaryEntry, nId = 100101},
        [2] = {nType = AllEnum.SideBaner.DictionaryEntry, nId = 100101, nOtherCount = 2},
        [3] = {nType = AllEnum.SideBaner.DictionaryReward, mapReward = {id = 1, count = 10}},
        [4] = {nType = AllEnum.SideBaner.DictionaryReward, mapReward = {id = 1, count = 10}, nOtherCount = 2},
        [5] = {nType = AllEnum.SideBaner.Favour, nId = 103},
        [6] = {nType = AllEnum.SideBaner.Favour, nId = 103, nOtherCount = 2},
        [7] = {nType = AllEnum.SideBaner.Achievement, nId = 1},
        [8] = {nType = AllEnum.SideBaner.Achievement, nId = 1, nOtherCount = 2},
    })

    self.tbDictionaryEntry = {100101,100201,100301}
    self.tbAchievement = {1,2,3,4,7,12}
]]

------------------------------ public -----------------------------
function PlayerSideBannerData:Init()
    self.tbDictionaryEntry = {}
    self.tbAchievement = {}
    self.tbFavour = {}

    EventManager.Add("DispatchMsgDone", self, self.OnEvent_TryOpenSideBanner)
end

function PlayerSideBannerData:UnInit()
    EventManager.Remove("DispatchMsgDone", self, self.OnEvent_TryOpenSideBanner)
end

function PlayerSideBannerData:OnEvent_TryOpenSideBanner()
    self:TryOpenSideBanner(true)
end

function PlayerSideBannerData:TryOpenSideBanner(bLimit)
    if bLimit and ( -- 可能有很多地方要不立即弹，看需求添加这块的内容
        ModuleManager.GetIsAdventure() or
        PanelManager.GetCurPanelId() == PanelId.Login or
        PanelManager.GetCurPanelId() == PanelId.GachaSpin or
        PanelManager.CheckPanelOpen(PanelId.DatingLandmark) or
        PanelManager.CheckPanelOpen(PanelId.Dating)
    ) then
        return
    end

    local mapData = {}
    -- 成就
    if next(self.tbAchievement) ~= nil then
        local nAchievementCount = #self.tbAchievement
        if nAchievementCount == 1 then
            table.insert(mapData, {nType = AllEnum.SideBaner.Achievement, nId = self.tbAchievement[1]})
        else
            local function comp(a,b)
                local aRarity = ConfigTable.GetData("Achievement", a).Rarity
                local bRarity = ConfigTable.GetData("Achievement", b).Rarity
                if aRarity ~= bRarity then
                    return aRarity < bRarity
                elseif a ~= b then
                    return a < b
                end
            end
            table.sort(self.tbAchievement, comp)
            table.insert(mapData, {nType = AllEnum.SideBaner.Achievement, nId = self.tbAchievement[1], nOtherCount = nAchievementCount - 1})
        end
    end
    -- 词条收录
    if next(self.tbDictionaryEntry) ~= nil then
        local nEntryCount = #self.tbDictionaryEntry
        if nEntryCount == 1 then
            table.insert(mapData, {nType = AllEnum.SideBaner.DictionaryEntry, nId = self.tbDictionaryEntry[1]})
        else
            table.insert(mapData, {nType = AllEnum.SideBaner.DictionaryEntry, nId = self.tbDictionaryEntry[1], nOtherCount = nEntryCount - 1})
        end
    end
    -- 信任度提升
    if next(self.tbFavour) ~= nil then
        local tbChar = {}
        local nFavourCount = 0
        for _, v in ipairs(self.tbFavour) do
            if tbChar[v] == nil then
                tbChar[v] = 1
                nFavourCount = nFavourCount + 1
            end
        end
        if nFavourCount == 1 then
            table.insert(mapData, {nType = AllEnum.SideBaner.Favour, nId = self.tbFavour[1]})
        else
            table.insert(mapData, {nType = AllEnum.SideBaner.Favour, nId = self.tbFavour[1], nOtherCount = nFavourCount - 1})
        end
    end

    if next(mapData) == nil then
        return
    end

    self.tbDictionaryEntry = {}
    self.tbAchievement = {}
    self.tbFavour = {}
    EventManager.Hit("OpenSideBanner", mapData)
end

function PlayerSideBannerData:AddDictionaryEntry(nId)
    table.insert(self.tbDictionaryEntry, nId)
end

function PlayerSideBannerData:AddAchievement(nId)
    table.insert(self.tbAchievement, nId)
end

function PlayerSideBannerData:AddFavour(nId)
    table.insert(self.tbFavour, nId)
end

return PlayerSideBannerData
