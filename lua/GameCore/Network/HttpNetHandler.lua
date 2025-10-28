-- 网络消息处理
local PB = require "pb"
-- local protoc = require "GameCore.Network.protoc"


local TimerManager = require "GameCore.Timer.TimerManager"
local TimerResetType = require "GameCore.Timer.TimerResetType"
local HttpNetHandlerPlus = require "GameCore.Network.HttpNetHandlerPlus"

local HttpNetHandler = {}
local mapProcessFunction = nil
local mapNetMsgIdFailed = {}

local timerPingPong = nil -- 心跳计时�?
local PING_PONG_INTERVAL = 120 -- 单位：秒
local TBRELOGIN_CODE = { 110107, 10003, 110106, 100106 }

local function SetTokenAES(sToken, pubKey, Cipher)
    NovaAPI.TOKEN = sToken
    NovaAPI.SetAeadKey(pubKey,Cipher)
end
local function SetToken(sToken)
    NovaAPI.TOKEN = sToken
end
local function MakeNetMsgIdMap()
    for k, v in pairs(NetMsgId.Id) do
        if string.find(k, "_req") ~= nil then
            local fail = string.gsub(k, "_req", "_failed_ack")
            local nId_fail = NetMsgId.Id[fail]
            if nId_fail ~= nil then
                mapNetMsgIdFailed[v] = nId_fail -- key:发送id，value:失败id
            end
        end
    end
end

-- process function --
local function ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Coin:ChangeCoin(mapDecodedChangeInfo["proto.Res"]) -- 货币资源数量变更，数组�?
    PlayerData.Item:ChangeItem(mapDecodedChangeInfo["proto.Item"]) -- 道具数量变更，数组�?
    PlayerData.Char:GetNewChar(mapDecodedChangeInfo["proto.Char"]) -- 角色数据变更，数�?(理论上一般只可能是获得角�?)�?
    PlayerData.Base:ChangeEnergy(mapDecodedChangeInfo["proto.Energy"])
    PlayerData.Base:ChangeWorldClass(mapDecodedChangeInfo["proto.WorldClass"])
    PlayerData.Base:ChangeTitle(mapDecodedChangeInfo["proto.Title"])
    PlayerData.Disc:CreateNewDisc(mapDecodedChangeInfo["proto.Disc"])
    PlayerData.Base:ChangeHonorTitle(mapDecodedChangeInfo["proto.Honor"]) -- 称号变化
    PlayerData.HeadData:ChangePlayerHead(mapDecodedChangeInfo["proto.HeadIcon"]) -- 头像变化
    -- PlayerData:ProcSpecialChange(mapDecodedChangeInfo.Special) -- 特殊数据变化，需与服务器约定�?
end
local function NOTHING_NEED_TO_BE_DONE(mapData)
end

local function ike_succeed_ack(mapData)
    SetTokenAES(mapData.Token, mapData.PubKey,mapData.Cipher)
    NovaAPI.MarkServerTimeStamp(mapData.ServerTs)
end
local function ike_failed_ack(mapData)
    EventManager.Hit("LoginFailed")
end
local function player_login_succeed_ack(mapMsgData)
    SetToken(mapMsgData.Token)
end
local function player_login_failed_ack(mapMsgData)
    EventManager.Hit("LoginFailed")
    NovaAPI.ResetIke()
end
local function player_data_succeed_ack(mapMsgData)
    PopUpManager.InitLoginQueue()
    PlayerData.Base:CacheAccInfo(mapMsgData.Acc)
    PlayerData.Base:CacheEnergyInfo(mapMsgData.Energy)
    PlayerData.Base:CacheTitleInfo(mapMsgData.Titles)
    PlayerData.Base:CacheHonorTitleInfo(mapMsgData.Honors)
    PlayerData.Base:CacheHonorTitleList(mapMsgData.HonorList)
    PlayerData.Base:CacheWorldClassInfo(mapMsgData.WorldClass)
    PlayerData.Base:CacheSendGiftCount(mapMsgData.SendGiftCnt)
    PlayerData.Coin:CacheCoin(mapMsgData.Res)
    PlayerData.Char:CacheCharacters(mapMsgData.Chars)
    PlayerData.Team:CacheFormationInfo(mapMsgData.Formation)
    --PlayerData.Mainline:CacheMainline(mapMsgData.MainLines,mapMsgData.Chapters)
    PlayerData.Item:CacheItemData(mapMsgData.Items)
    PlayerData.Activity:CacheActivityData(mapMsgData.Activities)
    PlayerData.State:CacheStateData(mapMsgData.State)
    PlayerData.RogueBoss:CacheRogueBossData(mapMsgData.RegionBossLevels)
    PlayerData.RogueBoss:CacheWeeklyCopiesData(mapMsgData.WeekBossLevels)
    PlayerData.Quest:CacheTourGroupOrder(mapMsgData.TourGuideQuestGroup)
    PlayerData.Quest:CacheAllQuest(mapMsgData.Quests.List)
    PlayerData.Quest:CacheDailyActiveIds(mapMsgData.DailyActiveIds)
    PlayerData.Achievement:CacheBattleAchievementData(mapMsgData.Achievements)
    PlayerData.Daily.CacheDailyData(mapMsgData.SigninIndex)
    PlayerData.Handbook:CacheHandbookData(mapMsgData.Handbook)
    PlayerData.Board:CacheBoardData(mapMsgData.Board)
    PlayerData.DailyInstance:CacheDailyInstanceLevel(mapMsgData.DailyInstances)
    PlayerData.Dictionary:CacheDictionaryData(mapMsgData.Dictionaries)
    PlayerData.Phone:CachePhoneMsgCount(mapMsgData.Phone)
    PlayerData.Disc:CacheDiscData(mapMsgData.Discs)
    PlayerData.Disc:CacheBGMDisc(mapMsgData.MusicInfo)
    PlayerData.EquipmentInstance:CacheEquipmentInstanceLevel(mapMsgData.CharGemInstances)
    PlayerData.StarTower:CachePassedId(mapMsgData.RglPassedIds)
    PlayerData.Avg:CacheAvgData(mapMsgData.Story)
    PlayerData.StarTower:CacheStarTowerTicket(mapMsgData.TowerTicket)
    PlayerData.Shop:CacheDailyShopReward(mapMsgData.DailyShopRewardStatus)
    PlayerData.Dating:CacheDatingCharIds(mapMsgData.DatingCharIds)
    PlayerData.VampireSurvivor:CacheLevelData(mapMsgData.VampireSurvivorRecord)
    PlayerData.SkillInstance:CacheSkillInstanceLevel(mapMsgData.SkillInstances)

    NovaAPI.MarkServerTimeStamp(mapMsgData.ServerTs)
    PlayerData.Base:SetNextRefreshTime(mapMsgData.ServerTs)
    PlayerData.Dispatch.CacheDispatchData(mapMsgData.Agent)
    PlayerData.Activity:CacheActivityGroupData()

    PlayerData.TutorialData:CacheTutorialData(mapMsgData.TutorialLevels)

    --printLog("登录时的 ServerTs:" .. tostring(mapMsgData.ServerTs))


    --红点相关
    --角色档案红点
    PlayerData.Char:UpdateAllCharRecordInfoRedDot()
    if CS.SDKManager.Instance:IsSDKInit() then
        CS.SDKManager.Instance:RoleInfoUpload(tostring(PlayerData.Base._nPlayerId), PlayerData.Base._sPlayerNickName, mapMsgData.ServerTs)
    end
    --角色命座红点
    PlayerData.Talent:UpdateAllCharTalentRedDot()
    PlayerData.Filter:InitSortData()
    EventManager.Hit("Get_Player_Data_Succeed")
end
--[[ local function player_data_failed_ack(mapMsgData) end
local function player_reg_failed_ack(mapMsgData) end
local function player_name_edit_succeed_ack(mapMsgData) end
local function player_name_edit_failed_ack(mapMsgData) end
local function player_head_icon_set_succeed_ack(mapMsgData) end
local function player_head_icon_set_failed_ack(mapMsgData) end ]]
local function player_board_set_succeed_ack(mapMsgData)
    PlayerData.Board:SetBoardSuccess()
end
local function player_board_set_failed_ack(mapMsgData)
    PlayerData.Board:SetBoardFail()
end
local function player_world_class_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Base:PlayerWorldClassRewardReceiveSuc(mapMsgData)
end
local function player_world_class_advance_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Base:PlayerWorldClassAdvanceSuc(mapMsgData)
end
--[[ local function player_world_class_reward_receive_failed_ack(mapMsgData) end ]]
local function world_class_reward_state_notify(mapMsgData)
    PlayerData.State:CacheWorldClassRewardState(mapMsgData)
end
local function energy_buy_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    --刷新购买次数
    PlayerData.Base:RefreshEnergyBuyCount(mapMsgData.Count)
end

local function item_use_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function item_use_failed_ack(mapMsgData) end ]]
local function item_product_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function item_quick_growth_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function fragments_convert_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function item_product_failed_ack(mapMsgData) end ]]
local function player_ping_succeed_ack(mapMsgData)
    NovaAPI.MarkServerTimeStamp(mapMsgData.ServerTs)
    --printLog("收到心跳返回消息:" .. tostring(mapMsgData.ServerTs))
end
--[[local function mainline_apply_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function mainline_unlock_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function mainline_apply_failed_ack(mapMsgData) end
local function mainline_exit_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function mainline_exit_failed_ack(mapMsgData) end
local function mainline_settle_succeed_ack(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData.Change))
end]]
local function story_settle_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function gacha_spin_succeed_ack(mapMsgData)
    local function CheckNew(nTid)
        local mapItemCfgData = ConfigTable.GetData_Item(nTid)
        if mapItemCfgData == nil then
            return false
        end
        if mapItemCfgData.Type == GameEnum.itemType.Char then
            local mapChar = PlayerData.Char:GetCharDataByTid(nTid)
            return mapChar == nil
        elseif mapItemCfgData.Type == GameEnum.itemType.Disc then
            local mapDisc = PlayerData.Disc:GetDiscById(nTid)
            return mapDisc == nil
        else
            return false
        end
    end
    local tbReward = {}
    local tbItemId = {}
    for _, v in ipairs(mapMsgData.Cards) do
        local bNewHandBood = CheckNew(v.Card.Tid)
        local bNew = bNewHandBood and table.indexof(tbItemId, v.Card.Tid) < 1
        table.insert(tbItemId, v.Card.Tid)
        table.insert(tbReward, { id = v.Card.Tid, count = v.Card.Qty, rewardItem = v.Rewards, bNew = bNew })
        v.Card.bNew = bNew
    end
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Item:CacheFragmentsOverflow(nil, mapMsgData.Change)
end
--[[ local function gacha_spin_failed_ack(mapMsgData) end
local function gacha_information_succeed_ack(mapMsgData) end
local function gacha_information_failed_ack(mapMsgData) end]]
local function mail_list_succeed_ack(mapMsgData)
    PlayerData.Mail:CacheMailData(mapMsgData)
