local PB = require("pb")
local TimerManager = require("GameCore.Timer.TimerManager")
local TimerResetType = require("GameCore.Timer.TimerResetType")
local HttpNetHandlerPlus = require("GameCore.Network.HttpNetHandlerPlus")
local HttpNetHandler = {}
local mapProcessFunction = nil
local mapNetMsgIdFailed = {}
local timerPingPong = nil
local PING_PONG_INTERVAL = 120
local TBRELOGIN_CODE = {110107, 10003, 110106, 100106}
local SetTokenAES = function(sToken, pubKey, Cipher)
  -- function num : 0_0 , upvalues : _ENV
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  NovaAPI.TOKEN = sToken
  ;
  (NovaAPI.SetAeadKey)(pubKey, Cipher)
end

local SetToken = function(sToken)
  -- function num : 0_1 , upvalues : _ENV
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R1 in 'UnsetPending'

  NovaAPI.TOKEN = sToken
end

local MakeNetMsgIdMap = function()
  -- function num : 0_2 , upvalues : _ENV, mapNetMsgIdFailed
  for k,v in pairs(NetMsgId.Id) do
    if (string.find)(k, "_req") ~= nil then
      local fail = (string.gsub)(k, "_req", "_failed_ack")
      local nId_fail = (NetMsgId.Id)[fail]
      if nId_fail ~= nil then
        mapNetMsgIdFailed[v] = nId_fail
      end
    end
  end
end

local ProcChangeInfo = function(mapDecodedChangeInfo)
  -- function num : 0_3 , upvalues : _ENV
  (PlayerData.Coin):ChangeCoin(mapDecodedChangeInfo["proto.Res"])
  ;
  (PlayerData.Item):ChangeItem(mapDecodedChangeInfo["proto.Item"])
  ;
  (PlayerData.Char):GetNewChar(mapDecodedChangeInfo["proto.Char"])
  ;
  (PlayerData.Base):ChangeEnergy(mapDecodedChangeInfo["proto.Energy"])
  ;
  (PlayerData.Base):ChangeWorldClass(mapDecodedChangeInfo["proto.WorldClass"])
  ;
  (PlayerData.Base):ChangeTitle(mapDecodedChangeInfo["proto.Title"])
  ;
  (PlayerData.Disc):CreateNewDisc(mapDecodedChangeInfo["proto.Disc"])
  ;
  (PlayerData.Base):ChangeHonorTitle(mapDecodedChangeInfo["proto.Honor"])
  ;
  (PlayerData.HeadData):ChangePlayerHead(mapDecodedChangeInfo["proto.HeadIcon"])
end

local NOTHING_NEED_TO_BE_DONE = function(mapData)
  -- function num : 0_4
end

local ike_succeed_ack = function(mapData)
  -- function num : 0_5 , upvalues : SetTokenAES, _ENV
  SetTokenAES(mapData.Token, mapData.PubKey, mapData.Cipher)
  ;
  (NovaAPI.MarkServerTimeStamp)(mapData.ServerTs)
end

local ike_failed_ack = function(mapData)
  -- function num : 0_6 , upvalues : _ENV
  (EventManager.Hit)("LoginFailed")
end

local player_login_succeed_ack = function(mapMsgData)
  -- function num : 0_7 , upvalues : SetToken
  SetToken(mapMsgData.Token)
end

local player_login_failed_ack = function(mapMsgData)
  -- function num : 0_8 , upvalues : _ENV
  (EventManager.Hit)("LoginFailed")
  ;
  (NovaAPI.ResetIke)()
end

local player_data_succeed_ack = function(mapMsgData)
  -- function num : 0_9 , upvalues : _ENV
  (PopUpManager.InitLoginQueue)()
  ;
  (NovaAPI.MarkServerTimeStamp)(mapMsgData.ServerTs)
  ;
  (PlayerData.Base):CacheAccInfo(mapMsgData.Acc)
  ;
  (PlayerData.Base):CacheEnergyInfo(mapMsgData.Energy)
  ;
  (PlayerData.Base):CacheTitleInfo(mapMsgData.Titles)
  ;
  (PlayerData.Base):CacheHonorTitleInfo(mapMsgData.Honors)
  ;
  (PlayerData.Base):CacheHonorTitleList(mapMsgData.HonorList)
  ;
  (PlayerData.Base):CacheWorldClassInfo(mapMsgData.WorldClass)
  ;
  (PlayerData.Base):CacheSendGiftCount(mapMsgData.SendGiftCnt)
  ;
  (PlayerData.Base):CacheRenameTime(mapMsgData.NicknameResetTime)
  ;
  (PlayerData.Coin):CacheCoin(mapMsgData.Res)
  ;
  (PlayerData.Char):CacheCharacters(mapMsgData.Chars)
  ;
  (PlayerData.Team):CacheFormationInfo(mapMsgData.Formation)
  ;
  (PlayerData.Item):CacheItemData(mapMsgData.Items)
  ;
  (PlayerData.Activity):CacheActivityData(mapMsgData.Activities)
  ;
  (PlayerData.State):CacheStateData(mapMsgData.State)
  ;
  (PlayerData.RogueBoss):CacheRogueBossData(mapMsgData.RegionBossLevels)
  ;
  (PlayerData.RogueBoss):CacheWeeklyCopiesData(mapMsgData.WeekBossLevels)
  ;
  (PlayerData.Quest):CacheTourGroupOrder(mapMsgData.TourGuideQuestGroup)
  ;
  (PlayerData.Quest):CacheAllQuest((mapMsgData.Quests).List)
  ;
  (PlayerData.Quest):CacheDailyActiveIds(mapMsgData.DailyActiveIds)
  ;
  (PlayerData.Achievement):CacheBattleAchievementData(mapMsgData.Achievements)
  ;
  ((PlayerData.Daily).CacheDailyData)(mapMsgData.SigninIndex)
  ;
  (PlayerData.Handbook):CacheHandbookData(mapMsgData.Handbook)
  ;
  (PlayerData.Board):CacheBoardData(mapMsgData.Board)
  ;
  (PlayerData.DailyInstance):CacheDailyInstanceLevel(mapMsgData.DailyInstances)
  ;
  (PlayerData.Dictionary):CacheDictionaryData(mapMsgData.Dictionaries)
  ;
  (PlayerData.Phone):CachePhoneMsgCount(mapMsgData.Phone)
  ;
  (PlayerData.Disc):CacheDiscData(mapMsgData.Discs)
  ;
  (PlayerData.Disc):CacheBGMDisc(mapMsgData.MusicInfo)
  ;
  (PlayerData.EquipmentInstance):CacheEquipmentInstanceLevel(mapMsgData.CharGemInstances)
  ;
  (PlayerData.StarTower):CachePassedId(mapMsgData.RglPassedIds)
  ;
  (PlayerData.Avg):CacheAvgData(mapMsgData.Story)
  ;
  (PlayerData.StarTower):CacheStarTowerTicket(mapMsgData.TowerTicket)
  ;
  (PlayerData.Shop):CacheDailyShopReward(mapMsgData.DailyShopRewardStatus)
  ;
  (PlayerData.Dating):CacheDatingCharIds(mapMsgData.DatingCharIds)
  ;
  (PlayerData.VampireSurvivor):CacheLevelData(mapMsgData.VampireSurvivorRecord)
  ;
  (PlayerData.SkillInstance):CacheSkillInstanceLevel(mapMsgData.SkillInstances)
  ;
  (NovaAPI.SetRetryCount)()
  ;
  (PlayerData.Base):SetNextRefreshTime(mapMsgData.ServerTs)
  ;
  ((PlayerData.Dispatch).CacheDispatchData)(mapMsgData.Agent)
  ;
  (PlayerData.Activity):CacheActivityGroupData()
  ;
  (PlayerData.PopUp):RefreshPopUp()
  ;
  (PlayerData.TutorialData):CacheTutorialData(mapMsgData.TutorialLevels)
  ;
  (PlayerData.Char):UpdateAllCharRecordInfoRedDot()
  if ((CS.SDKManager).Instance):IsSDKInit() then
    ((CS.SDKManager).Instance):RoleInfoUpload(tostring((PlayerData.Base)._nPlayerId), (PlayerData.Base)._sPlayerNickName, mapMsgData.ServerTs)
  end
  ;
  (PlayerData.Talent):UpdateAllCharTalentRedDot()
  ;
  (PlayerData.Filter):InitSortData()
  ;
  (EventManager.Hit)("Get_Player_Data_Succeed")
end

local player_board_set_succeed_ack = function(mapMsgData)
  -- function num : 0_10 , upvalues : _ENV
  (PlayerData.Board):SetBoardSuccess()
end

local player_board_set_failed_ack = function(mapMsgData)
  -- function num : 0_11 , upvalues : _ENV
  (PlayerData.Board):SetBoardFail()
end

local player_world_class_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_12 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Base):PlayerWorldClassRewardReceiveSuc(mapMsgData)
end

local player_world_class_advance_succeed_ack = function(mapMsgData)
  -- function num : 0_13 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Base):PlayerWorldClassAdvanceSuc(mapMsgData)
end

local world_class_reward_state_notify = function(mapMsgData)
  -- function num : 0_14 , upvalues : _ENV
  (PlayerData.State):CacheWorldClassRewardState(mapMsgData)
end

local energy_buy_succeed_ack = function(mapMsgData)
  -- function num : 0_15 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Base):RefreshEnergyBuyCount(mapMsgData.Count)
end

local item_use_succeed_ack = function(mapMsgData)
  -- function num : 0_16 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local item_product_succeed_ack = function(mapMsgData)
  -- function num : 0_17 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local item_quick_growth_succeed_ack = function(mapMsgData)
  -- function num : 0_18 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local fragments_convert_succeed_ack = function(mapMsgData)
  -- function num : 0_19 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local player_ping_succeed_ack = function(mapMsgData)
  -- function num : 0_20 , upvalues : _ENV
  (NovaAPI.MarkServerTimeStamp)(mapMsgData.ServerTs)
end

