local TemplateItemCtrl = class("TemplateItemCtrl", BaseCtrl)
local LayoutRebuilder = ((CS.UnityEngine).UI).LayoutRebuilder
local _, Gray = (ColorUtility.TryParseHtmlString)("#5E89B4")
TemplateItemCtrl._mapNodeConfig = {
imgRare = {sComponentName = "Image"}
, 
imgIcon = {sComponentName = "Image"}
, 
Basic = {sNodeName = "--Basic--"}
, 
Item = {sNodeName = "--Item--"}
, 
Char = {sNodeName = "--Char--"}
, 
imgTimeLimit = {}
, 
imgBasicCharIcon = {sComponentName = "Image"}
, 
imgCharRare = {sComponentName = "Image"}
, 
imgTimeBg = {}
, 
rtImgTimeBg = {sNodeName = "imgTimeBg", sComponentName = "RectTransform"}
, 
imgTime = {nCount = 3}
, 
txtItemTime = {sComponentName = "TMP_Text"}
, 
goStar = {sCtrlName = "Game.UI.TemplateEx.TemplateStarCtrl"}
, 
Select = {}
, 
imgMultiSelected1 = {}
, 
imgMultiSelected2 = {}
, 
imgMultiSelectedMask1 = {}
, 
imgMultiSelectedMask2 = {}
, 
imgCharIcon = {sComponentName = "Image"}
, 
goReceived = {}
, 
txtReceived = {sComponentName = "TMP_Text", sLanguageId = "RogueBoss_Receive_Tip"}
, 
txtCount = {sComponentName = "TMP_Text"}
, 
txtX = {sComponentName = "TMP_Text"}
, 
imgFirstPass = {}
, 
imgThreePass = {}
, 
imgExtra = {}
, 
imgElement = {sComponentName = "Image"}
}
TemplateItemCtrl._mapEventConfig = {}
TemplateItemCtrl.SetItem = function(self, nItemId, nRarity, nCount, nExpire, bReceived, bFirstPass, bThreePass, bFullShow, bMat, bHideTime, bExtraDrop)
  -- function num : 0_0 , upvalues : _ENV
  local nStar = 0
  do
    if nItemId and nItemId ~= 0 then
      local mapCfg = (ConfigTable.GetData_Item)(nItemId)
      if mapCfg == nil then
        printError("Item CfgData Missing:" .. nItemId)
      end
      if mapCfg.Type == (GameEnum.itemType).Char then
        self:SetChar(nItemId, nCount, bReceived)
        return 
      end
      if mapCfg.Type == (GameEnum.itemType).Disc then
        nStar = 6 - mapCfg.Rarity
      end
    end
    self:_SwitchType((GameEnum.itemType).Item)
    self:_SetCommon(nItemId, nRarity, 0, nStar, nil, nExpire, bReceived, bHideTime)
    self:_SetCount(nCount, bFullShow, bMat)
    self:_SetPassState(bFirstPass, bThreePass, bExtraDrop)
  end
end

TemplateItemCtrl.SetChar = function(self, nItemId, nCount, bReceived, nRewardType)
  -- function num : 0_1 , upvalues : _ENV
  self:_SwitchType((GameEnum.itemType).Char)
  local itemCfg = (ConfigTable.GetData_Item)(nItemId)
  local nMaxStar = 6 - itemCfg.Rarity
  self:SetAtlasSprite((self._mapNode).imgCharRare, "12_rare", (AllEnum.FrameType_New).Item .. (AllEnum.FrameColor_New)[itemCfg.Rarity])
  self:_SetCommon(nItemId, nil, 0, nMaxStar, nil, nil, bReceived)
  if nCount and nCount > 1 then
    self:_SetCount(nCount)
  else
    self:_SetCount()
  end
  self:_SetPassState(not nRewardType or nRewardType == (AllEnum.RewardType).First, not nRewardType or nRewardType == (AllEnum.RewardType).Three, false)
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

TemplateItemCtrl.SetSelect = function(self, bSelect)
  -- function num : 0_2
  ((self._mapNode).Select):SetActive(bSelect)
end

TemplateItemCtrl.SetMultiSelected_Blue = function(self, bSelect)
  -- function num : 0_3
  ((self._mapNode).imgMultiSelected1):SetActive(bSelect)
  ;
  ((self._mapNode).imgMultiSelectedMask1):SetActive(bSelect)
end

TemplateItemCtrl.SetMultiSelected_Red = function(self, bSelect)
  -- function num : 0_4
  ((self._mapNode).imgMultiSelected2):SetActive(bSelect)
  ;
  ((self._mapNode).imgMultiSelectedMask2):SetActive(bSelect)
