local LocalData = require("GameCore.Data.LocalData")
local ConfigData = require("GameCore.Data.ConfigData")
local PlayerBuildData = class("PlayerBuildData")
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
PlayerBuildData.Init = function(self)
  -- function num : 0_0
  self._MapBuildData = {}
  self.hasData = false
  self:InitBuildRank()
end

PlayerBuildData.InitBuildRank = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self._tbBuildRank = {}
  local foreach = function(line)
    -- function num : 0_1_0 , upvalues : self
    -- DECOMPILER ERROR at PC2: Confused about usage of register: R1 in 'UnsetPending'

    (self._tbBuildRank)[line.Id] = line
  end

  ForEachTableLine(DataTable.StarTowerBuildRank, foreach)
  self._nBuildRankCount = #self._tbBuildRank
end

PlayerBuildData.GetBuildRank = function(self)
  -- function num : 0_2
  return self._tbBuildRank
end

PlayerBuildData.CreateBuildBriefData = function(self, mapBuildBriefMsg)
  -- function num : 0_3 , upvalues : _ENV
  if (self._MapBuildData)[mapBuildBriefMsg.Id] ~= nil then
    printLog((string.format)("编队信息重复！！！id= [%s]", mapBuildBriefMsg.Id))
  end
  local mapBuildData = {nBuildId = mapBuildBriefMsg.Id, sName = mapBuildBriefMsg.Name, 
tbChar = {}
, nScore = mapBuildBriefMsg.Score, mapRank = self:CalBuildRank(mapBuildBriefMsg.Score), bLock = mapBuildBriefMsg.Lock, bPreference = mapBuildBriefMsg.Preference, bDetail = false, 
tbDisc = {}
, 
tbSecondarySkill = {}
, 
tbPotentials = {}
, 
tbNotes = {}
, nTowerId = mapBuildBriefMsg.StarTowerId}
  for i = 1, 3 do
    (table.insert)(mapBuildData.tbChar, {nTid = ((mapBuildBriefMsg.Chars)[i]).CharId, nPotentialCount = ((mapBuildBriefMsg.Chars)[i]).PotentialCnt})
  end
  mapBuildData.tbDisc = mapBuildBriefMsg.DiscIds
  -- DECOMPILER ERROR at PC62: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self._MapBuildData)[mapBuildBriefMsg.Id] = mapBuildData
end

PlayerBuildData.CreateBuildDetailData = function(self, nBuildId, mapBuildDetailMsg)
  -- function num : 0_4 , upvalues : _ENV
  if mapBuildDetailMsg == nil or next(mapBuildDetailMsg) == nil then
    return 
  end
  if (self._MapBuildData)[nBuildId] == nil then
    printLog((string.format)("找不到编队信息！！！id= [%s]", nBuildId))
    return 
  end
  -- DECOMPILER ERROR at PC23: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self._MapBuildData)[nBuildId]).tbSecondarySkill = mapBuildDetailMsg.ActiveSecondaryIds
  for _,v in ipairs(mapBuildDetailMsg.Potentials) do
    local potentialCfg = (ConfigTable.GetData)("Potential", v.PotentialId)
    if potentialCfg then
      local nCharId = potentialCfg.CharId
      -- DECOMPILER ERROR at PC46: Confused about usage of register: R10 in 'UnsetPending'

      if (((self._MapBuildData)[nBuildId]).tbPotentials)[nCharId] == nil then
        (((self._MapBuildData)[nBuildId]).tbPotentials)[nCharId] = {}
      end
      ;
      (table.insert)((((self._MapBuildData)[nBuildId]).tbPotentials)[nCharId], {nPotentialId = v.PotentialId, nLevel = v.Level})
    end
  end
  local tbNotes = {}
  for _,v in pairs(mapBuildDetailMsg.SubNoteSkills) do
    tbNotes[v.Tid] = v.Qty
  end
  -- DECOMPILER ERROR at PC73: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self._MapBuildData)[nBuildId]).tbNotes = tbNotes
  -- DECOMPILER ERROR at PC76: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self._MapBuildData)[nBuildId]).bDetail = true
end

