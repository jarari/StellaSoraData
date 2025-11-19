local Actor2DManager = {}
local Offset = CS.Actor2DOffsetData
local ConfigActor2DInPanel = CS.ConfigActor2DInPanel
local Path = require("path")
local RT_SUB_SKILL_SHOW = false
local sRootPath = Settings.AB_ROOT_PATH
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local LocalSettingData = require("GameCore.Data.LocalSettingData")
local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local ResTypeAny = (GameResourceLoader.ResType).Any
local typeof = typeof
local TN = (AllEnum.Actor2DType).Normal
local TF = (AllEnum.Actor2DType).FullScreen
local RapidJson = require("rapidjson")
local Actor_Node_Path = (string.format)("%sUI/CommonEx/Template/----Actor2D_Node----.prefab", Settings.AB_ROOT_PATH)
local L2DType = {None = 0, Char = 1, Disc = 2, CG = 3}
local mapPanelConfig = {}
local CacheActor2DInPanelConfig = function()
  -- function num : 0_0 , upvalues : GameResourceLoader, ResTypeAny, typeof, ConfigActor2DInPanel, mapPanelConfig, _ENV
  local assetConfig = (GameResourceLoader.LoadAsset)(ResTypeAny, "Assets/AssetBundles/UI/CommonEx/Preference/Actor2DInPanel.asset", typeof(ConfigActor2DInPanel))
  local nLen = (assetConfig.arrData).Length - 1
  for i = 0, nLen do
    local data = (assetConfig.arrData)[i]
    local nPanelId = assetConfig:GetPanelId(i)
    local nReusePanelId = assetConfig:GetReusePanelId(i)
    local nL2DType = assetConfig:GetL2DType(i)
    if nPanelId >= 0 and nReusePanelId >= 0 and nL2DType >= 0 then
      mapPanelConfig[nPanelId] = {nReuse = nReusePanelId, v3PanelOffset = data.Offset, bL2D = data.PreferL2D, bHalf = data.PreferHalf, nType = nL2DType, bAutoAdjust = data.AutoAdjust, bSpBg = data.PreferActorBg, bHistoryType = data.HistoryType, sBg = data.UIBgName, bNoExSkin = data.NoExSkin}
    else
      printError("ConfigActor2DInPanel data error, index:" .. tostring(i) .. "," .. tostring(nPanelId) .. "," .. tostring(nReusePanelId) .. "," .. tostring(nL2DType))
    end
  end
end

local mapActor2DType = {}
local LoadLocalData = function()
  -- function num : 0_1 , upvalues : LocalData, _ENV, mapActor2DType
  local sJson = (LocalData.GetPlayerLocalData)("CharActor2DType")
  local tb = decodeJson(sJson)
  if type(tb) == "table" then
    mapActor2DType = tb
    mapActor2DType["1"] = true
  end
end

local SaveLocalData = function()
  -- function num : 0_2 , upvalues : RapidJson, mapActor2DType, LocalData
  local sJson = (RapidJson.encode)(mapActor2DType)
  ;
  (LocalData.SetPlayerLocalData)("CharActor2DType", sJson)
end

local GetActor2DType = function(nCharId, nPanelId, nDefaultType, bHistoryType, nSpecifyType)
  -- function num : 0_3 , upvalues : _ENV, mapActor2DType, SaveLocalData
  if bHistoryType ~= true then
    if nSpecifyType then
      return nSpecifyType
    end
    return nDefaultType
  end
  local nType = nil
  local sMainKey = tostring(nCharId)
  local sSubKey = tostring(nPanelId)
  local mapData = mapActor2DType[sMainKey]
  if mapData == nil then
    mapActor2DType[sMainKey] = {}
    mapData = mapActor2DType[sMainKey]
  end
  nType = mapData[sSubKey]
  if nType == nil then
    nType = nDefaultType
    mapData[sSubKey] = nType
    SaveLocalData()
  end
  if nSpecifyType then
    nType = nSpecifyType
  end
  return nType
end

local SaveActor2DType = function(nCharId, nPanelId, nType)
  -- function num : 0_4 , upvalues : mapActor2DType, _ENV, SaveLocalData
  if not mapActor2DType[tostring(nCharId)] then
    local mapData = {}
  end
  mapData[tostring(nPanelId)] = nType
  mapActor2DType[tostring(nCharId)] = mapData
  SaveLocalData()
end

local CheckL2DType = function(nCharId, nSkinId, nType, bAutoAdjust)
  -- function num : 0_5 , upvalues : TN, _ENV, TF
  if nType == TN then
    return true, TN
  else
    local skin_data = (PlayerData.CharSkin):GetSkinDataBySkinId(nSkinId)
    if skin_data == nil then
      if bAutoAdjust == true then
        return false, TN
      else
        return false, TF
      end
    else
      local bAvailable = skin_data:CheckFavorCG()
      if bAvailable == true then
        return true, TF
      else
        if bAutoAdjust == true then
          return false, TN
        else
          return false, TF
        end
      end
    end
  end
end

local GetFullSceneAssetPath = function(nCGId, bL2D)
  -- function num : 0_6 , upvalues : _ENV
  local cfgData = (ConfigTable.GetData)("CharacterCG", nCGId)
  if cfgData == nil then
    printError((string.format)("读取CharacterCG配置失败！！！id = [%s]", nCGId))
  else
    if bL2D then
      return cfgData.FullScreenL2D
    else
      return cfgData.FullScreenPortrait
    end
  end
end

local CheckNoExSkin = function(mapPanelCfg, mapSkinData)
  -- function num : 0_7 , upvalues : _ENV
  do
    if mapPanelCfg.bNoExSkin == true and mapSkinData.Type == (GameEnum.skinType).ADVANCE then
      local mapChar = (ConfigTable.GetData_Character)(mapSkinData.CharId)
      if mapChar ~= nil then
        mapSkinData = (ConfigTable.GetData_CharacterSkin)(mapChar.DefaultSkinId)
      end
    end
    return mapSkinData
  end
end

local GetAssetPath = function(mapData, bL2D, nType)
  -- function num : 0_8 , upvalues : TN, TF, GetFullSceneAssetPath
  if bL2D == true then
    if nType == TN then
      return mapData.L2D
    else
      if nType == TF then
        return GetFullSceneAssetPath(mapData.CharacterCG, bL2D)
      end
    end
  else
    if nType == TN then
      return mapData.Portrait
    else
      if nType == TF then
        return GetFullSceneAssetPath(mapData.CharacterCG, bL2D)
      end
    end
  end
end

local LoadAsset = function(sPath, t)
  -- function num : 0_9 , upvalues : GameResourceLoader, ResTypeAny, _ENV, typeof
  return (GameResourceLoader.LoadAsset)(ResTypeAny, Settings.AB_ROOT_PATH .. sPath, typeof(t))
end

local LoadSprite = function(sPath, sName, bDisc)
  -- function num : 0_10 , upvalues : _ENV, Path, LoadAsset, typeof
  local _sPath = sPath
  if bDisc then
    _sPath = (string.format)("%s.png", sPath)
  else
    _sPath = (string.format)("%s/atlas_png/a/%s.png", (Path.dirname)(sPath), sName)
  end
  return LoadAsset(_sPath, typeof(Sprite))
end

local LoadImage = function(sPath)
  -- function num : 0_11 , upvalues : GameResourceLoader, ResTypeAny, _ENV, typeof
  return (GameResourceLoader.LoadAsset)(ResTypeAny, Settings.AB_ROOT_PATH .. sPath, typeof(Sprite))
end

local mapOffsetAsset = {}
local GetOffset = function(sOffset)
  -- function num : 0_12 , upvalues : mapOffsetAsset, LoadAsset, Offset
  local objOffsetAsset = mapOffsetAsset[sOffset]
  if objOffsetAsset == nil then
    objOffsetAsset = LoadAsset(sOffset, Offset)
    mapOffsetAsset[sOffset] = objOffsetAsset
  end
  return objOffsetAsset
end

local GetTargetPosScale = function(sOffset, sPose, nPanelId, bFull, b100)
  -- function num : 0_13 , upvalues : GetOffset, _ENV
  local objOffset = GetOffset(sOffset)
  local nX, nY = 0, 0
  local s, x, y = objOffset:GetOffsetData(nPanelId, indexOfPose(sPose), bFull ~= true, nX, nY)
  if b100 == true then
    x = x * 100
    y = y * 100
  end
  local v3Pos = Vector3(x, y, 0)
  local v3Scale = Vector3(s, s, 1)
  do return v3Pos, v3Scale end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

local SetRelativeL2DPoseScale = function(tr, sOffset)
  -- function num : 0_14 , upvalues : GetOffset, _ENV
  local objOffset = GetOffset(sOffset)
  local nX, nY = 0, 0
  local s, x, y = objOffset:GetL2DData(nX, nY)
  if s <= 0 then
    x = 0
  end
  tr.localPosition = Vector3(x, y, 0)
  tr.localScale = Vector3(s, s, 1)
end

local SetPanelOffset = function(tbRenderer, nPanelId)
  -- function num : 0_15 , upvalues : _ENV, mapPanelConfig
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R2 in 'UnsetPending'

  if nPanelId == nil then
    (tbRenderer.trPanelOffset).localPosition = Vector3.zero
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (tbRenderer.trPanelOffset).localScale = Vector3.one
  else
    local data = mapPanelConfig[nPanelId]
    if data ~= nil then
      local x, y, s = 0, 0, 1
      if data.nReuse > 0 then
        x = (data.v3PanelOffset).x
        y = (data.v3PanelOffset).y
        s = (data.v3PanelOffset).z
      end
      if s <= 0 then
        s = 1
      end
      -- DECOMPILER ERROR at PC35: Confused about usage of register: R6 in 'UnsetPending'

      ;
      (tbRenderer.trPanelOffset).localPosition = Vector3(x, y, 0)
      -- DECOMPILER ERROR at PC42: Confused about usage of register: R6 in 'UnsetPending'

      ;
      (tbRenderer.trPanelOffset).localScale = Vector3(s, s, 1)
    end
  end
end

local mapL2DPrefab = {}
local GetL2DPrefab = function(sL2D)
  -- function num : 0_16 , upvalues : mapL2DPrefab, LoadAsset, _ENV
  local objL2DPrefab = mapL2DPrefab[sL2D]
  if objL2DPrefab == nil then
    objL2DPrefab = LoadAsset(sL2D, Object)
    mapL2DPrefab[sL2D] = objL2DPrefab
  end
  return objL2DPrefab
end

local mapSprite = {}
local GetSprite = function(sPortrait, sName, bDisc)
  -- function num : 0_17 , upvalues : mapSprite, LoadSprite
  local sprite = nil
  local map = mapSprite[sPortrait]
  if map == nil then
    map = {}
    sprite = LoadSprite(sPortrait, sName, bDisc)
    map[sName] = sprite
    mapSprite[sPortrait] = map
  else
    sprite = map[sName]
    if sprite == nil then
      sprite = LoadSprite(sPortrait, sName, bDisc)
      map[sName] = sprite
    end
  end
  return sprite
end

local mapBg = {}
local GetBg = function(sBg)
  -- function num : 0_18 , upvalues : mapBg, LoadImage
  local sprite = mapBg[sBg]
  if sprite == nil then
    sprite = LoadImage(sBg)
    mapBg[sBg] = sprite
  end
  return sprite
end

local GetUIDefaultBgName = function(sUIDefaultBg)
  -- function num : 0_19 , upvalues : _ENV
  if type(sUIDefaultBg) == "string" and sUIDefaultBg ~= "" then
    return (string.format)("Image/UIBG/%s.png", sUIDefaultBg)
  else
    return nil
  end
end