end
--[[ local function mail_list_failed_ack(mapMsgData) end ]]
local function mail_read_succeed_ack(mapMsgData)
    PlayerData.Mail:ReadMail(mapMsgData)
end
--[[ local function mail_read_failed_ack(mapMsgData) end ]]
local function mail_recv_succeed_ack(mapMsgData)
    local mapDecodeInfo = UTILS.DecodeChangeInfo(mapMsgData.Items)
    --PlayerData.Mail:ReceiveMailItem(mapMsgData)
    ProcChangeInfo(mapDecodeInfo)
    --暂时log一下收到的物品
    local serpent = require "serpent"
    print(serpent.block(mapDecodeInfo))
    ---------------------
end
--[[ local function mail_recv_failed_ack(mapMsgData) end ]]
local function mail_remove_succeed_ack(mapMsgData)
    PlayerData.Mail:RemoveMail(mapMsgData)
end
local function dictionary_reward_receive_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(tbDecodeChange)
end
local function char_gem_instance_settle_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function char_gem_instance_sweep_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function skill_instance_sweep_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function activity_detail_succeed_ack(mapMsgData)
    PlayerData.Activity:CacheAllActivityData(mapMsgData)
end
local function activity_periodic_reward_receive_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(tbDecodeChange)
end
local function activity_periodic_final_reward_receive_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(tbDecodeChange)
end
local function activity_login_reward_receive_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(tbDecodeChange)
end
local function activity_trial_reward_receive_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(tbDecodeChange)
end
local function phone_contacts_info_succeed_ack(mapMsgData)
    PlayerData.Phone:CacheAddressBookData(mapMsgData.List)
end
local function phone_contacts_report_succeed_ack(mapMsgData)
    PlayerData.Phone:PhoneContactReportSuc(mapMsgData)
end
-------------------------------RogueBuild-------------------------
local function star_tower_build_delete_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData.Change)
    PlayerData.StarTower:AddStarTowerTicket(mapMsgData.Ticket)
    ProcChangeInfo(tbDecodeChange)
end

local function quest_reward_recv_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function star_tower_build_whether_save_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    PlayerData.StarTower:AddStarTowerTicket(mapMsgData.Ticket)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function star_tower_give_up_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)

    ProcChangeInfo(mapDecodedChangeInfo)
end
local function star_tower_interact_succeed_ack(mapMsgData)
    if mapMsgData.Settle then
        -- 结算�?
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Settle.Change)
        ProcChangeInfo(mapDecodedChangeInfo)
    end
end
------------------------------ startower ------------------------------
local function star_tower_apply_failed_ack()
    PlayerData.StarTower:ClearData()
end
local function tower_growth_node_unlock_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(tbDecodeChange)
end
local function tower_growth_group_node_unlock_succeed_ack(mapMsgData)
    local tbDecodeChange = UTILS.DecodeChangeInfo(mapMsgData.ChangeInfo)
    ProcChangeInfo(tbDecodeChange)
end
local function quest_tower_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function npc_affinity_plot_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function npc_affinity_plot_reward_receive_failed_ack(mapMsgData)
    EventManager.Hit(EventId.ClosePanel,PanelId.PureAvgStory)
end
------------------------------ Friend ------------------------------
--[[ local function friend_list_get_succeed_ack(mapMsgData) end
local function friend_list_get_failed_ack(mapMsgData) end
local function friend_uid_search_succeed_ack(mapMsgData) end
local function friend_uid_search_failed_ack(mapMsgData) end
local function friend_name_search_succeed_ack(mapMsgData) end
local function friend_name_search_failed_ack(mapMsgData) end
local function friend_add_succeed_ack(mapMsgData) end
local function friend_add_failed_ack(mapMsgData) end
local function friend_add_agree_succeed_ack(mapMsgData) end
local function friend_add_agree_failed_ack(mapMsgData) end
local function friend_all_agree_succeed_ack(mapMsgData) end
local function friend_all_agree_failed_ack(mapMsgData) end
local function friend_delete_succeed_ack(mapMsgData) end
local function friend_delete_failed_ack(mapMsgData) end
local function friend_invites_delete_succeed_ack(mapMsgData) end
local function friend_invites_delete_failed_ack(mapMsgData) end ]]
local function friend_receive_energy_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function friend_receive_energy_failed_ack(mapMsgData) end
local function friend_send_energy_succeed_ack(mapMsgData) end
local function friend_send_energy_failed_ack(mapMsgData) end
local function friend_star_set_succeed_ack(mapMsgData) end
local function friend_star_set_failed_ack(mapMsgData) end

local function resident_shop_get_succeed_ack(mapMsgData) end
local function resident_shop_get_failed_ack(mapMsgData) end ]]
local function resident_shop_purchase_succeed_ack(mapMsgData)
    if not mapMsgData.IsRefresh then
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        ProcChangeInfo(mapDecodedChangeInfo)
    end
end
local function daily_shop_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function resident_shop_purchase_failed_ack(mapMsgData) end ]]


------------------------------ Char -------------------------------
local function char_advance_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function char_skin_set_succeed_ack(mapMsgData) end
local function char_skin_set_failed_ack(mapMsgData) end ]]
------------------------------ Achievement ------------------------------
local function achievement_reward_receive_succeed_ack(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData))
end
--[[ local function achievement_reward_receive_failed_ack(mapMsgData) end
local function achievement_info_succeed_ack(mapMsgData) end
local function achievement_info_failed_ack(mapMsgData) end ]]
local function achievement_change_notify(mapMsgData)
    PlayerData.Achievement:ChangeAchievementData(mapMsgData)
end
local function achievement_state_notify(mapMsgData)
    PlayerData.State:CacheAchievementState(mapMsgData.New)
end
------------------------------ Daily ------------------------------
local function monthly_card_rewards_notify(mapMsgData)
    if mapMsgData.Switch then
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        ProcChangeInfo(mapDecodedChangeInfo)
    end
    PlayerData.Daily.ProcessMonthlyCard(mapMsgData)
end
local function signin_reward_change_notify(mapMsgData)
    if mapMsgData.Switch then
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        ProcChangeInfo(mapDecodedChangeInfo)
    end
    PlayerData.Daily.ProcessDailyCheckIn(mapMsgData)
end
---------------------------BattlePass----------------------------------
local function battle_pass_info_succeed_ack(mapMsgData)
    PlayerData.BattlePass:CacheBattlePassInfo(mapMsgData)
end
local function battle_pass_quest_reward_receive_succeed_ack(mapMsgData)
    PlayerData.BattlePass:OnQuestReceive(mapMsgData)
end
local function battle_pass_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function battle_pass_level_buy_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function battle_pass_order_collect_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.CollectResp.Items)
    ProcChangeInfo(mapDecodedChangeInfo)
end
------------------------------ Mall ------------------------------
--[[ local function mall_gem_list_succeed_ack(mapMsgData) end
local function mall_gem_list_failed_ack(mapMsgData) end
local function mall_gem_order_succeed_ack(mapMsgData) end
local function mall_gem_order_failed_ack(mapMsgData) end
local function mall_order_cancel_succeed_ack(mapMsgData) end
local function mall_order_cancel_failed_ack(mapMsgData) end ]]
local function mall_order_collect_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Items)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function mall_order_collect_failed_ack(mapMsgData) end
local function mall_monthlyCard_list_succeed_ack(mapMsgData) end
local function mall_monthlyCard_list_failed_ack(mapMsgData) end
local function mall_monthlyCard_order_succeed_ack(mapMsgData) end
local function mall_monthlyCard_order_failed_ack(mapMsgData) end
local function mall_package_list_succeed_ack(mapMsgData) end
local function mall_package_list_failed_ack(mapMsgData) end ]]
local function mall_package_order_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function mall_shop_order_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function mall_package_order_failed_ack(mapMsgData) end ]]
local function gem_convert_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--[[ local function gem_convert_failed_ack(mapMsgData) end ]]
------------------------------------------------------
------------------------------ Talent ------------------------------
local function talent_unlock_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function talent_reset_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function talent_node_reset_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function talent_group_unlock_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
------------------------------ Disc ------------------------------
local function disc_strengthen_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function disc_promote_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function disc_limit_break_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function disc_read_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
------------------------------ GM ------------------------------
--[[ local function sudo_succeed_ack(mapMsgData) end
local function sudo_failed_ack(mapMsgData) end
local function player_new_notify(mapMsgData) end ]]
local function mail_state_notify(mapMsgData)
    PlayerData.Mail:UpdateMailList(mapMsgData)
end
--[[ local function player_relogin_notify(mapMsgData) end
local function token_expire_notify(mapMsgData) end
local function player_ban_notify(mapMsgData) end ]]
local function player_relogin_expire_ban(mapMsgData)
    HttpNetHandler.UnsetPingPong()
end
local function quest_change_notify(mapMsgData)
    PlayerData.Quest:OnQuestProgressChanged(mapMsgData)
    --刷新红点
    PlayerData.Quest:UpdateQuestRedDot(mapMsgData.Type)
end
local function chars_final_notify(mapMsgData)
    PlayerData.Char:CacheCharacters(mapMsgData.List)
end
local function character_skin_gain_notify(mapMsgData)
    PlayerData.CharSkin:SkinGainEnqueue(mapMsgData)
end
local function character_skin_change_notify(mapMsgData)
    PlayerData.Char:SetCharSkinId(mapMsgData.CharId, mapMsgData.SkinId)
    -- printLog("收到更换皮肤通知�?" .. mapMsgData.CharId .. ", " .. mapMsgData.SkinId)
end
local function world_class_change_notify(mapMsgData)
    --PlayerData.Base:ChangeWorldClass(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData.Change))
end
local function world_class_number_notify(mapMsgData)
    PlayerData.State:CacheWorldClassRewardStateGM(mapMsgData.RewardsFlag)
    PlayerData.Base:ChangeWorldClassGM(mapMsgData)