PlayerBuildData.GetAllBuildBriefData = function(self, callback)
  -- function num : 0_5
  if not self.hasData then
    self:NetMsg_GetBuildBriefData(self.GetBuildBriefDataCallback, callback)
    return false
  end
  self:GetBuildBriefDataCallback(callback)
  return true
end

PlayerBuildData.GetBuildCount = function(self, callback)
  -- function num : 0_6
  if not self.hasData then
    self:NetMsg_GetBuildBriefData(self.GetBuildCountCallBack, callback)
    return false
  end
  self:GetBuildCountCallBack(callback)
  return true
end

PlayerBuildData.GetBuildDetailData = function(self, callback, nBuildId)
  -- function num : 0_7 , upvalues : _ENV
  if (self._MapBuildData)[nBuildId] == nil then
    if self.hasData then
      printWarn("没有该id的build，大概率已被分解：" .. nBuildId)
      if callback then
        callback()
      end
      return false
    end
    local callBack = function()
    -- function num : 0_7_0 , upvalues : self, callback, nBuildId
    self:GetBuildDetailData(callback, nBuildId)
  end

    self:NetMsg_GetBuildBriefData(self.GetBuildBriefDataCallback, callBack)
    return false
  end
  do
    if not ((self._MapBuildData)[nBuildId]).bDetail then
      self:NetMsg_GetBuildDetailData(nBuildId, self.GetBuildDetailDataCallback, callback, nBuildId)
      return false
    end
    self:GetBuildDetailDataCallback(callback, nBuildId)
    return true
  end
end

PlayerBuildData.ChangeBuildName = function(self, nBuildId, sName, callback)
  -- function num : 0_8
  self:NetMsg_ChangeBuildName(nBuildId, sName, callback)
end

PlayerBuildData.ChangeBuildLock = function(self, nBuildId, bLock, callback)
  -- function num : 0_9
  self:NetMsg_ChangeBuildLock(nBuildId, bLock, callback)
end

PlayerBuildData.DeleteBuild = function(self, tbBuildId, callback, cbClose)
  -- function num : 0_10
  self:NetMsg_BuildDelete(tbBuildId, callback, cbClose)
end

PlayerBuildData.DeleteBuildByActivity = function(self, tbBuildId)
  -- function num : 0_11 , upvalues : _ENV
  for _,bBuildId in ipairs(tbBuildId) do
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R7 in 'UnsetPending'

    (self._MapBuildData)[bBuildId] = nil
  end
end

PlayerBuildData.SetBuildPreference = function(self, tbCheckInIds, tbCheckOutIds, callback)
  -- function num : 0_12
  self:NetMsg_BuildPreference(tbCheckInIds, tbCheckOutIds, callback)
end

PlayerBuildData.SaveBuild = function(self, nBuildID, bDelete, bLock, bPreference, sName, callback)
  -- function num : 0_13
  self:NetMsg_SaveBuild(nBuildID, bDelete, bLock, bPreference, sName, callback)
end

