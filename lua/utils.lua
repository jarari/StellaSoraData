local Debug = (CS.UnityEngine).Debug
Object = (CS.UnityEngine).Object
Sprite = (CS.UnityEngine).Sprite
Texture = (CS.UnityEngine).Texture
Color = (CS.UnityEngine).Color
ColorUtility = (CS.UnityEngine).ColorUtility
Transform = (CS.UnityEngine).Transform
RectTransform = (CS.UnityEngine).RectTransform
GameObject = (CS.UnityEngine).GameObject
Vector2 = (CS.UnityEngine).Vector2
Vector3 = (CS.UnityEngine).Vector3
Quaternion = (CS.UnityEngine).Quaternion
NovaAPI = CS.NovaAPI
CSTimerManager = CS.TimerManager
DOTween = ((CS.DG).Tweening).DOTween
Sequence = (((CS.DG).Tweening).DOTween).Sequence
Ease = ((CS.DG).Tweening).Ease
RotateMode = ((CS.DG).Tweening).RotateMode
TweenExtensions = CS.TweenExtensions
GameUIUtils = CS.GameUIUtils
local PB = require("pb")
require("functions")
local rapidjson = require("rapidjson")
GameEnum = require("Game.CodeGen.GAME_ENUM_DEFINE")
AllEnum = require("GameCore.Common.AllEnum")
Settings = require("GameCore.Common.Settings")
EventId = require("GameCore.Event.EventId")
EventManager = require("GameCore.Event.EventManager")
PlayerData = require("GameCore.Data.PlayerData")
NetMsgId = require("GameCore.Network.NetMsgId")
HttpNetHandler = require("GameCore.Network.HttpNetHandler")
PanelId = require("GameCore.UI.PanelId")
PanelManager = require("GameCore.UI.PanelManager")
BasePanel = require("GameCore.UI.BasePanel")
BaseCtrl = require("GameCore.UI.BaseCtrl")
RedDotDefine = require("GameCore.RedDot.RedDotDefine")
RedDotManager = require("GameCore.RedDot.RedDotManager")
PopUpManager = require("GameCore.Data.PopUpManager")
local util = require("xlua.util")
async_to_sync = util.async_to_sync
coroutine_call = util.coroutine_call
cs_generator = util.cs_generator
loadpackage = util.loadpackage
auto_id_map = util.auto_id_map
hotfix_ex = util.hotfix_ex
bind = util.bind
createdelegate = util.createdelegate
state = util.state
print_func_ref_by_csharp = util.print_func_ref_by_csharp
cs_coroutine = require("xlua.cs_coroutine")
local serpent = require("serpent")
printLog = function(str)
  -- function num : 0_0 , upvalues : Debug
  (Debug.Log)(str)
end

printWarn = function(str)
  -- function num : 0_1 , upvalues : Debug
  (Debug.LogWarning)(str)
end

printError = function(str)
  -- function num : 0_2 , upvalues : Debug
  (Debug.LogError)(str)
end

printTable = function(tb)
  -- function num : 0_3 , upvalues : _ENV, serpent
  if type(tb) == "table" then
    print((serpent.block)(tb))
  end
end

traceback = function(str)
  -- function num : 0_4 , upvalues : Debug, _ENV
  (Debug.LogError)((debug.traceback)(str))
end

timeFormat_MS = function(value)
  -- function num : 0_5 , upvalues : _ENV
  local min = (math.floor)(value / 60)
  local sec = value - min * 60
  if min < 10 then
    min = "0" .. min
  end
  if sec < 10 then
    sec = "0" .. sec
  end
  return min .. ":" .. sec
end

timeFormat_HMS = function(value)
  -- function num : 0_6 , upvalues : _ENV
  local hor = (math.floor)(value / 60 / 60)
  local min = (math.floor)((value - hor * 60 * 60) / 60)
  local sec = value - hor * 60 * 60 - min * 60
  if hor < 10 then
    hor = "0" .. hor
  end
  if min < 10 then
    min = "0" .. min
  end
  if sec < 10 then
    sec = "0" .. sec
  end
  return hor .. ":" .. min .. ":" .. sec
end

timeFormat_DHMS = function(value)
  -- function num : 0_7 , upvalues : _ENV
  local day = (math.floor)(value / 60 / 60 / 24)
  value = value % 86400
  local hor = (math.floor)(value / 60 / 60)
  local min = (math.floor)((value - hor * 60 * 60) / 60)
  local sec = value - hor * 60 * 60 - min * 60
  if hor < 10 then
    hor = "0" .. hor
  end
  if min < 10 then
    min = "0" .. min
  end
  if sec < 10 then
    sec = "0" .. sec
  end
  if day > 0 then
    return (string.format)("%dd %s", day, hor .. ":" .. min .. ":" .. sec)
  else
    return hor .. ":" .. min .. ":" .. sec
  end
end

timeFormat_Table = function(value)
  -- function num : 0_8 , upvalues : _ENV
  local tbTime = {}
  local day = (math.floor)(value / 60 / 60 / 24)
  value = value % 86400
  local hour = (math.floor)(value / 60 / 60)
  local min = (math.floor)((value - hour * 60 * 60) / 60)
  local sec = value - hour * 60 * 60 - min * 60
  tbTime.day = day
  tbTime.hour = hour
  tbTime.min = min
  tbTime.sec = sec
  return tbTime
end

GetNextWeekRefreshTime = function()
  -- function num : 0_9 , upvalues : _ENV
  local nCurTimeWithTimeZone = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  local tbCurDate = (os.date)("!*t", nCurTimeWithTimeZone)
  local nCurWeekday = tbCurDate.wday
  if nCurWeekday ~= 1 or not 7 then
    nCurWeekday = nCurWeekday - 1
  end
  local nDays = 7 - (nCurWeekday)
  local nDailyRefreshOffsetHour = (ConfigTable.GetConfigNumber)("DailyRefreshOffsetHour")
  if tbCurDate.hour < nDailyRefreshOffsetHour then
    if nCurWeekday == 1 then
      nDays = 0
    else
      nDays = nDays + 1
    end
  end
  local nNextOpenTime = ((CS.ClientManager).Instance):GetNextRefreshTime(nCurTime)
  if nDays > 0 then
    for i = 1, nDays do
      nCurTime = nNextOpenTime
      nNextOpenTime = ((CS.ClientManager).Instance):GetNextRefreshTime(nCurTime)
    end
  end
  do
    return nNextOpenTime
  end
end

FormatNum = function(num)
  -- function num : 0_10 , upvalues : _ENV
  if num <= 0 then
    return 0
  else
    local t1, t2 = (math.modf)(num)
    if t2 > 0 then
      return num
    else
      return t1
    end
  end
end

FormatEffectValue = function(nValue, bPercent, nFormat)
  -- function num : 0_11 , upvalues : _ENV
  if bPercent then
    nValue = nValue * 100
  end
  if nValue == 0 and bPercent then
    return "0%"
  end
  local sValue = nil
  if nFormat == (GameEnum.ValueFormat).Int then
    nValue = (math.floor)(nValue)
    sValue = (string.format)("%d", nValue)
  else
    if nFormat == (GameEnum.ValueFormat).ODP then
      sValue = (string.format)("%.1f", nValue)
      sValue = sValue:gsub("0+$", "")
    else
      if nFormat == (GameEnum.ValueFormat).TDP then
        sValue = (string.format)("%.2f", nValue)
        sValue = sValue:gsub("0+$", "")
      end
    end
  end
  sValue = sValue:gsub("%.$", "")
  if bPercent then
    sValue = sValue .. "%"
  end
  return sValue
end

FormatWithCommas = function(nValue)
  -- function num : 0_12 , upvalues : _ENV
  local s, integer, decimal = tostring(nValue), "", ""
  local dot = (string.find)(s, "%.")
  if dot then
    integer = (string.sub)(s, 1, dot - 1)
    decimal = (string.sub)(s, dot + 1)
  else
    integer = s
  end
  integer = (string.reverse)(integer)
  integer = (string.gsub)(integer, "(%d%d%d)", "%1,")
  integer = (string.reverse)(integer)
  if (string.sub)(integer, 1, 1) == "," then
    integer = (string.sub)(integer, 2)
  end
  if decimal ~= "" then
    return integer .. "." .. decimal
  else
    return integer
  end
end

indexOfPose = function(sPose)
  -- function num : 0_13 , upvalues : _ENV
  local tbCharPose = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "aj", "ak", "al", "am", "an", "ao", "ap", "aq", "ar", "as", "at", "au", "av", "aw", "ax", "ay", "az"}
  local nIdx = (table.indexof)(tbCharPose, sPose)
  if nIdx < 0 then
    nIdx = 0
  end
  return nIdx
end

instantiate = function(...)
  -- function num : 0_14 , upvalues : _ENV
  return (GameObject.Instantiate)(...)
end

destroy = function(obj)
  -- function num : 0_15 , upvalues : _ENV
  if not obj:IsNull() then
    (GameObject.Destroy)(obj)
  end
end

destroyImmediate = function(obj)
  -- function num : 0_16 , upvalues : _ENV
  if not obj:IsNull() then
    (GameObject.DestroyImmediate)(obj)
  end
end

luaCoroutineStart = function(runner, ...)
  -- function num : 0_17 , upvalues : util
  return runner:StartCoroutine((util.cs_generator)(...))
end

luaCoroutineStop = function(runner, coroutine)
  -- function num : 0_18
  runner:StopCoroutine(coroutine)
end

delChildren = function(go)
  -- function num : 0_19 , upvalues : _ENV
  if (go.transform).childCount > 0 then
    for i = (go.transform).childCount, 1, -1 do
      local obj = ((go.transform):GetChild(i - 1)).gameObject
      destroy(obj)
    end
  end
end

ProcContentWord = function(sContentWord, bUsePresetColor)
  -- function num : 0_20 , upvalues : _ENV
  if bUsePresetColor == nil then
    bUsePresetColor = false
  end
  local tbContent = (string.split)(sContentWord, "$")
  local sRetContent = tbContent[1]
  for i,v in ipairs(tbContent) do
    if i > 1 then
      local sHeadFourChar = (string.sub)(v, 1, 4)
      local nWordId = (tonumber(sHeadFourChar))
      local sWord = nil
      do
        if type(nWordId) == "number" then
          local data = (ConfigTable.GetData)("ContentWord", nWordId)
          if data ~= nil then
            sWord = data.Word
          end
        end
        if sWord == nil then
          sWord = "$" .. v
        else
          do
            do
              if not ((ConfigTable.GetData)("ContentWord", nWordId)).PresetColor then
                local sColor = bUsePresetColor ~= true or ""
              end
              if sColor ~= "" then
                sWord = (string.format)("<color=%s>%s</color>", sColor, sWord)
              end
              sWord = (string.gsub)(v, sHeadFourChar, sWord)
              sRetContent = sRetContent .. sWord
              -- DECOMPILER ERROR at PC74: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC74: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC74: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC74: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC74: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC74: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  return sRetContent
end

GetLanguageIndex = function(sLan)
  -- function num : 0_21 , upvalues : _ENV
  for i,v in ipairs(AllEnum.LanguageInfo) do
    if v[1] == sLan then
      return i
    end
  end
  return 1