local story_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_21 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local gacha_spin_succeed_ack = function(mapMsgData)
  -- function num : 0_22 , upvalues : _ENV, ProcChangeInfo
  local CheckNew = function(nTid)
    -- function num : 0_22_0 , upvalues : _ENV
    local mapItemCfgData = (ConfigTable.GetData_Item)(nTid)
    if mapItemCfgData == nil then
      return false
    end
    if mapItemCfgData.Type == (GameEnum.itemType).Char then
      local mapChar = (PlayerData.Char):GetCharDataByTid(nTid)
      return mapChar == nil
    elseif mapItemCfgData.Type == (GameEnum.itemType).Disc then
      local mapDisc = (PlayerData.Disc):GetDiscById(nTid)
      return mapDisc == nil
    else
      return false
    end
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end

  local tbReward = {}
  local tbItemId = {}
  for _,v in ipairs(mapMsgData.Cards) do
    local bNewHandBood = CheckNew((v.Card).Tid)
    local bNew = not bNewHandBood or (table.indexof)(tbItemId, (v.Card).Tid) < 1
    ;
    (table.insert)(tbItemId, (v.Card).Tid)
    ;
    (table.insert)(tbReward, {id = (v.Card).Tid, count = (v.Card).Qty, rewardItem = v.Rewards, bNew = bNew})
    -- DECOMPILER ERROR at PC44: Confused about usage of register: R11 in 'UnsetPending'

    ;
    (v.Card).bNew = bNew
  end
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Item):CacheFragmentsOverflow(nil, mapMsgData.Change)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

local mail_list_succeed_ack = function(mapMsgData)
  -- function num : 0_23 , upvalues : _ENV
  (PlayerData.Mail):CacheMailData(mapMsgData)
end

local mail_read_succeed_ack = function(mapMsgData)
  -- function num : 0_24 , upvalues : _ENV
  (PlayerData.Mail):ReadMail(mapMsgData)
end

local mail_recv_succeed_ack = function(mapMsgData)
  -- function num : 0_25 , upvalues : _ENV, ProcChangeInfo
  local mapDecodeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Items)
  ProcChangeInfo(mapDecodeInfo)
end

local mail_remove_succeed_ack = function(mapMsgData)
  -- function num : 0_26 , upvalues : _ENV
  (PlayerData.Mail):RemoveMail(mapMsgData)
end

local dictionary_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_27 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(tbDecodeChange)
end

local char_gem_instance_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_28 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local char_gem_instance_sweep_succeed_ack = function(mapMsgData)
  -- function num : 0_29 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local skill_instance_sweep_succeed_ack = function(mapMsgData)
  -- function num : 0_30 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_detail_succeed_ack = function(mapMsgData)
  -- function num : 0_31 , upvalues : _ENV
  (PlayerData.Activity):CacheAllActivityData(mapMsgData)
end

local activity_periodic_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_32 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(tbDecodeChange)
end

local activity_periodic_final_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_33 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(tbDecodeChange)
end

local activity_login_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_34 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(tbDecodeChange)
end

local activity_trial_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_35 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(tbDecodeChange)
end

local phone_contacts_info_succeed_ack = function(mapMsgData)
  -- function num : 0_36 , upvalues : _ENV
  (PlayerData.Phone):CacheAddressBookData(mapMsgData.List)
end

local phone_contacts_report_succeed_ack = function(mapMsgData)
  -- function num : 0_37 , upvalues : _ENV
  (PlayerData.Phone):PhoneContactReportSuc(mapMsgData)
end

local star_tower_build_delete_succeed_ack = function(mapMsgData)
  -- function num : 0_38 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ;
  (PlayerData.StarTower):AddStarTowerTicket(mapMsgData.Ticket)
  ProcChangeInfo(tbDecodeChange)
end

local quest_reward_recv_succeed_ack = function(mapMsgData)
  -- function num : 0_39 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local star_tower_build_whether_save_succeed_ack = function(mapMsgData)
  -- function num : 0_40 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ;
  (PlayerData.StarTower):AddStarTowerTicket(mapMsgData.Ticket)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local star_tower_give_up_succeed_ack = function(mapMsgData)
  -- function num : 0_41 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local star_tower_interact_succeed_ack = function(mapMsgData)
  -- function num : 0_42 , upvalues : _ENV, ProcChangeInfo
  if mapMsgData.Settle then
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)((mapMsgData.Settle).Change)
    ProcChangeInfo(mapDecodedChangeInfo)
  end
end

local star_tower_apply_failed_ack = function()
  -- function num : 0_43 , upvalues : _ENV
  (PlayerData.StarTower):ClearData()
end

local tower_growth_node_unlock_succeed_ack = function(mapMsgData)
  -- function num : 0_44 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(tbDecodeChange)
end

local tower_growth_group_node_unlock_succeed_ack = function(mapMsgData)
  -- function num : 0_45 , upvalues : _ENV, ProcChangeInfo
  local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMsgData.ChangeInfo)
  ProcChangeInfo(tbDecodeChange)
end

local quest_tower_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_46 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local npc_affinity_plot_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_47 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local npc_affinity_plot_reward_receive_failed_ack = function(mapMsgData)
  -- function num : 0_48 , upvalues : _ENV
  (EventManager.Hit)(EventId.ClosePanel, PanelId.PureAvgStory)
end

local friend_receive_energy_succeed_ack = function(mapMsgData)
  -- function num : 0_49 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local resident_shop_purchase_succeed_ack = function(mapMsgData)
  -- function num : 0_50 , upvalues : _ENV, ProcChangeInfo
  if not mapMsgData.IsRefresh then
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
  end
end

local daily_shop_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_51 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local char_advance_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_52 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local achievement_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_53 , upvalues : ProcChangeInfo, _ENV
  ProcChangeInfo((UTILS.DecodeChangeInfo)(mapMsgData))
end

local achievement_change_notify = function(mapMsgData)
  -- function num : 0_54 , upvalues : _ENV
  (PlayerData.Achievement):ChangeAchievementData(mapMsgData)
end

local achievement_state_notify = function(mapMsgData)
  -- function num : 0_55 , upvalues : _ENV
  (PlayerData.State):CacheAchievementState(mapMsgData.New)
end

local monthly_card_rewards_notify = function(mapMsgData)
  -- function num : 0_56 , upvalues : _ENV, ProcChangeInfo
  do
    if mapMsgData.Switch then
      local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
      ProcChangeInfo(mapDecodedChangeInfo)
    end
    ;
    ((PlayerData.Daily).ProcessMonthlyCard)(mapMsgData)
  end
end

local signin_reward_change_notify = function(mapMsgData)
  -- function num : 0_57 , upvalues : _ENV, ProcChangeInfo
  do
    if mapMsgData.Switch then
      local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
      ProcChangeInfo(mapDecodedChangeInfo)
    end
    ;
    ((PlayerData.Daily).ProcessDailyCheckIn)(mapMsgData)
  end
end

local battle_pass_info_succeed_ack = function(mapMsgData)
  -- function num : 0_58 , upvalues : _ENV
  (PlayerData.BattlePass):CacheBattlePassInfo(mapMsgData)
end

local battle_pass_quest_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_59 , upvalues : _ENV
  (PlayerData.BattlePass):OnQuestReceive(mapMsgData)
end

local battle_pass_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_60 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local battle_pass_level_buy_succeed_ack = function(mapMsgData)
  -- function num : 0_61 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local battle_pass_order_collect_succeed_ack = function(mapMsgData)
  -- function num : 0_62 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)((mapMsgData.CollectResp).Items)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local mall_order_collect_succeed_ack = function(mapMsgData)
  -- function num : 0_63 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Items)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local mall_package_order_succeed_ack = function(mapMsgData)
  -- function num : 0_64 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local mall_shop_order_succeed_ack = function(mapMsgData)
  -- function num : 0_65 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local gem_convert_succeed_ack = function(mapMsgData)
  -- function num : 0_66 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local talent_unlock_succeed_ack = function(mapMsgData)
  -- function num : 0_67 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local talent_reset_succeed_ack = function(mapMsgData)
  -- function num : 0_68 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local talent_node_reset_succeed_ack = function(mapMsgData)
  -- function num : 0_69 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local talent_group_unlock_succeed_ack = function(mapMsgData)
  -- function num : 0_70 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local disc_strengthen_succeed_ack = function(mapMsgData)
  -- function num : 0_71 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local disc_promote_succeed_ack = function(mapMsgData)
  -- function num : 0_72 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local disc_limit_break_succeed_ack = function(mapMsgData)
  -- function num : 0_73 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local disc_read_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_74 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local mail_state_notify = function(mapMsgData)
  -- function num : 0_75 , upvalues : _ENV
  (PlayerData.Mail):UpdateMailList(mapMsgData)
end

local player_relogin_expire_ban = function(mapMsgData)
  -- function num : 0_76 , upvalues : HttpNetHandler
  (HttpNetHandler.UnsetPingPong)()
end

local quest_change_notify = function(mapMsgData)
  -- function num : 0_77 , upvalues : _ENV
  (PlayerData.Quest):OnQuestProgressChanged(mapMsgData)
  ;
  (PlayerData.Quest):UpdateQuestRedDot(mapMsgData.Type)
end

local chars_final_notify = function(mapMsgData)
  -- function num : 0_78 , upvalues : _ENV
  (PlayerData.Char):CacheCharacters(mapMsgData.List)
end

local character_skin_gain_notify = function(mapMsgData)
  -- function num : 0_79 , upvalues : _ENV
  (PlayerData.CharSkin):SkinGainEnqueue(mapMsgData)
end

local character_skin_change_notify = function(mapMsgData)
  -- function num : 0_80 , upvalues : _ENV
  (PlayerData.Char):SetCharSkinId(mapMsgData.CharId, mapMsgData.SkinId)
end

local world_class_change_notify = function(mapMsgData)
  -- function num : 0_81 , upvalues : ProcChangeInfo, _ENV
  ProcChangeInfo((UTILS.DecodeChangeInfo)(mapMsgData.Change))
end

local world_class_number_notify = function(mapMsgData)
  -- function num : 0_82 , upvalues : _ENV
  (PlayerData.State):CacheWorldClassRewardStateInBoard(mapMsgData.RewardsFlag)
  ;
  (PlayerData.Base):ChangeWorldClassInBoard(mapMsgData)
end

local world_class_quest_complete_notify = function(mapMsgData)
  -- function num : 0_83 , upvalues : _ENV
  for _,v in pairs(mapMsgData.List) do
    (PlayerData.Quest):OnQuestProgressChanged(v)
    ;
    (PlayerData.Quest):UpdateQuestRedDot(v.Type)
  end
end

local char_reset_notify = function(mapMsgData)
  -- function num : 0_84 , upvalues : _ENV
  (PlayerData.Char):CacheCharacters({mapMsgData})
end

local char_change_notify = function(mapMsgData)
  -- function num : 0_85 , upvalues : _ENV
  (PlayerData.Char):CacheCharacters({mapMsgData})
end

local char_advance_reward_state_notify = function(mapMsgData)
  -- function num : 0_86 , upvalues : _ENV
  (PlayerData.State):CacheCharactersAdRewards_Notify(mapMsgData)
end

local items_change_notify = function(mapMsgData)
  -- function num : 0_87 , upvalues : ProcChangeInfo, _ENV
  ProcChangeInfo((UTILS.DecodeChangeInfo)(mapMsgData))
end