PlayerBuildData.CheckHasBuild = function(self)
  -- function num : 0_14 , upvalues : _ENV
  do return next(self._MapBuildData) ~= nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerBuildData.GetBuildAllEft = function(self, nBuildId)
  -- function num : 0_15 , upvalues : _ENV
  local ret = {}
  local mapBuildData = (self._MapBuildData)[nBuildId]
  if mapBuildData == nil or not mapBuildData.bDetail then
    print("没有对应build 或未获取该build详细数据")
    return ret
  end
  local mapCharEffect = {}
  local mapPotentialAddLevel = {}
  for _,mapChar in ipairs(mapBuildData.tbChar) do
    mapCharEffect[mapChar.nTid] = {}
    -- DECOMPILER ERROR at PC31: Confused about usage of register: R11 in 'UnsetPending'

    ;
    (mapCharEffect[mapChar.nTid])[(AllEnum.EffectType).Affinity] = (PlayerData.Char):CalcAffinityEffect(mapChar.nTid)
    -- DECOMPILER ERROR at PC42: Confused about usage of register: R11 in 'UnsetPending'

    ;
    (mapCharEffect[mapChar.nTid])[(AllEnum.EffectType).Talent] = (PlayerData.Char):CalcTalentEffect(mapChar.nTid)
    -- DECOMPILER ERROR at PC53: Confused about usage of register: R11 in 'UnsetPending'

    ;
    (mapCharEffect[mapChar.nTid])[(AllEnum.EffectType).Equipment] = (PlayerData.Equipment):GetCharEquipmentEffect(mapChar.nTid)
    mapPotentialAddLevel[mapChar.nTid] = (PlayerData.Char):GetCharEnhancedPotential(mapChar.nTid)
  end
  for nCharId,tbPerk in pairs(mapBuildData.tbPotentials) do
    for _,mapPerkInfo in ipairs(tbPerk) do
      local nPotentialId = mapPerkInfo.nPotentialId
      local nPotentialCount = mapPerkInfo.nLevel
      if mapPotentialAddLevel[nCharId] ~= nil and (mapPotentialAddLevel[nCharId])[nPotentialId] ~= nil then
        nPotentialCount = nPotentialCount + (mapPotentialAddLevel[nCharId])[nPotentialId]
      end
      -- DECOMPILER ERROR at PC95: Confused about usage of register: R18 in 'UnsetPending'

      if (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] == nil then
        (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] = {}
      end
      local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
      if mapPotentialCfgData == nil then
        printError("Potential CfgData Missing:" .. nPotentialId)
      else
        -- DECOMPILER ERROR at PC118: Confused about usage of register: R19 in 'UnsetPending'

        ;
        ((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId] = {
{}
, nPotentialCount}
        if mapPotentialCfgData.EffectId1 ~= 0 then
          (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId1)
        end
        if mapPotentialCfgData.EffectId2 ~= 0 then
          (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId2)
        end
        if mapPotentialCfgData.EffectId3 ~= 0 then
          (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId3)
        end
        if mapPotentialCfgData.EffectId4 ~= 0 then
          (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId4)
        end
      end
    end
  end
  local mapDiscEffect = {}
  for nIndex,nDiscId in ipairs(mapBuildData.tbDisc) do
    if nIndex <= 3 then
      local tbDiscEft = (PlayerData.Disc):CalcDiscEffectInBuild(nDiscId, mapBuildData.tbSecondarySkill)
      mapDiscEffect[nDiscId] = tbDiscEft
    end
  end
  local tbNoteInfo, mapNoteEffect = {}, {}
  for i,v in pairs(mapBuildData.tbNotes) do
    local noteInfo = (CS.Lua2CSharpInfo_NoteInfo)()
    noteInfo.noteId = i
    noteInfo.noteCount = v
    ;
    (table.insert)(tbNoteInfo, noteInfo)
    local mapCfg = (ConfigTable.GetData)("SubNoteSkill", i)
    if mapCfg then
      local tbEft = {}
      for _,nEftId in pairs(mapCfg.EffectId) do
        (table.insert)(tbEft, {nEftId, v})
      end
      mapNoteEffect[i] = tbEft
    end
  end
  return mapCharEffect, mapDiscEffect, mapNoteEffect, tbNoteInfo
end

PlayerBuildData.GetBuildAttrBase = function(self, nBuildId, bTrial)
  -- function num : 0_16 , upvalues : _ENV, ConfigData
  local ret = {}
  if not bTrial or not self:GetTrialBuild(nBuildId) then
    local mapBuildData = (self._MapBuildData)[nBuildId]
  end
  if mapBuildData == nil or not mapBuildData.bDetail then
    print("没有对应build 或未获取该build详细数据")
    return ret
  end
  local tbAttrList = {}
  for _,v in ipairs(AllEnum.AttachAttr) do
    tbAttrList[v.sKey] = {Key = v.sKey, Value = 0, CfgValue = 0}
  end
  local mapRank = mapBuildData.mapRank
  local nAttrId = (UTILS.GetBuildAttributeId)(mapRank.AttrBaseGroupId, mapRank.Level)
  if nAttrId > 0 then
    local mapAttribute = (ConfigTable.GetData_Attribute)(tostring(nAttrId))
    if mapAttribute then
      for _,v in ipairs(AllEnum.AttachAttr) do
        local nParamValue = mapAttribute[v.sKey] or 0
        local nValue = v.bPercent and nParamValue * ConfigData.IntFloatPrecision * 100 or nParamValue
        tbAttrList[v.sKey] = {Key = v.sKey, Value = nValue, CfgValue = nParamValue}
      end
    end
  end
  do
    return tbAttrList
  end
end

PlayerBuildData.CalBuildRank = function(self, nScore)
  -- function num : 0_17 , upvalues : _ENV
  local nMin = 1
  local nMax = self._nBuildRankCount
  local mapRank = (self._tbBuildRank)[1]
  while 1 do
    while 1 do
      while 1 do
        if nMin <= nMax then
          local nMiddle = (math.floor)((nMin + nMax) / 2)
          if nMiddle == self._nBuildRankCount or ((self._tbBuildRank)[nMiddle]).MinGrade <= nScore and nScore < ((self._tbBuildRank)[nMiddle + 1]).MinGrade then
            mapRank = (self._tbBuildRank)[nMiddle]
            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
      if nScore < ((self._tbBuildRank)[nMiddle]).MinGrade then
        nMax = nMiddle - 1
        -- DECOMPILER ERROR at PC35: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC35: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
    nMin = nMiddle + 1
  end
  do
    return mapRank
  end
end

PlayerBuildData.CheckCoinMax = function(self, nCoin, confirmDelete)
  -- function num : 0_18 , upvalues : _ENV, LocalData, newDayTime
  local nLimit = (PlayerData.StarTower):GetStarTowerRewardLimit()
  local nCur = (PlayerData.StarTower):GetStarTowerTicket()
  local confirm = function()
    -- function num : 0_18_0 , upvalues : confirmDelete, _ENV
    if confirmDelete ~= nil and type(confirmDelete) == "function" then
      confirmDelete()
    end
  end

  if nLimit < nCoin + nCur then
    local TipsTime = (LocalData.GetPlayerLocalData)("Build_Tips_Time")
    local _tipDay = 0
    if TipsTime ~= nil then
      _tipDay = tonumber(TipsTime)
    end
    local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local fixedTimeStamp = curTimeStamp + newDayTime * 3600
    local nYear = tonumber((os.date)("!%Y", fixedTimeStamp))
    local nMonth = tonumber((os.date)("!%m", fixedTimeStamp))
    local nDay = tonumber((os.date)("!%d", fixedTimeStamp))
    local nowD = nYear * 366 + nMonth * 31 + nDay
    if nowD == _tipDay then
      confirm()
    else
      local isSelectAgain = false
      do
        local confirmCallback = function()
    -- function num : 0_18_1 , upvalues : isSelectAgain, _ENV, newDayTime, LocalData, confirm
    if isSelectAgain then
      local _curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
      local _fixedTimeStamp = _curTimeStamp + newDayTime * 3600
      local _nYear = tonumber((os.date)("!%Y", _fixedTimeStamp))
      local _nMonth = tonumber((os.date)("!%m", _fixedTimeStamp))
      local _nDay = tonumber((os.date)("!%d", _fixedTimeStamp))
      local _nowD = _nYear * 366 + _nMonth * 31 + _nDay
      ;
      (LocalData.SetPlayerLocalData)("Build_Tips_Time", tostring(_nowD))
    end
    do
      confirm()
    end
  end

        local againCallback = function(isSelect)
    -- function num : 0_18_2 , upvalues : isSelectAgain
    isSelectAgain = isSelect
  end

        local msg = {nType = (AllEnum.MessageBox).Confirm, sContent = (ConfigTable.GetUIText)("BUILD_11"), callbackConfirm = confirmCallback, callbackAgain = againCallback, bBlur = false}
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, msg)
      end
    end
  else
    do
      confirm()
    end
  end