local Init_RT = function(tbRenderer)
  -- function num : 0_20 , upvalues : RT_SUB_SKILL_SHOW, _ENV
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

  if tbRenderer._RenderTexture == nil then
    if RT_SUB_SKILL_SHOW == true then
      (tbRenderer._cam).orthographicSize = 10.24
      local nW = (math.floor)(2048 * Settings.RENDERTEXTURE_SIZE_FACTOR)
      local nH = (math.floor)(2048 * Settings.RENDERTEXTURE_SIZE_FACTOR)
      tbRenderer._RenderTexture = (GameUIUtils.GenerateRenderTextureFor2D)(nW, nH)
      -- DECOMPILER ERROR at PC27: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (tbRenderer._RenderTexture).name = "Actor2DMgr(Init_RT)(SUB_SKILL_SHOW)"
      -- DECOMPILER ERROR at PC30: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (tbRenderer._cam).targetTexture = tbRenderer._RenderTexture
    else
      do
        -- DECOMPILER ERROR at PC36: Confused about usage of register: R1 in 'UnsetPending'

        ;
        (tbRenderer._cam).orthographicSize = Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT / 200
        local nW = (math.floor)(Settings.CURRENT_CANVAS_FULL_RECT_WIDTH * Settings.RENDERTEXTURE_SIZE_FACTOR)
        local nH = (math.floor)(Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT * Settings.RENDERTEXTURE_SIZE_FACTOR)
        tbRenderer._RenderTexture = (GameUIUtils.GenerateRenderTextureFor2D)(nW, nH)
        -- DECOMPILER ERROR at PC60: Confused about usage of register: R3 in 'UnsetPending'

        ;
        (tbRenderer._RenderTexture).name = "Actor2DMgr(Init_RT)"
        -- DECOMPILER ERROR at PC63: Confused about usage of register: R3 in 'UnsetPending'

        ;
        (tbRenderer._cam).targetTexture = tbRenderer._RenderTexture
      end
    end
  end
end

local UnInit_RT = function(tbRenderer)
  -- function num : 0_21 , upvalues : _ENV
  if tbRenderer._targetRawImage ~= nil then
    (NovaAPI.SetTexture)(tbRenderer._targetRawImage, nil)
    tbRenderer._targetRawImage = nil
  end
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

  if tbRenderer._cam ~= nil then
    (tbRenderer._cam).targetTexture = nil
  end
  if tbRenderer._RenderTexture ~= nil then
    (GameUIUtils.ReleaseRenderTexture)(tbRenderer._RenderTexture)
    tbRenderer._RenderTexture = nil
  end
  if tbRenderer._RenderTextureAvg ~= nil then
    (GameUIUtils.ReleaseRenderTexture)(tbRenderer._RenderTextureAvg)
    tbRenderer._RenderTextureAvg = nil
  end
end

local Set_RawImg = function(tbRenderer, rawImg)
  -- function num : 0_22 , upvalues : Init_RT, _ENV, RT_SUB_SKILL_SHOW
  Init_RT(tbRenderer)
  if rawImg ~= tbRenderer._targetRawImage then
    if tbRenderer._targetRawImage ~= nil then
      (NovaAPI.SetTexture)(tbRenderer._targetRawImage, nil)
    end
    tbRenderer._targetRawImage = rawImg
    ;
    (NovaAPI.SetTexture)(tbRenderer._targetRawImage, tbRenderer._RenderTexture)
    if RT_SUB_SKILL_SHOW then
      (((tbRenderer._targetRawImage).gameObject):GetComponent("RectTransform")).sizeDelta = Vector2(2048, 2048)
    else
      ;
      (((tbRenderer._targetRawImage).gameObject):GetComponent("RectTransform")).sizeDelta = Vector2(Settings.CURRENT_CANVAS_FULL_RECT_WIDTH, Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT)
    end
  end
  -- DECOMPILER ERROR at PC49: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (tbRenderer._tr).localScale = Vector3.one
  ;
  ((tbRenderer._cam).gameObject):SetActive(true)
end

local UnSet_RawImg = function(tbRenderer)
  -- function num : 0_23 , upvalues : _ENV
  if tbRenderer._targetRawImage ~= nil then
    (NovaAPI.SetTexture)(tbRenderer._targetRawImage, nil)
    tbRenderer._targetRawImage = nil
  end
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (tbRenderer._tr).localScale = Vector3.zero
  ;
  ((tbRenderer._cam).gameObject):SetActive(false)
end

local MAX_L2D_INS_COUNT = 5
local MAX_L2D_RENDERER_COUNT = 3
local trL2DInsRoot, trL2DRendererRoot = nil, nil
local tbL2DRenderer = {}
local nDuration = 0.5
local mapPlayedCG = {}
local mapCurrent = {
tbChar = {}
, nPanelId = 0, nOffsetPanelId = 0, nActor2DType = 0, bUseL2D = false, bUseFull = false, 
tbDisc = {}
, 
tbCg = {}
, L2DType = L2DType.None}
local GetL2DRendererStructure = function(trRenderer)
  -- function num : 0_24 , upvalues : _ENV
  local LayerMask = (CS.UnityEngine).LayerMask
  local tb = {}
  tb._tr = trRenderer
  tb._cam = (trRenderer:GetChild(0)):GetComponent("Camera")
  tb._RenderTexture = nil
  tb._RenderTextureAvg = nil
  tb._targetRawImage = nil
  tb.spr_bg = (trRenderer:Find("customized_bg")):GetComponent("SpriteRenderer")
  tb.animator = trRenderer:Find("animator")
  tb.animatorCtrl = (tb.animator):GetComponent("Animator")
  tb.trPanelOffset = trRenderer:Find("animator/panel_offset")
  tb.trFreeDrag = trRenderer:Find("animator/panel_offset/free_drag")
  tb.trOffset = trRenderer:Find("animator/panel_offset/free_drag/actor_offset")
  tb.parent_L2D = trRenderer:Find("animator/panel_offset/free_drag/actor_offset/L2D")
  tb.parent_PNG = trRenderer:Find("animator/panel_offset/free_drag/actor_offset/PNG")
  tb.trEmojiRoot = trRenderer:Find("animator/panel_offset/free_drag/----emoji----/emoji_root")
  tb.spr_body = (trRenderer:Find("animator/panel_offset/free_drag/actor_offset/PNG/sp_body")):GetComponent("SpriteRenderer")
  tb.spr_face = (trRenderer:Find("animator/panel_offset/free_drag/actor_offset/PNG/sp_face")):GetComponent("SpriteRenderer")
  tb.sL2D = nil
  tb.trL2DIns = nil
  tb.nLayerIndex = (LayerMask.NameToLayer)("Cam_Layer_4")
  return tb
end

local GetL2DIns = function(sL2D)
  -- function num : 0_25 , upvalues : trL2DInsRoot, GetL2DPrefab, _ENV, MAX_L2D_INS_COUNT
  local trIns = nil
  if trL2DInsRoot == nil then
    return 
  end
  local nChildCount = trL2DInsRoot.childCount - 1
  for i = 0, nChildCount do
    local trChild = trL2DInsRoot:GetChild(i)
    if trChild.name == sL2D then
      trIns = trChild
      break
    end
  end
  do
    if trIns ~= nil and trIns:IsNull() == false then
      return trIns, false
    else
      local objPrefab = GetL2DPrefab(sL2D)
      if objPrefab == nil then
        return nil, false
      end
      local goIns = instantiate(objPrefab, trL2DInsRoot)
      goIns.name = sL2D
      trIns = goIns.transform
      if MAX_L2D_INS_COUNT < trL2DInsRoot.childCount then
        destroyImmediate((trL2DInsRoot:GetChild(0)).gameObject)
      end
      return trIns, true
    end
  end
end

local SetL2DInsParent = function(trIns, trParent)
  -- function num : 0_26 , upvalues : _ENV
  if trIns == nil then
    return 
  end
  trIns:SetParent(trParent)
  trIns.localPosition = Vector3.zero
  trIns.localScale = Vector3.one
end

local ResetRenderer = function(tbRenderer)
  -- function num : 0_27 , upvalues : UnSet_RawImg, UnInit_RT, SetL2DInsParent, trL2DInsRoot, SetPanelOffset, _ENV, Actor2DManager
  UnSet_RawImg(tbRenderer)
  UnInit_RT(tbRenderer)
  if tbRenderer.trL2DIns ~= nil then
    SetL2DInsParent(tbRenderer.trL2DIns, trL2DInsRoot)
    tbRenderer.trL2DIns = nil
  end
  tbRenderer.sL2D = nil
  SetPanelOffset(tbRenderer)
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localPosition = Vector3.zero
  -- DECOMPILER ERROR at PC25: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localScale = Vector3.one
  ;
  (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_body, nil)
  ;
  (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_face, nil)
  ;
  (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_bg, nil)
  -- DECOMPILER ERROR at PC44: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (tbRenderer.parent_L2D).localScale = Vector3.zero
  -- DECOMPILER ERROR at PC48: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (tbRenderer.parent_PNG).localScale = Vector3.zero
  ;
  (Actor2DManager.ResetActor2DAnim)(tbRenderer)
end

local GetRenderer = function(sL2D, bForceMatch, nIndex)
  -- function num : 0_28 , upvalues : _ENV, tbL2DRenderer
  local tbRenderer = nil
  for i,v in ipairs(tbL2DRenderer) do
    -- DECOMPILER ERROR at PC10: Unhandled construct in 'MakeBoolean' P1

    if bForceMatch == true and v.sL2D == sL2D then
      tbRenderer = v
      break
    end
    -- DECOMPILER ERROR at PC21: Unhandled construct in 'MakeBoolean' P1

    if nIndex == nil and (v.sL2D == sL2D or v.sL2D == nil) then
      tbRenderer = v
      break
    end
    if v.sL2D == sL2D or v.sL2D == nil and i == nIndex then
      tbRenderer = v
      break
    end
  end
  do
    return tbRenderer
  end
end

local SetL2D = function(sL2D, sOffset, rawImg, nCurPanelId, nReusePanelId, nType, bFull, sBg, tbRenderer)
  -- function num : 0_29 , upvalues : GetL2DIns, _ENV, TN, SetRelativeL2DPoseScale, SetL2DInsParent, TF, SetPanelOffset, GetTargetPosScale, nDuration, GetBg, Set_RawImg
  if tbRenderer == nil then
    return 
  end
  local bPlaySwitchAnim = true
  if tbRenderer.sL2D == nil then
    bPlaySwitchAnim = false
    local trIns, bIsNew = GetL2DIns(sL2D)
    if trIns == nil then
      printError("未找到根节点")
    end
    tbRenderer.sL2D = sL2D
    tbRenderer.trL2DIns = trIns
    if bIsNew == true then
      if nType == TN then
        SetRelativeL2DPoseScale(trIns:Find("root"), sOffset)
      end
      trIns:SetLayerRecursively(tbRenderer.nLayerIndex)
    end
    SetL2DInsParent(trIns, tbRenderer.parent_L2D)
  end
  do
    local v3TargetLocalPos = Vector3(0, 0, 0)
    local v3TargetLocalScale = Vector3.one
    if nType == TF then
      SetPanelOffset(tbRenderer)
      -- DECOMPILER ERROR at PC50: Confused about usage of register: R12 in 'UnsetPending'

      ;
      (tbRenderer.trOffset).localPosition = v3TargetLocalPos
      -- DECOMPILER ERROR at PC52: Confused about usage of register: R12 in 'UnsetPending'

      ;
      (tbRenderer.trOffset).localScale = v3TargetLocalScale
    else
      SetPanelOffset(tbRenderer, nCurPanelId)
      v3TargetLocalPos = GetTargetPosScale(sOffset, "a", nReusePanelId, bFull)
      if bPlaySwitchAnim == true then
        (((tbRenderer.trOffset):DOLocalMove(v3TargetLocalPos, nDuration)):SetUpdate(true)):SetEase(Ease.OutQuint)
        ;
        (((tbRenderer.trOffset):DOScale(v3TargetLocalScale, nDuration)):SetUpdate(true)):SetEase(Ease.OutQuint)
        ;
        (EventManager.Hit)(EventId.TemporaryBlockInput, nDuration)
      else
        -- DECOMPILER ERROR at PC100: Confused about usage of register: R12 in 'UnsetPending'

        ;
        (tbRenderer.trOffset).localPosition = v3TargetLocalPos
        -- DECOMPILER ERROR at PC102: Confused about usage of register: R12 in 'UnsetPending'

        ;
        (tbRenderer.trOffset).localScale = v3TargetLocalScale
      end
    end
    if sBg == nil or sBg == "" then
      (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_bg, nil)
      -- DECOMPILER ERROR at PC116: Confused about usage of register: R12 in 'UnsetPending'

      ;
      ((tbRenderer.spr_bg).transform).localScale = Vector3.zero
    else
      ;
      (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_bg, GetBg(sBg))
      -- DECOMPILER ERROR at PC129: Confused about usage of register: R12 in 'UnsetPending'

      ;
      ((tbRenderer.spr_bg).transform).localScale = Vector3.one
    end
    -- DECOMPILER ERROR at PC133: Confused about usage of register: R12 in 'UnsetPending'

    ;
    (tbRenderer.parent_L2D).localScale = Vector3.one
    -- DECOMPILER ERROR at PC137: Confused about usage of register: R12 in 'UnsetPending'

    ;
    (tbRenderer.trFreeDrag).localPosition = Vector3.zero
    -- DECOMPILER ERROR at PC141: Confused about usage of register: R12 in 'UnsetPending'

    ;
    (tbRenderer.trFreeDrag).localScale = Vector3.one
    Set_RawImg(tbRenderer, rawImg)
  end
