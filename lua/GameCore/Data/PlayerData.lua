-- 动态数据管理（服务器发来的玩家数据）
local PlayerData = {
    back2Login = false,
    back2Home = false,
}

function PlayerData.Init()
    --[[
        所有客户端缓存服务器发来的数据，都在此处写一下定义，即便是无意义�? = nil，也写一下�?
        此处当作头文件阅读，方便协作开发人员查找数据�?
        必要的话，某些数据可以先初始化好 table 结构�?
        �? table 的话，尽量注释写一下大致结构�?

        2021.7.7
        将数据拆分为lua类保�? 在同目录的DataClass目录�?
    ]]

    -- 玩家基础数据
    local PlayerBaseData = require "GameCore.Data.DataClass.PlayerBaseData"
    PlayerData.Base = PlayerBaseData.new()
    PlayerData.Base:Init()

    -- 玩家拥有的货币资源数�?
    local PlayerCoinData = require "GameCore.Data.DataClass.PlayerCoinData"
    PlayerData.Coin = PlayerCoinData.new()
    PlayerData.Coin:Init()

    -- 玩家拥有的角色数�?
    local PlayerCharData = require "GameCore.Data.DataClass.PlayerCharData"
    PlayerData.Char = PlayerCharData.new()
    PlayerData.Char:Init()

    -- 玩家编队数据
    local PlayerTeamData = require "GameCore.Data.DataClass.PlayerTeamData"
    PlayerData.Team = PlayerTeamData.new()
    PlayerData.Team:Init()

    -- 玩家主线关卡通关数据
    local PlayerMainlineData = require "GameCore.Data.DataClass.PlayerMainlineDataEx"
    PlayerData.Mainline = PlayerMainlineData.new()
    PlayerData.Mainline:Init()

    -- 玩家随机关卡数据（临时）
    local PlayerRoguelikeData = require "GameCore.Data.DataClass.PlayerRoguelikeData"
    PlayerData.Roguelike = PlayerRoguelikeData.new()
    PlayerData.Roguelike:Init()

    --玩家物品数据
    local PlayerItemData = require "GameCore.Data.DataClass.PlayerItemData"
    PlayerData.Item = PlayerItemData.new()
    PlayerData.Item:Init()

    --玩家抽卡数据
    local PlayerGachaData = require "GameCore.Data.DataClass.PlayerGachaData"
    PlayerData.Gacha = PlayerGachaData.new()
    PlayerData.Gacha:Init()

    --玩家邮件数据
    local PlayerMailData = require "GameCore.Data.DataClass.PlayerMailData"
    PlayerData.Mail = PlayerMailData.new()
    PlayerData.Mail:Init()

    --玩家状态数�?
    local PlayerStateData = require "GameCore.Data.DataClass.PlayerStateData"
    PlayerData.State = PlayerStateData.new()
    PlayerData.State:Init()

    -- 玩家build数据新版
    local PlayerBuildData = require "GameCore.Data.DataClass.PlayerBuildData"
    PlayerData.Build = PlayerBuildData.new()
    PlayerData.Build:Init()

    PlayerData.nCurGameType = AllEnum.WorldMapNodeType.Mainline

    --玩家地区boss数据
    local PlayerRogueBossData = require "GameCore.Data.DataClass.PlayerRogueBossData"
    PlayerData.RogueBoss = PlayerRogueBossData.new()
    PlayerData.RogueBoss:Init()

    --玩家好友数据
    local PlayerFriendData = require "GameCore.Data.DataClass.PlayerFriendData"
    PlayerData.Friend = PlayerFriendData.new()
    PlayerData.Friend:Init()

    --玩家任务数据
    local PlayerQuestData = require "GameCore.Data.DataClass.PlayerQuestData"
    PlayerData.Quest = PlayerQuestData.new()
    PlayerData.Quest:Init()

    --玩家商店数据
    local PlayerShopData = require "GameCore.Data.DataClass.PlayerShopData"
    PlayerData.Shop = PlayerShopData.new()
    PlayerData.Shop:Init()

    --玩家引导数据
    local PlayerGuideData = require "GameCore.Data.DataClass.PlayerGuideData"
    PlayerData.Guide = PlayerGuideData.new()
    PlayerData.Guide:Init()

    --玩家成就数据
    local PlayerAchievementData = require "GameCore.Data.DataClass.PlayerAchievementData"
    PlayerData.Achievement = PlayerAchievementData.new()
    PlayerData.Achievement:Init()

    --玩家每日数据
    PlayerData.Daily = require "GameCore.Data.DataClass.PlayerDailyData"
    PlayerData.Daily.Init()

    --玩家氪金商城数据
    PlayerData.Mall = require "GameCore.Data.DataClass.PlayerMallData"
    PlayerData.Mall:Init()

    --玩家图鉴数据
    local PlayerHandbookData = require "GameCore.Data.DataClass/PlayerHandbookData"
    PlayerData.Handbook = PlayerHandbookData.new()
    PlayerData.Handbook:Init()

    --玩家皮肤数据
    local PlayerCharSkinData = require "GameCore.Data.DataClass/PlayerCharSkinData"
    PlayerData.CharSkin = PlayerCharSkinData.new()
    PlayerData.CharSkin:Init()

    --对决数据
    local PlayerTravelerDuelData = require "GameCore.Data.DataClass.PlayerTravelerDuelData"
    PlayerData.TravelerDuel = PlayerTravelerDuelData.new()
    PlayerData.TravelerDuel:Init()

    --看板数据
    local PlayerBoardData = require "GameCore.Data.DataClass.PlayerBoardData"
    PlayerData.Board = PlayerBoardData.new()
    PlayerData.Board:Init()
    
    --角色音频数据
    local PlayerVoiceData = require "GameCore.Data.DataClass.PlayerVoiceData"
    PlayerData.Voice = PlayerVoiceData.new()
    PlayerData.Voice:Init()

    --日常副本数据
    local PlayerDailyInstanceData = require "GameCore.Data.DataClass.PlayerDailyInstanceData"
    PlayerData.DailyInstance = PlayerDailyInstanceData.new()
    PlayerData.DailyInstance:Init()

    --装备副本数据
    local PlayerEquipmentInstanceData = require "GameCore.Data.DataClass.PlayerEquipmentInstanceData"
    PlayerData.EquipmentInstance = PlayerEquipmentInstanceData.new()
    PlayerData.EquipmentInstance:Init()

    --技能素材本数据
    local PlayerSkillInstanceData = require "GameCore.Data.DataClass.PlayerSkillInstanceData"
    PlayerData.SkillInstance = PlayerSkillInstanceData.new()
    PlayerData.SkillInstance:Init()

    ----露营
    --PlayerData.PlayerCampingData = require "GameCore.Data.DataClass.PlayerCampingData"
    --PlayerData.PlayerCampingData = PlayerData.PlayerCampingData.new()
    --PlayerData.PlayerCampingData:Init()
    
    --材料合成
    local PlayerCraftingData = require "GameCore.Data.DataClass.PlayerCraftingData"
    PlayerData.Crafting = PlayerCraftingData.new()
    PlayerData.Crafting:Init()

    --玩家字典数据
    local PlayerDictionaryData = require "GameCore.Data.DataClass.PlayerDictionaryData"
    PlayerData.Dictionary = PlayerDictionaryData.new()
    PlayerData.Dictionary:Init()

    --玩家活动数据
    local PlayerActivityData = require "GameCore.Data.DataClass.Activity.PlayerActivityData"
    PlayerData.Activity = PlayerActivityData.new()
    PlayerData.Activity:Init()
    
    --手机数据
    local PlayerPhoneData = require "GameCore.Data.DataClass.PlayerPhoneData"
    PlayerData.Phone = PlayerPhoneData.new()
    PlayerData.Phone:Init()

    --无尽塔数据
    local PlayerInfinityTowerData = require "GameCore.Data.DataClass.PlayerInfinityTowerData"
    PlayerData.InfinityTower = PlayerInfinityTowerData.new()
    PlayerData.InfinityTower:Init()

    --战令数据
    local PlayerBattlePassData = require "GameCore.Data.DataClass.PlayerBattlePassData"
    PlayerData.BattlePass = PlayerBattlePassData.new()
    PlayerData.BattlePass:Init()

    --天赋数据
    local PlayerTalentData = require "GameCore.Data.DataClass.PlayerTalentData"
    PlayerData.Talent = PlayerTalentData.new()
    PlayerData.Talent:Init()

    --天赋数据
    local PlayerDiscData = require "GameCore.Data.DataClass.PlayerDiscData"
    PlayerData.Disc = PlayerDiscData.new()
    PlayerData.Disc:Init()

    --装备数据
    local PlayerEquipmentData = require "GameCore.Data.DataClass.PlayerEquipmentDataEx"
    PlayerData.Equipment = PlayerEquipmentData.new()
    PlayerData.Equipment:Init()

    --星塔数据
    local PlayerStarTowerData = require "GameCore.Data.DataClass.PlayerStarTowerData"
    PlayerData.StarTower = PlayerStarTowerData.new()
    PlayerData.StarTower:Init()

    -- Avg数据（旅行故事（主线关卡））
    local AvgData = require "GameCore.Data.DataClass.AvgData"
    PlayerData.Avg = AvgData.new()
    PlayerData.Avg:Init()

    -- 筛选数据
    local FilterData = require "GameCore.Data.DataClass.FilterData"
    PlayerData.Filter = FilterData.new()
    PlayerData.Filter:Init()
    printLog("Player data inited.")

    --派遣功能
    PlayerData.Dispatch = require"GameCore.Data.DataClass.DispatchData"
    PlayerData.Dispatch.Init()
    
    --星塔图鉴
    local StarTowerBookData = require "GameCore.Data.DataClass.StarTowerBookData"
    PlayerData.StarTowerBook = StarTowerBookData.new()
    PlayerData.StarTowerBook:Init()
    
    --约会数据
    local DatingData = require "GameCore.Data.DataClass.PlayerDatingData"
    PlayerData.Dating = DatingData.new()
    PlayerData.Dating:Init()

    --吸血鬼
    local PlayerVampireSurvivorData = require "GameCore.Data.DataClass.PlayerVampireSurvivorData"
    PlayerData.VampireSurvivor = PlayerVampireSurvivorData.new()
    PlayerData.VampireSurvivor:Init()

    --侧边栏数据
    local PlayerSideBannerData = require "GameCore.Data.DataClass.PlayerSideBannerData"
    PlayerData.SideBanner = PlayerSideBannerData.new()
    PlayerData.SideBanner:Init()

    --Video
    local PlayerVideoData = require "GameCore.Data.DataClass.PlayerVideoData"
    PlayerData.AVProVideo = PlayerVideoData.new()
    PlayerData.AVProVideo:Init()

    --Boss积分挑战 数据
    local PlayerScoreBossData = require "GameCore.Data.DataClass.PlayerScoreBossData"
    PlayerData.ScoreBoss = PlayerScoreBossData.new()
    PlayerData.ScoreBoss:Init()

    --公告数据
    local GameAnnouncementData=require "GameCore.Data.DataClass.GameAnnouncementData"
    PlayerData.AnnouncementData=GameAnnouncementData.new()
    PlayerData.AnnouncementData:Init()

    --总力战数据
    local JointDrillData =require "GameCore.Data.DataClass.PlayerJointDrillData"
    PlayerData.JointDrill = JointDrillData.new()
    PlayerData.JointDrill:Init()

    -- 试玩数据
    local TrialData = require "GameCore.Data.DataClass.PlayerTrialData"
    PlayerData.Trial = TrialData.new()
    PlayerData.Trial:Init()

    --教学关数据
    local TutorialData=require"GameCore.Data.DataClass.Tutorial.PlayerTutorialData"
    PlayerData.TutorialData = TutorialData.new()
    PlayerData.TutorialData:Init()

    -- 活动剧情数据
    local ActivityAvgData = require "GameCore.Data.DataClass.Activity.ActivityAvgData"
    PlayerData.ActivityAvg = ActivityAvgData.new()
    PlayerData.ActivityAvg:Init()

    -- 头像数据
    local HeadData = require "GameCore.Data.DataClass.PlayerHeadData"
    PlayerData.HeadData = HeadData.new()
    PlayerData.HeadData:Init()

    -- 弹框，打脸公告数据
    local PopUpData = require "GameCore.Data.DataClass.PopUpData"
    PlayerData.PopUp = PopUpData.new()
    PlayerData.PopUp:Init()

    -- 故事集
    local StorySet = require "GameCore.Data.DataClass.PlayerStorySetData"
    PlayerData.StorySet = StorySet.new()
    PlayerData.StorySet:Init()

    local function foreachEnumDesc(mapData)
        CacheTable.SetField("_EnumDesc", mapData.EnumName, mapData.Value, mapData.Key)
    end
    ForEachTableLine(DataTable.EnumDesc,foreachEnumDesc)