end

GetLanguageByIndex = function(nIndex)
  -- function num : 0_22 , upvalues : _ENV
  local tbLanInfo = (AllEnum.LanguageInfo)[nIndex]
  if tbLanInfo ~= nil then
    return tbLanInfo[1]
  else
    return (AllEnum.Language).CN
  end
end

GetLanguageSurfixByIndex = function(nIndex)
  -- function num : 0_23 , upvalues : _ENV
  local tbLanInfo = (AllEnum.LanguageInfo)[nIndex]
  if tbLanInfo ~= nil then
    return tbLanInfo[3]
  else
    return "_cn"
  end
end

GetAvgLuaRequireRoot = function(nIndex)
  -- function num : 0_24 , upvalues : _ENV
  local sFolderSurfix = GetLanguageSurfixByIndex(nIndex) .. "/"
  local sRootPath = "Game/UI/Avg/" .. sFolderSurfix
  if AVG_EDITOR == true and (NovaAPI.IsRuntimeWindowsPlayer)() == true then
    sRootPath = "/../../../../" .. sFolderSurfix
  end
  return sRootPath
end

ProcAvgTextContent = function(sContent, nLanguageIndex)
  -- function num : 0_25 , upvalues : _ENV
  local nIndex = (PlayerData.Base):GetPlayerSex() == true and 2 or 1
  if nLanguageIndex == nil then
    nLanguageIndex = GetLanguageIndex(Settings.sCurrentTxtLanguage)
  end
  if nLanguageIndex < 1 or #AllEnum.LanguageInfo < nLanguageIndex then
    nLanguageIndex = 1
  end
  sContent = ProcContentWord(sContent, true)
  sContent = (string.gsub)(sContent, "==RT==", "\n")
  sContent = (string.gsub)(sContent, "==PLAYER_NAME==", (PlayerData.Base):GetPlayerNickName())
  local AvgUIText = require(GetAvgLuaRequireRoot(nLanguageIndex) .. "Preset/AvgUIText")
  local mapSex = AvgUIText.SEX
  for k,v in pairs(mapSex) do
    sContent = (string.gsub)(sContent, k, v[nIndex])
  end
  return sContent
end

ProcAvgTextContentFallback = function(sTextLan, sVoLan, bIsMale, sCN_F, sCN_M, sJP_F, sJP_M)
  -- function num : 0_26 , upvalues : _ENV
  if sCN_F == nil then
    sCN_F = ""
  end
  if sCN_M == nil then
    sCN_M = ""
  end
  if sJP_F == nil then
    sJP_F = ""
  end
  if sJP_M == nil then
    sJP_M = ""
  end
  local sContent = ""
  local tbFallback = nil
  if sTextLan == (AllEnum.Language).CN then
    tbFallback = {sCN_F}
    if bIsMale == true then
      (table.insert)(tbFallback, sCN_M)
    end
    if sVoLan == (AllEnum.Language).JP then
      (table.insert)(tbFallback, sJP_F)
      if bIsMale == true then
        (table.insert)(tbFallback, sJP_M)
      end
    end
  else
    if sTextLan == (AllEnum.Language).JP then
      tbFallback = {sJP_F}
      if MULTI_LANGUAGE_GENDER_TEXT_COMPATIBLE == true and sJP_F == "" then
        (table.insert)(tbFallback, sCN_F)
      end
      if bIsMale == true then
        (table.insert)(tbFallback, sJP_M)
        if MULTI_LANGUAGE_GENDER_TEXT_COMPATIBLE == true and sJP_M == "" then
          (table.insert)(tbFallback, sCN_M)
        end
      end
    else
      if sTextLan == (AllEnum.Language).TW or sTextLan == (AllEnum.Language).EN or sTextLan == (AllEnum.Language).KR then
        tbFallback = {sJP_F}
        if bIsMale == true then
          (table.insert)(tbFallback, sJP_M)
        end
        if sVoLan == (AllEnum.Language).CN then
          (table.insert)(tbFallback, sCN_F)
          if bIsMale == true then
            (table.insert)(tbFallback, sCN_M)
          end
        end
        if MULTI_LANGUAGE_GENDER_TEXT_COMPATIBLE == true and sVoLan == (AllEnum.Language).JP and sJP_F == "" and sJP_M == "" then
          (table.insert)(tbFallback, sCN_F)
          if bIsMale == true then
            (table.insert)(tbFallback, sCN_M)
          end
        end
      end
    end
  end
  if type(tbFallback) == "table" then
    local n = #tbFallback
    for i = n, 1, -1 do
      local s = tbFallback[i]
      if type(s) == "string" and s ~= "" then
        sContent = s
        break
      end
    end
  end
  do
    return sContent
  end
end

AdjustMainRoleAvgCharId = function(sAvgCharId)
  -- function num : 0_27 , upvalues : _ENV
  if sAvgCharId == nil then
    sAvgCharId = "avg3_100"
  end
  local tbMainRoleAvgCharId = {"avg3_100", "avg3_101"}
  local nIdx = (table.indexof)(tbMainRoleAvgCharId, sAvgCharId)
  do
    if (PlayerData.Base):GetPlayerSex() ~= true or not 2 then
      local nIndex = nIdx <= 0 or 1
    end
    do return tbMainRoleAvgCharId[nIndex] end
    do return sAvgCharId end
  end
end

CalcTextAnimDuration = function(sContent, nLanguageIndex, bIsBB)
  -- function num : 0_28 , upvalues : _ENV
  local tbInterval = {0.03, 0.03, 0.03, 0.01, 0.03}
  local tbIntervalForBB = {0.25, 0.25, 0.25, 0.083, 0.25}
  if bIsBB ~= true or not tbIntervalForBB[nLanguageIndex] then
    local nInterval = tbInterval[nLanguageIndex]
  end
  if nInterval == nil and (bIsBB ~= true or not tbIntervalForBB[1]) then
    nInterval = tbInterval[1]
  end
  local sPureContent = (string.gsub)(sContent, "<.->", "")
  sPureContent = (string.gsub)(sPureContent, "\n", "")
  local nDuration = (string.utf8len)(sPureContent) * nInterval
  return nDuration
end

Avg_ProcRes_M_F = function(sName)
  -- function num : 0_29 , upvalues : _ENV
  local nLen = (string.len)(sName)
  local surfix = (string.sub)(sName, nLen - 2, nLen)
  if surfix == "_MP" or surfix == "_FP" then
    if (PlayerData.Base):GetPlayerSex() == true then
      surfix = "_MP"
    else
      surfix = "_FP"
    end
    sName = (string.sub)(sName, 1, nLen - 3) .. surfix
    return sName
  else
    return sName
  end
end

Avg_ProcEnquotes = function(s)
  -- function num : 0_30 , upvalues : _ENV
  s = (string.gsub)(s, "\\", "")
  s = (string.gsub)(s, "\'", "\\\'")
  s = (string.gsub)(s, "\"", "\\\"")
  return s
end

decodeJson = function(sJson)
  -- function num : 0_31 , upvalues : _ENV, rapidjson
  local tbData = {}
  if type(sJson) == "string" and sJson ~= "" then
    tbData = (rapidjson.decode)(sJson)
    if tbData == nil then
      tbData = {}
      printError("json文本配置格式有误，该文本为：" .. sJson)
    end
  end
  return tbData
end

IsStartsWith = function(str, start)
  -- function num : 0_32 , upvalues : _ENV
  do return (string.sub)(str, 1, (string.len)(start)) == start end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

UFT8ToUnicode = function(convertStr)
  -- function num : 0_33 , upvalues : _ENV
  if type(convertStr) ~= "string" then
    return convertStr
  end
  local resultDec = 0
  local i = 1
  local num1 = (string.byte)(convertStr, i)
  if num1 ~= nil then
    local tempVar1, tempVar2 = 0, 0
    if num1 >= 0 and num1 <= 127 then
      tempVar1 = num1
      tempVar2 = 0
    else
      if num1 & 224 == 192 then
        local t1 = 0
        local t2 = 0
        t1 = num1 & 31
        i = i + 1
        num1 = (string.byte)(convertStr, i)
        t2 = num1 & 63
        tempVar1 = t2 | (t1 & 3) << 6
        tempVar2 = (t1) >> 2
      else
        do
          if num1 & 240 == 224 then
            local t1 = 0
            local t2 = 0
            local t3 = 0
            t1 = num1 & 31
            i = i + 1
            num1 = (string.byte)(convertStr, i)
            t2 = num1 & 63
            i = i + 1
            num1 = (string.byte)(convertStr, i)
            t3 = num1 & 63
            tempVar1 = (t2 & 3) << 6 | t3
            tempVar2 = (t1) << 4 | (t2) >> 2
          end
          do
            do
              resultDec = (tempVar2) * 256 + (tempVar1)
              return resultDec
            end
          end
        end
      end
    end
  end
end

local DecodeChangeInfo = function(mapChangeInfo)
  -- function num : 0_34 , upvalues : _ENV, PB
  local mapDecodedChangeInfo = {}
  if type(mapChangeInfo) ~= "table" then
    return mapDecodedChangeInfo
  end
  if mapChangeInfo.Props == nil then
    return mapDecodedChangeInfo
  end
  for nIndex,mapGoogleProtobufAny in ipairs(mapChangeInfo.Props) do
    if mapGoogleProtobufAny.type_url == "" or mapGoogleProtobufAny.type_url == nil then
      printError("ChangeInfo 格式错误")
      return mapDecodedChangeInfo
    end
    local tbSubUrl = (string.split)(mapGoogleProtobufAny.type_url, "/")
    local sProtoMsgName = tbSubUrl[2]
    local mapDecodedData = (PB.decode)(sProtoMsgName, mapGoogleProtobufAny.value)
    if mapDecodedChangeInfo[sProtoMsgName] == nil then
      mapDecodedChangeInfo[sProtoMsgName] = {}
    end
    ;
    (table.insert)(mapDecodedChangeInfo[sProtoMsgName], mapDecodedData)
  end
  return mapDecodedChangeInfo
end

local OpenReceiveByChangeInfo = function(mapChangeInfo, callback, sTip)
  -- function num : 0_35 , upvalues : _ENV
  local mapReward = (PlayerData.Item):ProcessRewardChangeInfo(mapChangeInfo)
  ;
  (UTILS.OpenReceiveByReward)(mapReward, callback, sTip)
end

local OpenReceiveByDisplayItem = function(tbItem, mapChangeInfo, callback, sTip, nTitleType)
  -- function num : 0_36 , upvalues : _ENV
  local mapTrans = (PlayerData.Item):ProcessTransChangeInfo(mapChangeInfo)
  local tbReward, tbSpReward = (PlayerData.Item):ProcessRewardDisplayItem(tbItem, mapTrans)
  local mapReward = {tbReward = tbReward, tbSpReward = tbSpReward, tbSrc = mapTrans.tbSrc, tbDst = mapTrans.tbDst}
  ;
  (UTILS.OpenReceiveByReward)(mapReward, callback, sTip, nTitleType)