end

local GetActor2DParams = function(nPanelId, nCharId, nSkinId, param, nSpecifyType)
  -- function num : 0_30 , upvalues : mapPanelConfig, _ENV, CheckNoExSkin, LocalSettingData, mapCurrent, GetActor2DType, CheckL2DType, GetUIDefaultBgName, TF, GetAssetPath
  local tbConfig = mapPanelConfig[nPanelId]
  if tbConfig == nil then
    printError("此界面未定义“如何”显示2D角色，panel id:" .. tostring(nPanelId))
    return 
  end
  if nSkinId == nil then
    nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
  end
  local mapSkinData = (ConfigTable.GetData_CharacterSkin)(nSkinId)
  mapSkinData = CheckNoExSkin(tbConfig, mapSkinData)
  if mapSkinData == nil then
    printError("未找到角色皮肤数据")
  end
  if tbConfig.bL2D then
    local bL = (LocalSettingData.mapData).UseLive2D
  end
  if type(param) == "table" and param[1] == "TalentL2D" then
    bL = true
  end
  local bF = not tbConfig.bHalf
  if mapCurrent.nPanelId == nPanelId and mapCurrent.bUseFull ~= nil then
    bF = mapCurrent.bUseFull
  end
  local nT = GetActor2DType(nCharId, nPanelId, tbConfig.nType, tbConfig.bHistoryType, nSpecifyType)
  local bSetSuccess = true
  bSetSuccess = CheckL2DType(nCharId, nSkinId, nT, tbConfig.bAutoAdjust)
  local sBg = GetUIDefaultBgName(tbConfig.sBg)
  if tbConfig.bSpBg == true then
    sBg = mapSkinData.Bg .. ".png"
  end
  if nT == TF then
    sBg = nil
  end
  local nOffsetDataPanelId = nPanelId
  if tbConfig.nReuse > 0 then
    nOffsetDataPanelId = tbConfig.nReuse
  end
  local sAssetPath = GetAssetPath(mapSkinData, bL, nT)
  local sOffset = mapSkinData.Offset
  if bL == true and type(param) == "table" and param[1] == "TalentL2D" then
    local nDefaultSkinId = ((ConfigTable.GetData_Character)(nCharId)).DefaultSkinId
    local mapDefaultSkinData = (ConfigTable.GetData_CharacterSkin)(nDefaultSkinId)
    sAssetPath = mapDefaultSkinData.L2D
    sAssetPath = (string.gsub)(sAssetPath, "_L.prefab", "_LT.prefab")
  end
  do
    return sAssetPath, sOffset, bL, nOffsetDataPanelId, nT, bF, sBg, bSetSuccess
  end
end

local GetFace = function(nSkinId, nPanelId, param)
  -- function num : 0_31 , upvalues : _ENV
  local sFace, sFieldName = nil, nil
  if param ~= nil and (nPanelId == PanelId.BattleResult or nPanelId == PanelId.RoguelikeResult or nPanelId == PanelId.RogueBossResult or nPanelId == PanelId.StarTowerResult) then
    if param == true then
      sFieldName = "BattelWin"
    else
      sFieldName = "BattleLose"
    end
  end
  local mapData = (ConfigTable.GetData)("CharacterSkinPanelFace", nSkinId)
  if mapData ~= nil then
    if nPanelId == PanelId.MainView then
      sFace = mapData.MainView
    else
      if nPanelId == PanelId.CharInfo then
        sFace = mapData.CharInfo
      else
        if nPanelId == PanelId.BattleResult or nPanelId == PanelId.RoguelikeResult or nPanelId == PanelId.RogueBossResult or nPanelId == PanelId.StarTowerResult then
          sFace = mapData[sFieldName]
        end
      end
    end
  end
  if sFace == "" or sFace == nil then
    sFace = "002"
  end
  return sFace
end

local GetName = function(sPortrait, sFace)
  -- function num : 0_32 , upvalues : Path, _ENV
  local sFileFullName = (Path.basename)(sPortrait)
  local sFileExtName = (Path.extension)(sPortrait)
  local sFileName = (string.gsub)(sFileFullName, sFileExtName, "")
  sFileName = (string.gsub)(sFileName, "_a", "")
  local sBodyName = (string.format)("%s_%s", sFileName, "001")
  local sFaceName = (string.format)("%s_%s", sFileName, sFace)
  return sBodyName, sFaceName
end

local SetPortrait = function(sPortrait, sFace, sOffset, rawImg, nCurPanelId, nReusePanelId, nType, bFull, sBg, tbRenderer)
  -- function num : 0_33 , upvalues : _ENV, TN, GetName, GetSprite, GetBg, TF, SetPanelOffset, GetTargetPosScale, nDuration, Set_RawImg
  if tbRenderer == nil then
    printError("未找到 Renderer")
  end
  local bPlaySwitchAnim = true
  if tbRenderer.sL2D == nil then
    bPlaySwitchAnim = false
    if nType == TN then
      local sBodyName, sFaceName = GetName(sPortrait, sFace)
      ;
      (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_body, GetSprite(sPortrait, sBodyName))
      ;
      (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_face, GetSprite(sPortrait, sFaceName))
    else
      do
        ;
        (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_body, nil)
        ;
        (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_face, GetBg(sPortrait))
        tbRenderer.sL2D = sPortrait
        local v3TargetLocalPos = Vector3(0, 0, 0)
        local v3TargetLocalScale = Vector3.one
        if nType == TF then
          SetPanelOffset(tbRenderer)
          -- DECOMPILER ERROR at PC61: Confused about usage of register: R13 in 'UnsetPending'

          ;
          (tbRenderer.trOffset).localPosition = v3TargetLocalPos
          -- DECOMPILER ERROR at PC63: Confused about usage of register: R13 in 'UnsetPending'

          ;
          (tbRenderer.trOffset).localScale = v3TargetLocalScale
        else
          SetPanelOffset(tbRenderer, nCurPanelId)
          v3TargetLocalPos = GetTargetPosScale(sOffset, "a", nReusePanelId, bFull)
          if bPlaySwitchAnim == true then
            (((tbRenderer.trOffset):DOLocalMove(v3TargetLocalPos, nDuration)):SetUpdate(true)):SetEase(Ease.OutQuint)
            ;
            (((tbRenderer.trOffset):DOScale(v3TargetLocalScale, nDuration)):SetUpdate(true)):SetEase(Ease.OutQuint)
            ;
            (EventManager.Hit)(EventId.TemporaryBlockInput, nDuration)
          else
            -- DECOMPILER ERROR at PC111: Confused about usage of register: R13 in 'UnsetPending'

            ;
            (tbRenderer.trOffset).localPosition = v3TargetLocalPos
            -- DECOMPILER ERROR at PC113: Confused about usage of register: R13 in 'UnsetPending'

            ;
            (tbRenderer.trOffset).localScale = v3TargetLocalScale
          end
        end
        if sBg == nil or sBg == "" then
          (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_bg, nil)
          -- DECOMPILER ERROR at PC127: Confused about usage of register: R13 in 'UnsetPending'

          ;
          ((tbRenderer.spr_bg).transform).localScale = Vector3.zero
        else
          ;
          (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_bg, GetBg(sBg))
          -- DECOMPILER ERROR at PC140: Confused about usage of register: R13 in 'UnsetPending'

          ;
          ((tbRenderer.spr_bg).transform).localScale = Vector3.one
        end
        -- DECOMPILER ERROR at PC144: Confused about usage of register: R13 in 'UnsetPending'

        ;
        (tbRenderer.parent_PNG).localScale = Vector3.one
        -- DECOMPILER ERROR at PC148: Confused about usage of register: R13 in 'UnsetPending'

        ;
        (tbRenderer.trFreeDrag).localPosition = Vector3.zero
        -- DECOMPILER ERROR at PC152: Confused about usage of register: R13 in 'UnsetPending'

        ;
        (tbRenderer.trFreeDrag).localScale = Vector3.one
        Set_RawImg(tbRenderer, rawImg)
      end
    end
  end
end

Actor2DManager.Init = function()
  -- function num : 0_34 , upvalues : trL2DInsRoot, _ENV, trL2DRendererRoot, GameResourceLoader, ResTypeAny, Actor_Node_Path, typeof, MAX_L2D_RENDERER_COUNT, GetL2DRendererStructure, tbL2DRenderer, mapCurrent, CacheActor2DInPanelConfig, RapidJson
  trL2DInsRoot = ((GameObject.Find)("==== UI ROOT ====/----Actor2D_OffScreen_Renderer----/----CachedInstance----")).transform
  trL2DRendererRoot = ((GameObject.Find)("==== UI ROOT ====/----Actor2D_OffScreen_Renderer----/----Renderer----")).transform
  local bundleGroup = (GameResourceLoader.MakeBundleGroup)("UI", 99999)
  local actor_node = (GameResourceLoader.LoadAsset)(ResTypeAny, Actor_Node_Path, typeof(Object), bundleGroup, 99999)
  for i = 1, MAX_L2D_RENDERER_COUNT do
    local trRenderer = instantiate(actor_node, trL2DRendererRoot)
    trRenderer.name = i
    local pos = (trRenderer.transform).localPosition
    pos.x = pos.x + (i - 1) * 10000
    -- DECOMPILER ERROR at PC42: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (trRenderer.transform).localPosition = pos
    local tb = GetL2DRendererStructure(trRenderer.transform)
    if tb ~= nil then
      (table.insert)(tbL2DRenderer, tb)
      ;
      (table.insert)(mapCurrent.tbChar, {nCharId = 0, nSkinId = 0, sBg = nil, sAssetPath = nil, sFace = nil, sOffset = nil, rawImg = nil})
      ;
      (table.insert)(mapCurrent.tbDisc, {nDiscId = 0, sAssetPath = nil, rawImg = nil})
      ;
      (table.insert)(mapCurrent.tbCg, {nCgId = 0, sAssetPath = nil, rawImg = nil})
    end
  end
  CacheActor2DInPanelConfig()
  local mapFallbackOrder = {
chat_b = {"chat_a"}
, 
chat_c = {"chat_a"}
, 
chat_d = {"chat_a"}
, 
presents_a = {"chat_a"}
, 
presents_b = {"chat_b", "chat_a"}
, 
shy_a = {"chat_a"}
, 
think_a = {"chat_b", "chat_a"}
, 
special_a = {"chat_a"}
, 
special_b = {"chat_b", "chat_a"}
}
  local sJson = (RapidJson.encode)(mapFallbackOrder)
  ;
  (NovaAPI.SetL2DAnimFallbackRules)(sJson)
end

Actor2DManager.ClearAll = function()
  -- function num : 0_35 , upvalues : _ENV, tbL2DRenderer, ResetRenderer, UnInit_RT, trL2DInsRoot, mapOffsetAsset, mapL2DPrefab, mapSprite, mapBg, GameResourceLoader
  for i,tbRenderer in ipairs(tbL2DRenderer) do
    if tbRenderer.sL2D ~= nil then
      ResetRenderer(tbRenderer)
    end
    UnInit_RT(tbRenderer)
  end
  if trL2DInsRoot ~= nil then
    delChildren(trL2DInsRoot.gameObject)
  end
  mapOffsetAsset = {}
  mapL2DPrefab = {}
  mapSprite = {}
  mapBg = {}
  ;
  (GameResourceLoader.Unload)("Actor2D")
  ;
  (GameResourceLoader.Unload)("Disc")
  ;
  (GameResourceLoader.Unload)("CG")
  ;
  (GameResourceLoader.Unload)("Image")
end