end

TemplateItemCtrl.SetLock = function(self, bLock)
  -- function num : 0_5
end

TemplateItemCtrl._SetChar = function(self, nCharId)
  -- function num : 0_6 , upvalues : _ENV
  if nCharId and nCharId ~= 0 then
    (((self._mapNode).imgCharIcon).gameObject):SetActive(true)
    local nCharSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
    local mapCharSkin = (ConfigTable.GetData_CharacterSkin)(nCharSkinId)
    self:SetPngSprite((self._mapNode).imgCharIcon, mapCharSkin.Icon .. (AllEnum.CharHeadIconSurfix).S)
  else
    do
      ;
      (((self._mapNode).imgCharIcon).gameObject):SetActive(false)
    end
  end
end

TemplateItemCtrl._SetCommon = function(self, nItemId, nRarity, nStar, nMaxStar, nCharId, nExpire, bReceived, bHideTime)
  -- function num : 0_7 , upvalues : _ENV, LayoutRebuilder
  self:_SetChar(nCharId)
  ;
  ((self._mapNode).Select):SetActive(false)
  ;
  ((self._mapNode).imgMultiSelected1):SetActive(false)
  ;
  ((self._mapNode).imgMultiSelectedMask1):SetActive(false)
  ;
  ((self._mapNode).imgMultiSelected2):SetActive(false)
  ;
  ((self._mapNode).imgMultiSelectedMask2):SetActive(false)
  ;
  ((self._mapNode).goStar):SetStar(nStar, nMaxStar)
  ;
  ((self._mapNode).goReceived):SetActive(bReceived)
  ;
  (((self._mapNode).imgTimeLimit).gameObject):SetActive(false)
  if not nItemId or nItemId == 0 then
    (((self._mapNode).imgIcon).gameObject):SetActive(false)
    self:SetAtlasSprite((self._mapNode).imgRare, "12_rare", (AllEnum.FrameType_New).Item .. (AllEnum.FrameColor_New)[0])
    ;
    ((self._mapNode).imgTimeBg):SetActive(false)
    return 
  end
  local mapCfg = (ConfigTable.GetData_Item)(nItemId)
  ;
  (((self._mapNode).imgIcon).gameObject):SetActive(true)
  if mapCfg.Type == (GameEnum.itemType).Disc then
    self:SetPngSprite((self._mapNode).imgIcon, mapCfg.Icon .. (AllEnum.OutfitIconSurfix).Item)
    local mapDiscCfgData = (ConfigTable.GetData)("Disc", nItemId)
    if mapDiscCfgData ~= nil then
      self:SetAtlasSprite((self._mapNode).imgElement, "12_rare", ((AllEnum.Star_Element)[mapDiscCfgData.EET]).icon)
      ;
      (((self._mapNode).imgElement).gameObject):SetActive(true)
    end
  else
    do
      if mapCfg.Type == (GameEnum.itemType).Char then
        self:SetPngSprite((self._mapNode).imgBasicCharIcon, mapCfg.Icon)
        local mapCharCfgData = (ConfigTable.GetData)("Character", nItemId)
        if mapCharCfgData ~= nil then
          self:SetAtlasSprite((self._mapNode).imgElement, "12_rare", ((AllEnum.Char_Element)[mapCharCfgData.EET]).icon)
          ;
          (((self._mapNode).imgElement).gameObject):SetActive(true)
        end
      else
        do
          self:SetPngSprite((self._mapNode).imgIcon, mapCfg.Icon)
          ;
          (((self._mapNode).imgElement).gameObject):SetActive(false)
          if not nRarity and nItemId then
            nRarity = mapCfg.Rarity
          end
          local sPath = (AllEnum.FrameType_New).Item .. (AllEnum.FrameColor_New)[nRarity]
          self:SetAtlasSprite((self._mapNode).imgRare, "12_rare", sPath)
          local nTimeType = nil
          local sTimeStr = ""
          if nExpire and nExpire ~= 0 then
            local curTime = ((CS.ClientManager).Instance).serverTimeStamp
            local remainTime = nExpire - curTime
            if remainTime >= 86400 then
              sTimeStr = (math.floor)(remainTime / 86400) .. (ConfigTable.GetUIText)("Depot_Item_LeftTime_Day")
              nTimeType = 1
            else
              if remainTime >= 3600 then
                sTimeStr = (math.floor)(remainTime / 3600) .. (ConfigTable.GetUIText)("Depot_Item_LeftTime_Hour")
                nTimeType = 2
              else
                local nMin = (math.max)((math.floor)(remainTime / 60), 1)
                sTimeStr = nMin .. (ConfigTable.GetUIText)("Depot_LeftTime_Min")
                nTimeType = 3
              end
            end
          end
          do
            ;
            ((self._mapNode).imgTimeBg):SetActive(nTimeType ~= nil)
            if nTimeType then
              (NovaAPI.SetTMPText)((self._mapNode).txtItemTime, sTimeStr)
              ;
              (LayoutRebuilder.ForceRebuildLayoutImmediate)((self._mapNode).rtImgTimeBg)
              for i = 1, 3 do
                (((self._mapNode).imgTime)[i]):SetActive(i == nTimeType)
              end
            end
            ;
            (((self._mapNode).imgTimeLimit).gameObject):SetActive(mapCfg and ((mapCfg.ExpireType ~= 0 and nTimeType == nil and not bHideTime)))
            -- DECOMPILER ERROR: 5 unprocessed JMP targets
          end
        end
      end
    end
  end