end

PlayerBuildData.CacheRogueBuild = function(self, mapBuildInfo)
  -- function num : 0_19
  self:CreateBuildBriefData(mapBuildInfo.Brief)
  self:CreateBuildDetailData((mapBuildInfo.Brief).Id, mapBuildInfo.Detail)
end

PlayerBuildData.GetBuildBriefDataCallback = function(self, callBack)
  -- function num : 0_20 , upvalues : _ENV
  local ret = {}
  for _,mapBuild in pairs(self._MapBuildData) do
    (table.insert)(ret, mapBuild)
  end
  callBack(ret, self._MapBuildData)
end

PlayerBuildData.GetBuildDetailDataCallback = function(self, callBack, nBuildId)
  -- function num : 0_21
  callBack((self._MapBuildData)[nBuildId])
end

PlayerBuildData.GetBuildCountCallBack = function(self, callBack)
  -- function num : 0_22 , upvalues : _ENV
  local ret = 0
  for _,_ in pairs(self._MapBuildData) do
    ret = ret + 1
  end
  callBack(ret)
end

PlayerBuildData.NetMsg_GetBuildBriefData = function(self, func, ...)
  -- function num : 0_23 , upvalues : _ENV
  local arg = {...}
  local MsgCallBack = function(_, msgData)
    -- function num : 0_23_0 , upvalues : self, _ENV, func, arg
    self.hasData = true
    for _,mapBuild in ipairs(msgData.Briefs) do
      self:CreateBuildBriefData(mapBuild)
    end
    func(self, (table.unpack)(arg))
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_brief_list_get_req, {}, nil, MsgCallBack)
end