local friend_state_notify = function(mapMsgData)
  -- function num : 0_88 , upvalues : _ENV
  (PlayerData.Friend):UpdateFriendState(mapMsgData)
end

local friend_energy_state_notify = function(mapMsgData)
  -- function num : 0_89 , upvalues : _ENV
  (PlayerData.Friend):UpdateFriendEnergy(mapMsgData)
end

local boss_level_final_notify = function(mapMsgData)
  -- function num : 0_90 , upvalues : _ENV
  (PlayerData.RogueBoss):CacheRogueBossData({mapMsgData})
end

local region_boss_level_apply_succeed_ack = function(mapMsgData)
  -- function num : 0_91 , upvalues : _ENV
  (PlayerData.RogueBoss):EnterRegionBoss(mapMsgData)
end

local region_boss_level_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_92 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.RogueBoss):RegionBossLevelSettleSuccess(mapMsgData)
end

local region_boss_level_sweep_succeed_ack = function(mapMsgData)
  -- function num : 0_93 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local skill_instance_apply_succeed_ack = function(mapMsgData)
  -- function num : 0_94 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local week_boss_apply_succeed_ack = function(mapMsgData)
  -- function num : 0_95 , upvalues : _ENV
  print("week succeed")
  ;
  (PlayerData.RogueBoss):EnterWeekBoss(mapMsgData)
end

local week_boss_apply_failed_ack = function(mapMsgData)
  -- function num : 0_96 , upvalues : _ENV
  print("week failed")
end

local week_boss_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_97 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.RogueBoss):WeeklyCopiesLevelSettleReqSuccess(mapMsgData)
end

local week_boss_settle_failed_ack = function(mapMsgData)
  -- function num : 0_98 , upvalues : _ENV
  print("week settle failed")
end

local week_boss_refresh_ticket_notify = function(mapMsgData)
  -- function num : 0_99 , upvalues : _ENV, ProcChangeInfo
  print("week settle reset")
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local handbook_change_notify = function(mapMsgData)
  -- function num : 0_100 , upvalues : _ENV
  (PlayerData.Handbook):UpdateHandbookData(mapMsgData)
end

local char_up_change_notify = function(mapMsgData)
  -- function num : 0_101 , upvalues : _ENV
  for _,v in pairs(mapMsgData.Handbook) do
    (PlayerData.Handbook):UpdateHandbookData(v)
  end
  ;
  (PlayerData.Char):CacheCharacters({mapMsgData.Char})
end

local daily_instance_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_102 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local daily_instance_raid_succeed_ack = function(mapMsgData)
  -- function num : 0_103 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local mall_package_state_notify = function(mapMsgData)
  -- function num : 0_104 , upvalues : _ENV
  (RedDotManager.SetValid)(RedDotDefine.Mall_Free, nil, mapMsgData.New)
end

local quest_state_notify = function(mapMessageData)
  -- function num : 0_105 , upvalues : _ENV
  (PlayerData.Quest):UpdateServerQuestRedDot(mapMessageData)
end

local dictionary_change_notify = function(mapMsgData)
  -- function num : 0_106 , upvalues : _ENV
  (PlayerData.Dictionary):ChangeDictionaryData(mapMsgData)
end

local clear_all_traveler_due_notify = function(mapMsgData)
  -- function num : 0_107 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.TravelerDuel):CacheTravelerDuelLevelData(mapMsgData)
end

local clear_all_region_boss_level_notify = function(mapMsgData)
  -- function num : 0_108 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.RogueBoss):CacheRogueBossData(mapMsgData.RegionBossLevels)
end

local clear_all_week_boss_notify = function(mapMsgData)
  -- function num : 0_109 , upvalues : _ENV
  (PlayerData.RogueBoss):CacheWeeklyCopiesData(mapMsgData.WeekBossLevels)
end

local st_clear_all_star_tower_notify = function(mapMsgData)
  -- function num : 0_110 , upvalues : _ENV
  (PlayerData.StarTower):CachePassedId(mapMsgData.Ids)
end

local clear_all_daily_instance_notify = function(mapMsgData)
  -- function num : 0_111 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.DailyInstance):CacheDailyInstanceLevel(mapMsgData.DailyInstances)
end

local clear_all_char_gem_instance_notify = function(mapMsgData)
  -- function num : 0_112 , upvalues : _ENV
  (PlayerData.EquipmentInstance):CacheEquipmentInstanceLevel(mapMsgData.CharGemInstances)
end

local st_import_build_notify = function(mapMsgData)
  -- function num : 0_113 , upvalues : _ENV
  (PlayerData.Build):CacheRogueBuild(mapMsgData)
end

local st_export_build_notify = function(mapMsgData)
  -- function num : 0_114 , upvalues : _ENV
  -- DECOMPILER ERROR at PC4: Confused about usage of register: R1 in 'UnsetPending'

  ((CS.UnityEngine).GUIUtility).systemCopyBuffer = mapMsgData.Value
end

local char_affinity_final_notify = function(mapMsgData)
  -- function num : 0_115 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Char):ChangeCharAffinityValue(mapMsgData.Info)
end

local char_affinity_reward_state_notify = function(mapMsgData)
  -- function num : 0_116
end

local activity_change_notify = function(mapMsgData)
  -- function num : 0_117 , upvalues : _ENV
  (PlayerData.Activity):RefreshActivityData(mapMsgData)
end

local activity_state_change_notify = function(mapMsgData)
  -- function num : 0_118 , upvalues : _ENV
  (PlayerData.Activity):RefreshActivityStateData(mapMsgData)
end

local activity_quest_change_notify = function(mapMsgData)
  -- function num : 0_119 , upvalues : _ENV
  (PlayerData.Activity):RefreshSingleQuest(mapMsgData)
end

local mail_overflow_notify = function(mapMsgData)
  -- function num : 0_120 , upvalues : _ENV
  (PlayerData.State):SetMailOverflow(true)
end

local infinity_tower_rewards_state_notify = function(mapMsgData)
  -- function num : 0_121 , upvalues : _ENV
  (PlayerData.InfinityTower):InfinityTowerRewardsStateNotify(mapMsgData)
end

local phone_chat_change_notify = function(mapMsgData)
  -- function num : 0_122 , upvalues : _ENV
  (PlayerData.Phone):NewChatTrigger(mapMsgData)
end

local character_fragments_overflow_change_notify = function(mapMsgData)
  -- function num : 0_123 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Item):CacheFragmentsOverflow(mapMsgData)
end

local infinity_tower_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_124 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local infinity_tower_daily_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_125 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local infinity_tower_plot_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_126 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local disc_reset_notify = function(mapMsgData)
  -- function num : 0_127 , upvalues : _ENV
  (PlayerData.Disc):UpdateDiscData(mapMsgData.Id, mapMsgData)
end

local story_complete_notify = function(mapMsgData)
  -- function num : 0_128 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Avg):CacheAvgData(mapMsgData)
end

local clear_all_story_notify = function(mapMsgData)
  -- function num : 0_129 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Avg):CacheAvgData(mapMsgData)
end

local activity_login_rewards_notify = function(mapMsgData)
  -- function num : 0_130 , upvalues : _ENV
  (PlayerData.Activity):CacheLoginRewardActData(mapMsgData.ActivityId, mapMsgData)
end

local star_tower_book_potential_notify = function(mapMsgData)
  -- function num : 0_131 , upvalues : _ENV
  (PlayerData.StarTowerBook):CharPotentialBookChange(mapMsgData)
end

local star_tower_book_event_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_132 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local tower_book_fate_card_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_133 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local star_tower_book_potential_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_134 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local star_tower_book_event_notify = function(mapMsgData)
  -- function num : 0_135
end

local tower_book_fate_card_collect_notify = function(mapMsgData)
  -- function num : 0_136 , upvalues : _ENV
  (PlayerData.StarTowerBook):FateCardBookChange(mapMsgData)
  ;
  (PlayerData.VampireSurvivor):AddTalentPoint(mapMsgData.Cards)
end

local tower_book_fate_card_reward_notify = function(mapMsgData)
  -- function num : 0_137 , upvalues : _ENV
  (PlayerData.StarTowerBook):FateCardBookRewardChange(mapMsgData)
end

local region_boss_level_challenge_ticket_notify = function(mapMsgData)
  -- function num : 0_138 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (EventManager.Hit)("region_boss_ticket_notify", (AllEnum.CoinItemId).RogueHardCoreTick)
end

local honor_change_notify = function(mapMsgData)
  -- function num : 0_139 , upvalues : _ENV
  (PlayerData.Base):CacheHonorTitleInfo(mapMsgData.Honors)
  ;
  (EventManager.Hit)("HonorTitle_Change")
end

local tower_growth_node_change_notify = function(mapMsgData)
  -- function num : 0_140 , upvalues : _ENV
  (PlayerData.StarTower):ParseGrowthData(mapMsgData.Detail)
  ;
  (PlayerData.StarTower):UpdateGrowthReddot()
end

local add_vampire_season_score_notify = function(mapMsgData)
  -- function num : 0_141 , upvalues : _ENV
  (PlayerData.VampireSurvivor):CacheScore(mapMsgData.Value)
end

local clear_all_vampire_survivor_notify = function(mapMsgData)
  -- function num : 0_142 , upvalues : _ENV
  (PlayerData.VampireSurvivor):CachePassedId(mapMsgData.Ids)
end

local star_tower_sub_note_skill_info_notify = function(mapMsgData)
  -- function num : 0_143 , upvalues : _ENV
  local sTip = "音符掉落查询：\n"
  local printTableHelper = function(t, indent)
    -- function num : 0_143_0 , upvalues : _ENV, sTip, printTableHelper
    if not indent then
      indent = 0
    end
    for k,v in pairs(t) do
      local formatting = (string.rep)(" ", indent) .. tostring(k) .. ": "
      if type(v) == "table" then
        sTip = sTip .. formatting .. "\n"
        printTableHelper(v, indent + 4)
      else
        sTip = sTip .. formatting .. tostring(v) .. "\n"
      end
    end
  end

  printTableHelper(mapMsgData.SubNoteSkillInfo, 0)
  print(sTip)
end

local refresh_agent_notify = function(mapMsgData)
  -- function num : 0_144 , upvalues : _ENV
  ((PlayerData.Dispatch).RefreshAgentInfos)(mapMsgData)
end

local clear_all_skill_instance_notify = function(mapMsgData)
  -- function num : 0_145 , upvalues : _ENV
  (PlayerData.SkillInstance):CacheSkillInstanceLevel(mapMsgData.SkillInstances)
end

local st_skip_floor_notify = function(mapMsgData)
  -- function num : 0_146 , upvalues : _ENV
  (EventManager.Hit)("st_skip_floor_notify", mapMsgData)
end