end

TemplateItemCtrl._SetCount = function(self, nCount, bFullShow, bMat)
  -- function num : 0_8 , upvalues : _ENV, Gray
  if nCount and type(nCount) == "string" and nCount ~= "" then
    (NovaAPI.SetTMPText)((self._mapNode).txtCount, nCount)
    ;
    (NovaAPI.SetTMPColor)((self._mapNode).txtCount, Blue_Normal)
    ;
    (NovaAPI.SetTMPColor)((self._mapNode).txtX, Blue_Normal)
    ;
    (((self._mapNode).txtX).gameObject):SetActive(true)
    ;
    (((self._mapNode).txtCount).gameObject):SetActive(true)
  else
    if nCount and nCount > 1 then
      if nCount > 999999 then
        local nFloor = (math.floor)(nCount / 100)
        local nK = (string.format)("%.0f", nFloor / 10)
        local sCount = nK .. "k"
        ;
        (NovaAPI.SetTMPText)((self._mapNode).txtCount, sCount)
      else
        do
          ;
          (NovaAPI.SetTMPText)((self._mapNode).txtCount, nCount)
          ;
          (NovaAPI.SetTMPColor)((self._mapNode).txtCount, Blue_Normal)
          ;
          (NovaAPI.SetTMPColor)((self._mapNode).txtX, Blue_Normal)
          ;
          (((self._mapNode).txtX).gameObject):SetActive(true)
          ;
          (((self._mapNode).txtCount).gameObject):SetActive(true)
          if nCount and nCount == 0 then
            (NovaAPI.SetTMPText)((self._mapNode).txtCount, nCount)
            ;
            (NovaAPI.SetTMPColor)((self._mapNode).txtCount, Gray)
            ;
            (NovaAPI.SetTMPColor)((self._mapNode).txtX, Gray)
            ;
            (((self._mapNode).txtX).gameObject):SetActive(true)
            ;
            (((self._mapNode).txtCount).gameObject):SetActive(true)
          else
            if nCount and nCount == 1 then
              (NovaAPI.SetTMPText)((self._mapNode).txtCount, nCount)
              if bMat then
                (NovaAPI.SetTMPColor)((self._mapNode).txtCount, Blue_Normal)
                ;
                (NovaAPI.SetTMPColor)((self._mapNode).txtX, Blue_Normal)
              end
              ;
              (((self._mapNode).txtX).gameObject):SetActive(true)
              ;
              (((self._mapNode).txtCount).gameObject):SetActive(true)
            else
              ;
              (NovaAPI.SetTMPText)((self._mapNode).txtCount, "")
              ;
              (((self._mapNode).txtX).gameObject):SetActive(false)
              ;
              (((self._mapNode).txtCount).gameObject):SetActive(false)
            end
          end
        end
      end
    end
  end
end

TemplateItemCtrl._SetPassState = function(self, bFirstPass, bThreePass, bExtraDrop)
  -- function num : 0_9
  ((self._mapNode).imgFirstPass):SetActive(bFirstPass)
  ;
  ((self._mapNode).imgThreePass):SetActive(bThreePass)
  ;
  ((self._mapNode).imgExtra):SetActive(bExtraDrop)
end

TemplateItemCtrl._SwitchType = function(self, enumType)
  -- function num : 0_10 , upvalues : _ENV
  ((self._mapNode).Item):SetActive(enumType == (GameEnum.itemType).Item)
  ;
  ((self._mapNode).Char):SetActive(enumType == (GameEnum.itemType).Char)
  ;
  ((self._mapNode).Basic):SetActive(enumType ~= (GameEnum.itemType).Char)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

return TemplateItemCtrl

