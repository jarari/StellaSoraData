--筛选临时数据
local FilterData = class("FilterData")
local LocalData = require "GameCore.Data.LocalData"
---@diagnostic disable-next-line: duplicate-set-field
function FilterData:ctor()
end
function FilterData:Init()
    self.tbCacheFilter = {} -- for temp operation
    self.tbFilter = {}
    for fKey, v in pairs(AllEnum.ChooseOptionCfg) do
        self.tbFilter[fKey] = {}
        for sKey, _ in pairs(v.items) do
            self.tbFilter[fKey][sKey] = false -- 默认非选中
        end
    end
--需要将排序记录到本地数据 所以在这里添加
    self.nFormationCharSrotType = AllEnum.SortType.Level
    self.bFormationCharOrder = false

    self.nFormationDiscSrotType = AllEnum.SortType.Level
    self.bFormationDiscOrder = false
end

function FilterData:Reset(tbOption)
    if tbOption == nil then
        return
    end
    self.tbCacheFilter = {}
    for fKey, _ in pairs(self.tbFilter) do
        if table.indexof(tbOption,fKey) > 0 then
            for sKey, _ in pairs(self.tbFilter[fKey]) do
                self.tbFilter[fKey][sKey] = false
            end
        end
    end
end

function FilterData:IsDirty(optionType)
    if optionType == AllEnum.OptionType.Char then
        local dirty = self:_IsDirty(AllEnum.ChooseOption.Char_Element)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Char_Rarity)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Char_PowerStyle)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Char_TacticalStyle)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Char_AffiliatedForces)
        return dirty
    elseif optionType == AllEnum.OptionType.Disc then
        local dirty = self:_IsDirty(AllEnum.ChooseOption.Star_Element)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Star_Rarity)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Star_Note)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Star_Tag)
        return dirty
    elseif optionType == AllEnum.OptionType.Equipment then
        local dirty = self:_IsDirty(AllEnum.ChooseOption.Equip_Rarity)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_Type)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_Theme_Circle)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_Theme_Square)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_Theme_Pentagon)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_PowerStyle)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_TacticalStyle)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_AffiliatedForces)
        dirty = dirty or self:_IsDirty(AllEnum.ChooseOption.Equip_Match)
        return dirty
    end
    return false
end

function  FilterData:_IsDirty(fKey)
    for _, result in pairs(self.tbFilter[fKey]) do
        if result == true then
            return true
        end
    end
    return false
end

--- 筛选规则
--- 1.默认不选中
--- 2.一个维度中，所有都未选中，就默认全都是选中; 一个维度多选中，是或的关系
--- 3.多维度选中，需要并处理
--- 4.新盘音符，特殊处理，并逻辑
--- 角色过滤(元素，品质，xx体系)
function FilterData:CheckFilterByChar(charId)
    local charData = ConfigTable.GetData_Character(charId) --PlayerData.Char:GetCharDataById(charId)
    local mapCharDescCfg = ConfigTable.GetData("CharacterDes",charId)
    --printTable(charData)
    local isFilter = true
    if mapCharDescCfg == nil or charData == nil then
        return isFilter
    end
    ---char element
    isFilter = self:_GetFilterByKey(AllEnum.ChooseOption.Char_Element,charData.EET)
    ---char rarity
    isFilter = isFilter and self:_GetFilterByKey(AllEnum.ChooseOption.Char_Rarity,charData.Grade)
    ---char PowerStyle
    isFilter = isFilter and self:_GetFilterByKey(AllEnum.ChooseOption.Char_PowerStyle,charData.Class)
    ---char TacticalStyle
    isFilter = isFilter and self:_GetFilterByKey(AllEnum.ChooseOption.Char_TacticalStyle,mapCharDescCfg.Tag[2])
    ---char AffiliatedForces
    isFilter = isFilter and self:_GetFilterByKey(AllEnum.ChooseOption.Char_AffiliatedForces,mapCharDescCfg.Tag[3])
    return isFilter