local st_add_team_exp_notify = function(mapMsgData)
  -- function num : 0_147 , upvalues : _ENV
  (EventManager.Hit)("st_add_team_exp_notify", mapMsgData)
end

local st_add_new_case_notify = function(mapMsgData)
  -- function num : 0_148 , upvalues : _ENV
  (EventManager.Hit)("st_add_new_case_notify", mapMsgData)
end

local st_items_change_notify = function(mapMsgData)
  -- function num : 0_149 , upvalues : _ENV
  (EventManager.Hit)("items_change_notify", mapMsgData)
end

local tower_change_sub_note_skill_notify = function(mapMsgData)
  -- function num : 0_150 , upvalues : _ENV
  (EventManager.Hit)("note_change_notify", mapMsgData)
end

local change_npc_affinity_notify = function(mapMsgData)
  -- function num : 0_151 , upvalues : _ENV
  (PlayerData.StarTower):ChangeNpcAffinity(mapMsgData)
end

local traveler_duel_rank_succeed_ack = function(msgData)
  -- function num : 0_152 , upvalues : _ENV
  (PlayerData.TravelerDuel):CacheTravelerDuelRankingData(msgData)
end

local traveler_duel_info_failed_ack = function()
  -- function num : 0_153 , upvalues : _ENV
  (EventManager.Hit)(EventId.SetTransition)
end

local vampire_talent_reset_succeed_ack = function(msgData)
  -- function num : 0_154 , upvalues : _ENV
  (PlayerData.VampireSurvivor):ResetTalentPoint()
end

local vampire_talent_unlock_succeed_ack = function(msgData)
  -- function num : 0_155
end

local vampire_talent_detail_failed_ack = function()
  -- function num : 0_156 , upvalues : _ENV
  (EventManager.Hit)("GetTalentDataVampire", false)
end

local vampire_survivor_reward_chest_failed_ack = function()
  -- function num : 0_157 , upvalues : _ENV
  (EventManager.Hit)("VampireRewardChestFailed")
end

local vampire_survivor_reward_select_failed_ack = function()
  -- function num : 0_158 , upvalues : _ENV
  (EventManager.Hit)("VampireLevelRewardFailed")
end

local vampire_survivor_quest_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_159 , upvalues : ProcChangeInfo, _ENV
  ProcChangeInfo((UTILS.DecodeChangeInfo)(mapMsgData))
end

local char_affinity_quest_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_160 , upvalues : _ENV
  do
    if mapMsgData.Info ~= nil and (mapMsgData.Info).Rewards ~= nil then
      local data = nil
      for _,v in pairs((mapMsgData.Info).Rewards) do
        if data == nil then
          data = {}
        end
        ;
        (table.insert)(data, {NewId = v.Tid})
      end
      ;
      (PlayerData.Base):ChangeHonorTitle(data)
    end
    ;
    (PlayerData.Char):ChangeCharAffinityValue(mapMsgData.Info)
  end
end

local char_affinity_gift_send_succeed_ack = function(mapMsgData)
  -- function num : 0_161 , upvalues : ProcChangeInfo, _ENV
  ProcChangeInfo((UTILS.DecodeChangeInfo)(mapMsgData.Change))
  ;
  (PlayerData.Base):RefreshSendGiftCount(mapMsgData.SendGiftCnt)
  ;
  (PlayerData.Char):ChangeCharAffinityValue(mapMsgData.Info)
end

local char_recruitment_succeed_ack = function(mapMsgData)
  -- function num : 0_162 , upvalues : ProcChangeInfo, _ENV
  ProcChangeInfo((UTILS.DecodeChangeInfo)(mapMsgData))
end

local agent_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_163 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local agent_new_notify = function(mapMsgData)
  -- function num : 0_164 , upvalues : _ENV
  ((PlayerData.Dispatch).RefreshWeeklyDispatchs)(mapMsgData.Ids)
end

local agent_apply_failed_ack = function(mapMsgData)
  -- function num : 0_165 , upvalues : _ENV
  ((PlayerData.Dispatch).ResetReqLock)()
end

local char_dating_landmark_select_succeed_ack = function(mapMsgData)
  -- function num : 0_166 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Char):ChangeCharAffinityValue(mapMsgData.Info)
end

local char_dating_event_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_167 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local char_dating_gift_send_succeed_ack = function(mapMsgData)
  -- function num : 0_168 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (PlayerData.Char):ChangeCharAffinityValue(mapMsgData.Info)
end

local char_archive_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_169 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_mining_daily_reward_notify = function(mapMsgData)
  -- function num : 0_170 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (EventManager.Hit)("Mining_Daily_Reward", mapMsgData)
end

local activity_mining_supplement_reward_notify = function(mapMsgData)
  -- function num : 0_171 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (EventManager.Hit)("Mining_Supplement_Reward", mapMsgData)
end

local activity_mining_quest_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_172 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.ChangeInfo)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_mining_story_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_173 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_mining_dig_succeed_ack = function(mapMsgData)
  -- function num : 0_174 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.ChangeInfo)
  ProcChangeInfo(mapDecodedChangeInfo)
  ;
  (EventManager.Hit)("Mining_UpdateRigResult", mapMsgData)
end

local activity_mining_energy_convert_notify = function(mapMsgData)
  -- function num : 0_175 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local score_boss_star_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_176 , upvalues : ProcChangeInfo, _ENV
  ProcChangeInfo((UTILS.DecodeChangeInfo)(mapMsgData))
end

local redeem_code_succeed_ack = function(mapMsgData)
  -- function num : 0_177 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local notice_change_notify = function(mapMsgData)
  -- function num : 0_178 , upvalues : _ENV
  (EventManager.Hit)("NoticeChangeNotify", mapMsgData)
end

local joint_drill_apply_succeed_ack = function(mapMsgData)
  -- function num : 0_179 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local joint_drill_sweep_succeed_ack = function(mapMsgData)
  -- function num : 0_180 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local joint_drill_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_181 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local joint_drill_game_over_succeed_ack = function(mapMsgData)
  -- function num : 0_182 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local joint_drill_quest_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_183 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_joint_drill_refresh_ticket_notify = function(mapMsgData)
  -- function num : 0_184 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_tower_defense_story_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_185 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_tower_defense_quest_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_186 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local activity_tower_defense_level_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_187 , upvalues : _ENV, ProcChangeInfo
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ProcChangeInfo(mapDecodedChangeInfo)
end

local force_update_notify = function(mapMsgData)
  -- function num : 0_188 , upvalues : _ENV
  local clientVer = (NovaAPI.GetResVersion)()
  local serVer = tostring(mapMsgData.Value)
  if (UTILS.VersionCompare)(clientVer, serVer, 1) == -1 then
    (PlayerData.Base):NeedHotfix()
  end
end