end
local function world_class_quest_complete_notify(mapMsgData)
    for _, v in pairs(mapMsgData.List) do
        PlayerData.Quest:OnQuestProgressChanged(v)
        --刷新红点
        PlayerData.Quest:UpdateQuestRedDot(v.Type)
    end
end
local function char_reset_notify(mapMsgData)
    -- 此mapMsgData，直接就是mapMsgData.Char的一个数据，要变成table
    PlayerData.Char:CacheCharacters({ mapMsgData })
end
local function char_change_notify(mapMsgData)
    PlayerData.Char:CacheCharacters({ mapMsgData })
end
local function char_advance_reward_state_notify(mapMsgData)
    PlayerData.State:CacheCharactersAdRewards_Notify(mapMsgData)
end
local function items_change_notify(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData))
end
local function friend_state_notify(mapMsgData)
    PlayerData.Friend:UpdateFriendState(mapMsgData)
end
local function friend_energy_state_notify(mapMsgData)
    PlayerData.Friend:UpdateFriendEnergy(mapMsgData)
end
--[[ local function system_failed_ack(mapData) end ]]
local function boss_level_final_notify(mapMsgData)
    PlayerData.RogueBoss:CacheRogueBossData({ mapMsgData })
end
local function region_boss_level_apply_succeed_ack(mapMsgData)
    PlayerData.RogueBoss:EnterRegionBoss(mapMsgData)
end
--[[ local function region_boss_level_apply_failed_ack(mapMsgData) end ]]
local function region_boss_level_settle_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.RogueBoss:RegionBossLevelSettleSuccess(mapMsgData)
end
local function region_boss_level_sweep_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function skill_instance_apply_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end

local function week_boss_apply_succeed_ack(mapMsgData)
    print("week succeed")
    PlayerData.RogueBoss:EnterWeekBoss(mapMsgData)
end

local function week_boss_apply_failed_ack(mapMsgData)
    print("week failed")
end

local function week_boss_settle_succeed_ack(mapMsgData)
    --PlayerData.RogueBoss:SetIsWeeklyCopies(false)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.RogueBoss:WeeklyCopiesLevelSettleReqSuccess(mapMsgData)
end

local function week_boss_settle_failed_ack(mapMsgData)
    print("week settle failed")
    --PlayerData.RogueBoss:SetIsWeeklyCopies(false)
end

local function week_boss_refresh_ticket_notify(mapMsgData)
    print("week settle reset")
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end



--[[ local function region_boss_level_settle_failed_ack(mapMsgData) end ]]

--[[ local function player_learn_succeed_ack() end
local function player_learn_failed_ack() end ]]
local function handbook_change_notify(mapMsgData)
    PlayerData.Handbook:UpdateHandbookData(mapMsgData)
end
local function char_up_change_notify(mapMsgData)
    for _, v in pairs(mapMsgData.Handbook) do
        PlayerData.Handbook:UpdateHandbookData(v)
    end
    PlayerData.Char:CacheCharacters({ mapMsgData.Char })
end
local function daily_instance_settle_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function daily_instance_raid_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function mall_package_state_notify(mapMsgData)
    RedDotManager.SetValid(RedDotDefine.Mall_Free, nil, mapMsgData.New)
end
local function quest_state_notify(mapMessageData)
    PlayerData.Quest:UpdateServerQuestRedDot(mapMessageData)
end
local function dictionary_change_notify(mapMsgData)
    PlayerData.Dictionary:ChangeDictionaryData(mapMsgData)
end
local function clear_all_traveler_due_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.TravelerDuel:CacheTravelerDuelLevelData(mapMsgData)
end
local function clear_all_region_boss_level_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.RogueBoss:CacheRogueBossData(mapMsgData.RegionBossLevels)
end
local function clear_all_week_boss_notify(mapMsgData)
    PlayerData.RogueBoss:CacheWeeklyCopiesData(mapMsgData.WeekBossLevels)
end
local function st_clear_all_star_tower_notify(mapMsgData)
    PlayerData.StarTower:CachePassedId(mapMsgData.Ids)
end
local function clear_all_daily_instance_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.DailyInstance:CacheDailyInstanceLevel(mapMsgData.DailyInstances)
end
local function clear_all_char_gem_instance_notify(mapMsgData)
    PlayerData.EquipmentInstance:CacheEquipmentInstanceLevel(mapMsgData.CharGemInstances)
end
local function st_import_build_notify(mapMsgData)
    PlayerData.Build:CacheRogueBuild(mapMsgData)
end
local function st_export_build_notify(mapMsgData)
    CS.UnityEngine.GUIUtility.systemCopyBuffer = mapMsgData.Value
end
local function char_affinity_final_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Char:ChangeCharAffinityValue(mapMsgData.Info)
end
local function char_affinity_reward_state_notify(mapMsgData)
end
local function activity_change_notify(mapMsgData)
    PlayerData.Activity:RefreshActivityData(mapMsgData)
end
local function activity_state_change_notify(mapMsgData)
    PlayerData.Activity:RefreshActivityStateData(mapMsgData)
end
local function activity_quest_change_notify(mapMsgData)
    PlayerData.Activity:RefreshSingleQuest(mapMsgData)
end
local function mail_overflow_notify(mapMsgData)
    PlayerData.State:SetMailOverflow(true)
end
local function infinity_tower_rewards_state_notify(mapMsgData)
    PlayerData.InfinityTower:InfinityTowerRewardsStateNotify(mapMsgData)
end
local function phone_chat_change_notify(mapMsgData)
    PlayerData.Phone:NewChatTrigger(mapMsgData)
end
local function character_fragments_overflow_change_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Item:CacheFragmentsOverflow(mapMsgData)
end
local function infinity_tower_settle_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function infinity_tower_daily_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function infinity_tower_plot_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function disc_reset_notify(mapMsgData)
    PlayerData.Disc:UpdateDiscData(mapMsgData.Id, mapMsgData)
end
local function story_complete_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Avg:CacheAvgData(mapMsgData)

end
local function clear_all_story_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Avg:CacheAvgData(mapMsgData)
end
local function activity_login_rewards_notify(mapMsgData)
    PlayerData.Activity:CacheLoginRewardActData(mapMsgData.ActivityId, mapMsgData)
end
local function star_tower_book_potential_notify(mapMsgData)
    PlayerData.StarTowerBook:CharPotentialBookChange(mapMsgData)
end
local function star_tower_book_event_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function tower_book_fate_card_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function star_tower_book_potential_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function star_tower_book_event_notify(mapMsgData)
end
local function tower_book_fate_card_collect_notify(mapMsgData)
    PlayerData.StarTowerBook:FateCardBookChange(mapMsgData)
    PlayerData.VampireSurvivor:AddTalentPoint(mapMsgData.Cards)
end
local function tower_book_fate_card_reward_notify(mapMsgData)
    PlayerData.StarTowerBook:FateCardBookRewardChange(mapMsgData)
end
local function region_boss_level_challenge_ticket_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
    EventManager.Hit("region_boss_ticket_notify", AllEnum.CoinItemId.RogueHardCoreTick)
end
local function honor_change_notify(mapMsgData)
    PlayerData.Base:CacheHonorTitleInfo(mapMsgData.Honors)
    EventManager.Hit("HonorTitle_Change")
end
local function tower_growth_node_change_notify(mapMsgData)
    PlayerData.StarTower:ParseGrowthData(mapMsgData.Detail)
    PlayerData.StarTower:UpdateGrowthReddot()
end
local function add_vampire_season_score_notify(mapMsgData)
    PlayerData.VampireSurvivor:CacheScore(mapMsgData.Value)
end
local function clear_all_vampire_survivor_notify(mapMsgData)
    PlayerData.VampireSurvivor:CachePassedId(mapMsgData.Ids)
end
local function star_tower_sub_note_skill_info_notify(mapMsgData)
    local sTip = "音符掉落查询：\n"
    local function printTableHelper(t, indent)
        if not indent then
            indent = 0
        end
        for k, v in pairs(t) do
            local formatting = string.rep(" ", indent) .. tostring(k) .. ": "
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
local function refresh_agent_notify(mapMsgData)
    PlayerData.Dispatch.RefreshAgentInfos(mapMsgData)
end
local function clear_all_skill_instance_notify(mapMsgData)
    PlayerData.SkillInstance:CacheSkillInstanceLevel(mapMsgData.SkillInstances)
end
------------------------------StarTowerGM--------------------------
local function st_skip_floor_notify(mapMsgData)
    EventManager.Hit("st_skip_floor_notify", mapMsgData)
end
local function st_add_team_exp_notify(mapMsgData)
    EventManager.Hit("st_add_team_exp_notify", mapMsgData)
end
local function st_add_new_case_notify(mapMsgData)
    EventManager.Hit("st_add_new_case_notify", mapMsgData)
end
local function st_items_change_notify(mapMsgData)
    EventManager.Hit("items_change_notify", mapMsgData)
end
local function tower_change_sub_note_skill_notify(mapMsgData)
    EventManager.Hit("note_change_notify", mapMsgData)
end
local function change_npc_affinity_notify(mapMsgData)
    PlayerData.StarTower:GMChangeNpcAffinity(mapMsgData)
end
---------------------------TravelerDuel------------------------------
local function traveler_duel_rank_succeed_ack(msgData)
    PlayerData.TravelerDuel:CacheTravelerDuelRankingData(msgData)
end
local function traveler_duel_info_failed_ack()
    EventManager.Hit(EventId.SetTransition)
end
---------------------------VampireSurvivor---------------------------
local function vampire_talent_reset_succeed_ack(msgData)
    PlayerData.VampireSurvivor:ResetTalentPoint()
end
local function vampire_talent_unlock_succeed_ack(msgData)

end
local function vampire_talent_detail_failed_ack()
    EventManager.Hit("GetTalentDataVampire", false)
end
local function vampire_survivor_reward_chest_failed_ack()
    EventManager.Hit("VampireRewardChestFailed")
end
local function vampire_survivor_reward_select_failed_ack()
    EventManager.Hit("VampireLevelRewardFailed")
end
local function vampire_survivor_quest_reward_receive_succeed_ack(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData))
end
---------------------------affinity----------------------------------
local function char_affinity_quest_reward_receive_succeed_ack(mapMsgData)
    if mapMsgData.Info ~= nil and mapMsgData.Info.Rewards ~= nil then
        local data
        for _, v in pairs(mapMsgData.Info.Rewards) do
            if data == nil then
                data = {}
            end
            table.insert(data, {NewId = v.Tid})
        end
        PlayerData.Base:ChangeHonorTitle(data)
    end
    PlayerData.Char:ChangeCharAffinityValue(mapMsgData.Info)
