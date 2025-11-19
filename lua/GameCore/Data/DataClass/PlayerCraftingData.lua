local PlayerCraftingData = class("PlayerCraftingData")
PlayerCraftingData.Init = function(self)
  -- function num : 0_0
  self:InitCfgData()
end

PlayerCraftingData.InitCfgData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local foreachProduction = function(line)
    -- function num : 0_1_0 , upvalues : _ENV
    local lineData = line
    local tbMaterialList = {}
    for i = 1, 4 do
      local nMtId = line["RawMaterialId" .. i]
      local nMtCount = line["RawMaterialCount" .. i]
      if nMtId > 0 then
        local tbMtInfo = {nItemId = nMtId, nCount = nMtCount}
        ;
        (table.insert)(tbMaterialList, tbMtInfo)
      end
    end
    line.MaterialList = tbMaterialList
    ;
    (CacheTable.InsertData)("_ProductionPage", line.Tag, lineData)
    ;
    (CacheTable.InsertData)("_ProductionGroup", line.Group, lineData)
    ;
    (CacheTable.SetData)("_Production", line.Id, lineData)
  end

  ForEachTableLine(DataTable.Production, foreachProduction)
end

PlayerCraftingData.GetProductionListByPage = function(self, nPageType)
  -- function num : 0_2 , upvalues : _ENV
  local productionList = {}
  local nWorldClass = (PlayerData.Base):GetWorldClass()
  local tbList = (CacheTable.GetData)("_ProductionPage", nPageType)
  if tbList ~= nil then
    for _,v in ipairs(tbList) do
      if v.IsActivated and v.IsShowWorldLevel <= nWorldClass then
        (table.insert)(productionList, v)
      end
    end
  end
  do
    ;
    (table.sort)(productionList, function(a, b)
    -- function num : 0_2_0
    if a.Id >= b.Id then
      do return a.SortId ~= b.SortId end
      do return a.SotId < b.SortId end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
    return productionList
  end
end

PlayerCraftingData.GetProductionPageList = function(self)
  -- function num : 0_3 , upvalues : _ENV
  local tbPageList = {}
  local nWorldClass = (PlayerData.Base):GetWorldClass()
  if not (CacheTable.Get)("_ProductionPage") then
    local _ProductionPage = {}
  end
  for type,list in pairs(_ProductionPage) do
    if list ~= nil and next(list) ~= nil then
      local tbList = {}
      for _,v in ipairs(list) do
        if v.IsActived and v.IsShowWorldLevel <= nWorldClass then
          (table.insert)(tbList, v)
        end
      end
      ;
      (table.sort)(tbList, function(a, b)
    -- function num : 0_3_0
    if b.Id >= a.Id then
      do return a.SortId ~= b.SortId end
      do return a.SortId < b.SortId end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
      if next(tbList) ~= nil then
        local tbPage = {}
        tbPage.nType = type
        local typeCfg = (ConfigTable.GetData)("ProductionType", type)
        tbPage.nSortId = typeCfg.SortId
        tbPage.tbList = tbList
        ;
        (table.insert)(tbPageList, tbPage)
      end
    end
  end
  ;
  (table.sort)(tbPageList, function(a, b)
    -- function num : 0_3_1
    if a.nType >= b.nType then
      do return a.nSortId ~= b.nSortId end
      do return a.nSortId < b.nSortId end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
  return tbPageList
end

PlayerCraftingData.GetProductionById = function(self, nId)
  -- function num : 0_4 , upvalues : _ENV
  return (CacheTable.GetData)("_Production", nId)
end

PlayerCraftingData.CheckProductionUnlock = function(self, nProductionId)
  -- function num : 0_5 , upvalues : _ENV
  local bUnlock = false
  local tbCfg = (ConfigTable.GetData)("Production", nProductionId)
  do
    if tbCfg ~= nil and tbCfg.IsActived then
      local nWorldClass = (PlayerData.Base):GetWorldClass()
      bUnlock = tbCfg.IsShowWorldLevel <= nWorldClass and tbCfg.UnlockWorldLevel <= nWorldClass
    end
    do return bUnlock end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

PlayerCraftingData.GetProductionListByGroup = function(self, nGroupId)
  -- function num : 0_6 , upvalues : _ENV
  local tbGroupList = {}
  local tbList = (CacheTable.GetData)("_ProductionGroup", nGroupId)
  if tbList ~= nil then
    local nWorldClass = (PlayerData.Base):GetWorldClass()
    for _,v in ipairs(tbList) do
      if v.IsActived and v.IsShowWorldLevel <= nWorldClass then
        (table.insert)(tbGroupList, v)
      end
    end
  end
  do
    ;
    (table.sort)(tbGroupList, function(a, b)
    -- function num : 0_6_0
    if b.Id >= a.Id then
      do return a.SortId ~= b.SortId end
      do return a.SortId < b.SortId end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
    return tbGroupList
  end
end

PlayerCraftingData.SendMaterialCrafting = function(self, nProductionId, nCount, callback)
  -- function num : 0_7 , upvalues : _ENV
  local successCallback = function(MsgSend, mapMsgData)
    -- function num : 0_7_0 , upvalues : _ENV, callback
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).item_product_req, {Id = nProductionId, Num = nCount}, nil, successCallback)
end

PlayerCraftingData.SendPresentsCrafting = function(self, nProductionId, tbMatList, callback)
  -- function num : 0_8 , upvalues : _ENV
  local successCallback = function(MsgSend, mapMsgData)
    -- function num : 0_8_0 , upvalues : _ENV, callback
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).presents_crafting_req, {Id = nProductionId, PresentsIds = tbMatList}, nil, successCallback)
end

return PlayerCraftingData

