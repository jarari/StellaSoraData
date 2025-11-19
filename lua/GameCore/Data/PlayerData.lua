local PlayerData = {back2Login = false, back2Home = false}
PlayerData.Init = function()
  -- function num : 0_0 , upvalues : _ENV, PlayerData
  local PlayerBaseData = require("GameCore.Data.DataClass.PlayerBaseData")
  PlayerData.Base = (PlayerBaseData.new)()
  ;
  (PlayerData.Base):Init()
  local PlayerCoinData = require("GameCore.Data.DataClass.PlayerCoinData")
  PlayerData.Coin = (PlayerCoinData.new)()
  ;
  (PlayerData.Coin):Init()
  local PlayerCharData = require("GameCore.Data.DataClass.PlayerCharData")
  PlayerData.Char = (PlayerCharData.new)()
  ;
  (PlayerData.Char):Init()
  local PlayerTeamData = require("GameCore.Data.DataClass.PlayerTeamData")
  PlayerData.Team = (PlayerTeamData.new)()
  ;
  (PlayerData.Team):Init()
  local PlayerMainlineData = require("GameCore.Data.DataClass.PlayerMainlineDataEx")
  PlayerData.Mainline = (PlayerMainlineData.new)()
  ;
  (PlayerData.Mainline):Init()
  local PlayerRoguelikeData = require("GameCore.Data.DataClass.PlayerRoguelikeData")
  PlayerData.Roguelike = (PlayerRoguelikeData.new)()
  ;
  (PlayerData.Roguelike):Init()
  local PlayerItemData = require("GameCore.Data.DataClass.PlayerItemData")
  PlayerData.Item = (PlayerItemData.new)()
  ;
  (PlayerData.Item):Init()
  local PlayerGachaData = require("GameCore.Data.DataClass.PlayerGachaData")
  PlayerData.Gacha = (PlayerGachaData.new)()
  ;
  (PlayerData.Gacha):Init()
  local PlayerMailData = require("GameCore.Data.DataClass.PlayerMailData")
  PlayerData.Mail = (PlayerMailData.new)()
  ;
  (PlayerData.Mail):Init()
  local PlayerStateData = require("GameCore.Data.DataClass.PlayerStateData")
  PlayerData.State = (PlayerStateData.new)()
  ;
  (PlayerData.State):Init()
  local PlayerBuildData = require("GameCore.Data.DataClass.PlayerBuildData")
  PlayerData.Build = (PlayerBuildData.new)()
  ;
  (PlayerData.Build):Init()
  PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).Mainline
  local PlayerRogueBossData = require("GameCore.Data.DataClass.PlayerRogueBossData")
  PlayerData.RogueBoss = (PlayerRogueBossData.new)()
  ;
  (PlayerData.RogueBoss):Init()
  local PlayerFriendData = require("GameCore.Data.DataClass.PlayerFriendData")
  PlayerData.Friend = (PlayerFriendData.new)()
  ;
  (PlayerData.Friend):Init()
  local PlayerQuestData = require("GameCore.Data.DataClass.PlayerQuestData")
  PlayerData.Quest = (PlayerQuestData.new)()
  ;
  (PlayerData.Quest):Init()
  local PlayerShopData = require("GameCore.Data.DataClass.PlayerShopData")
  PlayerData.Shop = (PlayerShopData.new)()
  ;
  (PlayerData.Shop):Init()
  local PlayerGuideData = require("GameCore.Data.DataClass.PlayerGuideData")
  PlayerData.Guide = (PlayerGuideData.new)()
  ;
  (PlayerData.Guide):Init()
  local PlayerAchievementData = require("GameCore.Data.DataClass.PlayerAchievementData")
  PlayerData.Achievement = (PlayerAchievementData.new)()
  ;
  (PlayerData.Achievement):Init()
  PlayerData.Daily = require("GameCore.Data.DataClass.PlayerDailyData")
  ;
  ((PlayerData.Daily).Init)()
  PlayerData.Mall = require("GameCore.Data.DataClass.PlayerMallData")
  ;
  (PlayerData.Mall):Init()
  local PlayerHandbookData = require("GameCore.Data.DataClass/PlayerHandbookData")
  PlayerData.Handbook = (PlayerHandbookData.new)()
  ;
  (PlayerData.Handbook):Init()
  local PlayerCharSkinData = require("GameCore.Data.DataClass/PlayerCharSkinData")
  PlayerData.CharSkin = (PlayerCharSkinData.new)()
  ;
  (PlayerData.CharSkin):Init()
  local PlayerTravelerDuelData = require("GameCore.Data.DataClass.PlayerTravelerDuelData")
  PlayerData.TravelerDuel = (PlayerTravelerDuelData.new)()
  ;
  (PlayerData.TravelerDuel):Init()
  local PlayerBoardData = require("GameCore.Data.DataClass.PlayerBoardData")
  PlayerData.Board = (PlayerBoardData.new)()
  ;
  (PlayerData.Board):Init()
  local PlayerVoiceData = require("GameCore.Data.DataClass.PlayerVoiceData")
  PlayerData.Voice = (PlayerVoiceData.new)()
  ;
  (PlayerData.Voice):Init()
  local PlayerDailyInstanceData = require("GameCore.Data.DataClass.PlayerDailyInstanceData")
  PlayerData.DailyInstance = (PlayerDailyInstanceData.new)()
  ;
  (PlayerData.DailyInstance):Init()
  local PlayerEquipmentInstanceData = require("GameCore.Data.DataClass.PlayerEquipmentInstanceData")
  PlayerData.EquipmentInstance = (PlayerEquipmentInstanceData.new)()
  ;
  (PlayerData.EquipmentInstance):Init()
  local PlayerSkillInstanceData = require("GameCore.Data.DataClass.PlayerSkillInstanceData")
  PlayerData.SkillInstance = (PlayerSkillInstanceData.new)()
  ;
  (PlayerData.SkillInstance):Init()
  local PlayerCraftingData = require("GameCore.Data.DataClass.PlayerCraftingData")
  PlayerData.Crafting = (PlayerCraftingData.new)()
  ;
  (PlayerData.Crafting):Init()
  local PlayerDictionaryData = require("GameCore.Data.DataClass.PlayerDictionaryData")
  PlayerData.Dictionary = (PlayerDictionaryData.new)()
  ;
  (PlayerData.Dictionary):Init()
  local PlayerActivityData = require("GameCore.Data.DataClass.Activity.PlayerActivityData")
  PlayerData.Activity = (PlayerActivityData.new)()
  ;
  (PlayerData.Activity):Init()
  local PlayerPhoneData = require("GameCore.Data.DataClass.PlayerPhoneData")
  PlayerData.Phone = (PlayerPhoneData.new)()
  ;
  (PlayerData.Phone):Init()
  local PlayerInfinityTowerData = require("GameCore.Data.DataClass.PlayerInfinityTowerData")
  PlayerData.InfinityTower = (PlayerInfinityTowerData.new)()
  ;
  (PlayerData.InfinityTower):Init()
  local PlayerBattlePassData = require("GameCore.Data.DataClass.PlayerBattlePassData")
  PlayerData.BattlePass = (PlayerBattlePassData.new)()
  ;
  (PlayerData.BattlePass):Init()
  local PlayerTalentData = require("GameCore.Data.DataClass.PlayerTalentData")
  PlayerData.Talent = (PlayerTalentData.new)()
  ;
  (PlayerData.Talent):Init()
  local PlayerDiscData = require("GameCore.Data.DataClass.PlayerDiscData")
  PlayerData.Disc = (PlayerDiscData.new)()
  ;
  (PlayerData.Disc):Init()
  local PlayerEquipmentData = require("GameCore.Data.DataClass.PlayerEquipmentDataEx")
  PlayerData.Equipment = (PlayerEquipmentData.new)()
  ;
  (PlayerData.Equipment):Init()
  local PlayerStarTowerData = require("GameCore.Data.DataClass.PlayerStarTowerData")
  PlayerData.StarTower = (PlayerStarTowerData.new)()
  ;
  (PlayerData.StarTower):Init()
  local AvgData = require("GameCore.Data.DataClass.AvgData")
  PlayerData.Avg = (AvgData.new)()
  ;
  (PlayerData.Avg):Init()
  local FilterData = require("GameCore.Data.DataClass.FilterData")
  PlayerData.Filter = (FilterData.new)()
  ;
  (PlayerData.Filter):Init()
  printLog("Player data inited.")
  PlayerData.Dispatch = require("GameCore.Data.DataClass.DispatchData")
  ;
  ((PlayerData.Dispatch).Init)()
  local StarTowerBookData = require("GameCore.Data.DataClass.StarTowerBookData")
  PlayerData.StarTowerBook = (StarTowerBookData.new)()
  ;
  (PlayerData.StarTowerBook):Init()
  local DatingData = require("GameCore.Data.DataClass.PlayerDatingData")
  PlayerData.Dating = (DatingData.new)()
  ;
  (PlayerData.Dating):Init()
  local PlayerVampireSurvivorData = require("GameCore.Data.DataClass.PlayerVampireSurvivorData")
  PlayerData.VampireSurvivor = (PlayerVampireSurvivorData.new)()
  ;
  (PlayerData.VampireSurvivor):Init()
  local PlayerSideBannerData = require("GameCore.Data.DataClass.PlayerSideBannerData")
  PlayerData.SideBanner = (PlayerSideBannerData.new)()
  ;
  (PlayerData.SideBanner):Init()
  local PlayerScoreBossData = require("GameCore.Data.DataClass.PlayerScoreBossData")
  PlayerData.ScoreBoss = (PlayerScoreBossData.new)()
  ;
  (PlayerData.ScoreBoss):Init()
  local GameAnnouncementData = require("GameCore.Data.DataClass.GameAnnouncementData")
  PlayerData.AnnouncementData = (GameAnnouncementData.new)()
  ;
  (PlayerData.AnnouncementData):Init()
  local JointDrillData = require("GameCore.Data.DataClass.PlayerJointDrillData")
  PlayerData.JointDrill = (JointDrillData.new)()
  ;
  (PlayerData.JointDrill):Init()
  local TrialData = require("GameCore.Data.DataClass.PlayerTrialData")
  PlayerData.Trial = (TrialData.new)()
  ;
  (PlayerData.Trial):Init()
  local TutorialData = require("GameCore.Data.DataClass.Tutorial.PlayerTutorialData")
  PlayerData.TutorialData = (TutorialData.new)()
  ;
  (PlayerData.TutorialData):Init()
  local ActivityAvgData = require("GameCore.Data.DataClass.Activity.ActivityAvgData")
  PlayerData.ActivityAvg = (ActivityAvgData.new)()
  ;
  (PlayerData.ActivityAvg):Init()
  local HeadData = require("GameCore.Data.DataClass.PlayerHeadData")
  PlayerData.HeadData = (HeadData.new)()
  ;
  (PlayerData.HeadData):Init()
  local PopUpData = require("GameCore.Data.DataClass.PopUpData")
  PlayerData.PopUp = (PopUpData.new)()
  ;
  (PlayerData.PopUp):Init()
  local StorySet = require("GameCore.Data.DataClass.PlayerStorySetData")
  PlayerData.StorySet = (StorySet.new)()
  ;
  (PlayerData.StorySet):Init()
  local foreachEnumDesc = function(mapData)
    -- function num : 0_0_0 , upvalues : _ENV
    (CacheTable.SetField)("_EnumDesc", mapData.EnumName, mapData.Value, mapData.Key)
  end

  ForEachTableLine(DataTable.EnumDesc, foreachEnumDesc)