PlayerBuildData.NetMsg_GetBuildDetailData = function(self, nBuildId, func, ...)
  -- function num : 0_24 , upvalues : _ENV
  local arg = {...}
  local MsgCallBack = function(_, msgData)
    -- function num : 0_24_0 , upvalues : self, nBuildId, _ENV, func, arg
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R2 in 'UnsetPending'

    ((self._MapBuildData)[nBuildId]).tbSecondarySkill = (msgData.Detail).ActiveSecondaryIds
    for _,v in ipairs((msgData.Detail).Potentials) do
      local potentialCfg = (ConfigTable.GetData)("Potential", v.PotentialId)
      if potentialCfg then
        local nCharId = potentialCfg.CharId
        -- DECOMPILER ERROR at PC31: Confused about usage of register: R9 in 'UnsetPending'

        if (((self._MapBuildData)[nBuildId]).tbPotentials)[nCharId] == nil then
          (((self._MapBuildData)[nBuildId]).tbPotentials)[nCharId] = {}
        end
        ;
        (table.insert)((((self._MapBuildData)[nBuildId]).tbPotentials)[nCharId], {nPotentialId = v.PotentialId, nLevel = v.Level})
      end
    end
    local tbNotes = {}
    for _,v in pairs((msgData.Detail).SubNoteSkills) do
      tbNotes[v.Tid] = v.Qty
    end
    -- DECOMPILER ERROR at PC61: Confused about usage of register: R3 in 'UnsetPending'

    ;
    ((self._MapBuildData)[nBuildId]).tbNotes = tbNotes
    -- DECOMPILER ERROR at PC65: Confused about usage of register: R3 in 'UnsetPending'

    ;
    ((self._MapBuildData)[nBuildId]).bDetail = true
    func(self, (table.unpack)(arg))
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_detail_get_req, {BuildId = nBuildId}, nil, MsgCallBack)
end

PlayerBuildData.NetMsg_ChangeBuildName = function(self, nBuildId, sName, callback)
  -- function num : 0_25 , upvalues : _ENV
  local msg = {BuildId = nBuildId, Name = sName}
  local callBack = function()
    -- function num : 0_25_0 , upvalues : self, nBuildId, sName, callback
    -- DECOMPILER ERROR at PC4: Confused about usage of register: R0 in 'UnsetPending'

    ((self._MapBuildData)[nBuildId]).sName = sName
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_name_set_req, msg, nil, callBack)
end

PlayerBuildData.NetMsg_ChangeBuildLock = function(self, nBuildId, bLock, callback)
  -- function num : 0_26 , upvalues : _ENV
  local msg = {BuildId = nBuildId, Lock = bLock}
  local callBack = function()
    -- function num : 0_26_0 , upvalues : self, nBuildId, bLock, callback
    -- DECOMPILER ERROR at PC4: Confused about usage of register: R0 in 'UnsetPending'

    ((self._MapBuildData)[nBuildId]).bLock = bLock
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_lock_unlock_req, msg, nil, callBack)
end