local BindProcessFunction = function()
  -- function num : 0_189 , upvalues : mapProcessFunction, _ENV, ike_succeed_ack, ike_failed_ack, player_login_succeed_ack, player_login_failed_ack, player_data_succeed_ack, NOTHING_NEED_TO_BE_DONE, player_board_set_succeed_ack, player_board_set_failed_ack, player_world_class_reward_receive_succeed_ack, player_world_class_advance_succeed_ack, story_settle_succeed_ack, energy_buy_succeed_ack, HttpNetHandlerPlus, item_use_succeed_ack, item_product_succeed_ack, item_quick_growth_succeed_ack, fragments_convert_succeed_ack, player_ping_succeed_ack, traveler_duel_rank_succeed_ack, traveler_duel_info_failed_ack, char_advance_reward_receive_succeed_ack, gacha_spin_succeed_ack, mail_list_succeed_ack, mail_read_succeed_ack, mail_recv_succeed_ack, mail_remove_succeed_ack, star_tower_build_delete_succeed_ack, star_tower_build_whether_save_succeed_ack, star_tower_give_up_succeed_ack, star_tower_interact_succeed_ack, star_tower_apply_failed_ack, tower_growth_node_unlock_succeed_ack, tower_growth_group_node_unlock_succeed_ack, quest_tower_reward_receive_succeed_ack, npc_affinity_plot_reward_receive_succeed_ack, npc_affinity_plot_reward_receive_failed_ack, friend_receive_energy_succeed_ack, achievement_reward_receive_succeed_ack, resident_shop_purchase_succeed_ack, daily_shop_reward_receive_succeed_ack, mall_order_collect_succeed_ack, mall_package_order_succeed_ack, mall_shop_order_succeed_ack, gem_convert_succeed_ack, daily_instance_settle_succeed_ack, daily_instance_raid_succeed_ack, dictionary_reward_receive_succeed_ack, char_gem_instance_settle_succeed_ack, char_gem_instance_sweep_succeed_ack, skill_instance_sweep_succeed_ack, activity_detail_succeed_ack, activity_periodic_reward_receive_succeed_ack, activity_periodic_final_reward_receive_succeed_ack, activity_login_reward_receive_succeed_ack, activity_trial_reward_receive_succeed_ack, phone_contacts_info_succeed_ack, phone_contacts_report_succeed_ack, battle_pass_info_succeed_ack, battle_pass_quest_reward_receive_succeed_ack, battle_pass_reward_receive_succeed_ack, battle_pass_level_buy_succeed_ack, battle_pass_order_collect_succeed_ack, talent_unlock_succeed_ack, talent_reset_succeed_ack, talent_node_reset_succeed_ack, talent_group_unlock_succeed_ack, disc_strengthen_succeed_ack, disc_promote_succeed_ack, disc_limit_break_succeed_ack, disc_read_reward_receive_succeed_ack, vampire_talent_unlock_succeed_ack, vampire_talent_reset_succeed_ack, vampire_survivor_reward_chest_failed_ack, vampire_talent_detail_failed_ack, vampire_survivor_reward_select_failed_ack, vampire_survivor_quest_reward_receive_succeed_ack, mail_state_notify, player_relogin_expire_ban, quest_change_notify, chars_final_notify, character_skin_gain_notify, character_skin_change_notify, world_class_number_notify, world_class_quest_complete_notify, world_class_change_notify, char_reset_notify, items_change_notify, boss_level_final_notify, friend_state_notify, friend_energy_state_notify, char_change_notify, world_class_reward_state_notify, char_advance_reward_state_notify, achievement_change_notify, achievement_state_notify, monthly_card_rewards_notify, signin_reward_change_notify, handbook_change_notify, mall_package_state_notify, quest_state_notify, dictionary_change_notify, clear_all_traveler_due_notify, clear_all_region_boss_level_notify, clear_all_week_boss_notify, st_clear_all_star_tower_notify, clear_all_daily_instance_notify, clear_all_char_gem_instance_notify, st_import_build_notify, st_export_build_notify, char_affinity_final_notify, char_affinity_reward_state_notify, activity_change_notify, activity_state_change_notify, activity_quest_change_notify, mail_overflow_notify, infinity_tower_rewards_state_notify, phone_chat_change_notify, character_fragments_overflow_change_notify, infinity_tower_settle_succeed_ack, infinity_tower_daily_reward_receive_succeed_ack, infinity_tower_plot_reward_receive_succeed_ack, disc_reset_notify, story_complete_notify, clear_all_story_notify, activity_login_rewards_notify, star_tower_book_potential_notify, star_tower_book_event_notify, star_tower_book_event_reward_receive_succeed_ack, tower_book_fate_card_reward_receive_succeed_ack, star_tower_book_potential_reward_receive_succeed_ack, change_npc_affinity_notify, tower_book_fate_card_collect_notify, tower_book_fate_card_reward_notify, region_boss_level_challenge_ticket_notify, honor_change_notify, tower_growth_node_change_notify, char_up_change_notify, clear_all_vampire_survivor_notify, add_vampire_season_score_notify, star_tower_sub_note_skill_info_notify, refresh_agent_notify, clear_all_skill_instance_notify, st_skip_floor_notify, st_add_team_exp_notify, st_add_new_case_notify, st_items_change_notify, tower_change_sub_note_skill_notify, region_boss_level_apply_succeed_ack, region_boss_level_settle_succeed_ack, region_boss_level_sweep_succeed_ack, skill_instance_apply_succeed_ack, week_boss_apply_succeed_ack, week_boss_apply_failed_ack, week_boss_settle_succeed_ack, week_boss_settle_failed_ack, week_boss_refresh_ticket_notify, char_affinity_quest_reward_receive_succeed_ack, char_affinity_gift_send_succeed_ack, char_recruitment_succeed_ack, agent_reward_receive_succeed_ack, agent_new_notify, agent_apply_failed_ack, char_dating_landmark_select_succeed_ack, char_dating_event_reward_receive_succeed_ack, char_dating_gift_send_succeed_ack, char_archive_reward_receive_succeed_ack, activity_mining_daily_reward_notify, activity_mining_supplement_reward_notify, activity_mining_quest_reward_receive_succeed_ack, activity_mining_story_reward_receive_succeed_ack, activity_mining_dig_succeed_ack, activity_mining_energy_convert_notify, score_boss_star_reward_receive_succeed_ack, redeem_code_succeed_ack, notice_change_notify, joint_drill_apply_succeed_ack, joint_drill_sweep_succeed_ack, joint_drill_settle_succeed_ack, joint_drill_game_over_succeed_ack, joint_drill_quest_reward_receive_succeed_ack, activity_joint_drill_refresh_ticket_notify, activity_tower_defense_story_reward_receive_succeed_ack, activity_tower_defense_quest_reward_receive_succeed_ack, activity_tower_defense_level_settle_succeed_ack, force_update_notify
  mapProcessFunction = {[(NetMsgId.Id).ike_succeed_ack] = ike_succeed_ack, [(NetMsgId.Id).ike_failed_ack] = ike_failed_ack, [(NetMsgId.Id).player_login_succeed_ack] = player_login_succeed_ack, [(NetMsgId.Id).player_login_failed_ack] = player_login_failed_ack, [(NetMsgId.Id).player_data_succeed_ack] = player_data_succeed_ack, [(NetMsgId.Id).player_data_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_reg_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_name_edit_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_name_edit_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_head_icon_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_head_icon_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_board_set_succeed_ack] = player_board_set_succeed_ack, [(NetMsgId.Id).player_board_set_failed_ack] = player_board_set_failed_ack, [(NetMsgId.Id).player_skin_show_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_skin_show_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_chars_show_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_chars_show_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_signature_edit_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_signature_edit_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_world_class_reward_receive_succeed_ack] = player_world_class_reward_receive_succeed_ack, [(NetMsgId.Id).player_world_class_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_world_class_advance_succeed_ack] = player_world_class_advance_succeed_ack, [(NetMsgId.Id).player_world_class_advance_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_music_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_music_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).story_apply_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).story_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).story_settle_succeed_ack] = story_settle_succeed_ack, [(NetMsgId.Id).story_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_gender_edit_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_gender_edit_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).energy_buy_succeed_ack] = energy_buy_succeed_ack, [(NetMsgId.Id).energy_buy_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).energy_extract_succeed_ack] = HttpNetHandlerPlus.energy_extract_succeed_ack, [(NetMsgId.Id).energy_extract_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).item_use_succeed_ack] = item_use_succeed_ack, [(NetMsgId.Id).item_use_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).item_product_succeed_ack] = item_product_succeed_ack, [(NetMsgId.Id).item_product_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).item_quick_growth_succeed_ack] = item_quick_growth_succeed_ack, [(NetMsgId.Id).item_quick_growth_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).fragments_convert_succeed_ack] = fragments_convert_succeed_ack, [(NetMsgId.Id).fragments_convert_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_ping_succeed_ack] = player_ping_succeed_ack, [(NetMsgId.Id).traveler_duel_rank_succeed_ack] = traveler_duel_rank_succeed_ack, [(NetMsgId.Id).traveler_duel_info_failed_ack] = traveler_duel_info_failed_ack, [(NetMsgId.Id).traveler_duel_info_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_formation_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_formation_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).char_advance_reward_receive_succeed_ack] = char_advance_reward_receive_succeed_ack, [(NetMsgId.Id).char_skin_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).char_skin_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_spin_succeed_ack] = gacha_spin_succeed_ack, [(NetMsgId.Id).gacha_spin_failed_ack] = HttpNetHandlerPlus.gacha_spin_failed_ack, [(NetMsgId.Id).gacha_information_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_information_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_guarantee_reward_receive_succeed_ack] = HttpNetHandlerPlus.gacha_guarantee_reward_receive_succeed_ack, [(NetMsgId.Id).gacha_guarantee_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_newbie_info_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_newbie_info_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_newbie_spin_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_newbie_spin_failed_ack] = HttpNetHandlerPlus.gacha_newbie_spin_failed_ack, [(NetMsgId.Id).gacha_newbie_obtain_succeed_ack] = HttpNetHandlerPlus.gacha_newbie_obtain_succeed_ack, [(NetMsgId.Id).gacha_newbie_obtain_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_newbie_save_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gacha_newbie_save_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mail_list_succeed_ack] = mail_list_succeed_ack, [(NetMsgId.Id).mail_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mail_read_succeed_ack] = mail_read_succeed_ack, [(NetMsgId.Id).mail_read_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mail_recv_succeed_ack] = mail_recv_succeed_ack, [(NetMsgId.Id).mail_recv_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mail_remove_succeed_ack] = mail_remove_succeed_ack, [(NetMsgId.Id).mail_remove_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).char_gem_generate_succeed_ack] = HttpNetHandlerPlus.char_gem_generate_succeed_ack, [(NetMsgId.Id).char_gem_refresh_succeed_ack] = HttpNetHandlerPlus.char_gem_refresh_succeed_ack, [(NetMsgId.Id).char_gem_replace_attribute_succeed_ack] = HttpNetHandlerPlus.char_gem_replace_attribute_succeed_ack, [(NetMsgId.Id).char_gem_update_gem_lock_status_succeed_ack] = HttpNetHandlerPlus.char_gem_update_gem_lock_status_succeed_ack, [(NetMsgId.Id).char_gem_use_preset_succeed_ack] = HttpNetHandlerPlus.char_gem_use_preset_succeed_ack, [(NetMsgId.Id).char_gem_rename_preset_succeed_ack] = HttpNetHandlerPlus.char_gem_rename_preset_succeed_ack, [(NetMsgId.Id).char_gem_equip_gem_succeed_ack] = HttpNetHandlerPlus.char_gem_equip_gem_succeed_ack, [(NetMsgId.Id).char_gems_import_notify] = HttpNetHandlerPlus.char_gems_import_notify, [(NetMsgId.Id).char_gems_export_notify] = HttpNetHandlerPlus.char_gems_export_notify, [(NetMsgId.Id).star_tower_build_brief_list_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_brief_list_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_detail_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_detail_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_delete_succeed_ack] = star_tower_build_delete_succeed_ack, [(NetMsgId.Id).star_tower_build_delete_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_name_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_name_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_lock_unlock_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_lock_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_preference_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_preference_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_build_whether_save_succeed_ack] = star_tower_build_whether_save_succeed_ack, [(NetMsgId.Id).star_tower_build_whether_save_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_give_up_succeed_ack] = star_tower_give_up_succeed_ack, [(NetMsgId.Id).star_tower_give_up_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_interact_succeed_ack] = star_tower_interact_succeed_ack, [(NetMsgId.Id).star_tower_interact_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_apply_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).star_tower_apply_failed_ack] = star_tower_apply_failed_ack, [(NetMsgId.Id).tower_growth_detail_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).tower_growth_detail_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).tower_growth_node_unlock_succeed_ack] = tower_growth_node_unlock_succeed_ack, [(NetMsgId.Id).tower_growth_node_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).tower_growth_group_node_unlock_succeed_ack] = tower_growth_group_node_unlock_succeed_ack, [(NetMsgId.Id).tower_growth_group_node_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).quest_tower_reward_receive_succeed_ack] = quest_tower_reward_receive_succeed_ack, [(NetMsgId.Id).quest_tower_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).npc_affinity_plot_reward_receive_succeed_ack] = npc_affinity_plot_reward_receive_succeed_ack, [(NetMsgId.Id).npc_affinity_plot_reward_receive_failed_ack] = npc_affinity_plot_reward_receive_failed_ack, [(NetMsgId.Id).friend_list_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_list_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_uid_search_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_uid_search_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_name_search_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_name_search_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_add_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_add_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_add_agree_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_add_agree_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_all_agree_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_all_agree_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_delete_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_delete_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_invites_delete_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_invites_delete_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_receive_energy_succeed_ack] = friend_receive_energy_succeed_ack, [(NetMsgId.Id).friend_receive_energy_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_send_energy_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_send_energy_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_star_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_star_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_recommendation_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).friend_recommendation_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).achievement_reward_receive_succeed_ack] = achievement_reward_receive_succeed_ack, [(NetMsgId.Id).achievement_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).achievement_info_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).achievement_info_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).resident_shop_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).resident_shop_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).resident_shop_purchase_succeed_ack] = resident_shop_purchase_succeed_ack, [(NetMsgId.Id).resident_shop_purchase_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).daily_shop_reward_receive_succeed_ack] = daily_shop_reward_receive_succeed_ack, [(NetMsgId.Id).daily_shop_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_gem_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_gem_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_gem_order_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_gem_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_order_cancel_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_order_cancel_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_order_collect_succeed_ack] = mall_order_collect_succeed_ack, [(NetMsgId.Id).mall_order_collect_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_monthlyCard_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_monthlyCard_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_monthlyCard_order_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_monthlyCard_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_package_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_package_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_package_order_succeed_ack] = mall_package_order_succeed_ack, [(NetMsgId.Id).mall_package_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_shop_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_shop_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mall_shop_order_succeed_ack] = mall_shop_order_succeed_ack, [(NetMsgId.Id).mall_shop_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).gem_convert_succeed_ack] = gem_convert_succeed_ack, [(NetMsgId.Id).gem_convert_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).daily_instance_settle_succeed_ack] = daily_instance_settle_succeed_ack, [(NetMsgId.Id).daily_instance_raid_succeed_ack] = daily_instance_raid_succeed_ack, [(NetMsgId.Id).daily_instance_raid_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).dictionary_reward_receive_succeed_ack] = dictionary_reward_receive_succeed_ack, [(NetMsgId.Id).dictionary_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).char_gem_instance_settle_succeed_ack] = char_gem_instance_settle_succeed_ack, [(NetMsgId.Id).char_gem_instance_sweep_succeed_ack] = char_gem_instance_sweep_succeed_ack, [(NetMsgId.Id).char_gem_instance_apply_succeed_ack] = HttpNetHandlerPlus.char_gem_instance_apply_succeed_ack, [(NetMsgId.Id).skill_instance_sweep_succeed_ack] = skill_instance_sweep_succeed_ack, [(NetMsgId.Id).skill_instance_sweep_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_detail_succeed_ack] = activity_detail_succeed_ack, [(NetMsgId.Id).activity_detail_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_periodic_reward_receive_succeed_ack] = activity_periodic_reward_receive_succeed_ack, [(NetMsgId.Id).activity_periodic_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_periodic_final_reward_receive_succeed_ack] = activity_periodic_final_reward_receive_succeed_ack, [(NetMsgId.Id).activity_periodic_final_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_login_reward_receive_succeed_ack] = activity_login_reward_receive_succeed_ack, [(NetMsgId.Id).activity_login_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_trial_reward_receive_succeed_ack] = activity_trial_reward_receive_succeed_ack, [(NetMsgId.Id).activity_shop_purchase_succeed_ack] = HttpNetHandlerPlus.activity_shop_purchase_succeed_ack, [(NetMsgId.Id).phone_contacts_info_succeed_ack] = phone_contacts_info_succeed_ack, [(NetMsgId.Id).phone_contacts_info_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).phone_contacts_report_succeed_ack] = phone_contacts_report_succeed_ack, [(NetMsgId.Id).phone_contacts_report_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).battle_pass_info_succeed_ack] = battle_pass_info_succeed_ack, [(NetMsgId.Id).battle_pass_info_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).battle_pass_quest_reward_receive_succeed_ack] = battle_pass_quest_reward_receive_succeed_ack, [(NetMsgId.Id).battle_pass_quest_reward_receive_failed_ack] = HttpNetHandlerPlus.battle_pass_common_fail, [(NetMsgId.Id).battle_pass_reward_receive_succeed_ack] = battle_pass_reward_receive_succeed_ack, [(NetMsgId.Id).battle_pass_reward_receive_failed_ack] = HttpNetHandlerPlus.battle_pass_common_fail, [(NetMsgId.Id).battle_pass_level_buy_succeed_ack] = battle_pass_level_buy_succeed_ack, [(NetMsgId.Id).battle_pass_level_buy_failed_ack] = HttpNetHandlerPlus.battle_pass_common_fail, [(NetMsgId.Id).battle_pass_order_collect_succeed_ack] = battle_pass_order_collect_succeed_ack, [(NetMsgId.Id).battle_pass_order_collect_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).sudo_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).sudo_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).talent_unlock_succeed_ack] = talent_unlock_succeed_ack, [(NetMsgId.Id).talent_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).talent_reset_succeed_ack] = talent_reset_succeed_ack, [(NetMsgId.Id).talent_reset_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).talent_node_reset_succeed_ack] = talent_node_reset_succeed_ack, [(NetMsgId.Id).talent_node_reset_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).talent_background_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).talent_background_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).talent_group_unlock_succeed_ack] = talent_group_unlock_succeed_ack, [(NetMsgId.Id).talent_group_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).disc_strengthen_succeed_ack] = disc_strengthen_succeed_ack, [(NetMsgId.Id).disc_strengthen_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).disc_promote_succeed_ack] = disc_promote_succeed_ack, [(NetMsgId.Id).disc_promote_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).disc_limit_break_succeed_ack] = disc_limit_break_succeed_ack, [(NetMsgId.Id).disc_limit_break_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).disc_all_limit_break_succeed_ack] = HttpNetHandlerPlus.disc_all_limit_break_succeed_ack, [(NetMsgId.Id).disc_all_limit_break_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).disc_read_reward_receive_succeed_ack] = disc_read_reward_receive_succeed_ack, [(NetMsgId.Id).disc_read_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).story_set_info_succeed_ack] = HttpNetHandlerPlus.story_set_info_succeed_ack, [(NetMsgId.Id).story_set_info_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).story_set_reward_receive_succeed_ack] = HttpNetHandlerPlus.story_set_reward_receive_succeed_ack, [(NetMsgId.Id).story_set_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).story_set_state_notify] = HttpNetHandlerPlus.story_set_state_notify, [(NetMsgId.Id).vampire_survivor_area_change_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).vampire_survivor_settle_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).vampire_talent_unlock_succeed_ack] = vampire_talent_unlock_succeed_ack, [(NetMsgId.Id).vampire_talent_reset_succeed_ack] = vampire_talent_reset_succeed_ack, [(NetMsgId.Id).system_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).vampire_survivor_reward_chest_failed_ack] = vampire_survivor_reward_chest_failed_ack, [(NetMsgId.Id).vampire_talent_detail_failed_ack] = vampire_talent_detail_failed_ack, [(NetMsgId.Id).vampire_survivor_reward_select_failed_ack] = vampire_survivor_reward_select_failed_ack, [(NetMsgId.Id).vampire_survivor_quest_reward_receive_succeed_ack] = vampire_survivor_quest_reward_receive_succeed_ack, [(NetMsgId.Id).player_new_notify] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).mail_state_notify] = mail_state_notify, [(NetMsgId.Id).player_relogin_notify] = player_relogin_expire_ban, [(NetMsgId.Id).token_expire_notify] = player_relogin_expire_ban, [(NetMsgId.Id).player_ban_notify] = player_relogin_expire_ban, [(NetMsgId.Id).quest_change_notify] = quest_change_notify, [(NetMsgId.Id).chars_final_notify] = chars_final_notify, [(NetMsgId.Id).character_skin_gain_notify] = character_skin_gain_notify, [(NetMsgId.Id).character_skin_change_notify] = character_skin_change_notify, [(NetMsgId.Id).world_class_number_notify] = world_class_number_notify, [(NetMsgId.Id).world_class_quest_complete_notify] = world_class_quest_complete_notify, [(NetMsgId.Id).world_class_change_notify] = world_class_change_notify, [(NetMsgId.Id).char_reset_notify] = char_reset_notify, [(NetMsgId.Id).items_change_notify] = items_change_notify, [(NetMsgId.Id).region_boss_level_final_notify] = boss_level_final_notify, [(NetMsgId.Id).friend_state_notify] = friend_state_notify, [(NetMsgId.Id).friend_energy_state_notify] = friend_energy_state_notify, [(NetMsgId.Id).char_change_notify] = char_change_notify, [(NetMsgId.Id).world_class_reward_state_notify] = world_class_reward_state_notify, [(NetMsgId.Id).char_advance_reward_state_notify] = char_advance_reward_state_notify, [(NetMsgId.Id).achievement_change_notify] = achievement_change_notify, [(NetMsgId.Id).achievement_state_notify] = achievement_state_notify, [(NetMsgId.Id).monthly_card_rewards_notify] = monthly_card_rewards_notify, [(NetMsgId.Id).signin_reward_change_notify] = signin_reward_change_notify, [(NetMsgId.Id).handbook_change_notify] = handbook_change_notify, [(NetMsgId.Id).mall_package_state_notify] = mall_package_state_notify, [(NetMsgId.Id).quest_state_notify] = quest_state_notify, [(NetMsgId.Id).dictionary_change_notify] = dictionary_change_notify, [(NetMsgId.Id).clear_all_traveler_due_notify] = clear_all_traveler_due_notify, [(NetMsgId.Id).clear_all_region_boss_level_notify] = clear_all_region_boss_level_notify, [(NetMsgId.Id).clear_all_week_boss_notify] = clear_all_week_boss_notify, [(NetMsgId.Id).st_clear_all_star_tower_notify] = st_clear_all_star_tower_notify, [(NetMsgId.Id).clear_all_daily_instance_notify] = clear_all_daily_instance_notify, [(NetMsgId.Id).clear_all_char_gem_instance_notify] = clear_all_char_gem_instance_notify, [(NetMsgId.Id).st_import_build_notify] = st_import_build_notify, [(NetMsgId.Id).st_export_build_notify] = st_export_build_notify, [(NetMsgId.Id).char_affinity_final_notify] = char_affinity_final_notify, [(NetMsgId.Id).char_affinity_reward_state_notify] = char_affinity_reward_state_notify, [(NetMsgId.Id).activity_change_notify] = activity_change_notify, [(NetMsgId.Id).activity_state_change_notify] = activity_state_change_notify, [(NetMsgId.Id).activity_quest_change_notify] = activity_quest_change_notify, [(NetMsgId.Id).mail_overflow_notify] = mail_overflow_notify, [(NetMsgId.Id).infinity_tower_rewards_state_notify] = infinity_tower_rewards_state_notify, [(NetMsgId.Id).phone_chat_change_notify] = phone_chat_change_notify, [(NetMsgId.Id).character_fragments_overflow_change_notify] = character_fragments_overflow_change_notify, [(NetMsgId.Id).infinity_tower_settle_succeed_ack] = infinity_tower_settle_succeed_ack, [(NetMsgId.Id).infinity_tower_daily_reward_receive_succeed_ack] = infinity_tower_daily_reward_receive_succeed_ack, [(NetMsgId.Id).infinity_tower_plot_reward_receive_succeed_ack] = infinity_tower_plot_reward_receive_succeed_ack, [(NetMsgId.Id).disc_reset_notify] = disc_reset_notify, [(NetMsgId.Id).story_complete_notify] = story_complete_notify, [(NetMsgId.Id).clear_all_story_notify] = clear_all_story_notify, [(NetMsgId.Id).activity_login_rewards_notify] = activity_login_rewards_notify, [(NetMsgId.Id).star_tower_book_potential_notify] = star_tower_book_potential_notify, [(NetMsgId.Id).star_tower_book_event_notify] = star_tower_book_event_notify, [(NetMsgId.Id).star_tower_book_event_reward_receive_succeed_ack] = star_tower_book_event_reward_receive_succeed_ack, [(NetMsgId.Id).tower_book_fate_card_reward_receive_succeed_ack] = tower_book_fate_card_reward_receive_succeed_ack, [(NetMsgId.Id).star_tower_book_potential_reward_receive_succeed_ack] = star_tower_book_potential_reward_receive_succeed_ack, [(NetMsgId.Id).change_npc_affinity_notify] = change_npc_affinity_notify, [(NetMsgId.Id).tower_book_fate_card_collect_notify] = tower_book_fate_card_collect_notify, [(NetMsgId.Id).tower_book_fate_card_reward_notify] = tower_book_fate_card_reward_notify, [(NetMsgId.Id).region_boss_level_challenge_ticket_notify] = region_boss_level_challenge_ticket_notify, [(NetMsgId.Id).honor_change_notify] = honor_change_notify, [(NetMsgId.Id).tower_growth_node_change_notify] = tower_growth_node_change_notify, [(NetMsgId.Id).char_up_change_notify] = char_up_change_notify, [(NetMsgId.Id).clear_all_vampire_survivor_notify] = clear_all_vampire_survivor_notify, [(NetMsgId.Id).add_vampire_season_score_notify] = add_vampire_season_score_notify, [(NetMsgId.Id).vampire_survivor_talent_node_notify] = HttpNetHandlerPlus.vampire_survivor_talent_node_notify, [(NetMsgId.Id).star_tower_sub_note_skill_info_notify] = star_tower_sub_note_skill_info_notify, [(NetMsgId.Id).refresh_agent_notify] = refresh_agent_notify, [(NetMsgId.Id).clear_all_skill_instance_notify] = clear_all_skill_instance_notify, [(NetMsgId.Id).order_paid_notify] = HttpNetHandlerPlus.order_paid_notify, [(NetMsgId.Id).order_revoke_notify] = HttpNetHandlerPlus.order_revoke_notify, [(NetMsgId.Id).order_collected_notify] = HttpNetHandlerPlus.order_collected_notify, [(NetMsgId.Id).vampire_survivor_new_season_notify] = HttpNetHandlerPlus.vampire_survivor_new_season_notify, [(NetMsgId.Id).item_expired_change_notify] = HttpNetHandlerPlus.item_expired_change_notify, [(NetMsgId.Id).st_skip_floor_notify] = st_skip_floor_notify, [(NetMsgId.Id).st_add_team_exp_notify] = st_add_team_exp_notify, [(NetMsgId.Id).st_add_new_case_notify] = st_add_new_case_notify, [(NetMsgId.Id).st_items_change_notify] = st_items_change_notify, [(NetMsgId.Id).tower_change_sub_note_skill_notify] = tower_change_sub_note_skill_notify, [(NetMsgId.Id).region_boss_level_apply_succeed_ack] = region_boss_level_apply_succeed_ack, [(NetMsgId.Id).region_boss_level_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).region_boss_level_settle_succeed_ack] = region_boss_level_settle_succeed_ack, [(NetMsgId.Id).region_boss_level_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).region_boss_level_sweep_succeed_ack] = region_boss_level_sweep_succeed_ack, [(NetMsgId.Id).skill_instance_apply_succeed_ack] = skill_instance_apply_succeed_ack, [(NetMsgId.Id).skill_instance_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).week_boss_apply_succeed_ack] = week_boss_apply_succeed_ack, [(NetMsgId.Id).week_boss_apply_failed_ack] = week_boss_apply_failed_ack, [(NetMsgId.Id).week_boss_settle_succeed_ack] = week_boss_settle_succeed_ack, [(NetMsgId.Id).week_boss_settle_failed_ack] = week_boss_settle_failed_ack, [(NetMsgId.Id).week_boss_refresh_ticket_notify] = week_boss_refresh_ticket_notify, [(NetMsgId.Id).player_learn_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).player_learn_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).char_affinity_quest_reward_receive_succeed_ack] = char_affinity_quest_reward_receive_succeed_ack, [(NetMsgId.Id).char_affinity_quest_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).char_affinity_gift_send_succeed_ack] = char_affinity_gift_send_succeed_ack, [(NetMsgId.Id).char_affinity_gift_send_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).char_recruitment_succeed_ack] = char_recruitment_succeed_ack, [(NetMsgId.Id).char_recruitment_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).agent_reward_receive_succeed_ack] = agent_reward_receive_succeed_ack, [(NetMsgId.Id).agent_new_notify] = agent_new_notify, [(NetMsgId.Id).agent_apply_failed_ack] = agent_apply_failed_ack, [(NetMsgId.Id).char_dating_landmark_select_succeed_ack] = char_dating_landmark_select_succeed_ack, [(NetMsgId.Id).char_dating_event_reward_receive_succeed_ack] = char_dating_event_reward_receive_succeed_ack, [(NetMsgId.Id).char_dating_gift_send_succeed_ack] = char_dating_gift_send_succeed_ack, [(NetMsgId.Id).char_archive_reward_receive_succeed_ack] = char_archive_reward_receive_succeed_ack, [(NetMsgId.Id).char_archive_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_daily_reward_notify] = activity_mining_daily_reward_notify, [(NetMsgId.Id).activity_mining_supplement_reward_notify] = activity_mining_supplement_reward_notify, [(NetMsgId.Id).activity_mining_quest_reward_receive_succeed_ack] = activity_mining_quest_reward_receive_succeed_ack, [(NetMsgId.Id).activity_mining_quest_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_story_reward_receive_succeed_ack] = activity_mining_story_reward_receive_succeed_ack, [(NetMsgId.Id).activity_mining_story_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_apply_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_move_to_next_layer_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_move_to_next_layer_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_dig_succeed_ack] = activity_mining_dig_succeed_ack, [(NetMsgId.Id).activity_mining_dig_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_mining_energy_convert_notify] = activity_mining_energy_convert_notify, [(NetMsgId.Id).activity_mining_enter_layer_notify] = HttpNetHandlerPlus.activity_mining_enter_layer_notify, [(NetMsgId.Id).activity_mining_grids_error_notify] = HttpNetHandlerPlus.activity_mining_grids_error_notify, [(NetMsgId.Id).score_boss_star_reward_receive_succeed_ack] = score_boss_star_reward_receive_succeed_ack, [(NetMsgId.Id).activity_cookie_settle_succeed_ack] = HttpNetHandlerPlus.activity_cookie_settle_succeed_ack, [(NetMsgId.Id).redeem_code_succeed_ack] = redeem_code_succeed_ack, [(NetMsgId.Id).redeem_code_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).notice_change_notify] = notice_change_notify, [(NetMsgId.Id).joint_drill_apply_succeed_ack] = joint_drill_apply_succeed_ack, [(NetMsgId.Id).joint_drill_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).joint_drill_sweep_succeed_ack] = joint_drill_sweep_succeed_ack, [(NetMsgId.Id).joint_drill_sweep_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).joint_drill_settle_succeed_ack] = joint_drill_settle_succeed_ack, [(NetMsgId.Id).joint_drill_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).joint_drill_game_over_succeed_ack] = joint_drill_game_over_succeed_ack, [(NetMsgId.Id).joint_drill_game_over_failed_ack] = HttpNetHandlerPlus.joint_drill_game_over_failed_ack, [(NetMsgId.Id).joint_drill_quest_reward_receive_succeed_ack] = joint_drill_quest_reward_receive_succeed_ack, [(NetMsgId.Id).joint_drill_quest_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_joint_drill_refresh_ticket_notify] = activity_joint_drill_refresh_ticket_notify, [(NetMsgId.Id).joint_drill_sync_failed_ack] = HttpNetHandlerPlus.joint_drill_sync_failed_ack, [(NetMsgId.Id).joint_drill_give_up_failed_ack] = HttpNetHandlerPlus.joint_drill_give_up_failed_ack, [(NetMsgId.Id).activity_tower_defense_story_reward_receive_succeed_ack] = activity_tower_defense_story_reward_receive_succeed_ack, [(NetMsgId.Id).activity_tower_defense_story_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_tower_defense_quest_reward_receive_succeed_ack] = activity_tower_defense_quest_reward_receive_succeed_ack, [(NetMsgId.Id).activity_tower_defense_quest_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_tower_defense_level_settle_succeed_ack] = activity_tower_defense_level_settle_succeed_ack, [(NetMsgId.Id).activity_tower_defense_level_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_avg_reward_receive_succeed_ack] = HttpNetHandlerPlus.activity_story_reward_receive_succeed_ack, [(NetMsgId.Id).activity_avg_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_task_reward_receive_succeed_ack] = HttpNetHandlerPlus.activity_task_reward_receive_succeed_ack, [(NetMsgId.Id).activity_task_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_task_group_reward_receive_succeed_ack] = HttpNetHandlerPlus.activity_task_group_reward_receive_succeed_ack, [(NetMsgId.Id).activity_task_group_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).force_update_notify] = force_update_notify, [(NetMsgId.Id).player_head_icon_change_notify] = HttpNetHandlerPlus.player_head_icon_change_notify, [(NetMsgId.Id).tutorial_level_settle_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).tutorial_level_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).tutorial_level_reward_receive_succeed_ack] = HttpNetHandlerPlus.tutorial_level_reward_receive_succeed_ack, [(NetMsgId.Id).tutorial_level_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).activity_levels_settle_failed_ack] = HttpNetHandlerPlus.activity_levels_settle_failed_ack, [(NetMsgId.Id).build_convert_detail_list_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).build_convert_detail_list_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).build_convert_submit_succeed_ack] = HttpNetHandlerPlus.build_convert_submit_succeed_ack, [(NetMsgId.Id).build_convert_submit_failed_ack] = NOTHING_NEED_TO_BE_DONE, [(NetMsgId.Id).build_convert_group_reward_receive_succeed_ack] = HttpNetHandlerPlus.build_convert_group_reward_receive_succeed_ack, [(NetMsgId.Id).build_convert_group_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE}