end

PlayerData.UnInit = function()
  -- function num : 0_1 , upvalues : PlayerData
  (PlayerData.Base):UnInit()
  ;
  ((PlayerData.Daily).UnInit)()
  PlayerData.Base = nil
  PlayerData.Coin = nil
  PlayerData.Char = nil
  PlayerData.Team = nil
  PlayerData.Mainline = nil
  PlayerData.Roguelike = nil
  PlayerData.Item = nil
  PlayerData.Gacha = nil
  PlayerData.Mail = nil
  PlayerData.State = nil
  PlayerData.Friend = nil
  ;
  (PlayerData.Quest):UnInit()
  PlayerData.Quest = nil
  ;
  (PlayerData.Guide):UnInit()
  PlayerData.Guide = nil
  PlayerData.PlayerFixedRoguelikeData = nil
  ;
  (PlayerData.Shop):UnInit()
  PlayerData.Shop = nil
  PlayerData.Achievement = nil
  ;
  (PlayerData.Mall):UnInit()
  PlayerData.Handbook = nil
  PlayerData.CharSkin = nil
  ;
  (PlayerData.TravelerDuel):UnInit()
  PlayerData.TravelerDuel = nil
  PlayerData.DailyInstance = nil
  ;
  (PlayerData.EquipmentInstance):UnInit()
  PlayerData.EquipmentInstance = nil
  ;
  (PlayerData.SkillInstance):UnInit()
  PlayerData.SkillInstance = nil
  PlayerData.Board = nil
  ;
  (PlayerData.Voice):UnInit()
  PlayerData.Voice = nil
  PlayerData.Dictionary = nil
  ;
  (PlayerData.Activity):UnInit()
  PlayerData.Activity = nil
  PlayerData.Phone = nil
  ;
  (PlayerData.InfinityTower):UnInit()
  PlayerData.InfinityTower = nil
  PlayerData.Talent = nil
  PlayerData.Disc = nil
  PlayerData.Equipment = nil
  PlayerData.Filter = nil
  PlayerData.StarTowerBook = nil
  ;
  (PlayerData.StarTower):UnInit()
  PlayerData.StarTower = nil
  ;
  (PlayerData.Dating):UnInit()
  PlayerData.Dating = nil
  ;
  (PlayerData.Avg):UnInit()
  ;
  (PlayerData.VampireSurvivor):UnInit()
  PlayerData.VampireSurvivor = nil
  ;
  (PlayerData.SideBanner):UnInit()
  PlayerData.SideBanner = nil
  ;
  (PlayerData.ScoreBoss):UnInit()
  PlayerData.ScoreBoss = nil
  PlayerData.AnnouncementData = nil
  ;
  (PlayerData.JointDrill):UnInit()
  PlayerData.JointDrill = nil
  PlayerData.Trial = nil
  PlayerData.StorySet = nil
end

return PlayerData