Actor2DManager.SetActor2D_ForSubSKill = function(nPanelId, rawImg, nCharId, nSkinId, param, nIndex)
  -- function num : 0_36 , upvalues : RT_SUB_SKILL_SHOW, Actor2DManager
  RT_SUB_SKILL_SHOW = true
  ;
  (Actor2DManager.SetActor2D)(nPanelId, rawImg, nCharId, nSkinId, param, nIndex)
  RT_SUB_SKILL_SHOW = false
end

Actor2DManager.SetActor2DWithRender = function(nPanelId, rawImg, nCharId, nSkinId, param, trRenderer, defaultNT)
  -- function num : 0_37 , upvalues : mapActor2DType, LoadLocalData, GetActor2DParams, GetL2DRendererStructure, SetL2D, GetFace, SetPortrait, TN, Actor2DManager, TF, _ENV
  if mapActor2DType["1"] ~= true then
    LoadLocalData()
  end
  local mapCurChar = {}
  local sAssetPath, sOffset, bL, nOffsetDataPanelId, nT, bF, sBg, bSetSuccess = GetActor2DParams(nPanelId, nCharId, nSkinId, nil, defaultNT)
  local sFace = nil
  local tbRenderer = GetL2DRendererStructure(trRenderer)
  if bL == true then
    SetL2D(sAssetPath, sOffset, rawImg, nPanelId, nOffsetDataPanelId, nT, bF, sBg, tbRenderer)
  else
    sFace = GetFace(nSkinId, nPanelId, param)
    SetPortrait(sAssetPath, sFace, sOffset, rawImg, nPanelId, nOffsetDataPanelId, nT, bF, sBg, tbRenderer)
  end
  local nAnimLength = 0
  if bL == true then
    if nT == TN then
      (Actor2DManager.PlayL2DAnim)(tbRenderer.trL2DIns, "idle", true, true)
    else
    end
  end
  if nT == TF then
    if nPanelId == PanelId.MainView then
      (Actor2DManager.PlayL2DAnim)(tbRenderer.trL2DIns, "idle", true, true)
      return bSetSuccess, nT, nAnimLength, tbRenderer
    end
  end
end

Actor2DManager.UnSetActor2DWithRender = function(tbRenderer)
  -- function num : 0_38 , upvalues : ResetRenderer
  if tbRenderer == nil then
    return 
  end
  if tbRenderer ~= nil then
    ResetRenderer(tbRenderer)
  end
end

Actor2DManager.SetActor2D = function(nPanelId, rawImg, nCharId, nSkinId, param, nIndex)
  -- function num : 0_39 , upvalues : mapActor2DType, LoadLocalData, mapCurrent, L2DType, Actor2DManager, GetActor2DParams, GetRenderer, SetL2D, GetFace, SetPortrait, _ENV, TN, TF
  if mapActor2DType["1"] ~= true then
    LoadLocalData()
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  if mapCurrent.L2DType == L2DType.Char then
    (Actor2DManager.UnsetActor2D)(true, nIndex)
  else
    if mapCurrent.L2DType == L2DType.Disc then
      (Actor2DManager.UnSetDisc2D)(true, nIndex)
    else
      if mapCurrent.L2DType == L2DType.CG then
        (Actor2DManager.UnSetCg2D)(true, nIndex)
      else
        ;
        (Actor2DManager.UnsetActor2D)(true, nIndex)
        ;
        (Actor2DManager.UnSetDisc2D)(true, nIndex)
        ;
        (Actor2DManager.UnSetCg2D)(true, nIndex)
      end
    end
  end
  local sAssetPath, sOffset, bL, nOffsetDataPanelId, nT, bF, sBg, bSetSuccess = GetActor2DParams(nPanelId, nCharId, nSkinId, param)
  local sFace = nil
  local tbRenderer = GetRenderer(sAssetPath, false, nIndex)
  if bL == true then
    SetL2D(sAssetPath, sOffset, rawImg, nPanelId, nOffsetDataPanelId, nT, bF, sBg, tbRenderer)
  else
    sFace = GetFace(nSkinId, nPanelId, param)
    SetPortrait(sAssetPath, sFace, sOffset, rawImg, nPanelId, nOffsetDataPanelId, nT, bF, sBg, tbRenderer)
  end
  mapCurChar.nCharId = nCharId
  mapCurChar.nSkinId = nSkinId
  mapCurChar.sBg = sBg
  mapCurChar.sAssetPath = sAssetPath
  mapCurChar.sFace = sFace
  mapCurChar.sOffset = sOffset
  mapCurChar.rawImg = rawImg
  mapCurrent.nPanelId = nPanelId
  mapCurrent.nOffsetPanelId = nOffsetDataPanelId
  mapCurrent.nActor2DType = nT
  mapCurrent.bUseL2D = bL
  mapCurrent.bUseFull = bF
  mapCurrent.L2DType = L2DType.Char
  mapCurChar.dragPos = Vector3.zero
  local nAnimLength = 0
  if bL == true then
    if type(param) == "table" and param[1] == "TalentL2D" then
      local nL2DStatus = param[2]
      local sAnimName = "idle_0"
      if nL2DStatus == 0 then
        sAnimName = "idle_0"
      else
        if nL2DStatus == 1 then
          sAnimName = "idle_0a"
        else
          if nL2DStatus == 2 then
            sAnimName = "idle_1"
          else
            if nL2DStatus >= 3 then
              sAnimName = "idle_2"
            end
          end
        end
      end
      ;
      (Actor2DManager.PlayAnim)(sAnimName, true, nIndex, true)
      local tbRule = {"0", "1", "2", "3", "5", "4"}
      local trIns = nil
      if (tbRenderer.parent_L2D).childCount > 0 then
        trIns = (tbRenderer.parent_L2D):GetChild(0)
      end
      if trIns ~= nil then
        local trBG = trIns:Find("root/----bg_effect----")
        local trFG = trIns:Find("root/----fg_effect----")
        for nI,sNodeName in ipairs(tbRule) do
          local bVisible = nI - 1 <= nL2DStatus
          local trNodeBG = trBG:Find(sNodeName)
          if trNodeBG ~= nil then
            (trNodeBG.gameObject):SetActive(bVisible)
          end
          local trNodeFG = trFG:Find(sNodeName)
          if trNodeFG ~= nil then
            (trNodeFG.gameObject):SetActive(bVisible)
          end
        end
      end
    elseif nT == TN then
      (Actor2DManager.PlayAnim)("idle", true, nIndex)
    elseif nT == TF then
      if nPanelId == PanelId.MainView then
        nAnimLength = (Actor2DManager.PlayCGAnim)(false, nIndex)
      else
        (Actor2DManager.PlayAnim)("idle", true, nIndex)
      end
    end
  end
  do return bSetSuccess, nT, nAnimLength end
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

Actor2DManager.UnsetActor2D = function(bKeepData, nIndex, bForce, tbRenderer)
  -- function num : 0_40 , upvalues : mapCurrent, L2DType, _ENV, GetRenderer, ResetRenderer, tbL2DRenderer, UnInit_RT
  if not mapCurrent.L2DType == L2DType.Char then
    return 
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  if tbRenderer == nil and type(mapCurChar.sAssetPath) == "string" and mapCurChar.sAssetPath ~= "" then
    tbRenderer = GetRenderer(mapCurChar.sAssetPath, true)
  end
  if tbRenderer ~= nil then
    ResetRenderer(tbRenderer)
  end
  if bForce == true and nIndex ~= nil and tbL2DRenderer ~= nil and tbL2DRenderer[nIndex] ~= nil then
    UnInit_RT(tbL2DRenderer[nIndex])
  end
  if bKeepData ~= true then
    mapCurChar.nCharId = 0
    mapCurChar.nSkinId = 0
    mapCurChar.sBg = nil
    mapCurChar.sAssetPath = nil
    mapCurChar.sFace = nil
    mapCurChar.sOffset = nil
    mapCurChar.rawImg = nil
    mapCurChar.dragPos = Vector3.zero
    mapCurrent.nOffsetPanelId = 0
    mapCurrent.nActor2DType = 0
    mapCurrent.bUseL2D = false
    mapCurrent.nPanelId = 0
    mapCurrent.bUseFull = false
    mapCurrent.L2DType = L2DType.None
  end
end

Actor2DManager.SwitchFullHalf = function(nIndex)
  -- function num : 0_41 , upvalues : mapCurrent, GetRenderer, SetL2D, SetPortrait
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  local bF = not mapCurrent.bUseFull
  local tbRenderer = GetRenderer(mapCurChar.sAssetPath, false, nIndex)
  if mapCurrent.bUseL2D == true then
    SetL2D(mapCurChar.sAssetPath, mapCurChar.sOffset, mapCurChar.rawImg, mapCurrent.nPanelId, mapCurrent.nOffsetPanelId, mapCurrent.nActor2DType, bF, mapCurChar.sBg, tbRenderer)
  else
    SetPortrait(mapCurChar.sAssetPath, mapCurChar.sFace, mapCurChar.sOffset, mapCurChar.rawImg, mapCurrent.nPanelId, mapCurrent.nOffsetPanelId, mapCurrent.nActor2DType, bF, mapCurChar.sBg, tbRenderer)
  end
  mapCurrent.bUseFull = bF
end

Actor2DManager.SwitchActor2DType = function(nIndex)
  -- function num : 0_42 , upvalues : mapCurrent, L2DType, mapPanelConfig, TN, TF, CheckL2DType, Actor2DManager, GetUIDefaultBgName, _ENV, CheckNoExSkin, GetAssetPath, GetRenderer, SetL2D, GetFace, SetPortrait, SaveActor2DType
  if not mapCurrent.L2DType == L2DType.Char then
    return 
  end
  local bSwitchSuccess = true
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  local tbConfig = mapPanelConfig[mapCurrent.nPanelId]
  local nRenderCharId = mapCurChar.nCharId
  local nRenderSkinId = mapCurChar.nSkinId
  local nType = mapCurrent.nActor2DType
  local nTargetType = nil
  if nType == TN then
    nTargetType = TF
  else
    nTargetType = TN
  end
  bSwitchSuccess = CheckL2DType(nRenderCharId, nRenderSkinId, nTargetType, tbConfig.bAutoAdjust)
  if nType == nTargetType then
    return bSwitchSuccess
  end
  nType = nTargetType
  ;
  (Actor2DManager.UnsetActor2D)(true, nIndex)
  local sBg = GetUIDefaultBgName(tbConfig.sBg)
  local mapSkinData = (ConfigTable.GetData_CharacterSkin)(nRenderSkinId)
  mapSkinData = CheckNoExSkin(tbConfig, mapSkinData)
  if mapSkinData == nil then
    printError("未找到角色皮肤数据")
  end
  if tbConfig.bSpBg == true then
    sBg = mapSkinData.Bg .. ".png"
  end
  if nType == TF then
    sBg = nil
  end
  local sAssetPath = (GetAssetPath(mapSkinData, mapCurrent.bUseL2D, nType))
  local sFace = nil
  local tbRenderer = GetRenderer(sAssetPath, false, nIndex)
  if mapCurrent.bUseL2D == true then
    SetL2D(sAssetPath, mapCurChar.sOffset, mapCurChar.rawImg, mapCurrent.nPanelId, mapCurrent.nOffsetPanelId, nType, mapCurrent.bUseFull, sBg, tbRenderer)
  else
    sFace = GetFace(nRenderSkinId, mapCurrent.nPanelId)
    SetPortrait(sAssetPath, sFace, mapCurChar.sOffset, mapCurChar.rawImg, mapCurrent.nPanelId, mapCurrent.nOffsetPanelId, nType, mapCurrent.bUseFull, sBg, tbRenderer)
  end
  mapCurChar.sBg = sBg
  mapCurChar.sAssetPath = sAssetPath
  mapCurChar.sFace = sFace
  mapCurrent.nActor2DType = nType
  SaveActor2DType(nRenderCharId, mapCurrent.nPanelId, nType)
  local nAnimLength = 0
  if mapCurrent.bUseL2D == true then
    if nType == TN then
      (Actor2DManager.PlayAnim)("idle", true, nIndex)
    else
      if nType == TF then
        if mapCurrent.nPanelId == PanelId.MainView then
          nAnimLength = (Actor2DManager.PlayCGAnim)(false, nIndex)
        else
          ;
          (Actor2DManager.PlayAnim)("idle", true, nIndex)
        end
      end
    end
  end
  return bSwitchSuccess, nType, nAnimLength
