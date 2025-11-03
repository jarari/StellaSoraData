--[[
红点配置
   红点路径定义UI穿透规则
   可变参数用<param>配置
]]
local RedDotDefine = {
   --根节点
   Root = "Root",

   --邮件
   Mail = "Mail",
   Mail_UnRead = "Mail.UnRead",       --未读邮件
   Mail_UnReceive = "Mail.UnReceive", --未领取奖励邮件
   Mail_New = "Mail.New",             --新邮件

   --任务
   Task = "Task",
   Task_Daily = "Task.Daily", --日常任务
   Task_Guide = "Task.Guide", --手册任务

   --旅团等级任务
   WorldClass = "Task.WorldClass",
   WorldClass_LevelUp = "Task.WorldClass.LevelUp.<param>",
   WorldClass_Advance = "Task.WorldClass.Advance.<param>",

   --角色
   Role = "Role",
   Role_Item = "Role.Item.<param>",
   Role_Upgrade = "Role.Item.<param>.Upgrade",                             -- 升级入口
   Role_AdvanceReward = "Role.Item.<param>.Upgrade.AdvanceReward.<param>", -- 升阶奖励
   Role_Talent = "Role.Item.<param>.Talent",                               -- 天赋入口红点
   Role_Relation = "Role.Item.<param>.Relation",                           -- 档案入口红点
   Role_AffinityTask = "Role.Item.<param>.Relation.AffinityTask",          -- 好感度任务
   Role_AffinityPlot = "Role.Item.<param>.Relation.Plot",                  -- 好感度剧情红点
   Role_AffinityPlotItem = "Role.Item.<param>.Relation.Plot.<param>",      -- 好感度剧情红点
   Role_RecordReward = "Role.Item.<param>.Relation.Record",                -- 档案信息页签奖励红点
   Role_RecordRewardItem = "Role.Item.<param>.Relation.Record.<param>",    -- 档案信息奖励红点
   --以下为不穿透的红点
   Role_Record_Info = "RecordInfo.<param>",                                -- 档案页签红点（不穿透）
   Role_Record_Info_Item = "RecordInfo.<param>.Info.<param>",              -- 新解锁档案红点（不穿透）
   Role_Record_InfoUpdate_Item = "RecordInfo.<param>.Update.<param>",      -- 档案更新红点（不穿透）
   Role_Record_BaseInfoUpdate_Item = "RecordInfo.<param>.BaseInfo_Update", -- 档案基本信息更新红点（不穿透）
   Role_Record_Voice = "RecordVoice.<param>",                              -- 档案语音页签红点（不穿透）
   Role_Record_Voice_Item = "RecordVoice.<param>.<param>",                 -- 新解锁语音红点（不穿透）
   
   --关卡入口
   Map = "Map",
   --主线
   Map_MainLine = "MainLine",
   Map_MainLine_Entrance = "MainLine.Entrance", --主线入口红点
   Map_MainLine_Chapter = "MainLine.Entrance.Chapter.<param>", --主线章节红点
   Map_MainLine_Reward = "MainLine.Entrance.Reward.<param>", --主线章节奖励
   MainStoryClue="Clue",
   MianStoryClue_Use="Clue.Use.<param>",--主线的线索
   Story_Set = "MainLine.StorySet",             --故事集入口
   Story_Set_Server = "MainLine.StorySet.Server",      --故事集入口(登录时服务器下发的红点)
   Story_Set_Chapter = "MainLine.StorySet.<param>",     --故事集章节
   Story_Set_Section = "MainLine.StorySet.<param>.<param>",     --故事集小节
   
   --旅人对决
   Map_TravelerDuel = "TravelerDuel",
   Task_Season = "TravelerDuel.Season.Task", --赛季任务
   Task_Duel = "TravelerDuel.Duel.Task",     --对决任务
   --无尽塔
   Map_Infinity = "Map.Infinity",
   Map_InfinityTowerDaily = "Map.Infinity.Daily",
   Map_InfinityTowerPlot = "Map.Infinity.Plot",

   --资源任务
   Map_Resource = "Map.Resource",
   Map_RogueBoss = "Map.Resource.RogueBoss",--区域boss

   --商城
   Mall = "Mall",
   Mall_Free = "Mall.Free",             --免费礼包页签
   FreePackage = "FreePackage.<param>", --免费礼包

   --好友
   Friend = "Friend",
   Friend_Apply = "Friend.Apply",                   --好友申请
   Friend_Energy = "Friend.Energy",                 --好友赠送体力
   Friend_Info = "Friend.Info",                     --个人信息
   Friend_Info_Title = "Friend.Info.Title",         --头衔
   Friend_Title_Item = "Friend.Info.Title.<param>", --头衔条目
   Friend_Info_Head = "Friend.Info.Head",           --头像
   Friend_Head_Item = "Friend.Info.Head.<param>",   --头像条目
   Friend_Honor_Title = "Friend.Info.HonorTitle",    --荣誉称号
   Friend_Honor_Title_Item = "Friend.Info.HonorTitle.<param>",    --荣誉称号条目

   --字典
   Dictionary = "Menu.Dictionary",
   Dictionary_Main = "Menu.Dictionary.Main.<param>",
   Dictionary_Sub = "Menu.Dictionary.Main.<param>.Sub.<param>",

   --活动
   Activity = "Activity",
   Activity_Tab = "Activity.Tab.<param>", -- 登录时服务器下发的红点状态
   Activity_TabNew = "Activity.TabNew.<param>",
   Activity_Periodic_Quest_Group = "Activity.<param>.Periodic.<param>",
   Activity_Periodic_Final_Reward = "Activity.<param>.Final",
   Activity_Mining_Quest_Group="Activity.MiningQuestGroup",
   Activity_Mining_Quest="Activity.MiningQuestGroup.<param>",
   Activity_TowerDefense_LevelTab="Activity.TowerDefense.Level.<param>",
   Activity_TowerDefense_Level="Activity.TowerDefense.Level.<param>.<param>",
   Activity_TowerDefense_AllStory="Activity.TowerDefense.Story",
   Activity_TowerDefense_Story="Activity.TowerDefense.Story.<param>",
   Activity_TowerDefense_AllQuest="Activity.TowerDefense.Quest",
   Activity_TowerDefense_QuestGroup="Activity.TowerDefense.Quest.<param>",
   Activity_TowerDefense_Quest="Activity.TowerDefense.Quest.<param>.<param>",
   Activity_Group = "Activity.Group.<param>", -- 活动组红点
   Activity_GroupNew = "Activity.GroupNew.<param>",
   Activity_Group_Task = "Activity.Group.<param>.Task.<param>", -- 泳装活动红点，普通
   Activity_Group_Task_Group = "Activity.Group.<param>.Task.<param>.<param>", -- 泳装活动任务红点
   Activity_GroupNew_Avg = "Activity.GroupNew.<param>.Avg.<param>", -- 泳装活动红点,新
   Activity_GroupNew_Avg_Group = "Activity.GroupNew.<param>.Avg.<param>.<param>", -- 泳装活动avg红点
   --中型活动关卡
   ActivityLevel = "Activity.GroupNew.<param>.ActivityLevel",
   ActivityLevel_Explore = "Activity.GroupNew.<param>.ActivityLevel.Explore",--普通关卡
   ActivityLevel_Explore_Level = "Activity.GroupNew.<param>.ActivityLevel.Explore.<param>",--普通关卡
   ActivityLevel_Adventure = "Activity.GroupNew.<param>.ActivityLevel.Adventure",--挑战关卡
   ActivityLevel_Adventure_Level = "Activity.GroupNew.<param>.ActivityLevel.Adventure.<param>",--挑战关卡
   

   --手机
   Phone = "Phone",
   Phone_Chat = "Phone.Chat",
   Phone_New = "Phone.Chat.New",
   Phone_UnComplete = "Phone_UnComplete",
   Phone_New_Item = "Phone.Chat.New.<param>",
   Phone_UnComplete_Item = "Phone_UnComplete_Item.<param>",
   Phone_Dating = "Phone.Dating",
   Phone_Dating_Char = "Phone.Dating.Char.<param>",
   Phone_Dating_Reward = "Phone.Dating.Char.<param>.Reward.<param>",

   --战令
   BattlePass = "BattlePass",

   BattlePass_Quest = "BattlePass.Quest",
   BattlePass_Quest_Server = "BattlePass.Quest.Server",
   BattlePass_Quest_Daily = "BattlePass.Quest.Daily",
   BattlePass_Quest_Week = "BattlePass.Quest.Week",
   BattlePass_Reward = "BattlePass.Reward",

   --菜单
   Menu = "Menu",

   --星盘
   Disc = "Disc",
   Disc_Item = "Disc.Item.<param>",
   Disc_BreakLimit = "Disc.Item.<param>.BreakLimit",
   Disc_BreakBtn = "Disc.Item.<param>.BreakLimit.BreakBtn",
   Disc_Music = "Disc.Item.<param>.Music",
   Disc_SideB = "Disc.Item.<param>.Music.SideB",
   Disc_SideB_Read = "Disc.Item.<param>.Music.SideB.Read",
   Disc_SideB_Avg = "Disc.Item.<param>.Music.SideB.Avg",

   --物资（占位用）
   Depot = "Depot",

   -- 商店
   Shop = "Shop",
   Shop_Daily = "Shop.Daily",

   --星塔图鉴
   StarTowerBook = "StarTowerBook",
   StarTowerBook_Potential = "StarTowerBook.Potential",
   StarTowerBook_Potential_Element = "StarTowerBook.Potential.Element.<param>",
   StarTowerBook_Potential_Char = "StarTowerBook.Potential.Element.<param>.Char.<param>",
   StarTowerBook_Potential_Reward = "StarTowerBook.Potential.Element.<param>.Char.<param>.Reward",
   StarTowerBook_Potential_New = "PotentialNew.<param>",

   StarTowerBook_FateCard = "StarTowerBook.FateCard",
   StarTowerBook_FateCard_Bundle = "StarTowerBook.FateCard.<param>",
   StarTowerBook_FateCard_Bundle_Tog = "StarTowerBook.FateCard.<param>.Tog",
   StarTowerBook_FateCard_Reward = "StarTowerBook.FateCard.<param>.Tog.Reward",
   StarTowerBook_FateCard_New = "FateCardNew.<param>",

   StarTowerBook_Event = "StarTowerBook.Event",
   StarTowerBook_Event_Reward = "StarTowerBook.Event.<param>.Reward",

   StarTowerBook_Affinity = "StarTowerBook.Affinity",
   StarTowerBook_Affinity_Reward = "StarTowerBook.Affinity.<param>",
   -- 公告
   Notice = "Notice",

   -- 派遣
   Dispatch = "Dispatch",
   Dispatch_Tab = "Dispatch.Tab.<param>",
   Dispatch_Reward = "Dispatch.Tab.<param>.Reward.<param>",

   --星塔养成
   StarTowerGrowth = "StarTowerGrowth",

   --星塔任务
   StarTowerQuest = "StarTowerQuest",

   --成就
   Achievement="Menu.Achievement",
   Achievement_Tab="Menu.Achievement.Tab.<param>",

   --公告
   Announcement="Announcement",
   Announcement_Tab="Announcement.Tab.<param>",
   Announcement_Content="Announcement.Tab.<param>.Content.<param>",

   --无尽塔
   Map_ScoreBoss = "Map.ScoreBoss",
   Map_ScoreBossStar = "Map.ScoreBoss.Star",

   --吸血鬼任务
   VampireQuest = "VampireQuest",
   VampireQuest_Normal = "VampireQuest.Normal",
   VampireQuest_Hard = "VampireQuest.Hard",
   VampireQuest_Season = "VampireQuest.Season",

   VampireTalent = "VampireTalent",
   
   
   --总力战任务
   JointDrillQuest = "JointDrillQuest",
}

return RedDotDefine