PlayerBuildData.NetMsg_BuildDelete = function(self, tbBuildId, callback, cbClose)
  -- function num : 0_27 , upvalues : _ENV
  local msg = {BuildIds = tbBuildId}
  local callBack = function(_, mapMainData)
    -- function num : 0_27_0 , upvalues : _ENV, tbBuildId, self, cbClose, callback
    for _,bBuildId in ipairs(tbBuildId) do
      -- DECOMPILER ERROR at PC5: Confused about usage of register: R7 in 'UnsetPending'

      (self._MapBuildData)[bBuildId] = nil
    end
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMainData.Change, cbClose)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_delete_req, msg, nil, callBack)
end

PlayerBuildData.NetMsg_BuildPreference = function(self, tbCheckInIds, tbCheckOutIds, callback)
  -- function num : 0_28 , upvalues : _ENV
  local msg = {CheckInIds = tbCheckInIds, CheckOutIds = tbCheckOutIds}
  local callBack = function()
    -- function num : 0_28_0 , upvalues : _ENV, tbCheckInIds, self, tbCheckOutIds, callback
    for _,bBuildId in ipairs(tbCheckInIds) do
      -- DECOMPILER ERROR at PC6: Confused about usage of register: R5 in 'UnsetPending'

      ((self._MapBuildData)[bBuildId]).bPreference = true
    end
    for _,bBuildId in ipairs(tbCheckOutIds) do
      -- DECOMPILER ERROR at PC15: Confused about usage of register: R5 in 'UnsetPending'

      ((self._MapBuildData)[bBuildId]).bPreference = false
    end
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_preference_set_req, msg, nil, callBack)
end

PlayerBuildData.NetMsg_SaveBuild = function(self, nBuildID, bDelete, bLock, bPreference, sName, callback)
  -- function num : 0_29 , upvalues : _ENV
  local msg = {}
  msg.Delete = bDelete
  msg.Lock = bLock
  msg.Preference = bPreference
  msg.BuildName = sName
  local callBack = function(_, mapMainData)
    -- function num : 0_29_0 , upvalues : callback, bDelete, self, nBuildID, bLock, bPreference, sName
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

    if callback ~= nil then
      if bDelete then
        (self._MapBuildData)[nBuildID] = nil
      else
        -- DECOMPILER ERROR at PC14: Confused about usage of register: R2 in 'UnsetPending'

        ;
        ((self._MapBuildData)[nBuildID]).bLock = bLock
        -- DECOMPILER ERROR at PC19: Confused about usage of register: R2 in 'UnsetPending'

        ;
        ((self._MapBuildData)[nBuildID]).bPreference = bPreference
        -- DECOMPILER ERROR at PC24: Confused about usage of register: R2 in 'UnsetPending'

        ;
        ((self._MapBuildData)[nBuildID]).sName = sName
      end
      callback(mapMainData.Change)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_whether_save_req, msg, nil, callBack)
end