end
local function char_affinity_gift_send_succeed_ack(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData.Change))
    PlayerData.Base:RefreshSendGiftCount(mapMsgData.SendGiftCnt)
    PlayerData.Char:ChangeCharAffinityValue(mapMsgData.Info)
end
-------------------------------------------------------------------
------------------------------fragment recruit----------------------------------
local function char_recruitment_succeed_ack(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData))
end
----------------------------------------------------------------------
--------------------------Agent----------------------------
local function agent_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function agent_new_notify(mapMsgData)
    PlayerData.Dispatch.RefreshWeeklyDispatchs(mapMsgData.Ids)
end

local function agent_apply_failed_ack(mapMsgData)
    PlayerData.Dispatch.ResetReqLock()
end
--------------------------Dating----------------------------
local function char_dating_landmark_select_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Char:ChangeCharAffinityValue(mapMsgData.Info)
end
local function char_dating_event_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function char_dating_gift_send_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Char:ChangeCharAffinityValue(mapMsgData.Info)
end
local function char_archive_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
--------------------------Mining----------------------------
local function activity_mining_daily_reward_notify (mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
    EventManager.Hit("Mining_Daily_Reward", mapMsgData)
end

local function activity_mining_supplement_reward_notify (mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
    EventManager.Hit("Mining_Supplement_Reward", mapMsgData)
end

local function activity_mining_quest_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.ChangeInfo)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function activity_mining_story_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function activity_mining_dig_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.ChangeInfo)
    ProcChangeInfo(mapDecodedChangeInfo)
    EventManager.Hit("Mining_UpdateRigResult",mapMsgData)
end
local function activity_mining_energy_convert_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end

local function score_boss_star_reward_receive_succeed_ack(mapMsgData)
    ProcChangeInfo(UTILS.DecodeChangeInfo(mapMsgData))
end
---------------------------------兑换�?---------------------
local function  redeem_code_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
------------------------------------------------------------
---------------------------------走马灯---------------------
local function notice_change_notify(mapMsgData)
     EventManager.Hit("NoticeChangeNotify",mapMsgData)
end

------------------------------------------------------------
--------------------------------总力战----------------------
local function joint_drill_apply_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function joint_drill_sweep_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function joint_drill_settle_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function joint_drill_game_over_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function joint_drill_quest_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function activity_joint_drill_refresh_ticket_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end


------------------------------------------------------------
--------------------------------塔防------------------------

local function activity_tower_defense_story_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function activity_tower_defense_quest_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
local function activity_tower_defense_level_settle_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    ProcChangeInfo(mapDecodedChangeInfo)
end
------------------------------------------------------------
----------------------------热更提醒---------------------
local function force_update_notify(mapMsgData)
    local clientVer=NovaAPI.GetResVersion()
    local serVer= tostring(mapMsgData.Value)
    if UTILS.VersionCompare(clientVer,serVer,1) ==-1 then
        PlayerData.Base:NeedHotfix() 
    end
end
------------------------------------------------------------