end

local OpenReceiveByReward = function(mapReward, callback, sTip, nTitleType)
  -- function num : 0_37 , upvalues : _ENV
  local bOverflow = (PlayerData.State):GetMailOverflow()
  local open_mail = function()
    -- function num : 0_37_0 , upvalues : bOverflow, _ENV, callback
    if bOverflow then
      (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Mail_Overflow_Tip"), callbackConfirm = callback})
      ;
      (PlayerData.State):SetMailOverflow(false)
    else
      if callback then
        callback()
      end
    end
  end

  local open_trans = function()
    -- function num : 0_37_1 , upvalues : _ENV, mapReward, open_mail
    local tbSrc, tbDst = {}, {}
    local mapOverTrans = (PlayerData.Item):GetFragmentsOverflow()
    if mapOverTrans and mapOverTrans.tbSrc and #mapOverTrans.tbSrc > 0 then
      for _,v in ipairs(mapOverTrans.tbSrc) do
        (table.insert)(tbSrc, v)
      end
      for _,v in ipairs(mapOverTrans.tbDst) do
        (table.insert)(tbDst, v)
      end
    end
    do
      if mapReward and mapReward.tbSrc and #mapReward.tbSrc > 0 then
        for _,v in ipairs(mapReward.tbSrc) do
          (table.insert)(tbSrc, v)
        end
        for _,v in ipairs(mapReward.tbDst) do
          (table.insert)(tbDst, v)
        end
      end
      do
        if #tbDst > 0 and #tbSrc > 0 then
          (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceiveAutoTrans, tbSrc, tbDst, open_mail)
        else
          open_mail()
        end
      end
    end
  end

  local open_normal = function()
    -- function num : 0_37_2 , upvalues : mapReward, _ENV, open_trans, sTip, nTitleType
    if mapReward and mapReward.tbReward and #mapReward.tbReward > 0 then
      (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceivePropsTips, mapReward.tbReward, open_trans, sTip, nTitleType)
    else
      open_trans()
    end
  end

  if mapReward and mapReward.tbSpReward and #mapReward.tbSpReward > 0 then
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceiveSpecialReward, mapReward.tbSpReward, open_normal)
  else
    open_normal()
  end
end

local strLengthConfig = {
{
tbRange = {
{11904, 12255}
, 
{13312, 19903}
, 
{19968, 40959}
}
, sType = "中文", nCount = 2}
, 
{
tbRange = {
{4352, 4607}
, 
{12592, 12687}
, 
{44032, 55215}
}
, sType = "韩文", nCount = 2}
, 
{
tbRange = {
{12352, 12543}
, 
{12784, 12799}
}
, sType = "日文", nCount = 2}
, 
{
tbRange = {
{65280, 65519}
}
, sType = "全角符号", nCount = 2}
}
local GetParamStrLen = function(sParam)
  -- function num : 0_38 , upvalues : _ENV, strLengthConfig
  sParam = (string.gsub)(sParam, "</?[^>]+>", "")
  local nLength = 0
  local nIndex = 1
  while 1 do
    local curByte = (string.byte)(sParam, nIndex)
    local byteCount = 1
    if curByte > 239 then
      byteCount = 4
    else
      if curByte > 223 then
        byteCount = 3
      else
        if curByte > 128 then
          byteCount = 2
        else
          if curByte == 10 then
            byteCount = 1
          else
            byteCount = 1
          end
        end
      end
    end
    local subStr = (string.sub)(sParam, nIndex, nIndex + byteCount - 1)
    local charUnicodeNum = UFT8ToUnicode(subStr)
    local bContains = false
    local nAddCount = 1
    for _,v in ipairs(strLengthConfig) do
      local tbRange = v.tbRange
      for _,range in ipairs(tbRange) do
        if range[1] <= charUnicodeNum and charUnicodeNum <= range[2] then
          bContains = true
          nAddCount = v.nCount
          break
        end
      end
    end
    do
      if not bContains then
        do
          nLength = nLength + nAddCount
          nIndex = nIndex + byteCount
          -- DECOMPILER ERROR at PC73: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC73: LeaveBlock: unexpected jumping out IF_STMT

          -- DECOMPILER ERROR at PC73: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
  end
  if #sParam >= nIndex then
    return nLength
  end
end

local ParseByteString = function(sByte)
  -- function num : 0_39 , upvalues : _ENV
  return {(string.byte)(sByte, 1, -1)}
end

local IsBitSet = function(tbByte, nIndex)
  -- function num : 0_40 , upvalues : _ENV
  local nGroup64 = (math.ceil)(nIndex / 64) - 1
  local nIndexInGroup64 = nIndex - nGroup64 * 64
  local nGroup8 = (math.ceil)(nIndexInGroup64 / 8) - 1
  local nIndexInGroup8 = nIndexInGroup64 - nGroup8 * 8
  local nByteTableIndex = 8 - nGroup8 + nGroup64 * 8
  if not tbByte[nByteTableIndex] then
    return false
  end
  do return 1 << nIndexInGroup8 - 1 & tbByte[nByteTableIndex] > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

local GetBuildAttributeId = function(nGroupId, nLevel)
  -- function num : 0_41
  return nGroupId * 100000 + nLevel
end

local GetCharacterAttributeId = function(nCharId, nAdvance, nLevel)
  -- function num : 0_42
  return nCharId * 100000 + nAdvance * 1000 + nLevel
end

local GetDiscAttributeId = function(nGroupId, nPhase, nLevel)
  -- function num : 0_43
  return nGroupId * 1000 + nPhase * 100 + nLevel
end

local GetDiscExtraAttributeId = function(nGroupId, nStar)
  -- function num : 0_44
  return nGroupId * 10 + nStar
end

local GetPotentialId = function(nCharId, nIndex)
  -- function num : 0_45
  return 500000 + nCharId * 100 + nIndex
end

local ParseNoBrokenDesc = function(sDesc)
  -- function num : 0_46 , upvalues : _ENV
  if Settings.sCurrentTxtLanguage == (AllEnum.Language).EN or Settings.sCurrentTxtLanguage == (AllEnum.Language).KR then
    return sDesc
  else
    return "<nobr>" .. sDesc .. "</nobr>"
  end
end