end

Actor2DManager.PlayAnim = function(sAnimClipName, bForcePlay, nIndex, bForceLoop)
  -- function num : 0_43 , upvalues : mapCurrent, L2DType, GetRenderer, _ENV, Actor2DManager
  if mapCurrent.bUseL2D ~= true then
    return 
  end
  if sAnimClipName == nil then
    sAnimClipName = "idle"
  end
  if bForcePlay == nil then
    bForcePlay = false
  end
  if nIndex == nil then
    nIndex = 1
  end
  local sL2D = nil
  if mapCurrent.L2DType == L2DType.Disc then
    local mapCurDisc = (mapCurrent.tbDisc)[nIndex]
    sL2D = mapCurDisc.sAssetPath
  else
    do
      if mapCurrent.L2DType == L2DType.Char then
        local mapCurChar = (mapCurrent.tbChar)[nIndex]
        sL2D = mapCurChar.sAssetPath
      else
        do
          do
            if mapCurrent.L2DType == L2DType.CG then
              local mapCurDisc = (mapCurrent.tbCg)[nIndex]
              sL2D = mapCurDisc.sAssetPath
            end
            local tbRenderer = GetRenderer(sL2D, true)
            if tbRenderer == nil then
              printError("未找到 Renderer")
            end
            local bLoop = false
            if sAnimClipName == "idle" then
              bLoop = true
            end
            if bForceLoop == true then
              bLoop = true
            end
            ;
            (Actor2DManager.PlayL2DAnim)(tbRenderer.trL2DIns, sAnimClipName, bLoop, bForcePlay)
          end
        end
      end
    end
  end
end

Actor2DManager.PlayCGAnim = function(bForcePlayAnim, nIndex, trL2DIns, tbChar)
  -- function num : 0_44 , upvalues : mapCurrent, L2DType, TF, mapPlayedCG, GetRenderer, _ENV, Actor2DManager
  if not mapCurrent.L2DType == L2DType.Char then
    return 
  end
  if mapCurrent.nActor2DType ~= TF or mapCurrent.bUseL2D ~= true then
    return 0
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = tbChar
  if tbChar == nil then
    mapCurChar = (mapCurrent.tbChar)[nIndex]
  end
  local sL2D = mapCurChar.sAssetPath
  local bHasPlayedSinceLogin = mapPlayedCG[sL2D]
  if bHasPlayedSinceLogin ~= true or bForcePlayAnim == true then
    mapPlayedCG[sL2D] = true
    do
      if trL2DIns == nil then
        local tbRenderer = GetRenderer(sL2D, true)
        if tbRenderer == nil then
          printError("未找到 Renderer")
        end
        trL2DIns = tbRenderer.trL2DIns
      end
      do
        local nAnimLength = (NovaAPI.PlayL2DCGAnim)(trL2DIns)
        do return nAnimLength or 0 end
        ;
        (Actor2DManager.PlayAnim)("idle", true, nIndex)
        do return 0 end
      end
    end
  end
end

Actor2DManager.SkipCGAnim = function(nIndex)
  -- function num : 0_45 , upvalues : mapCurrent, L2DType, TF, GetRenderer, _ENV
  if not mapCurrent.L2DType == L2DType.Char then
    return 
  end
  if mapCurrent.nActor2DType ~= TF or mapCurrent.bUseL2D ~= true then
    return 
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  local sL2D = mapCurChar.sAssetPath
  local tbRenderer = GetRenderer(sL2D, true)
  if tbRenderer == nil then
    printError("未找到 Renderer")
  end
  ;
  (NovaAPI.SkipL2DCGAnim)(tbRenderer.trL2DIns)
end

Actor2DManager.PlayL2DAnim = function(tr, sAnimName, bLoop, bForcePlay)
  -- function num : 0_46 , upvalues : _ENV
  if tr == nil then
    return 
  end
  if sAnimName == nil then
    return 
  end
  do
    if (string.sub)(sAnimName, 1, 3) == "vo_" then
      local sSurfix = GetLanguageSurfixByIndex(GetLanguageIndex(Settings.sCurrentVoLanguage))
      sAnimName = sAnimName .. sSurfix
    end
    ;
    (NovaAPI.PlayL2DAnim)(tr, sAnimName, bLoop, bForcePlay)
  end
end

Actor2DManager.SetActor2D_PNG = function(trActor2D_PNG, nPanelId, nCharId, nSkinId, param)
  -- function num : 0_47 , upvalues : mapPanelConfig, _ENV, CheckNoExSkin, GetAssetPath, TN, GetFace, GetName, GetTargetPosScale, GetSprite
  local tbConfig = mapPanelConfig[nPanelId]
  if tbConfig == nil then
    printError("此界面未定义“如何”显示2D角色，panel id:" .. tostring(nPanelId))
    return 
  end
  if nSkinId == nil then
    nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
  end
  local mapSkinData = (ConfigTable.GetData_CharacterSkin)(nSkinId)
  mapSkinData = CheckNoExSkin(tbConfig, mapSkinData)
  if mapSkinData == nil then
    printError("未找到角色皮肤数据")
  end
  local bF = not tbConfig.bHalf
  local nOffsetDataPanelId = nPanelId
  if tbConfig.nReuse > 0 then
    nOffsetDataPanelId = tbConfig.nReuse
  end
  local sAssetPath = GetAssetPath(mapSkinData, false, TN)
  local sOffset = mapSkinData.Offset
  local sFace = GetFace(nSkinId, nPanelId, param)
  local sBodyName, sFaceName = GetName(sAssetPath, sFace)
  local v3TargetLocalPos, v3TargetLocalScale = GetTargetPosScale(sOffset, "a", nOffsetDataPanelId, bF, true)
  local spBody = GetSprite(sAssetPath, sBodyName)
  local spFace = GetSprite(sAssetPath, sFaceName)
  local trPanelOffset = trActor2D_PNG:GetChild(0)
  trPanelOffset.localPosition = Vector3((tbConfig.v3PanelOffset).x * 100, (tbConfig.v3PanelOffset).y * 100, 0)
  local _s = (tbConfig.v3PanelOffset).z
  if _s <= 0 then
    _s = 1
  end
  trPanelOffset.localScale = Vector3(_s, _s, 1)
  local trOffset = trPanelOffset:GetChild(0)
  trOffset.localPosition = v3TargetLocalPos
  trOffset.localScale = v3TargetLocalScale
  local imgBody = (trOffset:GetChild(0)):GetComponent("Image")
  local imgFace = (trOffset:GetChild(1)):GetComponent("Image")
  ;
  (NovaAPI.SetImageSpriteAsset)(imgBody, spBody)
  ;
  (NovaAPI.SetImageSpriteAsset)(imgFace, spFace)
  ;
  (NovaAPI.SetImageNativeSize)(imgBody)
  ;
  (NovaAPI.SetImageNativeSize)(imgFace)
end

Actor2DManager.PlayActor2DAnim = function(sAnimName, nIndex)
  -- function num : 0_48 , upvalues : mapCurrent, L2DType, tbL2DRenderer, _ENV, TimerManager, Actor2DManager
  if not mapCurrent.L2DType == L2DType.Char or not mapCurrent.L2DType == L2DType.None then
    return 
  end
  if nIndex == nil then
    nIndex = 1
  end
  local tbRenderer = tbL2DRenderer[nIndex]
  local nAnimLength = (NovaAPI.GetAnimClipLength)(tbRenderer.animatorCtrl, {sAnimName})
  ;
  (tbRenderer.animatorCtrl):Play(sAnimName)
  ;
  (TimerManager.Add)(1, nAnimLength, nil, function()
    -- function num : 0_48_0 , upvalues : Actor2DManager, tbRenderer
    (Actor2DManager.ResetActor2DAnim)(tbRenderer)
  end
, true, true, true, nil)
end

Actor2DManager.ResetActor2DAnim = function(tbRenderer)
  -- function num : 0_49 , upvalues : _ENV
  (tbRenderer.animatorCtrl):Play("Empty")
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

  ;
  ((tbRenderer.animator).transform).localPosition = Vector3.zero
end

Actor2DManager.SetActor2DTypeByPanel = function(nPanelId, nCharId, nType)
  -- function num : 0_50 , upvalues : _ENV, mapActor2DType, SaveLocalData
  local sMainKey = tostring(nCharId)
  local sSubKey = tostring(nPanelId)
  if mapActor2DType[sMainKey] == nil then
    mapActor2DType[sMainKey] = {}
  end
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (mapActor2DType[sMainKey])[sSubKey] = nType
  SaveLocalData()
end

Actor2DManager.GetActor2DTypeByPanel = function(nPanelId, nCharId)
  -- function num : 0_51 , upvalues : _ENV, mapActor2DType, TF
  local sMainKey = tostring(nCharId)
  local sSubKey = tostring(nPanelId)
  if mapActor2DType[sMainKey] ~= nil and (mapActor2DType[sMainKey])[sSubKey] ~= nil then
    return (mapActor2DType[sMainKey])[sSubKey]
  end
  return TF
end

Actor2DManager.SwitchActor2DDragOffset = function()
  -- function num : 0_52 , upvalues : mapCurrent, tbL2DRenderer, _ENV
  local mapCurChar = (mapCurrent.tbChar)[1]
  local tbRenderer = tbL2DRenderer[1]
  local v3Offset = (tbRenderer.trOffset).localPosition
  mapCurChar.dragPos = v3Offset
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localPosition = v3Offset
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localPosition = Vector3.zero
  return v3Offset
end

Actor2DManager.ResetActor2DDragOffset = function(v3Offset)
  -- function num : 0_53 , upvalues : mapCurrent, tbL2DRenderer, _ENV
  local mapCurChar = (mapCurrent.tbChar)[1]
  local tbRenderer = tbL2DRenderer[1]
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localPosition = Vector3.zero
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localPosition = v3Offset
  mapCurChar.dragPos = Vector3.zero
end

Actor2DManager.SetActor2DInUI = function(nPanelId, trRoot, nCharId, nSkinId, bLive2D)
  -- function num : 0_54 , upvalues : mapPanelConfig, _ENV, CheckNoExSkin, GetTargetPosScale, GetAssetPath, TN, LoadAsset, Actor2DManager
  local tbConfig = mapPanelConfig[nPanelId]
  if tbConfig == nil then
    printError("此界面未定义“如何”显示2D角色立绘, panel id:" .. tostring(nPanelId))
    return 
  end
  if nSkinId == nil then
    nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
  end
  local mapSkinData = (ConfigTable.GetData_CharacterSkin)(nSkinId)
  mapSkinData = CheckNoExSkin(tbConfig, mapSkinData)
  if mapSkinData == nil then
    printError("未找到角色皮肤数据")
  end
  local bF = not tbConfig.bHalf
  local bL2D = bLive2D == true
  local nOffsetDataPanelId = nPanelId
  if tbConfig.nReuse > 0 then
    nOffsetDataPanelId = tbConfig.nReuse
  end
  local sOffset = mapSkinData.Offset
  local trSlipInOutAnim = trRoot:GetChild(0)
  local trPanelOffset = trSlipInOutAnim:GetChild(0)
  local trRoleOffset = trPanelOffset:GetChild(0)
  local v3TargetLocalPos, v3TargetLocalScale = GetTargetPosScale(sOffset, "a", nOffsetDataPanelId, bF, false)
  local _s = (tbConfig.v3PanelOffset).z
  trPanelOffset.localPosition = Vector3((tbConfig.v3PanelOffset).x, (tbConfig.v3PanelOffset).y, 0)
  if _s <= 0 then
    _s = 1
  end
  trPanelOffset.localScale = Vector3(_s, _s, 1)
  trRoleOffset.localPosition = v3TargetLocalPos
  trRoleOffset.localScale = v3TargetLocalScale
  delChildren(trRoleOffset)
  local sAssetPath = GetAssetPath(mapSkinData, bL2D, TN)
  local objL2DPrefab = LoadAsset(sAssetPath, Object)
  local goIns = instantiate(objL2DPrefab, trRoleOffset)
  -- DECOMPILER ERROR at PC101: Confused about usage of register: R20 in 'UnsetPending'

  ;
  (goIns.transform).localPosition = Vector3.zero
  -- DECOMPILER ERROR at PC105: Confused about usage of register: R20 in 'UnsetPending'

  ;
  (goIns.transform).localScale = Vector3.one
  ;
  (Actor2DManager.PlayL2DAnim)(goIns.transform, "idle", true, true)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