end

HttpNetHandler.Init = function()
  -- function num : 0_190 , upvalues : _ENV, PB, BindProcessFunction, MakeNetMsgIdMap, HttpNetHandler
  local pbSchema = (NovaAPI.LoadLuaBytes)("GameCore/Network/proto.pb")
  assert((PB.load)(pbSchema))
  BindProcessFunction()
  NetMsgIdMap = MakeNetMsgIdMap()
  ;
  (EventManager.Add)("CS2LuaEvent_OnApplicationFocus", HttpNetHandler, HttpNetHandler.OnCS2LuaEvent_AppFocus)
end

HttpNetHandler.SendMsg = function(nNetMsgId, mapMessageData, sUrl, callback)
  -- function num : 0_191 , upvalues : _ENV, timerPingPong, TimerResetType, PB
  if (NovaAPI.IsEditorPlatform)() == true then
    printLog("发送消息：" .. nNetMsgId)
  end
  if nNetMsgId ~= (NetMsgId.Id).player_ping_req and timerPingPong ~= nil then
    timerPingPong:Reset(TimerResetType.ResetElapsed)
  end
  local data = assert((PB.encode)((NetMsgId.MsgName)[nNetMsgId], mapMessageData))
  ;
  (NovaAPI.AddSendMsgRequest)(nNetMsgId, data, callback, sUrl)