local function BindProcessFunction()
    mapProcessFunction = {
        [NetMsgId.Id.ike_succeed_ack] = ike_succeed_ack,
        [NetMsgId.Id.ike_failed_ack] = ike_failed_ack,

        [NetMsgId.Id.player_login_succeed_ack] = player_login_succeed_ack,
        [NetMsgId.Id.player_login_failed_ack] = player_login_failed_ack,
        [NetMsgId.Id.player_data_succeed_ack] = player_data_succeed_ack,
        [NetMsgId.Id.player_data_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_data_failed_ack,
        [NetMsgId.Id.player_reg_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_reg_failed_ack,
        [NetMsgId.Id.player_name_edit_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --player_name_edit_succeed_ack,
        [NetMsgId.Id.player_name_edit_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_name_edit_failed_ack,
        [NetMsgId.Id.player_head_icon_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --player_head_icon_set_succeed_ack,
        [NetMsgId.Id.player_head_icon_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_head_icon_set_failed_ack,
        [NetMsgId.Id.player_board_set_succeed_ack] = player_board_set_succeed_ack,
        [NetMsgId.Id.player_board_set_failed_ack] = player_board_set_failed_ack,
        [NetMsgId.Id.player_skin_show_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_skin_show_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_chars_show_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_chars_show_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_signature_edit_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_signature_edit_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_world_class_reward_receive_succeed_ack] = player_world_class_reward_receive_succeed_ack,
        [NetMsgId.Id.player_world_class_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_world_class_reward_receive_failed_ack,
        [NetMsgId.Id.player_world_class_advance_succeed_ack] = player_world_class_advance_succeed_ack,
        [NetMsgId.Id.player_world_class_advance_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_world_class_advance_failed_ack,
        [NetMsgId.Id.player_music_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_music_set_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.story_apply_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.story_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.story_settle_succeed_ack] = story_settle_succeed_ack,
        [NetMsgId.Id.story_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_gender_edit_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.player_gender_edit_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.energy_buy_succeed_ack] = energy_buy_succeed_ack,
        [NetMsgId.Id.energy_buy_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.energy_extract_succeed_ack] = HttpNetHandlerPlus.energy_extract_succeed_ack,
        [NetMsgId.Id.energy_extract_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.item_use_succeed_ack] = item_use_succeed_ack,
        [NetMsgId.Id.item_use_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.item_product_succeed_ack] = item_product_succeed_ack, --item_product_succeed_ack
        [NetMsgId.Id.item_product_failed_ack] = NOTHING_NEED_TO_BE_DONE, --item_product_failed_ack
        [NetMsgId.Id.item_quick_growth_succeed_ack] = item_quick_growth_succeed_ack,
        [NetMsgId.Id.item_quick_growth_failed_ack] = NOTHING_NEED_TO_BE_DONE, --item_quick_growth_failed_ack
        [NetMsgId.Id.fragments_convert_succeed_ack] = fragments_convert_succeed_ack,
        [NetMsgId.Id.fragments_convert_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.player_ping_succeed_ack] = player_ping_succeed_ack,
        -- [NetMsgId.Id.player_ping_failed_ack] = player_ping_failed_ack, -- 服务器不会返回失�?

        --[NetMsgId.Id.mainline_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.traveler_duel_rank_succeed_ack] = traveler_duel_rank_succeed_ack,
        [NetMsgId.Id.traveler_duel_info_failed_ack] = traveler_duel_info_failed_ack,
        [NetMsgId.Id.traveler_duel_info_succeed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.player_formation_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --player_formation_succeed_ack,
        [NetMsgId.Id.player_formation_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_formation_failed_ack,
        [NetMsgId.Id.char_advance_reward_receive_succeed_ack] = char_advance_reward_receive_succeed_ack,

        [NetMsgId.Id.char_skin_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --char_skin_set_succeed_ack,
        [NetMsgId.Id.char_skin_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, --char_skin_set_failed_ack,

        [NetMsgId.Id.gacha_spin_succeed_ack] = gacha_spin_succeed_ack,
        [NetMsgId.Id.gacha_spin_failed_ack] = HttpNetHandlerPlus.gacha_spin_failed_ack, --gacha_spin_failed_ack,
        [NetMsgId.Id.gacha_information_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_information_succeed_ack,
        [NetMsgId.Id.gacha_information_failed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_information_failed_ack,

        [NetMsgId.Id.gacha_guarantee_reward_receive_succeed_ack] = HttpNetHandlerPlus.gacha_guarantee_reward_receive_succeed_ack, --gacha_information_succeed_ack,
        [NetMsgId.Id.gacha_guarantee_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_information_failed_ack,

        [NetMsgId.Id.gacha_newbie_info_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_newbie_info_succeed_ack,
        [NetMsgId.Id.gacha_newbie_info_failed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_newbie_info_failed_ack,

        [NetMsgId.Id.gacha_newbie_spin_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_newbie_spin_succeed_ack,
        [NetMsgId.Id.gacha_newbie_spin_failed_ack] = HttpNetHandlerPlus.gacha_newbie_spin_failed_ack, --gacha_newbie_spin_failed_ack,

        [NetMsgId.Id.gacha_newbie_obtain_succeed_ack] = HttpNetHandlerPlus.gacha_newbie_obtain_succeed_ack, --gacha_newbie_obtain_succeed_ack,
        [NetMsgId.Id.gacha_newbie_obtain_failed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_newbie_obtain_failed_ack,

        [NetMsgId.Id.gacha_newbie_save_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_newbie_save_succeed_ack,
        [NetMsgId.Id.gacha_newbie_save_failed_ack] = NOTHING_NEED_TO_BE_DONE, --gacha_newbie_save_failed_ack,

        [NetMsgId.Id.mail_list_succeed_ack] = mail_list_succeed_ack,
        [NetMsgId.Id.mail_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mail_list_failed_ack,
        [NetMsgId.Id.mail_read_succeed_ack] = mail_read_succeed_ack,
        [NetMsgId.Id.mail_read_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mail_read_failed_ack,
        [NetMsgId.Id.mail_recv_succeed_ack] = mail_recv_succeed_ack,
        [NetMsgId.Id.mail_recv_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mail_recv_failed_ack,
        [NetMsgId.Id.mail_remove_succeed_ack] = mail_remove_succeed_ack,
        [NetMsgId.Id.mail_remove_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mail_remove_failed_ack,

        [NetMsgId.Id.char_gem_generate_succeed_ack] = HttpNetHandlerPlus.char_gem_generate_succeed_ack,
        [NetMsgId.Id.char_gem_refresh_succeed_ack] = HttpNetHandlerPlus.char_gem_refresh_succeed_ack,
        [NetMsgId.Id.char_gem_replace_attribute_succeed_ack] = HttpNetHandlerPlus.char_gem_replace_attribute_succeed_ack,
        [NetMsgId.Id.char_gem_update_gem_lock_status_succeed_ack] = HttpNetHandlerPlus.char_gem_update_gem_lock_status_succeed_ack,
        [NetMsgId.Id.char_gem_use_preset_succeed_ack] = HttpNetHandlerPlus.char_gem_use_preset_succeed_ack,
        [NetMsgId.Id.char_gem_rename_preset_succeed_ack] = HttpNetHandlerPlus.char_gem_rename_preset_succeed_ack,
        [NetMsgId.Id.char_gem_equip_gem_succeed_ack] = HttpNetHandlerPlus.char_gem_equip_gem_succeed_ack,
        [NetMsgId.Id.char_gems_import_notify] = HttpNetHandlerPlus.char_gems_import_notify,
        [NetMsgId.Id.char_gems_export_notify] = HttpNetHandlerPlus.char_gems_export_notify,

        [NetMsgId.Id.star_tower_build_brief_list_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_brief_list_get_succeed_ack,
        [NetMsgId.Id.star_tower_build_brief_list_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_brief_list_get_failed_ack,
        [NetMsgId.Id.star_tower_build_detail_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_detail_get_succeed_ack,
        [NetMsgId.Id.star_tower_build_detail_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_detail_get_failed_ack,
        [NetMsgId.Id.star_tower_build_delete_succeed_ack] = star_tower_build_delete_succeed_ack,
        [NetMsgId.Id.star_tower_build_delete_failed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_delete_failed_ack,
        [NetMsgId.Id.star_tower_build_name_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_name_set_succeed_ack,
        [NetMsgId.Id.star_tower_build_name_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_name_set_failed_ack,
        [NetMsgId.Id.star_tower_build_lock_unlock_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_lock_unlock_succeed_ack,
        [NetMsgId.Id.star_tower_build_lock_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_lock_unlock_failed_ack,
        [NetMsgId.Id.star_tower_build_preference_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_preference_set_succeed_ack,
        [NetMsgId.Id.star_tower_build_preference_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_preference_set_failed_ack,
        [NetMsgId.Id.star_tower_build_whether_save_succeed_ack] = star_tower_build_whether_save_succeed_ack,
        [NetMsgId.Id.star_tower_build_whether_save_failed_ack] = NOTHING_NEED_TO_BE_DONE, --star_tower_build_whether_save_failed_ack,
        [NetMsgId.Id.star_tower_give_up_succeed_ack] = star_tower_give_up_succeed_ack,
        [NetMsgId.Id.star_tower_give_up_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.star_tower_interact_succeed_ack] = star_tower_interact_succeed_ack,
        [NetMsgId.Id.star_tower_interact_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.star_tower_apply_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.star_tower_apply_failed_ack] = star_tower_apply_failed_ack,
        [NetMsgId.Id.tower_growth_detail_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.tower_growth_detail_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.tower_growth_node_unlock_succeed_ack] = tower_growth_node_unlock_succeed_ack,
        [NetMsgId.Id.tower_growth_node_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.tower_growth_group_node_unlock_succeed_ack] = tower_growth_group_node_unlock_succeed_ack,
        [NetMsgId.Id.tower_growth_group_node_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.quest_tower_reward_receive_succeed_ack] = quest_tower_reward_receive_succeed_ack,
        [NetMsgId.Id.quest_tower_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.npc_affinity_plot_reward_receive_succeed_ack] = npc_affinity_plot_reward_receive_succeed_ack,
        [NetMsgId.Id.npc_affinity_plot_reward_receive_failed_ack] = npc_affinity_plot_reward_receive_failed_ack,


        [NetMsgId.Id.friend_list_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_list_get_succeed_ack,
        [NetMsgId.Id.friend_list_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_list_get_failed_ack,
        [NetMsgId.Id.friend_uid_search_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_uid_search_succeed_ack,
        [NetMsgId.Id.friend_uid_search_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_uid_search_failed_ack,
        [NetMsgId.Id.friend_name_search_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_name_search_succeed_ack,
        [NetMsgId.Id.friend_name_search_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_name_search_failed_ack,
        [NetMsgId.Id.friend_add_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_add_succeed_ack,
        [NetMsgId.Id.friend_add_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_add_failed_ack,
        [NetMsgId.Id.friend_add_agree_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_add_agree_succeed_ack,
        [NetMsgId.Id.friend_add_agree_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_add_agree_failed_ack,
        [NetMsgId.Id.friend_all_agree_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_all_agree_succeed_ack,
        [NetMsgId.Id.friend_all_agree_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_all_agree_failed_ack,
        [NetMsgId.Id.friend_delete_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_delete_succeed_ack,
        [NetMsgId.Id.friend_delete_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_delete_failed_ack,
        [NetMsgId.Id.friend_invites_delete_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_invites_delete_succeed_ack,
        [NetMsgId.Id.friend_invites_delete_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_invites_delete_failed_ack,
        [NetMsgId.Id.friend_receive_energy_succeed_ack] = friend_receive_energy_succeed_ack,
        [NetMsgId.Id.friend_receive_energy_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_receive_energy_failed_ack,
        [NetMsgId.Id.friend_send_energy_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_send_energy_succeed_ack,
        [NetMsgId.Id.friend_send_energy_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_send_energy_failed_ack,
        [NetMsgId.Id.friend_star_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_star_set_succeed_ack,
        [NetMsgId.Id.friend_star_set_failed_ack] = NOTHING_NEED_TO_BE_DONE, --friend_star_set_failed_ack,
        [NetMsgId.Id.friend_recommendation_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.friend_recommendation_get_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.achievement_reward_receive_succeed_ack] = achievement_reward_receive_succeed_ack,
        [NetMsgId.Id.achievement_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, --achievement_reward_receive_failed_ack,
        [NetMsgId.Id.achievement_info_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --achievement_info_succeed_ack,
        [NetMsgId.Id.achievement_info_failed_ack] = NOTHING_NEED_TO_BE_DONE, --achievement_info_failed_ack,

        [NetMsgId.Id.resident_shop_get_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --resident_shop_get_succeed_ack,
        [NetMsgId.Id.resident_shop_get_failed_ack] = NOTHING_NEED_TO_BE_DONE, --resident_shop_get_failed_ack,
        [NetMsgId.Id.resident_shop_purchase_succeed_ack] = resident_shop_purchase_succeed_ack,
        [NetMsgId.Id.resident_shop_purchase_failed_ack] = NOTHING_NEED_TO_BE_DONE, --resident_shop_purchase_failed_ack,
        [NetMsgId.Id.daily_shop_reward_receive_succeed_ack] = daily_shop_reward_receive_succeed_ack,
        [NetMsgId.Id.daily_shop_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, --daily_shop_reward_receive_failed_ack,

        [NetMsgId.Id.mall_gem_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_gem_list_succeed_ack,
        [NetMsgId.Id.mall_gem_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_gem_list_failed_ack,
        [NetMsgId.Id.mall_gem_order_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_gem_order_succeed_ack,
        [NetMsgId.Id.mall_gem_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_gem_order_failed_ack,
        [NetMsgId.Id.mall_order_cancel_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_order_cancel_succeed_ack,
        [NetMsgId.Id.mall_order_cancel_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_order_cancel_failed_ack,
        [NetMsgId.Id.mall_order_collect_succeed_ack] = mall_order_collect_succeed_ack,
        [NetMsgId.Id.mall_order_collect_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.mall_monthlyCard_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_monthlyCard_list_succeed_ack,
        [NetMsgId.Id.mall_monthlyCard_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_monthlyCard_list_failed_ack,
        [NetMsgId.Id.mall_monthlyCard_order_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_monthlyCard_order_succeed_ack,
        [NetMsgId.Id.mall_monthlyCard_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_monthlyCard_order_failed_ack,
        [NetMsgId.Id.mall_package_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_package_list_succeed_ack,
        [NetMsgId.Id.mall_package_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_package_list_failed_ack,
        [NetMsgId.Id.mall_package_order_succeed_ack] = mall_package_order_succeed_ack,
        [NetMsgId.Id.mall_package_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_package_order_failed_ack,
        [NetMsgId.Id.mall_shop_list_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_shop_list_succeed_ack,
        [NetMsgId.Id.mall_shop_list_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_shop_list_failed_ack,
        [NetMsgId.Id.mall_shop_order_succeed_ack] = mall_shop_order_succeed_ack,
        [NetMsgId.Id.mall_shop_order_failed_ack] = NOTHING_NEED_TO_BE_DONE, --mall_shop_order_failed_ack,
        [NetMsgId.Id.gem_convert_succeed_ack] = gem_convert_succeed_ack,
        [NetMsgId.Id.gem_convert_failed_ack] = NOTHING_NEED_TO_BE_DONE, --gem_convert_failed_ack,
        [NetMsgId.Id.daily_instance_settle_succeed_ack] = daily_instance_settle_succeed_ack,
        [NetMsgId.Id.daily_instance_raid_succeed_ack] = daily_instance_raid_succeed_ack,
        [NetMsgId.Id.daily_instance_raid_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.dictionary_reward_receive_succeed_ack] = dictionary_reward_receive_succeed_ack,
        [NetMsgId.Id.dictionary_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, --dictionary_reward_receive_failed_ack
        [NetMsgId.Id.char_gem_instance_settle_succeed_ack] = char_gem_instance_settle_succeed_ack,
        [NetMsgId.Id.char_gem_instance_sweep_succeed_ack] = char_gem_instance_sweep_succeed_ack,
        [NetMsgId.Id.char_gem_instance_apply_succeed_ack] = HttpNetHandlerPlus.char_gem_instance_apply_succeed_ack,
        [NetMsgId.Id.skill_instance_sweep_succeed_ack] = skill_instance_sweep_succeed_ack,
        [NetMsgId.Id.skill_instance_sweep_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.activity_detail_succeed_ack] = activity_detail_succeed_ack,
        [NetMsgId.Id.activity_detail_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_periodic_reward_receive_succeed_ack] = activity_periodic_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_periodic_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, --activity_periodic_reward_receive_failed_ack
        [NetMsgId.Id.activity_periodic_final_reward_receive_succeed_ack] = activity_periodic_final_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_periodic_final_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE, --activity_periodic_final_reward_receive_failed_ack
        [NetMsgId.Id.activity_login_reward_receive_succeed_ack] = activity_login_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_login_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_trial_reward_receive_succeed_ack] = activity_trial_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_shop_purchase_succeed_ack] = HttpNetHandlerPlus.activity_shop_purchase_succeed_ack,

        [NetMsgId.Id.phone_contacts_info_succeed_ack] = phone_contacts_info_succeed_ack,
        [NetMsgId.Id.phone_contacts_info_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.phone_contacts_report_succeed_ack] = phone_contacts_report_succeed_ack,
        [NetMsgId.Id.phone_contacts_report_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.battle_pass_info_succeed_ack] = battle_pass_info_succeed_ack,
        [NetMsgId.Id.battle_pass_info_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.battle_pass_quest_reward_receive_succeed_ack] = battle_pass_quest_reward_receive_succeed_ack,
        [NetMsgId.Id.battle_pass_quest_reward_receive_failed_ack] = HttpNetHandlerPlus.battle_pass_common_fail,
        [NetMsgId.Id.battle_pass_reward_receive_succeed_ack] = battle_pass_reward_receive_succeed_ack,
        [NetMsgId.Id.battle_pass_reward_receive_failed_ack] = HttpNetHandlerPlus.battle_pass_common_fail,
        [NetMsgId.Id.battle_pass_level_buy_succeed_ack] = battle_pass_level_buy_succeed_ack,
        [NetMsgId.Id.battle_pass_level_buy_failed_ack] = HttpNetHandlerPlus.battle_pass_common_fail,
        [NetMsgId.Id.battle_pass_order_collect_succeed_ack] = battle_pass_order_collect_succeed_ack,
        [NetMsgId.Id.battle_pass_order_collect_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        
        [NetMsgId.Id.sudo_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --sudo_succeed_ack,
        [NetMsgId.Id.sudo_failed_ack] = NOTHING_NEED_TO_BE_DONE, --sudo_failed_ack,

        [NetMsgId.Id.talent_unlock_succeed_ack] = talent_unlock_succeed_ack,
        [NetMsgId.Id.talent_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.talent_reset_succeed_ack] = talent_reset_succeed_ack,
        [NetMsgId.Id.talent_reset_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.talent_node_reset_succeed_ack] = talent_node_reset_succeed_ack,
        [NetMsgId.Id.talent_node_reset_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.talent_background_set_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.talent_background_set_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.talent_group_unlock_succeed_ack] = talent_group_unlock_succeed_ack,
        [NetMsgId.Id.talent_group_unlock_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.disc_strengthen_succeed_ack] = disc_strengthen_succeed_ack,
        [NetMsgId.Id.disc_strengthen_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.disc_promote_succeed_ack] = disc_promote_succeed_ack,
        [NetMsgId.Id.disc_promote_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.disc_limit_break_succeed_ack] = disc_limit_break_succeed_ack,
        [NetMsgId.Id.disc_limit_break_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.disc_read_reward_receive_succeed_ack] = disc_read_reward_receive_succeed_ack,
        [NetMsgId.Id.disc_read_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        [NetMsgId.Id.story_set_info_succeed_ack] = HttpNetHandlerPlus.story_set_info_succeed_ack,
        [NetMsgId.Id.story_set_info_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.story_set_reward_receive_succeed_ack] = HttpNetHandlerPlus.story_set_reward_receive_succeed_ack,
        [NetMsgId.Id.story_set_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.story_set_state_notify] = HttpNetHandlerPlus.story_set_state_notify,

        --VampireSurvivor
        [NetMsgId.Id.vampire_survivor_area_change_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.vampire_survivor_settle_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.vampire_talent_unlock_succeed_ack] = vampire_talent_unlock_succeed_ack,
        [NetMsgId.Id.vampire_talent_reset_succeed_ack] = vampire_talent_reset_succeed_ack,
        [NetMsgId.Id.system_failed_ack] = NOTHING_NEED_TO_BE_DONE, --system_failed_ack,
        [NetMsgId.Id.vampire_survivor_reward_chest_failed_ack] = vampire_survivor_reward_chest_failed_ack,
        [NetMsgId.Id.vampire_talent_detail_failed_ack] = vampire_talent_detail_failed_ack,
        [NetMsgId.Id.vampire_survivor_reward_select_failed_ack] = vampire_survivor_reward_select_failed_ack,
        [NetMsgId.Id.vampire_survivor_quest_reward_receive_succeed_ack] = vampire_survivor_quest_reward_receive_succeed_ack,
        -- 通知类型 _notify 结尾
        [NetMsgId.Id.player_new_notify] = NOTHING_NEED_TO_BE_DONE, --player_new_notify,
        [NetMsgId.Id.mail_state_notify] = mail_state_notify,
        [NetMsgId.Id.player_relogin_notify] = player_relogin_expire_ban, --player_relogin_notify,
        [NetMsgId.Id.token_expire_notify] = player_relogin_expire_ban, --token_expire_notify,
        [NetMsgId.Id.player_ban_notify] = player_relogin_expire_ban, --player_ban_notify,
        [NetMsgId.Id.quest_change_notify] = quest_change_notify,
        [NetMsgId.Id.chars_final_notify] = chars_final_notify,
        [NetMsgId.Id.character_skin_gain_notify] = character_skin_gain_notify,
        [NetMsgId.Id.character_skin_change_notify] = character_skin_change_notify,
        [NetMsgId.Id.world_class_number_notify] = world_class_number_notify,
        [NetMsgId.Id.world_class_quest_complete_notify] = world_class_quest_complete_notify,
        [NetMsgId.Id.world_class_change_notify] = world_class_change_notify,
        [NetMsgId.Id.char_reset_notify] = char_reset_notify,
        [NetMsgId.Id.items_change_notify] = items_change_notify,
        [NetMsgId.Id.region_boss_level_final_notify] = boss_level_final_notify,
        [NetMsgId.Id.friend_state_notify] = friend_state_notify,
        [NetMsgId.Id.friend_energy_state_notify] = friend_energy_state_notify,
        [NetMsgId.Id.char_change_notify] = char_change_notify,
        [NetMsgId.Id.world_class_reward_state_notify] = world_class_reward_state_notify,
        [NetMsgId.Id.char_advance_reward_state_notify] = char_advance_reward_state_notify,
        [NetMsgId.Id.achievement_change_notify] = achievement_change_notify,
        [NetMsgId.Id.achievement_state_notify] = achievement_state_notify,
        [NetMsgId.Id.monthly_card_rewards_notify] = monthly_card_rewards_notify,
        [NetMsgId.Id.signin_reward_change_notify] = signin_reward_change_notify,
        [NetMsgId.Id.handbook_change_notify] = handbook_change_notify,
        [NetMsgId.Id.mall_package_state_notify] = mall_package_state_notify,
        [NetMsgId.Id.quest_state_notify] = quest_state_notify,
        [NetMsgId.Id.dictionary_change_notify] = dictionary_change_notify,
        [NetMsgId.Id.clear_all_traveler_due_notify] = clear_all_traveler_due_notify,
        [NetMsgId.Id.clear_all_region_boss_level_notify] = clear_all_region_boss_level_notify,
        [NetMsgId.Id.clear_all_week_boss_notify] = clear_all_week_boss_notify,
        [NetMsgId.Id.st_clear_all_star_tower_notify] = st_clear_all_star_tower_notify,
        [NetMsgId.Id.clear_all_daily_instance_notify] = clear_all_daily_instance_notify,
        [NetMsgId.Id.clear_all_char_gem_instance_notify] = clear_all_char_gem_instance_notify,
        [NetMsgId.Id.st_import_build_notify] = st_import_build_notify,
        [NetMsgId.Id.st_export_build_notify] = st_export_build_notify,
        [NetMsgId.Id.char_affinity_final_notify] = char_affinity_final_notify,
        [NetMsgId.Id.char_affinity_reward_state_notify] = char_affinity_reward_state_notify,
        [NetMsgId.Id.activity_change_notify] = activity_change_notify,
        [NetMsgId.Id.activity_state_change_notify] = activity_state_change_notify,
        [NetMsgId.Id.activity_quest_change_notify] = activity_quest_change_notify,
        [NetMsgId.Id.mail_overflow_notify] = mail_overflow_notify,
        [NetMsgId.Id.infinity_tower_rewards_state_notify] = infinity_tower_rewards_state_notify,
        [NetMsgId.Id.phone_chat_change_notify] = phone_chat_change_notify,
        [NetMsgId.Id.character_fragments_overflow_change_notify] = character_fragments_overflow_change_notify,
        [NetMsgId.Id.infinity_tower_settle_succeed_ack] = infinity_tower_settle_succeed_ack,
        [NetMsgId.Id.infinity_tower_daily_reward_receive_succeed_ack] = infinity_tower_daily_reward_receive_succeed_ack,
        [NetMsgId.Id.infinity_tower_plot_reward_receive_succeed_ack] = infinity_tower_plot_reward_receive_succeed_ack,
        [NetMsgId.Id.disc_reset_notify] = disc_reset_notify,
        [NetMsgId.Id.story_complete_notify] = story_complete_notify,
        [NetMsgId.Id.clear_all_story_notify] = clear_all_story_notify,
        [NetMsgId.Id.activity_login_rewards_notify] = activity_login_rewards_notify,
        [NetMsgId.Id.star_tower_book_potential_notify] = star_tower_book_potential_notify,
        [NetMsgId.Id.star_tower_book_event_notify] = star_tower_book_event_notify,
        [NetMsgId.Id.star_tower_book_event_reward_receive_succeed_ack] = star_tower_book_event_reward_receive_succeed_ack,
        [NetMsgId.Id.tower_book_fate_card_reward_receive_succeed_ack] = tower_book_fate_card_reward_receive_succeed_ack,
        [NetMsgId.Id.star_tower_book_potential_reward_receive_succeed_ack] = star_tower_book_potential_reward_receive_succeed_ack,
        [NetMsgId.Id.change_npc_affinity_notify] = change_npc_affinity_notify,

        [NetMsgId.Id.tower_book_fate_card_collect_notify] = tower_book_fate_card_collect_notify,
        [NetMsgId.Id.tower_book_fate_card_reward_notify] = tower_book_fate_card_reward_notify,
        [NetMsgId.Id.region_boss_level_challenge_ticket_notify] = region_boss_level_challenge_ticket_notify,
        [NetMsgId.Id.honor_change_notify] = honor_change_notify,
        [NetMsgId.Id.tower_growth_node_change_notify] = tower_growth_node_change_notify,
        [NetMsgId.Id.char_up_change_notify] = char_up_change_notify,
        [NetMsgId.Id.clear_all_vampire_survivor_notify] = clear_all_vampire_survivor_notify,
        [NetMsgId.Id.add_vampire_season_score_notify] = add_vampire_season_score_notify,
        [NetMsgId.Id.vampire_survivor_talent_node_notify] = HttpNetHandlerPlus.vampire_survivor_talent_node_notify,
        [NetMsgId.Id.star_tower_sub_note_skill_info_notify] = star_tower_sub_note_skill_info_notify,
        [NetMsgId.Id.refresh_agent_notify] = refresh_agent_notify,
        [NetMsgId.Id.clear_all_skill_instance_notify] = clear_all_skill_instance_notify,
        [NetMsgId.Id.order_paid_notify] = HttpNetHandlerPlus.order_paid_notify,
        [NetMsgId.Id.order_revoke_notify] = HttpNetHandlerPlus.order_revoke_notify,
        [NetMsgId.Id.order_collected_notify] = HttpNetHandlerPlus.order_collected_notify,
        [NetMsgId.Id.vampire_survivor_new_season_notify] = HttpNetHandlerPlus.vampire_survivor_new_season_notify,
        -----------------------新星�?----------------------
        [NetMsgId.Id.st_skip_floor_notify] = st_skip_floor_notify,
        [NetMsgId.Id.st_add_team_exp_notify] = st_add_team_exp_notify,
        [NetMsgId.Id.st_add_new_case_notify] = st_add_new_case_notify,
        [NetMsgId.Id.st_items_change_notify] = st_items_change_notify,
        [NetMsgId.Id.tower_change_sub_note_skill_notify] = tower_change_sub_note_skill_notify,
        --地区boss关卡
        [NetMsgId.Id.region_boss_level_apply_succeed_ack] = region_boss_level_apply_succeed_ack,
        [NetMsgId.Id.region_boss_level_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE, --region_boss_level_apply_failed_ack,
        [NetMsgId.Id.region_boss_level_settle_succeed_ack] = region_boss_level_settle_succeed_ack,
        [NetMsgId.Id.region_boss_level_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE, --region_boss_level_settle_failed_ack,
        [NetMsgId.Id.region_boss_level_sweep_succeed_ack] = region_boss_level_sweep_succeed_ack,
        --技能素材本
        [NetMsgId.Id.skill_instance_apply_succeed_ack] = skill_instance_apply_succeed_ack,
        [NetMsgId.Id.skill_instance_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        --周本boss关卡
        [NetMsgId.Id.week_boss_apply_succeed_ack] = week_boss_apply_succeed_ack,
        [NetMsgId.Id.week_boss_apply_failed_ack] = week_boss_apply_failed_ack, --region_boss_level_apply_failed_ack,
        [NetMsgId.Id.week_boss_settle_succeed_ack] = week_boss_settle_succeed_ack,
        [NetMsgId.Id.week_boss_settle_failed_ack] = week_boss_settle_failed_ack, --region_boss_level_settle_failed_ack,
        [NetMsgId.Id.week_boss_refresh_ticket_notify] = week_boss_refresh_ticket_notify,
        
        --新手引导
        [NetMsgId.Id.player_learn_succeed_ack] = NOTHING_NEED_TO_BE_DONE, --player_learn_succeed_ack,
        [NetMsgId.Id.player_learn_failed_ack] = NOTHING_NEED_TO_BE_DONE, --player_learn_failed_ack,


        --角色好感�?
        [NetMsgId.Id.char_affinity_quest_reward_receive_succeed_ack] = char_affinity_quest_reward_receive_succeed_ack,
        [NetMsgId.Id.char_affinity_quest_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.char_affinity_gift_send_succeed_ack] = char_affinity_gift_send_succeed_ack,
        [NetMsgId.Id.char_affinity_gift_send_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        --角色碎片招募
        [NetMsgId.Id.char_recruitment_succeed_ack] = char_recruitment_succeed_ack,
        [NetMsgId.Id.char_recruitment_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        --派遣
        [NetMsgId.Id.agent_reward_receive_succeed_ack] = agent_reward_receive_succeed_ack,
        [NetMsgId.Id.agent_new_notify] = agent_new_notify,
        [NetMsgId.Id.agent_apply_failed_ack] =agent_apply_failed_ack,
        --约会
        [NetMsgId.Id.char_dating_landmark_select_succeed_ack] = char_dating_landmark_select_succeed_ack,
        [NetMsgId.Id.char_dating_event_reward_receive_succeed_ack] = char_dating_event_reward_receive_succeed_ack,
        [NetMsgId.Id.char_dating_gift_send_succeed_ack] = char_dating_gift_send_succeed_ack,
        --档案奖励
        [NetMsgId.Id.char_archive_reward_receive_succeed_ack] = char_archive_reward_receive_succeed_ack,
        [NetMsgId.Id.char_archive_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,

        -- 扩容
        -- [NetMsgId.Id.AAA] = HttpNetHandlerPlus.ProcAAA,   �? HttpNetHandlerPlus.lua 中新增一�? function ProcAAA 来处�? AAA 消息的数据�?
        -- 活动玩法-挖格子
        [NetMsgId.Id.activity_mining_daily_reward_notify] = activity_mining_daily_reward_notify,
        [NetMsgId.Id.activity_mining_supplement_reward_notify] = activity_mining_supplement_reward_notify,
        [NetMsgId.Id.activity_mining_quest_reward_receive_succeed_ack] = activity_mining_quest_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_mining_quest_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_mining_story_reward_receive_succeed_ack] = activity_mining_story_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_mining_story_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_mining_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_mining_apply_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_mining_move_to_next_layer_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_mining_move_to_next_layer_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_mining_dig_succeed_ack] = activity_mining_dig_succeed_ack,
        [NetMsgId.Id.activity_mining_dig_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_mining_energy_convert_notify] = activity_mining_energy_convert_notify,
        [NetMsgId.Id.activity_mining_enter_layer_notify] = HttpNetHandlerPlus.activity_mining_enter_layer_notify,
        --bossRush 领取奖励
        [NetMsgId.Id.score_boss_star_reward_receive_succeed_ack] = score_boss_star_reward_receive_succeed_ack,
        --兑换码
        [NetMsgId.Id.redeem_code_succeed_ack]=redeem_code_succeed_ack,
        [NetMsgId.Id.redeem_code_failed_ack]=NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.notice_change_notify]=notice_change_notify,
        --总力战
        [NetMsgId.Id.joint_drill_apply_succeed_ack] = joint_drill_apply_succeed_ack,
        [NetMsgId.Id.joint_drill_apply_failed_ack] = NOTHING_NEED_TO_BE_DONE,
	    [NetMsgId.Id.joint_drill_sweep_succeed_ack] = joint_drill_sweep_succeed_ack,
        [NetMsgId.Id.joint_drill_sweep_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.joint_drill_settle_succeed_ack] = joint_drill_settle_succeed_ack,
        [NetMsgId.Id.joint_drill_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.joint_drill_game_over_succeed_ack] = joint_drill_game_over_succeed_ack,
        [NetMsgId.Id.joint_drill_game_over_failed_ack] = HttpNetHandlerPlus.joint_drill_game_over_failed_ack,
        [NetMsgId.Id.joint_drill_quest_reward_receive_succeed_ack] = joint_drill_quest_reward_receive_succeed_ack,
        [NetMsgId.Id.joint_drill_quest_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_joint_drill_refresh_ticket_notify] = activity_joint_drill_refresh_ticket_notify,
        [NetMsgId.Id.joint_drill_sync_failed_ack] = HttpNetHandlerPlus.joint_drill_sync_failed_ack,
        [NetMsgId.Id.joint_drill_give_up_failed_ack] = HttpNetHandlerPlus.joint_drill_give_up_failed_ack,
        --塔防
        [NetMsgId.Id.activity_tower_defense_story_reward_receive_succeed_ack]=activity_tower_defense_story_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_tower_defense_story_reward_receive_failed_ack]=NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_tower_defense_quest_reward_receive_succeed_ack]=activity_tower_defense_quest_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_tower_defense_quest_reward_receive_failed_ack]=NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_tower_defense_level_settle_succeed_ack]=activity_tower_defense_level_settle_succeed_ack,
        [NetMsgId.Id.activity_tower_defense_level_settle_failed_ack]=NOTHING_NEED_TO_BE_DONE,
        --活动剧情
        [NetMsgId.Id.activity_avg_reward_receive_succeed_ack]=HttpNetHandlerPlus.activity_story_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_avg_reward_receive_failed_ack]=NOTHING_NEED_TO_BE_DONE,
        --活动任务
        [NetMsgId.Id.activity_task_reward_receive_succeed_ack] = HttpNetHandlerPlus.activity_task_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_task_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.activity_task_group_reward_receive_succeed_ack] = HttpNetHandlerPlus.activity_task_group_reward_receive_succeed_ack,
        [NetMsgId.Id.activity_task_group_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        --热更提醒
        [NetMsgId.Id.force_update_notify]=force_update_notify,
        --更换头像
        [NetMsgId.Id.player_head_icon_change_notify] = HttpNetHandlerPlus.player_head_icon_change_notify,
        --教学关
        [NetMsgId.Id.tutorial_level_settle_succeed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.tutorial_level_settle_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        [NetMsgId.Id.tutorial_level_reward_receive_succeed_ack] = HttpNetHandlerPlus.tutorial_level_reward_receive_succeed_ack,
        [NetMsgId.Id.tutorial_level_reward_receive_failed_ack] = NOTHING_NEED_TO_BE_DONE,
        --中型活动
        [NetMsgId.Id.activity_levels_settle_failed_ack] = HttpNetHandlerPlus.activity_levels_settle_failed_ack
    }
end
------------------------------ public ------------------------------
function HttpNetHandler.Init()
    -- load protobuf schema
    local pbSchema = NovaAPI.LoadLuaBytes("GameCore/Network/proto.pb")
    assert(PB.load(pbSchema))
    BindProcessFunction()
    NetMsgIdMap = MakeNetMsgIdMap()
    EventManager.Add("CS2LuaEvent_OnApplicationFocus", HttpNetHandler, HttpNetHandler.OnCS2LuaEvent_AppFocus)
end
function HttpNetHandler.SendMsg(nNetMsgId, mapMessageData, sUrl, callback)
    printLog("发送消息：" .. nNetMsgId)
    if nNetMsgId ~= NetMsgId.Id.player_ping_req and timerPingPong ~= nil then
        timerPingPong:Reset(TimerResetType.ResetElapsed) -- 发送常规消息时重置心跳计时�?
    end
    local data = assert(PB.encode(NetMsgId.MsgName[nNetMsgId], mapMessageData))
    NovaAPI.AddSendMsgRequest(nNetMsgId, data, callback, sUrl)
end
function HttpNetHandler.DispatchMsg(MsgReceive, bIsNextMsg, MsgSend, bError, mapMainData)
    if type(bError) == "nil" then
        bError = false -- 标记服务器返回的首个 package 是否�? proto.Error，首个不�? error 才能正常执行 MsgSend.callback 方法�?
    end
    if type(mapMainData) == "nil" then
        mapMainData = {} -- 记录服务器返回的首个 package 内容，可能回调处需要使�?
    end
    local nReceiveMsgId = MsgReceive.msgId
    local mapReceiveMsgBody = MsgReceive.msgBody
    local sMsgName = NetMsgId.MsgName[nReceiveMsgId]

    local mapMsgData = assert(PB.decode(sMsgName, mapReceiveMsgBody))

    if mapProcessFunction == nil then
        return
    end

    -- 绑定了处理方法才执行
    local ProcessFunction = mapProcessFunction[nReceiveMsgId]
    if ProcessFunction ~= nil then
        printLog("处理消息，发送：" .. MsgSend.msgId .. "，接收：" .. nReceiveMsgId .. "，是否为嵌套消息�?" .. tostring(bIsNextMsg))
        ProcessFunction(mapMsgData)
    else
        printWarn("没有绑定消息处理函数，发送：" .. MsgSend.msgId .. "，接收：" .. nReceiveMsgId .. "，是否为嵌套消息�?" .. tostring(bIsNextMsg))
    end

    -- 标记服务器返回的首个 package 是否�? error
    if bIsNextMsg == false then
        bError = sMsgName == "proto.Error"
        MsgSend.receiveMsgId = nReceiveMsgId
        mapMainData = mapMsgData

        -- 如果返回的 msgId 并非 发送的 reqMsgId 对应的 failed_ack，则自己从关联中找到 failed_ack 执行对应绑定的回调。
        local nFailId = mapNetMsgIdFailed[MsgSend.msgId]
        if bError == true and nFailId ~= nil and nFailId ~= nReceiveMsgId then
            ProcessFunction = mapProcessFunction[nFailId]
            if ProcessFunction ~= nil then
                printLog("处理消息，收到服务器返回失败或错误，但其id并非对应Req的失败id，收到的：" .. nReceiveMsgId .. "应该对应的：" .. nFailId)
                ProcessFunction() -- 不能传 mapMsgData 因为它的结构是对应 nReceiveMsgId 的，不是对应 nFailId 的。
            end
        end
    end
    local bUseCommonErrorMsgBox = true -- login failed or ike failed: do not show common error msgbox
    if NovaAPI.IsServerMaintained() == true then
        if nReceiveMsgId == NetMsgId.Id.player_login_failed_ack or nReceiveMsgId == NetMsgId.Id.ike_failed_ack then
            bUseCommonErrorMsgBox = false
        end
    end
    -- 收到任何 package �? error 都会弹窗提示（如果需要针对错误单独区分处理，则绑定一个处理方法即可，此处为通用的收到服务器返回错误弹窗�?
    if sMsgName == "proto.Error" and bUseCommonErrorMsgBox == true then
        -- EventManager.Hit("Temp_Srv_Error_For_AVG")
        EventManager.Hit(EventId.SetTransition)
        local mapErrorCfg = ConfigTable.GetData("ErrorCode", mapMsgData.Code)
        if mapErrorCfg then
            local sErrorDetail = mapErrorCfg.Template
            if mapMsgData.Arguments and #mapMsgData.Arguments > 0 then
                sErrorDetail = string.format(mapErrorCfg.Template, table.unpack(mapMsgData.Arguments))
            end
            local bNeedTrace = false
            if mapMsgData.TraceId and mapMsgData.TraceId ~= 0 then
                bNeedTrace = true
                sErrorDetail = sErrorDetail .."\n" ..mapMsgData.TraceId
            end
            printError("服务器返回错误：" .. sErrorDetail)
            -- 不同情况下的提示表现不同，出现追踪id的话，就算是飘字也要弹窗
            local nShowType = mapErrorCfg.ShowType
            if bNeedTrace and nShowType == GameEnum.errorShowType.Tips then
                nShowType = GameEnum.errorShowType.Window
            end
            -- 目前除飘字以外都需要弹窗
            if nShowType ~= GameEnum.errorShowType.Tips then
                local function AlertCallback()
                    if bNeedTrace then
                        CS.UnityEngine.GUIUtility.systemCopyBuffer = mapMsgData.TraceId
                        EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("ErrorCode_Trace"))
                    end
                    --Action == 2 时，邮件重新拉取数据处理
                    if mapMsgData.Action and mapMsgData.Action == 2 then
                        if MsgSend.msgId == NetMsgId.Id.mail_recv_req or MsgSend.msgId == NetMsgId.Id.mail_remove_req or MsgSend.msgId == NetMsgId.Id.mail_read_req then
                            PlayerData.Mail:GetAgainAllMain()
                        end
                    end
                    --错误码是会导致返回登录界面的错误类型时，返回登录界面
                    if nShowType == GameEnum.errorShowType.Relogin then
                        PanelManager.OnConfirmBackToLogIn()
                    end
                end
                local msg = { nType = AllEnum.MessageBox.Alert, sContent = sErrorDetail, callbackConfirm = AlertCallback, bDisableSnap = true }
                if bNeedTrace then
                    msg.sConfirm = ConfigTable.GetUIText("ErrorCode_Btn_Copy")
                end
                if NovaAPI.GetClientChannel() == AllEnum.ChannelName.BanShu then
                    local a = string.gmatch(sErrorDetail, "%a+") -- 判断服务器返回的错误信息中是否含有英文字母，有的话就固定弹窗提示�?
                    if a() then
                        msg.sContent = "提示：服务器错误，请稍后再试�?"
                    end
                end
                -- 错误码是会导致返回登录界面的错误类型时，注册返回登录界面事件，同时修改确认按钮文本
                if nShowType == GameEnum.errorShowType.Relogin then
                    EventManager.Hit(EventId.OpenMessageBox, {
                        nType = AllEnum.MessageBox.Alert,
                        sContent = sErrorDetail,
                        callbackConfirm = AlertCallback,
                        sConfirm = ConfigTable.GetUIText("ErrorCode_Btn_Relogin")
                    })
                else
                    EventManager.Hit(EventId.OpenMessageBox, msg)
                end
            elseif nShowType == GameEnum.errorShowType.Tips then
                EventManager.Hit(EventId.OpenMessageBox, sErrorDetail)
            end
        else
            local msg = { nType = AllEnum.MessageBox.Alert, sContent = ConfigTable.GetUIText("ErrorCode_UnknowError") .. "SEC:" .. mapMsgData.Code, bDisableSnap = true }
            EventManager.Hit(EventId.OpenMessageBox, msg)
        end
    end

    -- 即便中间某个 next msg 没有绑处理方法，也要继续处理之后�? next msg 数据
    local dataNext = mapMsgData.NextPackage
    if dataNext == nil or dataNext == "" then
        -- 所�? next package 都解完了再处理回�?
        if bError == false and MsgSend.callback ~= nil then
            printLog("执行 network 回调，发送：" .. MsgSend.msgId .. "，接收：" .. MsgSend.receiveMsgId)
            MsgSend.callback(MsgSend, mapMainData)
            MsgSend.callback = nil
            EventManager.Hit("DispatchMsgDone")
        end
    else
        local msg = NovaAPI.ParseMessage(dataNext, true)
        if msg ~= nil then
            HttpNetHandler.DispatchMsg(msg, true, MsgSend, bError, mapMainData)
        end
    end
end
function HttpNetHandler.SendPingPong(_this, bManual, callback)
    -- printLog("发送心跳消�?")
    local msgSend = {} -- 发送心跳消�?
    HttpNetHandler.SendMsg(NetMsgId.Id.player_ping_req, msgSend, nil, callback)
    if bManual == true and timerPingPong ~= nil then
        timerPingPong:Reset(TimerResetType.ResetElapsed)
    end
end
function HttpNetHandler.SetPingPong()
    if timerPingPong == nil then
        timerPingPong = TimerManager.Add(0, PING_PONG_INTERVAL, HttpNetHandler, HttpNetHandler.SendPingPong, true, false, false, nil)
    else
        -- timerPingPong:Reset(TimerResetType.ResetElapsed)
        timerPingPong:Pause(false)
    end
end
function HttpNetHandler.UnsetPingPong()
    if timerPingPong ~= nil then
        timerPingPong:Pause(true)
    end
end
function HttpNetHandler.OnCS2LuaEvent_AppFocus(_, bFocus)
    if NovaAPI.IsRuntimeWindowsPlayer() == true then
        return
    end
    printLog( string.format("Lua HttpNetHandler OnCS2LuaEvent_AppFocus, bFocus:%s, timerPingPong is nil:%s", tostring(bFocus), tostring(timerPingPong == nil)) )
    if timerPingPong == nil then
        return
    end
    if bFocus == true then
        -- timerPingPong:Reset(TimerResetType.ResetElapsed)
        timerPingPong:Pause(false)
        printLog("Lua HttpNetHandler OnCS2LuaEvent_AppFocus, timerPingPong: RUN.")
    else
        timerPingPong:Pause(true)
        printLog("Lua HttpNetHandler OnCS2LuaEvent_AppFocus, timerPingPong: PAUSE.")
    end
end
function HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Coin:ChangeCoin(mapDecodedChangeInfo["proto.Res"]) -- 货币资源数量变更，数组�?
    PlayerData.Item:ChangeItem(mapDecodedChangeInfo["proto.Item"]) -- 道具数量变更，数组�?
    PlayerData.Char:GetNewChar(mapDecodedChangeInfo["proto.Char"]) -- 角色数据变更，数�?(理论上一般只可能是获得角�?)�?
    PlayerData.Base:ChangeEnergy(mapDecodedChangeInfo["proto.Energy"])
    PlayerData.Base:ChangeWorldClass(mapDecodedChangeInfo["proto.WorldClass"])
    PlayerData.Base:ChangeTitle(mapDecodedChangeInfo["proto.Title"])
    PlayerData.Disc:CreateNewDisc(mapDecodedChangeInfo["proto.Disc"])
    PlayerData.Base:ChangeHonorTitle(mapDecodedChangeInfo["proto.Honor"]) -- 称号变化
    PlayerData.HeadData:ChangePlayerHead(mapDecodedChangeInfo["proto.HeadIcon"]) -- 头像变化
    -- PlayerData:ProcSpecialChange(mapDecodedChangeInfo.Special) -- 特殊数据变化，需与服务器约定�?
end
return HttpNetHandler