Actor2DManager.PlayActor2DAnimInUI = function(trRoot, sAnimName)
  -- function num : 0_55 , upvalues : Actor2DManager
  local trSlipInOutAnim = trRoot:GetChild(0)
  local trPanelOffset = trSlipInOutAnim:GetChild(0)
  local trRoleOffset = trPanelOffset:GetChild(0)
  ;
  (Actor2DManager.PlayL2DAnim)(trRoleOffset:GetChild(0), "idle", false, true)
end

local drag_rang_width = {-8, 8}
local drag_rang_height = {-9, 9}
local getDragLimit = function(tbRenderer)
  -- function num : 0_56 , upvalues : drag_rang_width, drag_rang_height
  local localScale = (tbRenderer.trFreeDrag).localScale
  local panelOffset = (tbRenderer.trPanelOffset).localPosition
  local tbWidthRage = {(drag_rang_width[1] - panelOffset.x) * localScale.x, (drag_rang_width[2] - panelOffset.x) * localScale.x}
  local tbHeightRage = {(drag_rang_height[1] - panelOffset.y) * localScale.x, (drag_rang_height[2] - panelOffset.y) * localScale.x}
  return tbWidthRage, tbHeightRage
end

local clamp = function(x, min, max)
  -- function num : 0_57 , upvalues : _ENV
  return (math.max)((math.min)(x, max), min)
end

Actor2DManager.SyncLocalPos = function(x, y, nIndex, rect)
  -- function num : 0_58 , upvalues : mapCurrent, tbL2DRenderer, getDragLimit, _ENV, clamp
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  if mapCurChar == nil then
    return 
  end
  local tbRenderer = tbL2DRenderer[nIndex]
  local tbWidthRage, tbHeightRange = getDragLimit(tbRenderer)
  local deltaDragParam = 0.01
  mapCurChar.dragPos = Vector3((mapCurChar.dragPos).x + x * deltaDragParam, (mapCurChar.dragPos).y + y * deltaDragParam, 0)
  -- DECOMPILER ERROR at PC32: Confused about usage of register: R9 in 'UnsetPending'

  ;
  (mapCurChar.dragPos).x = clamp((mapCurChar.dragPos).x, tbWidthRage[1], tbWidthRage[2])
  -- DECOMPILER ERROR at PC40: Confused about usage of register: R9 in 'UnsetPending'

  ;
  (mapCurChar.dragPos).y = clamp((mapCurChar.dragPos).y, tbHeightRange[1], tbHeightRange[2])
  -- DECOMPILER ERROR at PC43: Confused about usage of register: R9 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localPosition = mapCurChar.dragPos
end

Actor2DManager.SyncLocalScale = function(s, nIndex)
  -- function num : 0_59 , upvalues : tbL2DRenderer, _ENV, getDragLimit, clamp
  if nIndex == nil then
    nIndex = 1
  end
  local tbRenderer = tbL2DRenderer[nIndex]
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localScale = Vector3(s, s, 1)
  local tbWidthRage, tbHeightRange = getDragLimit(tbRenderer)
  local localPos = (tbRenderer.trFreeDrag).localPosition
  localPos.x = clamp(localPos.x, tbWidthRage[1], tbWidthRage[2])
  localPos.y = clamp(localPos.y, tbHeightRange[1], tbHeightRange[2])
  -- DECOMPILER ERROR at PC34: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localPosition = Vector3(localPos.x, localPos.y, 0)
end

Actor2DManager.GetCurrentActor2DType = function()
  -- function num : 0_60 , upvalues : mapCurrent
  if mapCurrent ~= nil then
    return mapCurrent.nActor2DType
  end
end

Actor2DManager.GetMapPanelConfig = function(nPanelId)
  -- function num : 0_61 , upvalues : mapPanelConfig
  return mapPanelConfig[nPanelId]
end

Actor2DManager.SetBoardNPC2D = function(nPanelId, rawImg, nCharId, nSkinId, param, nIndex)
  -- function num : 0_62 , upvalues : mapActor2DType, LoadLocalData, mapCurrent, Actor2DManager, mapPanelConfig, _ENV, LocalSettingData, GetUIDefaultBgName, TF, GetAssetPath, GetRenderer, SetL2D, GetFace, SetPortrait, L2DType
  if mapActor2DType["1"] ~= true then
    LoadLocalData()
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  ;
  (Actor2DManager.UnsetBoardNPC2D)(nIndex)
  local tbConfig = mapPanelConfig[nPanelId]
  if tbConfig == nil then
    printError("此界面未定义“如何”显示2D角色，panel id:" .. tostring(nPanelId))
    return 
  end
  if nSkinId == nil then
    nSkinId = (PlayerData.Board):GetNPCDefaultSkinId(nCharId)
  end
  if nSkinId == nil then
    printError("系统NPC看板 skinId 为空！！！ charId = " .. nCharId)
    return 
  end
  local mapSkinData = (ConfigTable.GetData)("NPCSkin", nSkinId)
  if mapSkinData == nil then
    printError("未找到NPC皮肤数据")
  end
  if tbConfig.bL2D then
    local bL = (LocalSettingData.mapData).UseLive2D
  end
  local bF = not tbConfig.bHalf
  if mapCurrent.nPanelId == nPanelId and mapCurrent.bUseFull ~= nil then
    bF = mapCurrent.bUseFull
  end
  local nT = tbConfig.nType
  local sBg = GetUIDefaultBgName(tbConfig.sBg)
  if tbConfig.bSpBg == true then
    sBg = mapSkinData.Bg .. ".png"
  end
  if nT == TF then
    sBg = nil
  end
  local nOffsetDataPanelId = nPanelId
  if tbConfig.nReuse > 0 then
    nOffsetDataPanelId = tbConfig.nReuse
  end
  local sAssetPath = GetAssetPath(mapSkinData, bL, nT)
  if sAssetPath == nil or sAssetPath == "" then
    return 
  end
  local sOffset = mapSkinData.Offset
  local sFace = nil
  local tbRenderer = GetRenderer(sAssetPath, false, nIndex)
  if bL == true then
    SetL2D(sAssetPath, sOffset, rawImg, nPanelId, nOffsetDataPanelId, nT, bF, sBg, tbRenderer)
  else
    sFace = GetFace(nSkinId, nPanelId, param)
    SetPortrait(sAssetPath, sFace, sOffset, rawImg, nPanelId, nOffsetDataPanelId, nT, bF, sBg, tbRenderer)
  end
  mapCurChar.nCharId = nCharId
  mapCurChar.nSkinId = nSkinId
  mapCurChar.sBg = sBg
  mapCurChar.sAssetPath = sAssetPath
  mapCurChar.sFace = sFace
  mapCurChar.sOffset = sOffset
  mapCurChar.rawImg = rawImg
  mapCurrent.nPanelId = nPanelId
  mapCurrent.nOffsetPanelId = nOffsetDataPanelId
  mapCurrent.nActor2DType = nT
  mapCurrent.bUseL2D = bL
  mapCurrent.bUseFull = bF
  mapCurrent.L2DType = L2DType.Char
  local tbRenderer = GetRenderer(sAssetPath, true)
  if tbRenderer == nil then
    printError("未找到 Renderer")
  end
  ;
  (Actor2DManager.PlayL2DAnim)(tbRenderer.trL2DIns, "idle", true, true)
end

Actor2DManager.UnsetBoardNPC2D = function(nIndex)
  -- function num : 0_63 , upvalues : mapCurrent, _ENV, GetRenderer, ResetRenderer, L2DType
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurChar = (mapCurrent.tbChar)[nIndex]
  do
    if type(mapCurChar.sAssetPath) == "string" and mapCurChar.sAssetPath ~= "" then
      local tbRenderer = GetRenderer(mapCurChar.sAssetPath, true)
      if tbRenderer ~= nil then
        ResetRenderer(tbRenderer)
      end
    end
    mapCurChar.nCharId = 0
    mapCurChar.nSkinId = 0
    mapCurChar.sBg = nil
    mapCurChar.sAssetPath = nil
    mapCurChar.sFace = nil
    mapCurChar.sOffset = nil
    mapCurChar.rawImg = nil
    mapCurrent.nOffsetPanelId = 0
    mapCurrent.nActor2DType = 0
    mapCurrent.bUseL2D = false
    mapCurrent.nPanelId = 0
    mapCurrent.bUseFull = false
    mapCurrent.L2DType = L2DType.None
  end
end

Actor2DManager.SetBoardNPC2D_PNG = function(trActor2D_PNG, nPanelId, nNPCId, nSkinId, param)
  -- function num : 0_64 , upvalues : mapPanelConfig, _ENV, GetAssetPath, TN, GetFace, GetName, GetTargetPosScale, GetSprite
  local tbConfig = mapPanelConfig[nPanelId]
  if tbConfig == nil then
    printError("此界面未定义“如何”显示2D角色，panel id:" .. tostring(nPanelId))
    return 
  end
  if nSkinId == nil then
    nSkinId = (PlayerData.Board):GetNPCDefaultSkinId(nNPCId)
  end
  local mapSkinData = (ConfigTable.GetData)("NPCSkin", nSkinId)
  if mapSkinData == nil then
    printError("未找到NPC皮肤数据")
  end
  local bF = not tbConfig.bHalf
  local nOffsetDataPanelId = nPanelId
  if tbConfig.nReuse > 0 then
    nOffsetDataPanelId = tbConfig.nReuse
  end
  local sAssetPath = GetAssetPath(mapSkinData, false, TN)
  local sOffset = mapSkinData.Offset
  local sFace = GetFace(nSkinId, nPanelId, param)
  local sBodyName, sFaceName = GetName(sAssetPath, sFace)
  local v3TargetLocalPos, v3TargetLocalScale = GetTargetPosScale(sOffset, "a", nOffsetDataPanelId, bF, true)
  local spBody = GetSprite(sAssetPath, sBodyName)
  local spFace = GetSprite(sAssetPath, sFaceName)
  local trPanelOffset = trActor2D_PNG:GetChild(0)
  trPanelOffset.localPosition = Vector3((tbConfig.v3PanelOffset).x * 100, (tbConfig.v3PanelOffset).y * 100, 0)
  local _s = (tbConfig.v3PanelOffset).z
  if _s <= 0 then
    _s = 1
  end
  trPanelOffset.localScale = Vector3(_s, _s, 1)
  local trOffset = trPanelOffset:GetChild(0)
  trOffset.localPosition = v3TargetLocalPos
  trOffset.localScale = v3TargetLocalScale
  local imgBody = (trOffset:GetChild(0)):GetComponent("Image")
  local imgFace = (trOffset:GetChild(1)):GetComponent("Image")
  ;
  (NovaAPI.SetImageSpriteAsset)(imgBody, spBody)
  ;
  (NovaAPI.SetImageSpriteAsset)(imgFace, spFace)
  ;
  (NovaAPI.SetImageNativeSize)(imgBody)
  ;
  (NovaAPI.SetImageNativeSize)(imgFace)
end