PlayerBuildData.CreateTrialBuild = function(self, nTrialId)
  -- function num : 0_30 , upvalues : _ENV
  self._mapTrialBuild = {}
  local mapTrialData = (ConfigTable.GetData)("TrialBuild", nTrialId)
  if mapTrialData == nil then
    printError("试用编组数据没有找到：" .. nTrialId)
    return 
  end
  self._mapTrialBuild = {nBuildId = nTrialId, sName = mapTrialData.Name, 
tbChar = {}
, nScore = mapTrialData.Score, mapRank = self:CalBuildRank(mapTrialData.Score), bLock = false, bPreference = false, bDetail = true, 
tbDisc = {}
, 
tbSecondarySkill = {}
, 
tbPotentials = {}
, 
tbNotes = {}
, nTowerId = 0}
  local tbCharTrialId = {}
  for _,v in ipairs(mapTrialData.Char) do
    (table.insert)((self._mapTrialBuild).tbChar, {nTrialId = v, nTid = 0, nPotentialCount = 0})
    ;
    (table.insert)(tbCharTrialId, v)
  end
  -- DECOMPILER ERROR at PC63: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self._mapTrialBuild).tbDisc = mapTrialData.Disc
  -- DECOMPILER ERROR at PC66: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self._mapTrialBuild).tbSecondarySkill = mapTrialData.ActiveSecondaryIds
  local tbPotentials = decodeJson(mapTrialData.Potential)
  for _,v in pairs(tbPotentials) do
    local potentialCfg = (ConfigTable.GetData)("Potential", v.Tid)
    if potentialCfg then
      local nCharId = potentialCfg.CharId
      -- DECOMPILER ERROR at PC90: Confused about usage of register: R12 in 'UnsetPending'

      if not ((self._mapTrialBuild).tbPotentials)[nCharId] then
        ((self._mapTrialBuild).tbPotentials)[nCharId] = {}
      end
      ;
      (table.insert)(((self._mapTrialBuild).tbPotentials)[nCharId], {nPotentialId = v.Tid, nLevel = v.Level})
    end
  end
  local tbNoteJson = decodeJson(mapTrialData.Note)
  local tbNotes = {}
  for _,v in pairs(tbNoteJson) do
    tbNotes[v.Id] = v.Qty
  end
  -- DECOMPILER ERROR at PC118: Confused about usage of register: R7 in 'UnsetPending'

  ;
  (self._mapTrialBuild).tbNotes = tbNotes
  ;
  (PlayerData.Char):CreateTrialChar(tbCharTrialId)
  ;
  (PlayerData.Disc):CreateTrialDisc(mapTrialData.Disc)
  for k,v in pairs((self._mapTrialBuild).tbChar) do
    local mapTrialChar = (PlayerData.Char):GetTrialCharById(v.nTrialId)
    -- DECOMPILER ERROR at PC148: Confused about usage of register: R13 in 'UnsetPending'

    ;
    (((self._mapTrialBuild).tbChar)[k]).nTid = mapTrialChar ~= nil and mapTrialChar.nId or 0
  end
  return self._mapTrialBuild
end

PlayerBuildData.DeleteTrialBuild = function(self)
  -- function num : 0_31 , upvalues : _ENV
  self._mapTrialBuild = {}
  ;
  (PlayerData.Char):DeleteTrialChar()
  ;
  (PlayerData.Disc):DeleteTrialDisc()
end

PlayerBuildData.GetTrialBuild = function(self, nTrialId)
  -- function num : 0_32
  if self._mapTrialBuild then
    if (self._mapTrialBuild).nBuildId == nTrialId then
      return self._mapTrialBuild
    else
      self:DeleteTrialBuild()
    end
  end
  return self:CreateTrialBuild(nTrialId)
end