end
--- 新盘过滤(品质，音符)
function FilterData:CheckFilterByDisc(discId)
    local discCfg = ConfigTable.GetData("Disc", discId) --读取note
    local discData  = PlayerData.Disc:GetDiscById(discId)--读取rarity
    local isFilter = true
    --print("rarity:"..discData.nRarity)
    ---disc element
    isFilter = self:_GetFilterByKey(AllEnum.ChooseOption.Star_Element,discData.nEET)
    ---disc rarity
    isFilter = isFilter and self:_GetFilterByKey(AllEnum.ChooseOption.Star_Rarity,discData.nRarity)

    ---disc note[TODO:需要全部满足]
    ---A(note1/2/3) 包含 B(options)
    --print("------------------->"..discId)
    local isFilter2 = true
    local A = {} -- hash
    for _, noteId in ipairs(discData.tbShowNote or {}) do
        A[noteId] = true
    end
    for sKey, v in pairs(self.tbFilter[AllEnum.ChooseOption.Star_Note]) do
        if v == true then --选中
            -- 是否属于A
            if A[sKey] == nil then
                isFilter2 = false
            end
        end
    end

    isFilter = isFilter and isFilter2

    ---disc tag
    local isFilter3 = true
    local B = {} -- hash
    for _, tagId in pairs(discData.tbTag or {}) do
        B[tagId] = true
    end
    for sKey, v in pairs(self.tbFilter[AllEnum.ChooseOption.Star_Tag]) do
        if v == true then --选中
            -- 是否属于B
            if B[sKey] == nil then
                isFilter3 = false
            end
        end
    end

    isFilter = isFilter and isFilter3

    return isFilter
end
--- 纹章/武器过滤(品质，类型，主属性类型，随机属性标签，随机词条契合度)
function FilterData:CheckFilerByEquip(equipId, nCharId)
    local equipmentData = PlayerData.Equipment:GetEquipmentById(equipId)
    --print("rarity:"..equipmentData:GetRarity().." type:"..equipmentData:GetType())
    local isFilter = true
    local nEquipType = equipmentData:GetType()
    ---equip rarity
    isFilter = isFilter and  self:_GetFilterByKey(AllEnum.ChooseOption.Equip_Rarity,equipmentData:GetRarity())
    ---equip type
    isFilter = isFilter and  self:_GetFilterByKey(AllEnum.ChooseOption.Equip_Type, nEquipType)
    ---equip main attr
    local tbBaseAttrDescId = equipmentData:GetBaseAttrDescId()
    local tbSelectAttr = {}
    local tbCurAttr = {}
    if nEquipType == GameEnum.equipmentType.Square then
        tbCurAttr = self.tbFilter[AllEnum.ChooseOption.Equip_Theme_Square]
    elseif nEquipType == GameEnum.equipmentType.Circle then
        tbCurAttr = self.tbFilter[AllEnum.ChooseOption.Equip_Theme_Circle]
    elseif nEquipType == GameEnum.equipmentType.Pentagon then
        tbCurAttr = self.tbFilter[AllEnum.ChooseOption.Equip_Theme_Pentagon]
    end
    for nKey, v in pairs(tbCurAttr) do
        if v then
            tbSelectAttr[nKey] = 1
        end
    end
    local bAttr = true
    if next(tbSelectAttr) ~= nil then
        bAttr = false
        for _, id in ipairs(tbBaseAttrDescId) do
            if tbSelectAttr[id] ~= nil then
                bAttr = true
                break
            end
        end
        isFilter = isFilter and bAttr
    end

    ---equip tag
    local tbTag = equipmentData:GetTag()
    local tbSelectTag = {}
    for nKey, v in pairs(self.tbFilter[AllEnum.ChooseOption.Equip_PowerStyle]) do
        if v then
            tbSelectTag[nKey] = 1
        end
    end
    local bTag = true
    if next(tbSelectTag) ~= nil then
        bTag = false
        for _, tag in ipairs(tbTag) do
            if tbSelectTag[tag] ~= nil then
                bTag = true
                break
            end
        end
        isFilter = isFilter and bTag
    end

    tbSelectTag = {}
    for nKey, v in pairs(self.tbFilter[AllEnum.ChooseOption.Equip_TacticalStyle]) do
        if v then
            tbSelectTag[nKey] = 1
        end
    end
    if next(tbSelectTag) ~= nil then
        bTag = false
        for _, tag in ipairs(tbTag) do
            if tbSelectTag[tag] ~= nil then
                bTag = true
                break
            end
        end
        isFilter = isFilter and bTag
    end

    tbSelectTag = {}
    for nKey, v in pairs(self.tbFilter[AllEnum.ChooseOption.Equip_AffiliatedForces]) do
        if v then
            tbSelectTag[nKey] = 1
        end
    end
    if next(tbSelectTag) ~= nil then
        bTag = false
        for _, tag in ipairs(tbTag) do
            if tbSelectTag[tag] ~= nil then
                bTag = true
                break
            end
        end
        isFilter = isFilter and bTag
    end

    ---equip match
    if nCharId ~= nil then
        local nMatchCount = equipmentData:GetTagMatchCount(nCharId)
        isFilter = isFilter and self:_GetFilterByKey(AllEnum.ChooseOption.Equip_Match, nMatchCount)
    end
    
    return isFilter
