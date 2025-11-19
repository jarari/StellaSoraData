local HttpNetHandlerPlus = {}
HttpNetHandlerPlus.char_gem_generate_succeed_ack = function(mapMsgData)
  -- function num : 0_0 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.ChangeInfo)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.char_gem_refresh_succeed_ack = function(mapMsgData)
  -- function num : 0_1 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.ChangeInfo)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.char_gem_replace_attribute_succeed_ack = function(mapMsgData)
  -- function num : 0_2
end

HttpNetHandlerPlus.char_gem_update_gem_lock_status_succeed_ack = function(mapMsgData)
  -- function num : 0_3
end

HttpNetHandlerPlus.char_gem_use_preset_succeed_ack = function(mapMsgData)
  -- function num : 0_4
end

HttpNetHandlerPlus.char_gem_rename_preset_succeed_ack = function(mapMsgData)
  -- function num : 0_5
end

HttpNetHandlerPlus.char_gem_equip_gem_succeed_ack = function(mapMsgData)
  -- function num : 0_6
end

HttpNetHandlerPlus.char_gems_import_notify = function(mapMsgData)
  -- function num : 0_7 , upvalues : _ENV
  (PlayerData.Equipment):CacheEquipmentDataForChar(mapMsgData)
end

HttpNetHandlerPlus.char_gems_export_notify = function(mapMsgData)
  -- function num : 0_8 , upvalues : _ENV
  -- DECOMPILER ERROR at PC4: Confused about usage of register: R1 in 'UnsetPending'

  ((CS.UnityEngine).GUIUtility).systemCopyBuffer = mapMsgData.Value
end

HttpNetHandlerPlus.char_gem_instance_apply_succeed_ack = function(mapMsgData)
  -- function num : 0_9 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.disc_all_limit_break_succeed_ack = function(mapMsgData)
  -- function num : 0_10 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.order_paid_notify = function(mapMsgData)
  -- function num : 0_11 , upvalues : _ENV
  (PlayerData.Mall):ProcessOrderPaidNotify(mapMsgData)
end

HttpNetHandlerPlus.order_revoke_notify = function(mapMsgData)
  -- function num : 0_12 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.order_collected_notify = function(mapMsgData)
  -- function num : 0_13 , upvalues : _ENV
  (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).MessageBox, (ConfigTable.GetUIText)("Order_Collected_Notify"))
end

HttpNetHandlerPlus.activity_shop_purchase_succeed_ack = function(mapMsgData)
  -- function num : 0_14 , upvalues : _ENV
  if not mapMsgData.IsRefresh then
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
  end
end

HttpNetHandlerPlus.energy_extract_succeed_ack = function(mapMsgData)
  -- function num : 0_15 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.gacha_guarantee_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_16 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.vampire_survivor_talent_node_notify = function(mapData)
  -- function num : 0_17 , upvalues : _ENV
  (PlayerData.VampireSurvivor):CacheTalentData(mapData)
end

HttpNetHandlerPlus.gacha_newbie_obtain_succeed_ack = function(mapMsgData)
  -- function num : 0_18 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
  ;
  (PlayerData.Item):CacheFragmentsOverflow(nil, mapMsgData)
end

HttpNetHandlerPlus.gacha_newbie_spin_failed_ack = function(mapMsgData)
  -- function num : 0_19 , upvalues : _ENV
  (EventManager.Hit)("GachaProcessStart", false)
end

HttpNetHandlerPlus.gacha_spin_failed_ack = function(mapMsgData)
  -- function num : 0_20 , upvalues : _ENV
  (EventManager.Hit)("GachaProcessStart", false)
end

HttpNetHandlerPlus.activity_story_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_21 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.activity_task_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_22 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.activity_task_group_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_23 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.player_head_icon_change_notify = function(mapMsgData)
  -- function num : 0_24 , upvalues : _ENV
  (PlayerData.Base):ChangePlayerHeadId(mapMsgData.Set)
  ;
  (PlayerData.HeadData):DelHeadId(mapMsgData.Del)
end

HttpNetHandlerPlus.activity_mining_enter_layer_notify = function(mapMsgData)
  -- function num : 0_25 , upvalues : _ENV
  (EventManager.Hit)("Mining_UpdateLevelData", mapMsgData)
end

HttpNetHandlerPlus.activity_mining_grids_error_notify = function(mapMsgData)
  -- function num : 0_26 , upvalues : _ENV
  (EventManager.Hit)("Mining_Error")
end

HttpNetHandlerPlus.activity_cookie_settle_succeed_ack = function(mapMsgData)
  -- function num : 0_27 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.tutorial_level_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_28 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.story_set_info_succeed_ack = function(mapMsgData)
  -- function num : 0_29 , upvalues : _ENV
  (PlayerData.StorySet):CacheStorySetData(mapMsgData)
end

HttpNetHandlerPlus.story_set_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_30 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.story_set_state_notify = function(mapMsgData)
  -- function num : 0_31 , upvalues : _ENV
  (PlayerData.StorySet):UnlockNewChapter(mapMsgData.Value)
end

HttpNetHandlerPlus.vampire_survivor_new_season_notify = function(mapMsgData)
  -- function num : 0_32 , upvalues : _ENV
  (PlayerData.VampireSurvivor):OnNotifyRefresh(mapMsgData.Value)
end

HttpNetHandlerPlus.battle_pass_common_fail = function(mapMsgData)
  -- function num : 0_33 , upvalues : _ENV
  (EventManager.Hit)("BattlePassNeedRefresh")
end

HttpNetHandlerPlus.activity_levels_settle_failed_ack = function()
  -- function num : 0_34 , upvalues : _ENV
  (EventManager.Hit)("ActivityLevelSettle_Failed")
end

HttpNetHandlerPlus.joint_drill_game_over_failed_ack = function(mapMsgData)
  -- function num : 0_35 , upvalues : _ENV
  if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112701 then
    (EventManager.Hit)("JointDrillChallengeFinishError")
  end
end

HttpNetHandlerPlus.joint_drill_sync_failed_ack = function(mapMsgData)
  -- function num : 0_36 , upvalues : _ENV
  if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112704 then
    (EventManager.Hit)("JointDrillChallengeFinishError")
  end
end

HttpNetHandlerPlus.joint_drill_give_up_failed_ack = function(mapMsgData)
  -- function num : 0_37 , upvalues : _ENV
  if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112704 then
    (EventManager.Hit)("JointDrillChallengeFinishError")
  end
end

HttpNetHandlerPlus.build_convert_submit_succeed_ack = function(mapMsgData)
  -- function num : 0_38 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.build_convert_group_reward_receive_succeed_ack = function(mapMsgData)
  -- function num : 0_39 , upvalues : _ENV
  local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
  ;
  (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
end

HttpNetHandlerPlus.item_expired_change_notify = function(mapMsgData)
  -- function num : 0_40 , upvalues : _ENV
  (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Item_Change_Expired_Tips"))
end

return HttpNetHandlerPlus