local SubDesc = function(str, nLevel, nCompareLevel, mapLinkParam)
  -- function num : 0_47 , upvalues : _ENV, GetPotentialId, ParseNoBrokenDesc
  local ConfigData = require("GameCore.Data.ConfigData")
  local SubDescLink = function(originStr, mapParam)
    -- function num : 0_47_0 , upvalues : _ENV, GetPotentialId
    if originStr == nil or originStr == "" then
      return ""
    end
    local mapWord = {}
    for word in (string.gmatch)(originStr, "##.-#%d%d%d%d#") do
      if mapWord[word] == nil then
        local sWordId = (string.match)(word, "%d%d%d%d")
        local nWordId = tonumber(sWordId)
        if nWordId == nil then
          printError("词条 id 错误:" .. sWordId)
          mapWord[word] = sWordId
        else
          local mapWordData = (ConfigTable.GetData)("Word", nWordId)
          if mapWordData == nil or mapWordData.Icon == "" then
            printError("该词条 id 找不到数据:" .. sWordId)
            if mapWordData and mapWordData.Icon == "" then
              printError("该词条 id 找不到Icon:" .. sWordId)
            end
            mapWord[word] = (string.format)("<color=#FF0000>%s</color>", sWordId)
          else
            if mapWordData.Type == (GameEnum.wordLinkType).Word then
              mapWord[word] = (string.format)("<color=#%s><link=\"%d\"><u>%s</u>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Title, mapWordData.TitleIcon)
            else
              if mapWordData.Type == (GameEnum.wordLinkType).Potential then
                if mapParam == nil or mapParam.nCharId == nil then
                  printError("该<潜能>词条 id 找不到角色:" .. sWordId)
                  mapWord[word] = (string.format)("<color=#FF0000>%s</color>", sWordId)
                else
                  local nPotentialId = GetPotentialId(mapParam.nCharId, tonumber(mapWordData.Param1))
                  local mapItemCfg = (ConfigTable.GetData_Item)(nPotentialId)
                  if not mapItemCfg or not mapItemCfg.Title then
                    local sTitle = mapWordData.Title
                  end
                  mapWord[word] = (string.format)("<color=#%s><link=\"%d\"><u>%s</u></link></color>", mapWordData.Color, mapWordData.Id, sTitle)
                end
              end
            end
          end
        end
      end
    end
    for word,finalStr in pairs(mapWord) do
      originStr = (string.gsub)(originStr, word, finalStr)
    end
    return originStr
  end

  local ParseHitDamageDesc = function(nHitDamageId, nHitDamageLevel)
    -- function num : 0_47_1 , upvalues : _ENV, ConfigData
    local mapDamage = (ConfigTable.GetData_HitDamage)(nHitDamageId)
    if not mapDamage then
      return (string.format)("<color=#BD3059>该 hit damage id 找不到数据:%s</color>", nHitDamageId)
    end
    local nPercent = (mapDamage.SkillPercentAmend)[nHitDamageLevel]
    local nAbs = (mapDamage.SkillAbsAmend)[nHitDamageLevel]
    if not nPercent or not nAbs then
      return (string.format)("<color=#BD3059>该技能等级在 HitDamage 表中找不到数据, hit damage id:%d, level:%d</color>", nHitDamageId, nHitDamageLevel)
    end
    nPercent = nPercent * ConfigData.IntFloatPrecision
    nPercent = FormatNum(nPercent)
    nAbs = FormatNum(nAbs)
    if nPercent ~= 0 or not "" then
      local sPercent = tostring(nPercent) .. "%%"
    end
    if nAbs ~= 0 or not "" then
      local sAbs = tostring(nAbs)
    end
    if nPercent ~= 0 and nAbs ~= 0 then
      return sPercent .. "+" .. sAbs
    else
      return sPercent .. sAbs
    end
  end

  local GetValueKey = function(nDataId, nType, nValueLevel)
    -- function num : 0_47_2 , upvalues : _ENV
    local ret = nDataId
    if nType == (GameEnum.levelTypeData).Exclusive or nType == (GameEnum.levelTypeData).SkillSlot then
      ret = nDataId + nValueLevel * 10
    else
    end
    if nType ~= (GameEnum.levelTypeData).OutfitPromote or nType == (GameEnum.levelTypeData).OutfifBreak then
      return ret
    end
  end

  local ParseEffectDesc = function(nEffectId, nEffectLevel, nShowType)
    -- function num : 0_47_3 , upvalues : _ENV, GetValueKey
    local mapEffectCfgData = (ConfigTable.GetData_Effect)(nEffectId)
    if mapEffectCfgData == nil then
      return (string.format)("<color=#BD3059>该EffectId找不到数据:%s</color>", nEffectId)
    end
    local nValueKey = GetValueKey(nEffectId, mapEffectCfgData.levelTypeData, nEffectLevel)
    local mapEffectValueData = (ConfigTable.GetData)("EffectValue", nValueKey)
    if mapEffectValueData == nil then
      return (string.format)("<color=#BD3059>该EffectId和等级找不到Value数据:%s，%s</color>", nEffectId, nEffectLevel)
    end
    local sValue = mapEffectValueData.EffectTypeParam1
    local nValue = tonumber(sValue)
    if nValue == nil then
      return (string.format)("<color=#BD3059>该EffectValueId配置的数据不支持显示:%s</color>", nValueKey)
    end
    nValue = (math.abs)(nValue)
    if nShowType == 1 then
      nValue = nValue * 100
      return nValue .. "%%"
    end
    return tostring(nValue)
  end

  local ParseOnceDesc = function(nOnceId, nOnceLevel, nShowType)
    -- function num : 0_47_4 , upvalues : _ENV, GetValueKey, ConfigData
    local mapCfgData = (ConfigTable.GetData)("OnceAdditionalAttribute", nOnceId)
    if mapCfgData == nil then
      return (string.format)("<color=#BD3059>该OnceAdditionalAttributeId找不到数据:%s</color>", nOnceId)
    end
    local nValueKey = GetValueKey(nOnceId, mapCfgData.levelTypeData, nOnceLevel)
    local mapValueData = (ConfigTable.GetData)("OnceAdditionalAttributeValue", nValueKey)
    if mapValueData == nil then
      return (string.format)("<color=#BD3059>该OnceAdditionalAttributeId和等级找不到Value数据:%s，%s，%s</color>", nOnceId, nOnceLevel, nValueKey)
    end
    local nValue = mapValueData.Value1 * ConfigData.IntFloatPrecision
    nValue = (math.abs)(nValue)
    if nShowType == 1 then
      nValue = nValue * 100
      return nValue .. "%%"
    end
    return tostring(nValue)
  end

  local ParseShieldDesc = function(nShieldId, nShieldLevel, nShowType)
    -- function num : 0_47_5 , upvalues : _ENV, GetValueKey, ConfigData
    local mapCfgData = (ConfigTable.GetData)("Shield", nShieldId)
    if mapCfgData == nil then
      return (string.format)("<color=#BD3059>该ShieldId找不到数据:%s</color>", nShieldId)
    end
    local nValueKey = GetValueKey(nShieldId, mapCfgData.levelTypeData, nShieldLevel)
    local mapValueData = (ConfigTable.GetData)("ShieldValue", nValueKey)
    if mapValueData == nil then
      return (string.format)("<color=#BD3059>该ShieldId和等级找不到Value数据:%s，%s</color>", nShieldId, nShieldLevel)
    end
    local nValue = mapValueData.ReferenceScale
    nValue = nValue * ConfigData.IntFloatPrecision
    nValue = (math.abs)(nValue)
    if nShowType == 1 then
      nValue = nValue * 100
      return nValue .. "%%"
    end
    return tostring(nValue)
  end

  local ParseSriptDesc = function(nSriptId, nSriptLevel, nShowType)
    -- function num : 0_47_6 , upvalues : _ENV, GetValueKey, ConfigData
    local mapCfgData = (ConfigTable.GetData)("ScriptParameter", nSriptId)
    if mapCfgData == nil then
      return (string.format)("<color=#BD3059>该SriptId找不到数据:%s</color>", nSriptId)
    end
    local nValueKey = GetValueKey(nSriptId, mapCfgData.levelTypeData, nSriptLevel)
    local mapValueData = (ConfigTable.GetData)("ScriptParameterValue", nValueKey)
    if mapValueData == nil then
      return (string.format)("<color=#BD3059>该SriptId和等级找不到Value数据:%s，%s</color>", nSriptId, nSriptLevel)
    end
    local nValue = mapValueData.CommonData
    nValue = nValue * ConfigData.IntFloatPrecision
    nValue = (math.abs)(nValue)
    if nShowType == 1 then
      nValue = nValue * 100
      return nValue .. "%%"
    end
    return tostring(nValue)
  end

  local linkStr = SubDescLink(str, mapLinkParam)
  if nLevel == nil then
    return linkStr
  end
  local mapWord = {}
  for word in (string.gmatch)(linkStr, "&.-&") do
    local paramStr = (string.gsub)(word, "&", "")
    print(paramStr)
    local tbParam = (string.split)(paramStr, ",")
    local sTable = tbParam[1]
    local sKey = tbParam[2]
    local sShowType = tbParam[3]
    local nShowType = tonumber(sShowType)
    if nShowType == nil then
      nShowType = 0
    end
    if sTable == nil or sKey == nil then
      mapWord[word] = (string.format)("<color=#BD3059>配置错误，无法读取对应表名和ID：%s</color>", word)
    else
      local nKey = tonumber(sKey)
      if nKey == nil then
        mapWord[word] = (string.format)("<color=#BD3059>表ID配置错误，无法转为number：%s</color>", word)
      else
        if sTable == "HitDamage" then
          local subStr = ParseHitDamageDesc(nKey, nLevel)
          do
            do
              if nCompareLevel ~= nil then
                local sCompareStr = ParseHitDamageDesc(nKey, nCompareLevel)
                subStr = (string.format)("%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
              end
              mapWord[word] = subStr
              if sTable == "Effect" then
                local subStr = ParseEffectDesc(nKey, nLevel, nShowType)
                do
                  do
                    if nCompareLevel ~= nil then
                      local sCompareStr = ParseEffectDesc(nKey, nCompareLevel, nShowType)
                      subStr = (string.format)("%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                    end
                    mapWord[word] = subStr
                    if sTable == "Once" then
                      local subStr = ParseOnceDesc(nKey, nLevel, nShowType)
                      do
                        do
                          if nCompareLevel ~= nil then
                            local sCompareStr = ParseOnceDesc(nKey, nCompareLevel, nShowType)
                            subStr = (string.format)("%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                          end
                          mapWord[word] = subStr
                          if sTable == "Shield" then
                            local subStr = ParseShieldDesc(nKey, nLevel, nShowType)
                            do
                              do
                                if nCompareLevel ~= nil then
                                  local sCompareStr = ParseShieldDesc(nKey, nCompareLevel, nShowType)
                                  subStr = (string.format)("%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                                end
                                mapWord[word] = subStr
                                if sTable == "Script" then
                                  local subStr = ParseSriptDesc(nKey, nLevel, nShowType)
                                  do
                                    do
                                      do
                                        if nCompareLevel ~= nil then
                                          local sCompareStr = ParseSriptDesc(nKey, nCompareLevel, nShowType)
                                          subStr = (string.format)("%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                                        end
                                        mapWord[word] = subStr
                                        mapWord[word] = (string.format)("<color=#BD3059>未支持的表名：%s</color>", word)
                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out DO_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                        -- DECOMPILER ERROR at PC189: LeaveBlock: unexpected jumping out IF_STMT

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
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  for word,finalStr in pairs(mapWord) do
    linkStr = (string.gsub)(linkStr, word, finalStr)
  end
  return ParseNoBrokenDesc(linkStr)
end

local ParseDesc = function(mapDescConfig, nCompareLevelType, nCompareLevel, bSimple, nOverrideLevel, mapLinkParam)
  -- function num : 0_48 , upvalues : _ENV, GetPotentialId, ParseNoBrokenDesc
  if mapDescConfig == nil then
    printError("解析描述失败!")
    return ""
  end
  local ConfigData = require("GameCore.Data.ConfigData")
  if not bSimple or not mapDescConfig.BriefDesc then
    local str = mapDescConfig.Desc
  end
  local SubDescLink = function(originStr, mapParam)
    -- function num : 0_48_0 , upvalues : _ENV, GetPotentialId
    if originStr == nil or originStr == "" then
      return ""
    end
    local mapWord = {}
    for word in (string.gmatch)(originStr, "##.-#%d%d%d%d#") do
      if mapWord[word] == nil then
        local sWordId = (string.match)(word, "%d%d%d%d")
        local nWordId = tonumber(sWordId)
        if nWordId == nil then
          printError("词条 id 错误:" .. sWordId)
          mapWord[word] = sWordId
        else
          local mapWordData = (ConfigTable.GetData)("Word", nWordId)
          if mapWordData == nil or mapWordData.Icon == "" then
            printError("该词条 id 找不到数据:" .. sWordId)
            if mapWordData and mapWordData.Icon == "" then
              printError("该词条 id 找不到Icon:" .. sWordId)
            end
            mapWord[word] = (string.format)("<color=#FF0000>%s</color>", sWordId)
          else
            if mapWordData.Type == (GameEnum.wordLinkType).Word then
              mapWord[word] = (string.format)("<color=#%s><link=\"%d\"><u>%s</u>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Title, mapWordData.TitleIcon)
            else
              if mapWordData.Type == (GameEnum.wordLinkType).Potential then
                if mapParam == nil or mapParam.nCharId == nil then
                  printError("该<潜能>词条 id 找不到角色:" .. sWordId)
                  mapWord[word] = (string.format)("<color=#FF0000>%s</color>", sWordId)
                else
                  local nPotentialId = GetPotentialId(mapParam.nCharId, tonumber(mapWordData.Param1))
                  local mapItemCfg = (ConfigTable.GetData_Item)(nPotentialId)
                  if not mapItemCfg or not mapItemCfg.Title then
                    local sTitle = mapWordData.Title
                  end
                  mapWord[word] = (string.format)("<color=#%s><link=\"%d\"><u>%s</u></link></color>", mapWordData.Color, mapWordData.Id, sTitle)
                end
              end
            end
          end
        end
      end
    end
    for word,finalStr in pairs(mapWord) do
      originStr = (string.gsub)(originStr, word, finalStr)
    end
    return originStr
  end

  local linkStr = SubDescLink(str, mapLinkParam)
  local ParseHitDamageDesc = function(nHitDamageId, nHitDamageLevel)
    -- function num : 0_48_1 , upvalues : _ENV, ConfigData
    local sDesc = ""
    local mapDamage = (ConfigTable.GetData_HitDamage)(nHitDamageId)
    if not mapDamage then
      sDesc = (string.format)("<color=#BD3059>该 hit damage id 找不到数据:%s</color>", nHitDamageId)
      return sDesc
    end
    local levelType = mapDamage.levelTypeData
    nHitDamageLevel = (levelType == (GameEnum.levelTypeData).BreakCount and nHitDamageLevel < 1 and (not 1) and levelType ~= (GameEnum.levelTypeData).None) or 1
    local nPercent = (mapDamage.SkillPercentAmend)[nHitDamageLevel]
    local nAbs = (mapDamage.SkillAbsAmend)[nHitDamageLevel]
    if not nPercent or not nAbs then
      sDesc = (string.format)("<color=#BD3059>该技能等级在 HitDamage 表中找不到数据, hit damage id:%d, level:%d</color>", nHitDamageId, nHitDamageLevel)
      return sDesc
    end
    nPercent = nPercent * ConfigData.IntFloatPrecision
    nPercent = FormatNum(nPercent)
    nAbs = FormatNum(nAbs)
    if nPercent ~= 0 or not "" then
      local sPercent = tostring(nPercent) .. "%%"
    end
    if nAbs ~= 0 or not "" then
      local sAbs = tostring(nAbs)
    end
    if nPercent ~= 0 and nAbs ~= 0 then
      sDesc = sPercent .. "+" .. sAbs
    else
      sDesc = sPercent .. sAbs
    end
    return sDesc
  end

  local FormatValueShow = function(sValue, sShowType, sEnumType)
    -- function num : 0_48_2 , upvalues : _ENV, ConfigData
    if sShowType == "Text" then
      return sValue
    else
      if sShowType == "Enum" then
        sEnumType = tostring(sEnumType)
        if sEnumType ~= nil then
          local tbEnum = (CacheTable.GetData)("_EnumDesc", sEnumType)
          if tbEnum ~= nil then
            local nEnumValue = tonumber(sValue)
            if nEnumValue ~= nil then
              if tbEnum[nEnumValue] then
                return (ConfigTable.GetUIText)(tbEnum[nEnumValue])
              else
                printError(sEnumType .. "枚举未找到值:" .. nEnumValue)
                return nil
              end
            else
              printError("枚举值填写错误:" .. sValue)
              return nil
            end
          else
            do
              do
                printError("枚举类型填写错误:" .. sEnumType)
                do return nil end
                printError("枚举类型未填写")
                do return nil end
                local nValue = tonumber(sValue)
                if sShowType ~= "10K" and sShowType ~= "10KPct" and sShowType ~= "10KHdPct" then
                  local isIntFloat = nValue == nil
                  local isPercent = sShowType == "Pct" or sShowType == "HdPct" or sShowType == "10KPct" or sShowType == "10KHdPct"
                  local multiHundred = sShowType == "HdPct" or sShowType == "10KHdPct"
                  -- DECOMPILER ERROR at PC108: Unhandled construct in 'MakeBoolean' P3

                  if ((isIntFloat and nValue * ConfigData.IntFloatPrecision) or multiHundred) then
                    nValue = (math.abs)(nValue)
                    nValue = clearFloat(nValue)
                    local integer, decimal = (math.modf)(nValue)
                    if decimal >= 0.01 or not tostring(integer) then
                      sValue = tostring(nValue)
                    end
                    if not isPercent or not sValue .. "%%" then
                      do
                        do
                          do return sValue end
                          do return nil end
                          -- DECOMPILER ERROR: 10 unprocessed JMP targets
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
    end
  end

  local ParseLevelUpDesc = function(sTable, nId, nLevel, sParameter, sShowType, sEnumType)
    -- function num : 0_48_3 , upvalues : _ENV, FormatValueShow
    local GetValueKey = function(nDataId, nType, nValueLevel)
      -- function num : 0_48_3_0
      return nDataId + nValueLevel * 10
    end

    local sDesc, sErrorInfo = nil, nil
    local mapCfgData = DataTable[sTable]
    if mapCfgData ~= nil then
      local sValueTable = sTable .. "Value"
      local mapValueCfgData = DataTable[sValueTable]
      if mapValueCfgData ~= nil then
        local mapData = mapCfgData[nId]
        if mapData ~= nil then
          local nValueId = GetValueKey(nId, mapData.levelTypeData, nLevel)
          local mapValueData = mapValueCfgData[nValueId]
          if mapValueData ~= nil then
            local sValue = mapValueData[sParameter]
            if sValue ~= nil then
              sDesc = FormatValueShow(sValue, sShowType, sEnumType)
              if sDesc == nil then
                sErrorInfo = (string.format)("<color=#BD3059>%s表中该ValueId配置的数据解析失败:%s</color>", sValueTable, nValueId)
              end
            else
              sErrorInfo = (string.format)("<color=#BD3059>%s表中没有该字段:%s</color>", sValueTable, sParameter)
            end
          else
            do
              do
                do
                  do
                    sErrorInfo = (string.format)("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sValueTable, nValueId)
                    sErrorInfo = (string.format)("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sTable, nId)
                    sErrorInfo = (string.format)("<color=#BD3059>找不到该配置表:%s</color>", sValueTable)
                    sErrorInfo = (string.format)("<color=#BD3059>找不到该配置表:%s</color>", sTable)
                    if sErrorInfo ~= nil and sErrorInfo ~= "" then
                      printError(sErrorInfo)
                      sDesc = sErrorInfo
                    end
                    if sDesc == nil then
                      printError("描述解析失败")
                      sDesc = ""
                    end
                    return sDesc
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  local ParseNoLevelUpDesc = function(sTable, nId, sParameter, sShowType, sEnumType)
    -- function num : 0_48_4 , upvalues : _ENV, FormatValueShow
    local sDesc, sErrorInfo = nil, nil
    local mapCfgData = DataTable[sTable]
    if mapCfgData ~= nil then
      local mapData = mapCfgData[nId]
      if mapData ~= nil then
        local sValue = mapData[sParameter]
        if sValue ~= nil then
          sDesc = FormatValueShow(sValue, sShowType, sEnumType)
          if sDesc == nil then
            sErrorInfo = (string.format)("<color=#BD3059>%s表中该Id配置的数据解析失败:%s</color>", sTable, nId)
          end
        else
          sErrorInfo = (string.format)("<color=#BD3059>%s表中没有该字段:%s</color>", sTable, sParameter)
        end
      else
        do
          do
            sErrorInfo = (string.format)("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sTable, nId)
            sErrorInfo = (string.format)("<color=#BD3059>找不到该配置表:%s</color>", sTable)
            if sErrorInfo ~= nil and sErrorInfo ~= "" then
              printError(sErrorInfo)
              sDesc = sErrorInfo
            end
            if sDesc == nil then
              printError("描述解析失败")
              sDesc = ""
            end
            return sDesc
          end
        end
      end
    end
  end

  local mapWord = {}
  for word in (string.gmatch)(linkStr, "&.-&") do
    local sParameterKey = (string.gsub)(word, "&", "")
    local paramStr = mapDescConfig[sParameterKey]
    local tbParam = (string.split)(paramStr, ",")
    local sTable = tbParam[1]
    local sParseType = tbParam[2]
    local sKey = tbParam[3]
    local sParameter = tbParam[4]
    local sShowType = tbParam[5]
    local sEnumType = tbParam[6]
    if sTable == nil or sKey == nil then
      mapWord[word] = (string.format)("<color=#BD3059>配置错误，无法读取对应表名和ID：%s</color>", word)
    else
      local mapCfgData = DataTable[sTable]
      if mapCfgData ~= nil then
        local nKey = tonumber(sKey)
        if nKey == nil then
          mapWord[word] = (string.format)("<color=#BD3059>表ID配置错误，无法转为number：%s</color>", word)
        else
          local mapData = mapCfgData[nKey]
          if mapData ~= nil then
            local nLevel = 1
            nOverrideLevel = tonumber(nOverrideLevel)
            if mapData.levelTypeData == (GameEnum.levelTypeData).Exclusive then
              nLevel = (UTILS.QueryLevelInfo)(mapData.LevelData, mapData.levelTypeData, mapData.LevelData)
            else
              local nCharId = tonumber((string.sub)(sKey, 1, 3))
              nLevel = (UTILS.QueryLevelInfo)(nCharId, mapData.levelTypeData, mapData.LevelData, mapData.MainOrSupport)
            end
            do
              if (mapData.levelTypeData == (GameEnum.levelTypeData).Exclusive or mapData.levelTypeData == (GameEnum.levelTypeData).Note) and nOverrideLevel ~= nil then
                nLevel = nOverrideLevel
              end
              if sParseType == "DamageNum" and sTable == "HitDamage" then
                local subStr = ParseHitDamageDesc(nKey, nLevel)
                do
                  do
                    if nCompareLevelType ~= nil and mapData.levelTypeData == nCompareLevelType and nCompareLevel ~= nil then
                      local sCompareStr = ParseHitDamageDesc(nKey, nCompareLevel)
                      if subStr ~= sCompareStr then
                        subStr = (string.format)("%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                      end
                    end
                    mapWord[word] = subStr
                    if sParseType == "LevelUp" then
                      local subStr = ParseLevelUpDesc(sTable, nKey, nLevel, sParameter, sShowType, sEnumType)
                      do
                        do
                          do
                            do
                              do
                                if nCompareLevelType ~= nil and mapData.levelTypeData == nCompareLevelType and nCompareLevel ~= nil then
                                  local sCompareStr = ParseLevelUpDesc(sTable, nKey, nCompareLevel, sParameter, sShowType, sEnumType)
                                  if subStr ~= sCompareStr then
                                    subStr = (string.format)("%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                                  end
                                end
                                mapWord[word] = subStr
                                if sParseType == "NoLevel" then
                                  mapWord[word] = ParseNoLevelUpDesc(sTable, nKey, sParameter, sShowType, sEnumType)
                                end
                                mapWord[word] = (string.format)("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sTable, nKey)
                                mapWord[word] = (string.format)("<color=#BD3059>找不到该配置表:%s</color>", sTable)
                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out DO_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out DO_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out DO_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out DO_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out DO_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out DO_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out DO_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                -- DECOMPILER ERROR at PC221: LeaveBlock: unexpected jumping out IF_STMT

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
          end
        end
      end
    end
  end
  for word,finalStr in pairs(mapWord) do
    linkStr = (string.gsub)(linkStr, word, finalStr)
  end
  return ParseNoBrokenDesc(linkStr)
end

local ParseDiscDesc = function(originStr, mapSkill, mapSkillNext, nLayer, mapLinkParam)
  -- function num : 0_49 , upvalues : _ENV, ParseNoBrokenDesc
  originStr = (UTILS.SubDesc)(originStr, nil, nil, mapLinkParam)
  local mapWord = {}
  for word in (string.gmatch)(originStr, "{[0-9]*}") do
    if mapWord[word] == nil then
      local nCurLayer = nLayer
      local sWordId = (string.sub)(word, 2, #word - 1)
      local nWordId = tonumber(sWordId)
      if nWordId == nil then
        printError("wordId error:" .. sWordId)
        mapWord[word] = sWordId
      else
        local fieldName = "Param" .. nWordId
        if nCurLayer then
          local nMaxStringCount = #mapSkill[fieldName]
          if nMaxStringCount < nCurLayer then
            nCurLayer = nMaxStringCount
          end
          for k,v in ipairs(mapSkill[fieldName]) do
            if nCurLayer == k then
              mapWord[word] = v
            end
          end
        else
          do
            do
              do
                if mapSkillNext and mapSkill[fieldName] ~= mapSkillNext[fieldName] then
                  mapWord[word] = mapSkill[fieldName] .. "<color=#8cac59>(" .. mapSkillNext[fieldName] .. "↑)</color>"
                else
                  mapWord[word] = mapSkill[fieldName]
                end
                if not mapWord[word] then
                  mapWord[word] = "{未找到参数配置}"
                end
                mapWord[word] = (string.gsub)(mapWord[word], "%%", "%%%%")
                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out IF_THEN_STMT

                -- DECOMPILER ERROR at PC83: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
    end
  end
  for word,finalStr in pairs(mapWord) do
    originStr = (string.gsub)(originStr, word, finalStr)
  end
  return ParseNoBrokenDesc(originStr)
end

local ParseParamDesc = function(originStr, mapCfg, mapCfgNext, mapLinkParam, sColor)
  -- function num : 0_50 , upvalues : _ENV, ParseNoBrokenDesc
  originStr = (UTILS.SubDesc)(originStr, nil, nil, mapLinkParam)
  local mapWord = {}
  for word in (string.gmatch)(originStr, "{[0-9]*}") do
    if mapWord[word] == nil then
      local sWordId = (string.sub)(word, 2, #word - 1)
      local nWordId = tonumber(sWordId)
      if nWordId == nil then
        printError("wordId error:" .. sWordId)
        mapWord[word] = sWordId
      else
        do
          do
            local fieldName = "Param" .. nWordId
            if mapCfgNext and mapCfg[fieldName] ~= mapCfgNext[fieldName] then
              mapWord[word] = mapCfg[fieldName] .. "<color=#8cac59>(" .. mapCfgNext[fieldName] .. "↑)</color>"
            else
              if sColor then
                mapWord[word] = "<color=" .. sColor .. ">" .. mapCfg[fieldName] .. "</color>"
              else
                mapWord[word] = mapCfg[fieldName]
              end
            end
            if not mapWord[word] then
              mapWord[word] = "{未找到参数配置}"
            end
            mapWord[word] = (string.gsub)(mapWord[word], "%%", "%%%%")
            -- DECOMPILER ERROR at PC75: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC75: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC75: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC75: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC75: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  for word,finalStr in pairs(mapWord) do
    originStr = (string.gsub)(originStr, word, finalStr)
  end
  return ParseNoBrokenDesc(originStr)
end

local ParseRewardItemCount = function(tbReward)
  -- function num : 0_51 , upvalues : _ENV
  if tbReward == nil then
    return -1
  end
  if #tbReward < 3 then
    printError("物品数量配置错误，应有至少3个参数")
    return -1
  end
  if #tbReward == 3 then
    return tbReward[2]
  else
    if #tbReward > 3 then
      local countTxt = tbReward[2] .. "~" .. tbReward[3]
      return countTxt
    end
  end
  do
    return -1
  end
end

local QueryLevelInfo = function(nId, nType, nParam1, nParam2)
  -- function num : 0_52 , upvalues : _ENV
  local ret = nil
  ret = (PlayerData.StarTower):QueryLevelInfo(nId, nType, nParam1, nParam2)
  if ret == nil then
    ret = (PlayerData.Char):QueryLevelInfo(nId, nType, nParam1, nParam2)
  end
  return ret
end

local ParseLevelQuestTargetDesc = function(originStr, mapTarget)
  -- function num : 0_53 , upvalues : _ENV
  local mapSkillType = {[(GameEnum.LevelQuestTargetType).CastSkill] = true, [(GameEnum.LevelQuestTargetType).CastSkillEnd] = true}
  local mapWord = {}
  for word in (string.gmatch)(originStr, "{Param" .. "[0-9]*}") do
    if mapWord[word] == nil then
      local fieldName = (string.sub)(word, 2, #word - 1)
      local sParam = mapTarget[fieldName]
      if mapTarget.QuestType == (GameEnum.LevelQuestTargetType).KillMonster and fieldName == "Param2" then
        local nMonsterId = tonumber(sParam)
        local sMonsterName = sParam
        if nMonsterId then
          local monsterData = (ConfigTable.GetData)("Monster", nMonsterId)
          if monsterData then
            local monsterSkin = (ConfigTable.GetData)("MonsterSkin", monsterData.FAId)
            if monsterSkin then
              local monsterManual = (ConfigTable.GetData)("MonsterManual", monsterSkin.MonsterManual)
              if monsterManual then
                sMonsterName = monsterManual.Name
              end
            end
          end
        end
        do
          do
            sParam = sMonsterName
            if mapSkillType[mapTarget.QuestType] and fieldName == "Param2" then
              local nSkillId = tonumber(sParam)
              local sSkillName = sParam
              do
                do
                  do
                    do
                      if nSkillId then
                        local mapCfg = (ConfigTable.GetData)("Skill", nSkillId)
                        if mapCfg then
                          sSkillName = mapCfg.Title
                        end
                      end
                      sParam = sSkillName
                      mapWord[word] = "<color=#2be1f1>" .. sParam .. "</color>"
                      if not mapWord[word] then
                        mapWord[word] = "{未找到参数配置}"
                      end
                      mapWord[word] = (string.gsub)(mapWord[word], "%%", "%%%%")
                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out DO_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out DO_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out DO_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out IF_THEN_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out IF_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out DO_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out DO_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out IF_THEN_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out IF_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out IF_THEN_STMT

                      -- DECOMPILER ERROR at PC104: LeaveBlock: unexpected jumping out IF_STMT

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
  for word,finalStr in pairs(mapWord) do
    originStr = (string.gsub)(originStr, word, finalStr)
  end
  return originStr
end

local GetLevelQuestTargetProcess = function(mapTarget, nCur)
  -- function num : 0_54 , upvalues : _ENV
  local mapSkipProcess = {[(GameEnum.LevelQuestTargetType).ReceiveTriggerOpId] = true, [(GameEnum.LevelQuestTargetType).Null] = true, [(GameEnum.LevelQuestTargetType).RecoverEnergy] = true, [(GameEnum.LevelQuestTargetType).KillAllMonster] = true}
  if mapSkipProcess[mapTarget.QuestType] then
    return ""
  end
  if nCur then
    return "<color=#2be1f1>(" .. nCur .. "/" .. mapTarget.Param1 .. ")</color>"
  else
    return "<color=#2be1f1>(0/" .. mapTarget.Param1 .. ")</color>"
  end
end

local GetBezierPointByT = function(beginPos, handlePos, endPos, deltaTime)
  -- function num : 0_55
  local pow = 1 - deltaTime ^ 2
  local x = pow * beginPos.x + 2 * deltaTime * (1 - deltaTime) * handlePos.x + deltaTime * deltaTime * endPos.x
  local y = pow * beginPos.y + 2 * deltaTime * (1 - deltaTime) * handlePos.y + deltaTime * deltaTime * endPos.y
  local z = pow * beginPos.z + 2 * deltaTime * (1 - deltaTime) * handlePos.z + deltaTime * deltaTime * endPos.z
  return x, y, z
end

local _ = nil
_ = (ColorUtility.TryParseHtmlString)("#BD3059")
_ = (ColorUtility.TryParseHtmlString)("#264278")
_ = (ColorUtility.TryParseHtmlString)("#3B62AE")
_ = (ColorUtility.TryParseHtmlString)("#FAFAFA")
_ = (ColorUtility.TryParseHtmlString)("#2d4257")
_ = (ColorUtility.TryParseHtmlString)("#505c67")
local AddEffect = function(nCharId, nEffectId, nLevel, nUseCount)
  -- function num : 0_56 , upvalues : _ENV
  if nUseCount == nil then
    nUseCount = 0
  end
  local mapEftCfgData = (ConfigTable.GetData_Effect)(nEffectId)
  if mapEftCfgData == nil then
    printError("Effect Id missing" .. nEffectId)
    return nil
  end
  local nEffectValueId = nEffectId
  if mapEftCfgData.levelTypeData ~= (GameEnum.levelTypeData).None then
    nEffectValueId = nEffectValueId + nLevel * 10
  end
  local mapEftValueData = (ConfigTable.GetData)("EffectValue", nEffectValueId)
  if mapEftValueData == nil then
    printError("EffectValue Id missing" .. nEffectValueId)
    return nil
  end
  local nEftRemainTimes = -1
  if mapEftValueData.TakeEffectLimit ~= 0 then
    nEftRemainTimes = mapEftValueData.TakeEffectLimit - nUseCount
    if nEftRemainTimes <= 0 then
      printLog("效果次数已用完:" .. nEffectId)
      return nil
    end
  end
  local nEffectUid = safe_call_cs_func((CS.AdventureModuleHelper).SetActorEffect, nCharId, nEffectId, nEftRemainTimes, 0)
  return nEffectUid
end

local AddFateCardEft = function(nCharId, nEffectId, nRemainCount)
  -- function num : 0_57 , upvalues : _ENV
  if nRemainCount == 0 then
    printLog("效果次数已用完:" .. nEffectId)
    return nil
  end
  local nEffectUid = safe_call_cs_func((CS.AdventureModuleHelper).SetActorEffect, nCharId, nEffectId, nRemainCount, 0)
  return nEffectUid
end

local AddBuildEffect = function(mapCharEffect, mapDiscEffect, mapNoteEffect)
  -- function num : 0_58 , upvalues : _ENV
  local retCharEffect = {}
  local retDiscEffect = {}
  local retNoteEffect = {}
  for nCharId,mapEffect in pairs(mapCharEffect) do
    if mapEffect[(AllEnum.EffectType).Affinity] ~= nil then
      for _,nEffectId in ipairs(mapEffect[(AllEnum.EffectType).Affinity]) do
        if retCharEffect[(AllEnum.EffectType).Affinity] == nil then
          retCharEffect[(AllEnum.EffectType).Affinity] = {}
        end
        -- DECOMPILER ERROR at PC43: Confused about usage of register: R16 in 'UnsetPending'

        if (retCharEffect[(AllEnum.EffectType).Affinity])[nEffectId] == nil then
          (retCharEffect[(AllEnum.EffectType).Affinity])[nEffectId] = {}
        end
        local nEftUid = (UTILS.AddEffect)(nCharId, nEffectId, 0, 0)
        ;
        (table.insert)((retCharEffect[(AllEnum.EffectType).Affinity])[nEffectId], nEftUid)
      end
    end
    do
      if mapEffect[(AllEnum.EffectType).Talent] ~= nil then
        for _,nEffectId in ipairs(mapEffect[(AllEnum.EffectType).Talent]) do
          if retCharEffect[(AllEnum.EffectType).Talent] == nil then
            retCharEffect[(AllEnum.EffectType).Talent] = {}
          end
          -- DECOMPILER ERROR at PC98: Confused about usage of register: R16 in 'UnsetPending'

          if (retCharEffect[(AllEnum.EffectType).Talent])[nEffectId] == nil then
            (retCharEffect[(AllEnum.EffectType).Talent])[nEffectId] = {}
          end
          local nEftUid = (UTILS.AddEffect)(nCharId, nEffectId, 0, 0)
          ;
          (table.insert)((retCharEffect[(AllEnum.EffectType).Talent])[nEffectId], nEftUid)
        end
      end
      do
        if mapEffect[(AllEnum.EffectType).Potential] ~= nil then
          for nPotentialId,tbPotentialData in pairs(mapEffect[(AllEnum.EffectType).Potential]) do
            for _,nEffectId in ipairs(tbPotentialData[1]) do
              if retCharEffect[(AllEnum.EffectType).Potential] == nil then
                retCharEffect[(AllEnum.EffectType).Potential] = {}
              end
              -- DECOMPILER ERROR at PC157: Confused about usage of register: R21 in 'UnsetPending'

              if (retCharEffect[(AllEnum.EffectType).Potential])[nEffectId] == nil then
                (retCharEffect[(AllEnum.EffectType).Potential])[nEffectId] = {}
              end
              local nEftUid = (UTILS.AddEffect)(nCharId, nEffectId, tbPotentialData[2], 0)
              ;
              (table.insert)((retCharEffect[(AllEnum.EffectType).Potential])[nEffectId], nEftUid)
            end
          end
        end
        do
          if mapEffect[(AllEnum.EffectType).Equipment] ~= nil then
            for _,nEffectId in ipairs(mapEffect[(AllEnum.EffectType).Equipment]) do
              if retCharEffect[(AllEnum.EffectType).Equipment] == nil then
                retCharEffect[(AllEnum.EffectType).Equipment] = {}
              end
              -- DECOMPILER ERROR at PC214: Confused about usage of register: R16 in 'UnsetPending'

              if (retCharEffect[(AllEnum.EffectType).Equipment])[nEffectId] == nil then
                (retCharEffect[(AllEnum.EffectType).Equipment])[nEffectId] = {}
              end
              local nEftUid = (UTILS.AddEffect)(nCharId, nEffectId, 0, 0)
              ;
              (table.insert)((retCharEffect[(AllEnum.EffectType).Equipment])[nEffectId], nEftUid)
            end
          end
          do
            if mapDiscEffect ~= nil then
              for nDiscTid,tbDiscEffectId in pairs(mapDiscEffect) do
                if retDiscEffect[nDiscTid] == nil then
                  retDiscEffect[nDiscTid] = {}
                end
                for _,mapEft in ipairs(tbDiscEffectId) do
                  -- DECOMPILER ERROR at PC256: Confused about usage of register: R21 in 'UnsetPending'

                  if (retDiscEffect[nDiscTid])[mapEft[1]] == nil then
                    (retDiscEffect[nDiscTid])[mapEft[1]] = {}
                  end
                  local nEftUid = (UTILS.AddEffect)(nCharId, mapEft[1], mapEft[2], 0)
                  ;
                  (table.insert)((retDiscEffect[nDiscTid])[mapEft[1]], nEftUid)
                end
              end
            end
            do
              if mapNoteEffect ~= nil then
                for nNoteId,tbNoteEffectId in pairs(mapNoteEffect) do
                  if retNoteEffect[nNoteId] == nil then
                    retNoteEffect[nNoteId] = {}
                  end
                  for _,mapEft in ipairs(tbNoteEffectId) do
                    -- DECOMPILER ERROR at PC298: Confused about usage of register: R21 in 'UnsetPending'

                    if (retNoteEffect[nNoteId])[mapEft[1]] == nil then
                      (retNoteEffect[nNoteId])[mapEft[1]] = {}
                    end
                    local nEftUid = (UTILS.AddEffect)(nCharId, mapEft[1], mapEft[2], 0)
                    ;
                    (table.insert)((retNoteEffect[nNoteId])[mapEft[1]], nEftUid)
                  end
                end
              end
              do
                -- DECOMPILER ERROR at PC317: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC317: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC317: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC317: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC317: LeaveBlock: unexpected jumping out DO_STMT

              end
            end
          end
        end
      end
    end
  end
  return retCharEffect, retDiscEffect, retNoteEffect
end

local RemoveEffect = function(nEftUid, nCharId)
  -- function num : 0_59 , upvalues : _ENV
  safe_call_cs_func((CS.AdventureModuleHelper).RemoveActorEffect, nCharId, nEftUid)
end

local GetBattleSamples = function()
  -- function num : 0_60 , upvalues : _ENV
  local lstBattleSamples = ((CS.AdventureModuleHelper).GetBattleSamples)()
  local tbSamples = {}
  if lstBattleSamples ~= nil then
    local nCount = lstBattleSamples.Count - 1
    local csList2Table = function(list)
    -- function num : 0_60_0 , upvalues : _ENV
    if list == nil then
      return {}
    end
    local nLstCount = list.Count - 1
    local ret = {}
    for i = 0, nLstCount do
      (table.insert)(ret, list[i])
    end
    return ret
  end

    for i = 0, nCount do
      local mapSample = {}
      mapSample.FromSrcAtk = (lstBattleSamples[i]).fromSrcAtk
      mapSample.FromPerkIntensityRatio = (lstBattleSamples[i]).fromPerkIntensityRatio
      mapSample.FromSlotDmgRatio = (lstBattleSamples[i]).fromSlotDmgRatio
      mapSample.FromEE = (lstBattleSamples[i]).fromEE
      mapSample.FromGenDmgRatio = (lstBattleSamples[i]).fromGenDmgRatio
      mapSample.FromDmgPlus = (lstBattleSamples[i]).fromDmgPlus
      mapSample.FromCritRatio = (lstBattleSamples[i]).fromCritRatio
      mapSample.FromFinalDmgRatio = (lstBattleSamples[i]).fromFinalDmgRatio
      mapSample.FromFinalDmgPlus = (lstBattleSamples[i]).fromFinalDmgPlus
      mapSample.ToErAmend = (lstBattleSamples[i]).toErAmend
      mapSample.ToDefAmend = (lstBattleSamples[i]).toDefAmend
      mapSample.ToRcdSlotDmgRatio = (lstBattleSamples[i]).toRcdSlotDmgRatio
      mapSample.ToEERCD = (lstBattleSamples[i]).toEERCD
      mapSample.ToGenDmgRcdRatio = (lstBattleSamples[i]).toGenDmgRcdRatio
      mapSample.ToDmgPlusRcd = (lstBattleSamples[i]).toDmgPlusRcd
      mapSample.Dmg = (lstBattleSamples[i]).dmg
      mapSample.CritRate = (lstBattleSamples[i]).critRate
      mapSample.Hp = (lstBattleSamples[i]).maxHP
      mapSample.Log = {}
      ;
      (table.insert)(tbSamples, mapSample)
    end
  end
  do
    return tbSamples
  end
end

local GetCharDamageResult = function(tbCharId)
  -- function num : 0_61 , upvalues : _ENV
  local tbResult = {}
  for i = 1, #tbCharId do
    local nCharId = tbCharId[i]
    local nDamage = ((CS.AdventureModuleHelper).GetCharacterDamage)(nCharId, false)
    local actorInfo = {}
    actorInfo.nCharId = nCharId
    actorInfo.nDamage = nDamage
    ;
    (table.insert)(tbResult, actorInfo)
  end
  return tbResult
end

local ClickItemGridWithTips = function(nTid, transform, bOnlyItemTips, bShowDepot, bShowJumpto, nHasCount)
  -- function num : 0_62 , upvalues : _ENV
  local mapItemCfgData = (ConfigTable.GetData_Item)(nTid)
  if mapItemCfgData == nil then
    return 
  end
  if mapItemCfgData.Type == (GameEnum.itemType).Disc then
    (EventManager.Hit)(EventId.OpenPanel, PanelId.DiscSample, nTid)
    return 
  else
    if mapItemCfgData.Type == (GameEnum.itemType).Char then
      (EventManager.Hit)(EventId.OpenPanel, PanelId.CharBgTrialPanel, PanelId.CharInfoTrial, nTid, {nTid}, true)
      return 
    end
  end
  if bOnlyItemTips then
    local mapData = {nTid = nTid, bShowDepot = bShowDepot, bShowJumpto = bShowJumpto, nHasCount = nHasCount}
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ItemTips, transform, mapData)
  else
    do
      local mapData = {nTid = nTid, bShowDepot = bShowDepot, bShowJumpto = bShowJumpto, nHasCount = nHasCount}
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.ItemTips, transform, mapData)
    end
  end
end

local CheckIsTipsPanel = function(nPanelId)
  -- function num : 0_63 , upvalues : _ENV
  local tbAllTipsPanelId = {PanelId.ItemTips, PanelId.PerkTips, PanelId.SkillTips, PanelId.BtnTips, PanelId.MonsterTips, PanelId.EquipmentTips, PanelId.DiscSkillTips}
  do return (table.indexof)(tbAllTipsPanelId, nPanelId) > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

local ClickWordLink = function(link, sWordId, mapLinkParam)
  -- function num : 0_64 , upvalues : _ENV, GetPotentialId
  local nWordId = tonumber(sWordId)
  local mapWordData = (ConfigTable.GetData)("Word", nWordId)
  if mapWordData == nil then
    if sWordId == nil then
      printError("sWordId为空")
      return 
    end
    printError("wordId error:" .. sWordId)
    return 
  end
  if mapWordData.Type == (GameEnum.wordLinkType).Word then
    local mapData = {nPerkId = 0, nCount = 0, bWordTip = true, sWordId = sWordId}
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.PerkTips, link, mapData)
  else
    do
      if mapWordData.Type == (GameEnum.wordLinkType).Potential then
        if mapLinkParam == nil or mapLinkParam.nCharId == nil then
          printError("该<潜能>词条 id 找不到角色:" .. sWordId)
          return 
        else
          local nPotentialId = GetPotentialId(mapLinkParam.nCharId, tonumber(mapWordData.Param1))
          ;
          (EventManager.Hit)(EventId.OpenPanel, PanelId.PotentialDetail, nPotentialId, mapLinkParam.nLevel, mapLinkParam.nAddLv)
        end
      end
    end
  end
end

local build_priority = function(selected, default_priority)
  -- function num : 0_65 , upvalues : _ENV
  local priority = {}
  local selected_map = {}
  for _,field in ipairs(selected) do
    (table.insert)(priority, field)
    selected_map[field] = true
  end
  for _,field in ipairs(default_priority) do
    if not selected_map[field] then
      (table.insert)(priority, field)
    end
  end
  return priority
end

local compare_roles = function(a, b, sort_priority, bOrder)
  -- function num : 0_66 , upvalues : _ENV
  for i,field in ipairs(sort_priority) do
    local va, vb = a[field], b[field]
    if field == "Rare" or field == "nRarity" then
      if i == 1 and bOrder then
        if vb >= va then
          do return va == nil or vb == nil or va == vb end
          do return va < vb end
          -- DECOMPILER ERROR at PC42: Unhandled construct in 'MakeBoolean' P3

          if va >= vb then
            do
              do return (i ~= 1 or not bOrder) and field ~= "nEET" end
              do return vb < va end
              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  do return false end
  -- DECOMPILER ERROR: 10 unprocessed JMP targets
end

local SortByPriority = function(items, selected_fields, default_priority, bOrder)
  -- function num : 0_67 , upvalues : build_priority, _ENV, compare_roles
  local sort_priority = build_priority(selected_fields, default_priority)
  ;
  (table.sort)(items, function(a, b)
    -- function num : 0_67_0 , upvalues : compare_roles, sort_priority, bOrder
    return compare_roles(a, b, sort_priority, bOrder)
  end
)
end

local GetDayRefreshTimeOffset = function()
  -- function num : 0_68 , upvalues : _ENV
  local nNewDayTime = (ConfigTable.GetConfigNumber)("DailyRefreshOffsetHour") or 5
  if nNewDayTime > 24 then
    nNewDayTime = nNewDayTime % 24
  end
  return nNewDayTime
end

local SDK_Logout = function()
  -- function num : 0_69 , upvalues : _ENV
  local SDKManager = (CS.SDKManager).Instance
  if SDKManager:IsSDKInit() ~= true then
    return 
  end
  SDKManager:SwitchAccount()
end

local SDK_ShowAgreement = function()
  -- function num : 0_70 , upvalues : _ENV
  local SDKManager = (CS.SDKManager).Instance
  if SDKManager:IsSDKInit() ~= true then
    return 
  end
  local agreements = {}
  local sChannel = (NovaAPI.GetClientChannel)()
  if sChannel == "CN_Bilibili" or sChannel == "CN" or sChannel == "KOL" then
    (table.insert)(agreements, "user_agreement")
    ;
    (table.insert)(agreements, "privacy_agreement")
    ;
    (table.insert)(agreements, "child_privacy_agreement")
  else
    ;
    (table.insert)(agreements, "user_agreement")
    ;
    (table.insert)(agreements, "privacy_agreement")
    ;
    (table.insert)(agreements, "minors_shop_agreement")
  end
  ;
  (SDKManager.SDK):ShowAgreement(agreements)
end

local ServerChannel_CN = {[1] = "cn_android_official", [2] = "cn_ios_official", [4] = "cn_android_bilibili", [8] = "cn_harmony_official", [16] = "cn_pc_official", [32] = "cn_pc_bilibili"}
local ServerChannel_JP = {[1] = "jp_android_official", [2] = "jp_ios_official", [4] = "jp_android_onestore", [8] = "jp_pc_official"}
local ServerChannel_US = {[1] = "us_android_official", [2] = "us_ios_official", [4] = "us_android_onestore", [8] = "us_pc_official"}
local ServerChannel_KR = {[1] = "kr_android_official", [2] = "kr_ios_official", [4] = "kr_android_onestore", [8] = "kr_pc_official"}
local ServerChannel_TW = {[1] = "tw_android_official", [2] = "tw_ios_official", [4] = "tw_android_onestore", [8] = "tw_pc_official"}
local GetChannelConfigList = function()
  -- function num : 0_71 , upvalues : _ENV, ServerChannel_CN, ServerChannel_JP, ServerChannel_US, ServerChannel_KR, ServerChannel_TW
  local resultList = nil
  local clientPublishRegion = (CS.ClientConfig).ClientPublishRegion
  if clientPublishRegion == (CS.ClientPublishRegion).CN then
    resultList = ServerChannel_CN
  else
    if clientPublishRegion == (CS.ClientPublishRegion).JP then
      resultList = ServerChannel_JP
    else
      if clientPublishRegion == (CS.ClientPublishRegion).US then
        resultList = ServerChannel_US
      else
        if clientPublishRegion == (CS.ClientPublishRegion).KR then
          resultList = ServerChannel_KR
        else
          if clientPublishRegion == (CS.ClientPublishRegion).TW then
            resultList = ServerChannel_TW
          end
        end
      end
    end
  end
  return resultList
end

local CheckChannel = function(channel)
  -- function num : 0_72 , upvalues : _ENV, GetChannelConfigList
  local fullChannnel = (CS.ClientConfig).FullClientPublishChannelName
  local channelList = GetChannelConfigList()
  if channelList == nil then
    return false
  end
  local strChannel = channelList[channel]
  if strChannel == nil then
    return false
  end
  local tbClient = (string.split)(fullChannnel, "_")
  local tbServer = (string.split)(strChannel, "_")
  if tbClient[2] == nil or tbServer[2] == nil or tbClient[2] ~= tbServer[2] then
    return false
  end
  if tbClient[3] == "taptap" then
    tbClient[3] = "official"
  end
  if (string.match)(tbClient[3], "test") then
    tbClient[3] = "official"
  end
  if tbClient[3] == nil or tbServer[3] == nil or tbClient[3] ~= tbServer[3] then
    return false
  end
  return true
end

local CheckChannelList = function(channelList)
  -- function num : 0_73 , upvalues : _ENV, CheckChannel
  local sCurClientPublishRegion = (CS.ClientConfig).ClientPublishRegion
  if sCurClientPublishRegion == (CS.ClientPublishRegion).Other then
    return true
  end
  for i = 0, channelList.Count - 1 do
    if CheckChannel(channelList[i]) then
      return true
    end
  end
  return false
end

local CheckChannelList_Notice = function(channelList)
  -- function num : 0_74 , upvalues : _ENV, CheckChannel
  local sCurClientPublishRegion = (CS.ClientConfig).ClientPublishRegion
  if sCurClientPublishRegion == (CS.ClientPublishRegion).Other then
    return true
  end
  for _,channel in ipairs(channelList) do
    if CheckChannel(channel) then
      return true
    end
  end
  return false
end

local VersionCompare = function(v1, v2, num)
  -- function num : 0_75 , upvalues : _ENV
  local v1List = (string.split)(v1, ".")
  local v2List = (string.split)(v2, ".")
  for i = 1, num do
    if #v1List < i or #v2List < i then
      if #v1List < #v2List then
        return -1
      else
        if #v2List < #v1List then
          return 1
        else
          return 0
        end
      end
    end
    local v1_num = tonumber(v1List[i]) or 0
    local v2_num = tonumber(v2List[i]) or 0
    if v2_num < v1_num then
      return 1
    else
      if v1_num < v2_num then
        return -1
      end
    end
  end
  return 0
end

local GetBBSUrl = function()
  -- function num : 0_76 , upvalues : _ENV
  local result = false
  local url = ""
  local sChannel = (NovaAPI.GetClientChannel)()
  if sChannel == "CN" or sChannel == "CN_Taptap" then
    result = true
    url = "https://bbs-stellasora.yostar.net/"
  else
    if sChannel == "CN_TEST_1" then
      result = true
      url = "https://staging-bbs.yostar.net/"
    end
  end
  return result, url
end

local GetToolBoxUrl = function()
  -- function num : 0_77 , upvalues : _ENV
  local result = false
  local url = ""
  local sChannel = (NovaAPI.GetClientChannel)()
  local clientPublishRegion = (CS.ClientConfig).ClientPublishRegion
  if clientPublishRegion == (CS.ClientPublishRegion).CN then
    if sChannel == "CN" or sChannel == "CN_Bilibili" or sChannel == "CN_Taptap" then
      result = true
      url = "https://toolbox-stellasora.yostar.cn"
    else
      result = true
      url = "https://staging-web-toolbox-stellasora.yostar.cn"
    end
  else
    if clientPublishRegion == (CS.ClientPublishRegion).TW then
      if sChannel == "TW" then
        result = true
        url = "https://toolbox-stellasora.stargazer-games.com"
      else
        result = true
        url = "https://staging-web-toolbox-stellasora.stargazer-games.com"
      end
    else
      if clientPublishRegion == (CS.ClientPublishRegion).JP then
        if sChannel == "JP" then
          result = true
          url = "https://toolbox.stellasora.jp"
        else
          result = true
          url = "https://staging-web-toolbox.stellasora.jp"
        end
      else
        if clientPublishRegion == (CS.ClientPublishRegion).US then
          if sChannel == "EN" then
            result = true
            url = "https://toolbox.stellasora.global"
          else
            result = true
            url = "https://staging-web-toolbox.stellasora.global"
          end
        else
          if clientPublishRegion == (CS.ClientPublishRegion).KR then
            if sChannel == "KR" then
              result = true
              url = "https://toolbox.stellasora.kr"
            else
              result = true
              url = "https://staging-web-toolbox.stellasora.kr"
            end
          end
        end
      end
    end
  end
  return result, url
end

local GetExchangeCodeUrl = function()
  -- function num : 0_78 , upvalues : _ENV
  local result = false
  local url = ""
  local sChannel = (NovaAPI.GetClientChannel)()
  local clientPublishRegion = (CS.ClientConfig).ClientPublishRegion
  if clientPublishRegion ~= (CS.ClientPublishRegion).CN or clientPublishRegion == (CS.ClientPublishRegion).TW then
    if sChannel == "TW" then
      result = true
      url = "https://stellasora.stargazer-games.com/redemption?type=webview"
    else
      result = true
      url = "https://staging-web-stellasora.stargazer-games.com/redemption?type=webview"
    end
  else
    if clientPublishRegion == (CS.ClientPublishRegion).JP then
      if sChannel == "JP" then
        result = true
        url = "https://stellasora.jp/serial_code?type=webview"
      else
        result = true
        url = "https://staging-web.stellasora.jp/serial_code?type=webview"
      end
    else
      if clientPublishRegion == (CS.ClientPublishRegion).US then
        if sChannel == "EN" then
          result = true
          url = "https://stellasora.global/gift?type=webview"
        else
          result = true
          url = "https://staging-web.stellasora.global/gift?type=webview"
        end
      else
        if clientPublishRegion == (CS.ClientPublishRegion).KR then
          if sChannel == "KR" then
            result = true
            url = "https://stellasora.kr/gift?type=webview"
          else
            result = true
            url = "https://staging-web.stellasora.kr/gift?type=webview"
          end
        end
      end
    end
  end
  return result, url
end

-- DECOMPILER ERROR at PC461: Confused about usage of register: R57 in 'UnsetPending'

_G.UTILS = {DecodeChangeInfo = DecodeChangeInfo, OpenReceiveByChangeInfo = OpenReceiveByChangeInfo, OpenReceiveByDisplayItem = OpenReceiveByDisplayItem, OpenReceiveByReward = OpenReceiveByReward, GetParamStrLen = GetParamStrLen, ParseByteString = ParseByteString, IsBitSet = IsBitSet, GetBuildAttributeId = GetBuildAttributeId, GetCharacterAttributeId = GetCharacterAttributeId, GetDiscAttributeId = GetDiscAttributeId, GetDiscExtraAttributeId = GetDiscExtraAttributeId, GetPotentialId = GetPotentialId, SubDesc = SubDesc, ParseDesc = ParseDesc, ParseDiscDesc = ParseDiscDesc, ParseParamDesc = ParseParamDesc, ParseLevelQuestTargetDesc = ParseLevelQuestTargetDesc, GetLevelQuestTargetProcess = GetLevelQuestTargetProcess, ParseRewardItemCount = ParseRewardItemCount, GetBezierPointByT = GetBezierPointByT, AddEffect = AddEffect, AddFateCardEft = AddFateCardEft, AddBuildEffect = AddBuildEffect, RemoveEffect = RemoveEffect, GetBattleSamples = GetBattleSamples, GetCharDamageResult = GetCharDamageResult, ClickItemGridWithTips = ClickItemGridWithTips, QueryLevelInfo = QueryLevelInfo, SDK_Logout = SDK_Logout, SDK_ShowAgreement = SDK_ShowAgreement, ParseNoBrokenDesc = ParseNoBrokenDesc, CheckIsTipsPanel = CheckIsTipsPanel, ClickWordLink = ClickWordLink, CheckChannelList = CheckChannelList, VersionCompare = VersionCompare, SortByPriority = SortByPriority, GetDayRefreshTimeOffset = GetDayRefreshTimeOffset, GetBBSUrl = GetBBSUrl, GetToolBoxUrl = GetToolBoxUrl, GetExchangeCodeUrl = GetExchangeCodeUrl, CheckChannelList_Notice = CheckChannelList_Notice}