end

function PlayerData.UnInit()
    PlayerData.Base:UnInit()
    PlayerData.Daily.UnInit()
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
    PlayerData.Quest:UnInit()
    PlayerData.Quest = nil
    PlayerData.Guide:UnInit()
    PlayerData.Guide = nil
    PlayerData.PlayerFixedRoguelikeData = nil
    PlayerData.Shop:UnInit()
    PlayerData.Shop = nil
    PlayerData.Achievement = nil
    PlayerData.Mall:UnInit()
    PlayerData.Handbook = nil
    PlayerData.CharSkin = nil
    PlayerData.TravelerDuel:UnInit()
    PlayerData.TravelerDuel = nil
    PlayerData.DailyInstance = nil
    PlayerData.EquipmentInstance:UnInit()
    PlayerData.EquipmentInstance = nil
    PlayerData.SkillInstance:UnInit()
    PlayerData.SkillInstance = nil
    --PlayerData.PlayerCampingData = nil
    PlayerData.Board = nil
    PlayerData.Voice:UnInit()
    PlayerData.Voice = nil
    PlayerData.Dictionary = nil
    PlayerData.Activity:UnInit()
    PlayerData.Activity = nil
    PlayerData.Phone = nil
    PlayerData.InfinityTower:UnInit()
    PlayerData.InfinityTower = nil
    PlayerData.Talent = nil
    PlayerData.Disc = nil
    PlayerData.Equipment = nil
    PlayerData.Filter = nil
    PlayerData.StarTowerBook = nil
    PlayerData.StarTower:UnInit()
    PlayerData.StarTower = nil
    PlayerData.Dating:UnInit()
    PlayerData.Dating = nil
    PlayerData.Avg:UnInit()
    PlayerData.VampireSurvivor:UnInit()
    PlayerData.VampireSurvivor = nil
    PlayerData.SideBanner:UnInit()
    PlayerData.SideBanner = nil
    PlayerData.AVProVideo:UnInit()
    PlayerData.AVProVideo = nil
    PlayerData.ScoreBoss:UnInit()
    PlayerData.ScoreBoss = nil
    PlayerData.AnnouncementData=nil
    PlayerData.JointDrill:UnInit()
    PlayerData.JointDrill = nil
    PlayerData.Trial = nil
    PlayerData.StorySet = nil
end
return PlayerData