PlayerBuildData.GetTrialBuildAllEft = function(self)
  -- function num : 0_33 , upvalues : _ENV
  local ret = {}
  local mapBuildData = self._mapTrialBuild
  if mapBuildData == nil or not mapBuildData.bDetail then
    print("没有对应build 或未获取该build详细数据")
    return ret
  end
  local mapCharEffect = {}
  local mapTalentAddLevel = {}
  for _,mapChar in ipairs(mapBuildData.tbChar) do
    mapCharEffect[mapChar.nTid] = {}
    -- DECOMPILER ERROR at PC30: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (mapCharEffect[mapChar.nTid])[(AllEnum.EffectType).Talent] = (PlayerData.Talent):GetTrialTalentEffect(mapChar.nTrialId)
    mapTalentAddLevel[mapChar.nTid] = (PlayerData.Talent):GetTrialEnhancedPotential(mapChar.nTrialId)
  end
  local tbCharIdToTrial = {}
  for _,mapChar in ipairs(mapBuildData.tbChar) do
    tbCharIdToTrial[mapChar.nTid] = mapChar.nTrialId
  end
  for nCharId,tbPerk in pairs(mapBuildData.tbPotentials) do
    if tbCharIdToTrial[nCharId] then
      for _,mapPerkInfo in ipairs(tbPerk) do
        local nPotentialId = mapPerkInfo.nPotentialId
        local nPotentialCount = mapPerkInfo.nLevel
        if mapTalentAddLevel[nCharId] ~= nil and (mapTalentAddLevel[nCharId])[nPotentialId] ~= nil then
          nPotentialCount = nPotentialCount + (mapTalentAddLevel[nCharId])[nPotentialId]
        end
        -- DECOMPILER ERROR at PC85: Confused about usage of register: R18 in 'UnsetPending'

        if (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] == nil then
          (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] = {}
        end
        local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
        if mapPotentialCfgData == nil then
          printError("Potential CfgData Missing:" .. nPotentialId)
        else
          -- DECOMPILER ERROR at PC108: Confused about usage of register: R19 in 'UnsetPending'

          ;
          ((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId] = {
{}
, nPotentialCount}
          if mapPotentialCfgData.EffectId1 ~= 0 then
            (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId1)
          end
          if mapPotentialCfgData.EffectId2 ~= 0 then
            (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId2)
          end
          if mapPotentialCfgData.EffectId3 ~= 0 then
            (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId3)
          end
          if mapPotentialCfgData.EffectId4 ~= 0 then
            (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId4)
          end
        end
      end
    else
      do
        do
          printError("体验build内，有多余角色的潜能" .. nCharId)
          -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out IF_ELSE_STMT

          -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  local mapDiscEffect = {}
  for nIndex,nTrialDiscId in ipairs(mapBuildData.tbDisc) do
    if nIndex <= 3 then
      local tbDiscEft = (PlayerData.Disc):CalcTrialEffectInBuild(nTrialDiscId, mapBuildData.tbSecondarySkill)
      mapDiscEffect[nTrialDiscId] = tbDiscEft
    end
  end
  local tbNoteInfo, mapNoteEffect = {}, {}
  for i,v in pairs(mapBuildData.tbNotes) do
    local noteInfo = (CS.Lua2CSharpInfo_NoteInfo)()
    noteInfo.noteId = i
    noteInfo.noteCount = v
    ;
    (table.insert)(tbNoteInfo, noteInfo)
    local mapCfg = (ConfigTable.GetData)("SubNoteSkill", i)
    if mapCfg then
      local tbEft = {}
      for _,nEftId in pairs(mapCfg.EffectId) do
        (table.insert)(tbEft, {nEftId, v})
      end
      mapNoteEffect[i] = tbEft
    end
  end
  return mapCharEffect, mapDiscEffect, mapNoteEffect, tbNoteInfo
end

PlayerBuildData.SetBuildReportInfo = function(self, nBuildId)
  -- function num : 0_34 , upvalues : _ENV
  local mapDetailData = (self._MapBuildData)[nBuildId]
  if mapDetailData == nil or not ((self._MapBuildData)[nBuildId]).bDetail then
    printError("No Build Detail Data")
    return 
  end
  local tbNotes = {}
  for nTid,nQty in pairs(mapDetailData.tbNotes) do
    (table.insert)(tbNotes, {nTid, nQty})
  end
  local tbSkills = mapDetailData.tbSecondarySkill
  local tbDiscData = {}
  for _,nDiscId in ipairs(mapDetailData.tbDisc) do
    local stBuildDisc = (CS.BuildDiscData)()
    stBuildDisc.discId = nDiscId
    local mapDiscData = (PlayerData.Disc):GetDiscById(nDiscId)
    if mapDetailData ~= nil then
      stBuildDisc.level = mapDiscData.nLevel
      stBuildDisc.breakCount = mapDiscData.nStar
      stBuildDisc.advance = mapDiscData.nPhase
    end
    ;
    (table.insert)(tbDiscData, stBuildDisc)
  end
  local tbCharData = {}
  for _,mapChar in ipairs(mapDetailData.tbChar) do
    local stBuildCharData = (CS.BuildCharData)()
    stBuildCharData.charId = mapChar.nTid
    local tbEquipment = (PlayerData.Equipment):GetCharEquipmentEffect(mapChar.nTid)
    stBuildCharData.equipmentEffects = tbEquipment
    local tbPotentials = {}
    if (mapDetailData.tbPotentials)[mapChar.nTid] ~= nil then
      for _,mapPotential in ipairs((mapDetailData.tbPotentials)[mapChar.nTid]) do
        (table.insert)(tbPotentials, {mapPotential.nPotentialId, mapPotential.nLevel})
      end
    end
    do
      do
        stBuildCharData.potentialIds = tbPotentials
        ;
        (table.insert)(tbCharData, stBuildCharData)
        -- DECOMPILER ERROR at PC102: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  ;
  (NovaAPI.SetBuildReportInfo)(nBuildId, mapDetailData.sName or "", tbCharData, tbDiscData, tbSkills, tbNotes)
end

return PlayerBuildData