end

HttpNetHandler.DispatchMsg = function(MsgReceive, bIsNextMsg, MsgSend, bError, mapMainData)
  -- function num : 0_192 , upvalues : _ENV, PB, mapProcessFunction, mapNetMsgIdFailed, HttpNetHandler
  if type(bError) == "nil" then
    bError = false
  end
  if type(mapMainData) == "nil" then
    mapMainData = {}
  end
  local nReceiveMsgId = MsgReceive.msgId
  local mapReceiveMsgBody = MsgReceive.msgBody
  local sMsgName = (NetMsgId.MsgName)[nReceiveMsgId]
  local mapMsgData = assert((PB.decode)(sMsgName, mapReceiveMsgBody))
  if mapProcessFunction == nil then
    return 
  end
  local ProcessFunction = mapProcessFunction[nReceiveMsgId]
  if ProcessFunction ~= nil then
    printLog("处理消息，发送：" .. MsgSend.msgId .. "，接收：" .. nReceiveMsgId .. "，是否为嵌套消息�?" .. tostring(bIsNextMsg))
    ProcessFunction(mapMsgData)
  else
    printWarn("没有绑定消息处理函数，发送：" .. MsgSend.msgId .. "，接收：" .. nReceiveMsgId .. "，是否为嵌套消息�?" .. tostring(bIsNextMsg))
  end
  if sMsgName ~= "proto.Error" then
    bError = bIsNextMsg ~= false
    MsgSend.receiveMsgId = nReceiveMsgId
    mapMainData = mapMsgData
    do
      local nFailId = mapNetMsgIdFailed[MsgSend.msgId]
      if bError == true and nFailId ~= nil and nFailId ~= nReceiveMsgId then
        ProcessFunction = mapProcessFunction[nFailId]
        if ProcessFunction ~= nil then
          printLog("处理消息，收到服务器返回失败或错误，但其id并非对应Req的失败id，收到的：" .. nReceiveMsgId .. "应该对应的：" .. nFailId)
          ProcessFunction()
        end
      end
      local bUseCommonErrorMsgBox = true
      if (NovaAPI.IsServerMaintained)() == true and (nReceiveMsgId == (NetMsgId.Id).player_login_failed_ack or nReceiveMsgId == (NetMsgId.Id).ike_failed_ack) then
        bUseCommonErrorMsgBox = false
      end
      if sMsgName == "proto.Error" and bUseCommonErrorMsgBox == true then
        (EventManager.Hit)(EventId.SetTransition)
        local mapErrorCfg = (ConfigTable.GetData)("ErrorCode", mapMsgData.Code)
        do
          if mapErrorCfg then
            local sErrorDetail = mapErrorCfg.Template
            if mapMsgData.Arguments and #mapMsgData.Arguments > 0 then
              sErrorDetail = (string.format)(mapErrorCfg.Template, (table.unpack)(mapMsgData.Arguments))
            end
            local bNeedTrace = false
            if mapMsgData.TraceId and mapMsgData.TraceId ~= 0 then
              bNeedTrace = true
              sErrorDetail = sErrorDetail .. "\n" .. mapMsgData.TraceId
            end
            printError("服务器返回错误：" .. sErrorDetail)
            local nShowType = mapErrorCfg.ShowType
            if bNeedTrace and nShowType == (GameEnum.errorShowType).Tips then
              nShowType = (GameEnum.errorShowType).Window
            end
            if nShowType ~= (GameEnum.errorShowType).Tips then
              local AlertCallback = function()
    -- function num : 0_192_0 , upvalues : bNeedTrace, _ENV, mapMsgData, MsgSend, nShowType
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R0 in 'UnsetPending'

    if bNeedTrace then
      ((CS.UnityEngine).GUIUtility).systemCopyBuffer = mapMsgData.TraceId
      ;
      (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("ErrorCode_Trace"))
    end
    if mapMsgData.Action and mapMsgData.Action == 2 and (MsgSend.msgId == (NetMsgId.Id).mail_recv_req or MsgSend.msgId == (NetMsgId.Id).mail_remove_req or MsgSend.msgId == (NetMsgId.Id).mail_read_req) then
      (PlayerData.Mail):GetAgainAllMain()
    end
    if nShowType == (GameEnum.errorShowType).Relogin then
      (PanelManager.OnConfirmBackToLogIn)()
    end
  end

              local msg = {nType = (AllEnum.MessageBox).Alert, sContent = sErrorDetail, callbackConfirm = AlertCallback, bDisableSnap = true}
              if bNeedTrace then
                msg.sConfirm = (ConfigTable.GetUIText)("ErrorCode_Btn_Copy")
              end
              do
                do
                  do
                    if (NovaAPI.GetClientChannel)() == (AllEnum.ChannelName).BanShu then
                      local a = (string.gmatch)(sErrorDetail, "%a+")
                      if a() then
                        msg.sContent = "提示：服务器错误，请稍后再试�?"
                      end
                    end
                    if nShowType == (GameEnum.errorShowType).Relogin then
                      (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = sErrorDetail, callbackConfirm = AlertCallback, sConfirm = (ConfigTable.GetUIText)("ErrorCode_Btn_Relogin")})
                    else
                      (EventManager.Hit)(EventId.OpenMessageBox, msg)
                    end
                    if nShowType == (GameEnum.errorShowType).Tips then
                      (EventManager.Hit)(EventId.OpenMessageBox, sErrorDetail)
                    end
                    local msg = {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("ErrorCode_UnknowError") .. "SEC:" .. mapMsgData.Code, bDisableSnap = true}
                    ;
                    (EventManager.Hit)(EventId.OpenMessageBox, msg)
                  end
                  local dataNext = mapMsgData.NextPackage
                  -- DECOMPILER ERROR at PC281: Unhandled construct in 'MakeBoolean' P1

                  if (dataNext == nil or dataNext == "") and bError == false and MsgSend.callback ~= nil then
                    printLog("执行 network 回调，发送：" .. MsgSend.msgId .. "，接收：" .. MsgSend.receiveMsgId)
                    ;
                    (MsgSend.callback)(MsgSend, mapMainData)
                    MsgSend.callback = nil
                    ;
                    (EventManager.Hit)("DispatchMsgDone")
                  end
                  do
                    local msg = (NovaAPI.ParseMessage)(dataNext, true)
                    if msg ~= nil then
                      (HttpNetHandler.DispatchMsg)(msg, true, MsgSend, bError, mapMainData)
                    end
                    -- DECOMPILER ERROR: 16 unprocessed JMP targets
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

