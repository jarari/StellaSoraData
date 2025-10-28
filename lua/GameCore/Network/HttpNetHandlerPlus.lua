local HttpNetHandlerPlus = {}
function HttpNetHandlerPlus.char_gem_generate_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.ChangeInfo)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.char_gem_refresh_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.ChangeInfo)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.char_gem_replace_attribute_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_update_gem_lock_status_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_use_preset_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_rename_preset_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_equip_gem_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gems_import_notify(mapMsgData)
    PlayerData.Equipment:GM_CacheEquipmentData(mapMsgData)
end
function HttpNetHandlerPlus.char_gems_export_notify(mapMsgData)
    CS.UnityEngine.GUIUtility.systemCopyBuffer = mapMsgData.Value
end
function HttpNetHandlerPlus.char_gem_instance_apply_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.order_paid_notify(mapMsgData)
    PlayerData.Mall:ProcessOrderPaidNotify(mapMsgData)
end
function HttpNetHandlerPlus.order_revoke_notify(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.order_collected_notify(mapMsgData)
    -- OrderStateChange
    PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.MessageBox, ConfigTable.GetUIText("Order_Collected_Notify"))
end
function HttpNetHandlerPlus.activity_shop_purchase_succeed_ack(mapMsgData)
    if not mapMsgData.IsRefresh then
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
    end
end

function HttpNetHandlerPlus.energy_extract_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
--抽卡--------------------------------------------------
function HttpNetHandlerPlus.gacha_guarantee_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.vampire_survivor_talent_node_notify(mapData)
    PlayerData.VampireSurvivor:CacheTalentData(mapData)
end
function HttpNetHandlerPlus.gacha_newbie_obtain_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
    PlayerData.Item:CacheFragmentsOverflow(nil, mapMsgData)
end
function HttpNetHandlerPlus.gacha_newbie_spin_failed_ack(mapMsgData)
    EventManager.Hit("GachaProcessStart",false)
end
function HttpNetHandlerPlus.gacha_spin_failed_ack(mapMsgData)
    EventManager.Hit("GachaProcessStart",false)
end
--活动剧情--------------------------------------------------
function HttpNetHandlerPlus.activity_story_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
--活动任务--------------------------------------------------
function HttpNetHandlerPlus.activity_task_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.activity_task_group_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
--头像变化--------------------------------------------------
function HttpNetHandlerPlus.player_head_icon_change_notify(mapMsgData)
    PlayerData.Base:ChangePlayerHeadId(mapMsgData.Set)
    PlayerData.HeadData:DelHeadId(mapMsgData.Del)
end
--挖格子--------------------------------------------------
function HttpNetHandlerPlus.activity_mining_enter_layer_notify(mapMsgData)
    EventManager.Hit("Mining_UpdateLevelData",mapMsgData)
end
--教学关--------------------------------------------------
function HttpNetHandlerPlus.tutorial_level_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
--故事集--------------------------------------------------
function HttpNetHandlerPlus.story_set_info_succeed_ack(mapMsgData)
    PlayerData.StorySet:CacheStorySetData(mapMsgData)
end
function HttpNetHandlerPlus.story_set_reward_receive_succeed_ack(mapMsgData)
    local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
    HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.story_set_state_notify(mapMsgData)
    PlayerData.StorySet:UnlockNewChapter(mapMsgData.Value)
end
--吸血鬼--------------------------------------------------
function HttpNetHandlerPlus.vampire_survivor_new_season_notify(mapMsgData)
    PlayerData.VampireSurvivor:OnNotifyRefresh(mapMsgData.Value)
end
--BattlePass------------------------------------------------
function HttpNetHandlerPlus.battle_pass_common_fail(mapMsgData)
    EventManager.Hit("BattlePassNeedRefresh")
end

--中型活动关卡结算失败
function HttpNetHandlerPlus.activity_levels_settle_failed_ack()
    EventManager.Hit("ActivityLevelSettle_Failed")
end

--总力战---------------------------------------------------------
function HttpNetHandlerPlus.joint_drill_game_over_failed_ack(mapMsgData)
    --挑战不存在
    if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112701 then
        --挑战不存在，此时需要刷新下客户端状态防止卡死
        EventManager.Hit("JointDrillChallengeFinishError")
    end
end
function HttpNetHandlerPlus.joint_drill_sync_failed_ack(mapMsgData)
    --挑战已结束
    if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112704 then
        --挑战不存在，此时需要刷新下客户端状态防止卡死
        EventManager.Hit("JointDrillChallengeFinishError")
    end
end
function HttpNetHandlerPlus.joint_drill_give_up_failed_ack(mapMsgData)
    --挑战已结束
    if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112704 then
        --挑战不存在，此时需要刷新下客户端状态防止卡死
        EventManager.Hit("JointDrillChallengeFinishError")
    end
end
return HttpNetHandlerPlus