end

function FilterData:_GetFilterByKey(fKey,sKey)
    --1.先判断是否 全部未选
    local isAllFalse = false
    for optionKey, _ in pairs(self.tbFilter[fKey]) do
        isAllFalse = isAllFalse or self.tbFilter[fKey][optionKey]
    end
    if not isAllFalse then
        return true
    end
    --2.再进行通用判断
    --print(self.tbFilter[fKey][sKey])
    return self.tbFilter[fKey][sKey];
end

function FilterData:GetFilterByKey(fKey,sKey)
    return self.tbFilter[fKey][sKey];
end
--@param fKey 一级key
--@param sKey 二级key
--这里是temp数据的操作，Cache，当确认后 SyncFilterByCache
function FilterData:SetCacheFilterByKey(fKey,sKey,flag)
    --self.tbFilter[fKey][sKey] = flag;
    if self.tbCacheFilter[fKey] == nil then
        self.tbCacheFilter[fKey] = {}
    end
    self.tbCacheFilter[fKey][sKey] = flag;
end
--将cache 同步更新
function FilterData:SyncFilterByCache()
    for fKey, v in pairs(self.tbCacheFilter) do
        for sKey, vv in pairs(v) do
            self.tbFilter[fKey][sKey] = vv
        end
    end
end
function FilterData:GetCacheFilterByKey(fKey,sKey)
    if nil ~= self.tbCacheFilter[fKey] and nil ~= self.tbCacheFilter[fKey][sKey] then
        return self.tbCacheFilter[fKey][sKey], true
    end
    return self:GetFilterByKey(fKey,sKey), false
end
--sort
function FilterData:CacheCharSort(nType,bOrder)
    self.nFormationCharSrotType = nType
    self.bFormationCharOrder = bOrder

    LocalData.SetPlayerLocalData("FormationCharSrotType", self.nFormationCharSrotType)
    LocalData.SetPlayerLocalData("FormationCharOrder", self.bFormationCharOrder)
end
function FilterData:CacheDiscSort(nType,bOrder)
    self.nFormationDiscSrotType = nType
    self.bFormationDiscOrder = bOrder

    LocalData.SetPlayerLocalData("FormationDiscSrotType", self.nFormationDiscSrotType)
    LocalData.SetPlayerLocalData("FormationDiscOrder", self.bFormationDiscOrder)
end
function FilterData:InitSortData()
    self.nFormationCharSrotType = AllEnum.SortType.Level
    self.bFormationCharOrder = false

    self.nFormationDiscSrotType = AllEnum.SortType.Level
    self.bFormationDiscOrder = false


    self.nFormationCharSrotType = LocalData.GetPlayerLocalData("FormationCharSrotType") or AllEnum.SortType.Level
    self.bFormationCharOrder = LocalData.GetPlayerLocalData("FormationCharOrder") or false

    self.nFormationDiscSrotType = LocalData.GetPlayerLocalData("FormationDiscSrotType") or AllEnum.SortType.Level
    self.bFormationDiscOrder = LocalData.GetPlayerLocalData("FormationDiscOrder") or false
end
return FilterData