HttpNetHandler.SendPingPong = function(_this, bManual, callback)
  -- function num : 0_193 , upvalues : _ENV, HttpNetHandler, timerPingPong, TimerResetType
  if (NovaAPI.IsEditorPlatform)() == true then
    printLog("发送心跳消息")
  end
  local msgSend = {}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_ping_req, msgSend, nil, callback)
  if bManual == true and timerPingPong ~= nil then
    timerPingPong:Reset(TimerResetType.ResetElapsed)
  end
end

HttpNetHandler.SetPingPong = function()
  -- function num : 0_194 , upvalues : timerPingPong, TimerManager, PING_PONG_INTERVAL, HttpNetHandler
  if timerPingPong == nil then
    timerPingPong = (TimerManager.Add)(0, PING_PONG_INTERVAL, HttpNetHandler, HttpNetHandler.SendPingPong, true, false, false, nil)
  else
    timerPingPong:Pause(false)
  end
end

HttpNetHandler.UnsetPingPong = function()
  -- function num : 0_195 , upvalues : timerPingPong
  if timerPingPong ~= nil then
    timerPingPong:Pause(true)
  end
end

HttpNetHandler.OnCS2LuaEvent_AppFocus = function(_, bFocus)
  -- function num : 0_196 , upvalues : _ENV, timerPingPong
  if (NovaAPI.IsRuntimeWindowsPlayer)() == true then
    return 
  end
  local bForcePrintLog = false
  if timerPingPong ~= nil then
    printLog((string.format)("Lua HttpNetHandler OnCS2LuaEvent_AppFocus, bFocus:%s, timerPingPong is nil:%s", tostring(bFocus), tostring(bForcePrintLog ~= true and (NovaAPI.IsEditorPlatform)() ~= false)))
    if timerPingPong == nil then
      return 
    end
    if bFocus == true then
      timerPingPong:Pause(false)
      if bForcePrintLog == true or (NovaAPI.IsEditorPlatform)() == false then
        printLog("Lua HttpNetHandler OnCS2LuaEvent_AppFocus, timerPingPong: RUN.")
      end
    else
      timerPingPong:Pause(true)
      if bForcePrintLog == true or (NovaAPI.IsEditorPlatform)() == false then
        printLog("Lua HttpNetHandler OnCS2LuaEvent_AppFocus, timerPingPong: PAUSE.")
      end
    end
    -- DECOMPILER ERROR: 7 unprocessed JMP targets
  end
end

HttpNetHandler.ProcChangeInfo = function(mapDecodedChangeInfo)
  -- function num : 0_197 , upvalues : _ENV
  (PlayerData.Coin):ChangeCoin(mapDecodedChangeInfo["proto.Res"])
  ;
  (PlayerData.Item):ChangeItem(mapDecodedChangeInfo["proto.Item"])
  ;
  (PlayerData.Char):GetNewChar(mapDecodedChangeInfo["proto.Char"])
  ;
  (PlayerData.Base):ChangeEnergy(mapDecodedChangeInfo["proto.Energy"])
  ;
  (PlayerData.Base):ChangeWorldClass(mapDecodedChangeInfo["proto.WorldClass"])
  ;
  (PlayerData.Base):ChangeTitle(mapDecodedChangeInfo["proto.Title"])
  ;
  (PlayerData.Disc):CreateNewDisc(mapDecodedChangeInfo["proto.Disc"])
  ;
  (PlayerData.Base):ChangeHonorTitle(mapDecodedChangeInfo["proto.Honor"])
  ;
  (PlayerData.HeadData):ChangePlayerHead(mapDecodedChangeInfo["proto.HeadIcon"])
end

return HttpNetHandler