local sTempAssetPath, goTempL2DIns = nil, nil
Actor2DManager.SetActor2D_ForActor2DEditor = function(nPanelId, rawImg, sSkinId, bFull, sFullPath, s, x, y, bL2D, nL2DX, nL2DY, nL2DS, bNpc)
  -- function num : 0_65 , upvalues : _ENV, mapPanelConfig, GetUIDefaultBgName, GetRenderer, Set_RawImg, sTempAssetPath, SetPanelOffset, typeof, LoadAsset, goTempL2DIns
  if rawImg == nil then
    return 
  end
  local sFullPath_BodyPng = (string.format)("%s%s/atlas_png/a/%s_001.png", sFullPath, sSkinId, sSkinId)
  local sFullPath_FacePng = ((string.format)("%s%s/atlas_png/a/%s_002.png", sFullPath, sSkinId, sSkinId))
  local mapCharSkinData = nil
  if bNpc == true then
    mapCharSkinData = (ConfigTable.GetData)("NPCSkin", tonumber(sSkinId))
  else
    mapCharSkinData = (ConfigTable.GetData_CharacterSkin)(tonumber(sSkinId))
  end
  if mapCharSkinData == nil then
    printError("未找到皮肤数据")
  end
  local mapPanelCfgData = mapPanelConfig[nPanelId]
  if mapPanelCfgData.bSpBg ~= true or bNpc == true or mapCharSkinData == nil or not mapCharSkinData.Bg .. ".png" then
    local sFullPath_Bg = (string.format)("Assets/AssetBundles/%s", GetUIDefaultBgName(mapPanelCfgData.sBg))
    local tbRenderer = GetRenderer(sFullPath_BodyPng)
    if tbRenderer == nil then
      printError("未找到 Renderer")
    end
    Set_RawImg(tbRenderer, rawImg)
    sTempAssetPath = sFullPath_BodyPng
    tbRenderer.sL2D = sFullPath_BodyPng
    SetPanelOffset(tbRenderer, nPanelId)
    -- DECOMPILER ERROR at PC85: Confused about usage of register: R19 in 'UnsetPending'

    ;
    (tbRenderer.trOffset).localPosition = Vector3(x, y, 0)
    -- DECOMPILER ERROR at PC92: Confused about usage of register: R19 in 'UnsetPending'

    ;
    (tbRenderer.trOffset).localScale = Vector3(s, s, 1)
    -- DECOMPILER ERROR at PC96: Confused about usage of register: R19 in 'UnsetPending'

    ;
    (tbRenderer.parent_PNG).localScale = Vector3.one
    ;
    (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_body, (((CS.UnityEditor).AssetDatabase).LoadAssetAtPath)(sFullPath_BodyPng, typeof(Sprite)))
    ;
    (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_face, (((CS.UnityEditor).AssetDatabase).LoadAssetAtPath)(sFullPath_FacePng, typeof(Sprite)))
    -- DECOMPILER ERROR at PC127: Confused about usage of register: R19 in 'UnsetPending'

    ;
    ((tbRenderer.spr_bg).transform).localScale = Vector3.one
    ;
    (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_bg, (((CS.UnityEditor).AssetDatabase).LoadAssetAtPath)(sFullPath_Bg, typeof(Sprite)))
    local trL2D = nil
    -- DECOMPILER ERROR at PC147: Confused about usage of register: R20 in 'UnsetPending'

    if bL2D == true then
      (tbRenderer.parent_L2D).localScale = Vector3.one
      local sL2D = (string.format)("Actor2D/Character/%s/%s_L.prefab", sSkinId, sSkinId)
      local objL2DPrefab = LoadAsset(sL2D, Object)
      goTempL2DIns = instantiate(objL2DPrefab, tbRenderer.parent_L2D)
      ;
      (goTempL2DIns.transform):SetLayerRecursively((((CS.UnityEngine).LayerMask).NameToLayer)("Cam_Layer_4"))
      trL2D = (goTempL2DIns.transform):Find("root")
      if nL2DS == nil or nL2DS <= 0 then
        nL2DS = 1
      end
      trL2D.localPosition = Vector3(nL2DX or 0, nL2DY or 0, 0)
      trL2D.localScale = Vector3(nL2DS, nL2DS, 1)
      local goModel = ((trL2D:Find("----live2d_modle----")):GetChild(0)).gameObject
      local CubismRenderController = goModel:GetComponent("CubismRenderController")
      CubismRenderController.SortingOrder = 1
      ;
      (NovaAPI.SetSpriteRendererColor)(tbRenderer.spr_body, Color(1, 1, 1, 0.5))
      ;
      (NovaAPI.SetSPSortingOrder)(tbRenderer.spr_body, 900)
      ;
      (NovaAPI.SetSpriteRendererColor)(tbRenderer.spr_face, Color(1, 1, 1, 0.5))
      ;
      (NovaAPI.SetSPSortingOrder)(tbRenderer.spr_face, 901)
      local L2DAnimPlayer = goModel:GetComponent("L2DAnimPlayer")
      L2DAnimPlayer:PlayAnimInUI("ultra", true, true)
    else
      do
        ;
        (NovaAPI.SetSpriteRendererColor)(tbRenderer.spr_body, Color.white)
        ;
        (NovaAPI.SetSPSortingOrder)(tbRenderer.spr_body, 0)
        ;
        (NovaAPI.SetSpriteRendererColor)(tbRenderer.spr_face, Color.white)
        ;
        (NovaAPI.SetSPSortingOrder)(tbRenderer.spr_face, 1)
        return trL2D
      end
    end
  end
end

Actor2DManager.UnsetActor2D_ForActor2DEditor = function()
  -- function num : 0_66 , upvalues : sTempAssetPath, GetRenderer, ResetRenderer, goTempL2DIns, _ENV
  if sTempAssetPath == nil then
    return 
  end
  local tbRenderer = GetRenderer(sTempAssetPath, true)
  ResetRenderer(tbRenderer)
  sTempAssetPath = nil
  if goTempL2DIns ~= nil then
    destroy(goTempL2DIns)
    goTempL2DIns = nil
  end
end

Actor2DManager.SetActor2D_PNG_ForActor2DEditor = function(nPanelId, trActor2D_PNG, sCharId, sFullPath, s, x, y, sPose)
  -- function num : 0_67 , upvalues : _ENV, typeof, mapPanelConfig
  local sFullPath_BodyPng, sFullPath_FacePng = nil, nil
  if sPose == nil then
    sFullPath_BodyPng = (string.format)("%s/atlas_png/a/%s_001.png", sFullPath, sCharId)
    sFullPath_FacePng = (string.format)("%s/atlas_png/a/%s_002.png", sFullPath, sCharId)
  else
    sFullPath_BodyPng = (string.format)("%s/atlas_png/%s/%s_%s_001.png", sFullPath, sPose, sCharId, sPose)
    sFullPath_FacePng = (string.format)("%s/atlas_png/%s/%s_%s_002.png", sFullPath, sPose, sCharId, sPose)
  end
  local spBody = (((CS.UnityEditor).AssetDatabase).LoadAssetAtPath)(sFullPath_BodyPng, typeof(Sprite))
  local spFace = (((CS.UnityEditor).AssetDatabase).LoadAssetAtPath)(sFullPath_FacePng, typeof(Sprite))
  local trPanelOffset = trActor2D_PNG:GetChild(0)
  local tbConfig = mapPanelConfig[nPanelId]
  local _x, _y, _s = 0, 0, 1
  if tbConfig ~= nil then
    _x = (tbConfig.v3PanelOffset).x * 100
    _y = (tbConfig.v3PanelOffset).y * 100
    _s = (tbConfig.v3PanelOffset).z
  end
  if _s <= 0 then
    _s = 1
  end
  trPanelOffset.localPosition = Vector3(_x, _y, 0)
  trPanelOffset.localScale = Vector3(_s, _s, 1)
  local trOffset = trPanelOffset:GetChild(0)
  trOffset.localPosition = Vector3(x, y, 0)
  trOffset.localScale = Vector3(s, s, 1)
  local imgBody = (trOffset:GetChild(0)):GetComponent("Image")
  local imgFace = (trOffset:GetChild(1)):GetComponent("Image")
  ;
  (NovaAPI.SetImageSpriteAsset)(imgBody, spBody)
  ;
  (NovaAPI.SetImageSpriteAsset)(imgFace, spFace)
  ;
  (NovaAPI.SetImageNativeSize)(imgBody)
  ;
  (NovaAPI.SetImageNativeSize)(imgFace)
end

Actor2DManager.SetL2D_InBBVEditor = function(rawImg, bIsNpc, nSkinId, bIsCG)
  -- function num : 0_68 , upvalues : goTempL2DIns, _ENV, tbL2DRenderer, Set_RawImg, LoadAsset, Offset, Actor2DManager
  if goTempL2DIns ~= nil then
    destroy(goTempL2DIns)
    goTempL2DIns = nil
  end
  local sL2DPath, sOffsetPath, tbRenderer = nil, nil, nil
  tbRenderer = tbL2DRenderer[1]
  Set_RawImg(tbRenderer, rawImg)
  if bIsNpc == true then
    local mapSkinData = (ConfigTable.GetData)("NPCSkin", nSkinId)
    if mapSkinData == nil then
      printError("未找到NPC皮肤数据")
    end
    sL2DPath = mapSkinData.L2D
    sOffsetPath = mapSkinData.Offset
  else
    do
      local mapSkinData = (ConfigTable.GetData_CharacterSkin)(nSkinId)
      if mapSkinData == nil then
        printError("未找到角色皮肤数据")
      end
      sL2DPath = mapSkinData.L2D
      sOffsetPath = mapSkinData.Offset
      if bIsCG == true then
        local nCGId = mapSkinData.CharacterCG
        local mapCGData = (ConfigTable.GetData)("CharacterCG", nCGId)
        if mapCGData == nil then
          printError("未找到角色皮肤的CG数据")
        end
        sL2DPath = mapCGData.FullScreenL2D
      end
      do
        local objL2DPrefab = LoadAsset(sL2DPath, Object)
        goTempL2DIns = instantiate(objL2DPrefab, tbRenderer.parent_L2D)
        -- DECOMPILER ERROR at PC66: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (tbRenderer.parent_L2D).localScale = Vector3.one
        ;
        (goTempL2DIns.transform):SetLayerRecursively((((CS.UnityEngine).LayerMask).NameToLayer)("Cam_Layer_4"))
        if bIsCG ~= true then
          local objOffsetAsset = LoadAsset(sOffsetPath, Offset)
          local nX, nY = 0, 0
          local s, x, y = objOffsetAsset:GetOffsetData(PanelId.MainView, indexOfPose("a"), true, nX, nY)
          -- DECOMPILER ERROR at PC100: Confused about usage of register: R14 in 'UnsetPending'

          ;
          (tbRenderer.trOffset).localPosition = Vector3(x, y, 0)
          -- DECOMPILER ERROR at PC107: Confused about usage of register: R14 in 'UnsetPending'

          ;
          (tbRenderer.trOffset).localScale = Vector3(s, s, 1)
        else
          do
            -- DECOMPILER ERROR at PC112: Confused about usage of register: R8 in 'UnsetPending'

            ;
            (tbRenderer.trOffset).localPosition = Vector3.zero
            -- DECOMPILER ERROR at PC116: Confused about usage of register: R8 in 'UnsetPending'

            ;
            (tbRenderer.trOffset).localScale = Vector3.one
            ;
            (Actor2DManager.PlayL2DAnim_InBBVEditor)("idle", true)
          end
        end
      end
    end
  end
end

Actor2DManager.PlayL2DAnim_InBBVEditor = function(sAnimName, bLoop)
  -- function num : 0_69 , upvalues : goTempL2DIns, Actor2DManager
  if bLoop ~= true then
    (Actor2DManager.PlayL2DAnim)(goTempL2DIns.transform, sAnimName, goTempL2DIns == nil, true)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

Actor2DManager.DestroyL2D_InBBVEditor = function()
  -- function num : 0_70 , upvalues : goTempL2DIns, _ENV
  if goTempL2DIns ~= nil then
    destroy(goTempL2DIns)
    goTempL2DIns = nil
  end
end

local getDisc2DAssetsPath = function(nDiscId, bUseL2D)
  -- function num : 0_71 , upvalues : _ENV, GameResourceLoader, sRootPath
  local mapCfg = (ConfigTable.GetData)("Disc", nDiscId)
  do
    if mapCfg ~= nil then
      local sPath = ""
      if bUseL2D then
        sPath = mapCfg.DiscBg .. (AllEnum.DiscBgSurfix).L2d
        if (GameResourceLoader.ExistsAsset)(Settings.AB_ROOT_PATH .. sPath .. ".prefab") then
          return (AllEnum.Disc2DType).L2D, sPath
        end
        sPath = mapCfg.DiscBg .. (AllEnum.DiscBgSurfix).Main
        if (GameResourceLoader.ExistsAsset)(Settings.AB_ROOT_PATH .. sPath .. ".prefab") then
          return (AllEnum.Disc2DType).Main, sPath
        end
      end
      sPath = mapCfg.DiscBg .. (AllEnum.DiscBgSurfix).Image
      if (GameResourceLoader.ExistsAsset)(sRootPath .. sPath .. ".png") then
        return (AllEnum.Disc2DType).Base, sPath
      end
    end
    return 0, ""
  end
end

local SetDiscL2D = function(sL2D, rawImg, nIndex)
  -- function num : 0_72 , upvalues : GetRenderer, GetL2DIns, _ENV, SetL2DInsParent, Set_RawImg
  local tbRenderer = GetRenderer(sL2D, false, nIndex)
  if tbRenderer == nil then
    return 
  end
  do
    if tbRenderer.sL2D == nil then
      local trIns, bIsNew = GetL2DIns(sL2D)
      if trIns == nil then
        printError("未找到根节点")
      end
      tbRenderer.sL2D = sL2D
      tbRenderer.trL2DIns = trIns
      if bIsNew == true then
        trIns:SetLayerRecursively(tbRenderer.nLayerIndex)
      end
      SetL2DInsParent(trIns, tbRenderer.parent_L2D)
    end
    local v3TargetLocalPos = Vector3(0, 0, 0)
    local v3TargetLocalScale = Vector3.one
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trOffset).localPosition = v3TargetLocalPos
    -- DECOMPILER ERROR at PC40: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trOffset).localScale = v3TargetLocalScale
    -- DECOMPILER ERROR at PC44: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.parent_L2D).localScale = Vector3.one
    -- DECOMPILER ERROR at PC48: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trFreeDrag).localPosition = Vector3.zero
    -- DECOMPILER ERROR at PC52: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trFreeDrag).localScale = Vector3.one
    Set_RawImg(tbRenderer, rawImg)
  end
end

local SetDiscPortrait = function(sPortrait, rawImg, nIndex)
  -- function num : 0_73 , upvalues : GetRenderer, _ENV, GetSprite, Set_RawImg
  local tbRenderer = GetRenderer(sPortrait, false, nIndex)
  if tbRenderer == nil then
    printError("未找到 Renderer")
  end
  if tbRenderer.sL2D == nil then
    (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_body, GetSprite(sPortrait, sPortrait, true))
    ;
    (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_face, nil)
    tbRenderer.sL2D = sPortrait
  end
  local v3TargetLocalPos = Vector3(0, 0, 0)
  local v3TargetLocalScale = Vector3.one
  -- DECOMPILER ERROR at PC36: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localPosition = v3TargetLocalPos
  -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localScale = v3TargetLocalScale
  -- DECOMPILER ERROR at PC42: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.parent_PNG).localScale = Vector3.one
  -- DECOMPILER ERROR at PC46: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localPosition = Vector3.zero
  -- DECOMPILER ERROR at PC50: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localScale = Vector3.one
  Set_RawImg(tbRenderer, rawImg)
end

Actor2DManager.SetDisc2D = function(nDiscId, rawImg, bUseL2D, nIndex)
  -- function num : 0_74 , upvalues : mapActor2DType, LoadLocalData, mapCurrent, L2DType, Actor2DManager, LocalSettingData, getDisc2DAssetsPath, _ENV, SetDiscL2D, SetDiscPortrait
  if mapActor2DType["1"] ~= true then
    LoadLocalData()
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurDisc = (mapCurrent.tbDisc)[nIndex]
  if mapCurrent.L2DType == L2DType.Char then
    (Actor2DManager.UnsetActor2D)(true, nIndex)
  else
    if mapCurrent.L2DType == L2DType.Disc then
      (Actor2DManager.UnSetDisc2D)(true, nIndex)
    else
      if mapCurrent.L2DType == L2DType.CG then
        (Actor2DManager.UnSetCg2D)(true, nIndex)
      end
    end
  end
  local bL = not (LocalSettingData.mapData).UseLive2D or bUseL2D
  local nType, sPath = getDisc2DAssetsPath(nDiscId, bL)
  if nType == 0 then
    print("找不到星盘资源！！！nDiscId = " .. nDiscId)
    return 
  end
  if nType == (AllEnum.Disc2DType).Main or nType == (AllEnum.Disc2DType).L2D then
    sPath = sPath .. ".prefab"
    SetDiscL2D(sPath, rawImg, nIndex)
  else
    SetDiscPortrait(sPath, rawImg, nIndex)
  end
  mapCurDisc.nDiscId = nDiscId
  mapCurDisc.sAssetPath = sPath
  mapCurDisc.rawImg = rawImg
  mapCurrent.nPanelId = 0
  mapCurrent.nOffsetPanelId = 0
  mapCurrent.nActor2DType = 0
  mapCurrent.bUseL2D = nType == (AllEnum.Disc2DType).L2D
  mapCurrent.bUseFull = false
  mapCurrent.L2DType = L2DType.Disc
  if nType == (AllEnum.Disc2DType).L2D then
    (Actor2DManager.PlayAnim)("idle", true, nIndex)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

Actor2DManager.UnSetDisc2D = function(bKeepData, nIndex, bForce)
  -- function num : 0_75 , upvalues : mapCurrent, L2DType, _ENV, GetRenderer, ResetRenderer, tbL2DRenderer, UnInit_RT
  if not mapCurrent.L2DType == L2DType.Disc then
    return 
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurDisc = (mapCurrent.tbDisc)[nIndex]
  do
    if type(mapCurDisc.sAssetPath) == "string" and mapCurDisc.sAssetPath ~= "" then
      local tbRenderer = GetRenderer(mapCurDisc.sAssetPath, true)
      if tbRenderer ~= nil then
        ResetRenderer(tbRenderer)
      end
    end
    if bForce == true and nIndex ~= nil and tbL2DRenderer ~= nil and tbL2DRenderer[nIndex] ~= nil then
      UnInit_RT(tbL2DRenderer[nIndex])
    end
    if bKeepData ~= true then
      mapCurDisc.nDiscId = 0
      mapCurDisc.sAssetPath = nil
      mapCurDisc.rawImg = nil
      mapCurrent.nType = 0
    end
    mapCurrent.L2DType = L2DType.None
  end
end

local getCg2DAssetsPath = function(nCgId, bUseL2D)
  -- function num : 0_76 , upvalues : _ENV, GameResourceLoader, sRootPath
  local mapCfg = (ConfigTable.GetData)("MainScreenCG", nCgId)
  if mapCfg ~= nil then
    local sPath = ""
    if bUseL2D then
      sPath = mapCfg.FullScreenL2D
      if (GameResourceLoader.ExistsAsset)(Settings.AB_ROOT_PATH .. sPath .. ".prefab") then
        return (AllEnum.Cg2DType).L2D, sPath
      end
    end
    local tbResource = (PlayerData.Handbook):GetPlotResourcePath(nCgId)
    sPath = tbResource.FullScreenImg
    if (GameResourceLoader.ExistsAsset)(sRootPath .. sPath .. ".png") then
      return (AllEnum.Cg2DType).Base, sPath
    end
  end
  do
    return 0, ""
  end
end

local SetCgL2D = function(sL2D, rawImg, nIndex)
  -- function num : 0_77 , upvalues : GetRenderer, GetL2DIns, _ENV, SetL2DInsParent, Set_RawImg
  local tbRenderer = GetRenderer(sL2D, false, nIndex)
  if tbRenderer == nil then
    return 
  end
  do
    if tbRenderer.sL2D == nil then
      local trIns, bIsNew = GetL2DIns(sL2D)
      if trIns == nil then
        printError("未找到根节点")
      end
      tbRenderer.sL2D = sL2D
      tbRenderer.trL2DIns = trIns
      if bIsNew == true then
        trIns:SetLayerRecursively(tbRenderer.nLayerIndex)
      end
      SetL2DInsParent(trIns, tbRenderer.parent_L2D)
    end
    local v3TargetLocalPos = Vector3(0, 0, 0)
    local v3TargetLocalScale = Vector3.one
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trOffset).localPosition = v3TargetLocalPos
    -- DECOMPILER ERROR at PC40: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trOffset).localScale = v3TargetLocalScale
    -- DECOMPILER ERROR at PC44: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.parent_L2D).localScale = Vector3.one
    -- DECOMPILER ERROR at PC48: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trFreeDrag).localPosition = Vector3.zero
    -- DECOMPILER ERROR at PC52: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (tbRenderer.trFreeDrag).localScale = Vector3.one
    Set_RawImg(tbRenderer, rawImg)
  end
end

local SetCgPortrait = function(sPortrait, rawImg, nIndex)
  -- function num : 0_78 , upvalues : GetRenderer, _ENV, GetSprite, Set_RawImg
  local tbRenderer = GetRenderer(sPortrait, false, nIndex)
  if tbRenderer == nil then
    printError("未找到 Renderer")
  end
  if tbRenderer.sL2D == nil then
    (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_body, GetSprite(sPortrait, sPortrait, true))
    ;
    (NovaAPI.SetSpriteRendererSprite)(tbRenderer.spr_face, nil)
    tbRenderer.sL2D = sPortrait
  end
  local v3TargetLocalPos = Vector3(0, 0, 0)
  local v3TargetLocalScale = Vector3.one
  -- DECOMPILER ERROR at PC36: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localPosition = v3TargetLocalPos
  -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trOffset).localScale = v3TargetLocalScale
  -- DECOMPILER ERROR at PC42: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.parent_PNG).localScale = Vector3.one
  -- DECOMPILER ERROR at PC46: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localPosition = Vector3.zero
  -- DECOMPILER ERROR at PC50: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (tbRenderer.trFreeDrag).localScale = Vector3.one
  Set_RawImg(tbRenderer, rawImg)
end

Actor2DManager.SetCg2D = function(nCgId, rawImg, bUseL2D, nIndex)
  -- function num : 0_79 , upvalues : mapActor2DType, LoadLocalData, mapCurrent, L2DType, Actor2DManager, LocalSettingData, getCg2DAssetsPath, _ENV, SetCgL2D, SetCgPortrait
  if mapActor2DType["1"] ~= true then
    LoadLocalData()
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurCg = (mapCurrent.tbCg)[nIndex]
  if mapCurrent.L2DType == L2DType.Char then
    (Actor2DManager.UnsetActor2D)(true, nIndex)
  else
    if mapCurrent.L2DType == L2DType.Disc then
      (Actor2DManager.UnSetDisc2D)(true, nIndex)
    else
      if mapCurrent.L2DType == L2DType.CG then
        (Actor2DManager.UnSetCg2D)(true, nIndex)
      end
    end
  end
  local bL = not (LocalSettingData.mapData).UseLive2D or bUseL2D
  local nType, sPath = getCg2DAssetsPath(nCgId, bL)
  if nType == 0 then
    print("找不到CG资源！！！nCgId = " .. nCgId)
    return 
  end
  if nType == (AllEnum.Cg2DType).L2D then
    sPath = sPath .. ".prefab"
    SetCgL2D(sPath, rawImg, nIndex)
  else
    SetCgPortrait(sPath, rawImg, nIndex)
  end
  mapCurCg.nCgId = nCgId
  mapCurCg.sAssetPath = sPath
  mapCurCg.rawImg = rawImg
  mapCurrent.nPanelId = 0
  mapCurrent.nOffsetPanelId = 0
  mapCurrent.nActor2DType = 0
  mapCurrent.bUseL2D = nType == (AllEnum.Cg2DType).L2D
  mapCurrent.bUseFull = true
  mapCurrent.L2DType = L2DType.CG
  if nType == (AllEnum.Cg2DType).L2D then
    (Actor2DManager.PlayAnim)("idle", true, nIndex)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

Actor2DManager.UnSetCg2D = function(bKeepData, nIndex, bForce)
  -- function num : 0_80 , upvalues : mapCurrent, L2DType, _ENV, GetRenderer, ResetRenderer, tbL2DRenderer, UnInit_RT
  if not mapCurrent.L2DType == L2DType.CG then
    return 
  end
  if nIndex == nil then
    nIndex = 1
  end
  local mapCurCg = (mapCurrent.tbCg)[nIndex]
  do
    if type(mapCurCg.sAssetPath) == "string" and mapCurCg.sAssetPath ~= "" then
      local tbRenderer = GetRenderer(mapCurCg.sAssetPath, true)
      if tbRenderer ~= nil then
        ResetRenderer(tbRenderer)
      end
    end
    if bForce == true and nIndex ~= nil and tbL2DRenderer ~= nil and tbL2DRenderer[nIndex] ~= nil then
      UnInit_RT(tbL2DRenderer[nIndex])
    end
    if bKeepData ~= true then
      mapCurCg.nCgId = 0
      mapCurCg.sAssetPath = nil
      mapCurCg.rawImg = nil
      mapCurrent.nType = 0
    end
    mapCurrent.L2DType = L2DType.None
  end
end

return Actor2DManager

