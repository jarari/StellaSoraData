local LocalSettingData = {}
local LocalData = require("GameCore.Data.LocalData")
local WwiseManger = CS.WwiseAudioManager
local UIGameSystemSetup = CS.UIGameSystemSetup
local DefaultSoundValue = 100
local LoadLocalData = function(key, defaultValue)
  -- function num : 0_0 , upvalues : LocalData
  local value = (LocalData.GetLocalData)("GameSystemSettingsData", key)
  if value ~= nil then
    return value
  else
    return defaultValue
  end
end

local InitCurSignInData = function()
  -- function num : 0_1 , upvalues : LocalData
  (LocalData.DelLocalData)("UpgradeMat", "Presents")
  ;
  (LocalData.DelLocalData)("UpgradeMat", "Outfit")
end

local LoadSoundData = function()
  -- function num : 0_2 , upvalues : LocalSettingData, LoadLocalData, DefaultSoundValue
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R0 in 'UnsetPending'

  (LocalSettingData.mapData).NumMusic = LoadLocalData("NumMusic", DefaultSoundValue)
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).OpenMusic = LoadLocalData("OpenMusic", true)
  -- DECOMPILER ERROR at PC17: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).NumSfx = LoadLocalData("NumSfx", DefaultSoundValue)
  -- DECOMPILER ERROR at PC23: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).OpenSfx = LoadLocalData("OpenSfx", true)
  -- DECOMPILER ERROR at PC29: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).NumChar = LoadLocalData("NumChar", DefaultSoundValue)
  -- DECOMPILER ERROR at PC35: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).OpenChar = LoadLocalData("OpenChar", true)
  -- DECOMPILER ERROR at PC41: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).WwiseMuteInBackground = LoadLocalData("WwiseMuteInBackground", true)
end

local LoadBattleData = function()
  -- function num : 0_3 , upvalues : LocalSettingData, LoadLocalData, _ENV, UIGameSystemSetup
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R0 in 'UnsetPending'

  (LocalSettingData.mapData).Animation = LoadLocalData("Animation", (AllEnum.BattleAnimSetting).DayOnce)
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R0 in 'UnsetPending'

  if (LocalSettingData.mapData).Animation == 1 then
    (UIGameSystemSetup.Instance).PlayType = (UIGameSystemSetup.TimeLinePlayType).dayOnce
  else
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R0 in 'UnsetPending'

    if (LocalSettingData.mapData).Animation == 2 then
      (UIGameSystemSetup.Instance).PlayType = (UIGameSystemSetup.TimeLinePlayType).everyTime
    else
      -- DECOMPILER ERROR at PC33: Confused about usage of register: R0 in 'UnsetPending'

      if (LocalSettingData.mapData).Animation == 3 then
        (UIGameSystemSetup.Instance).PlayType = (UIGameSystemSetup.TimeLinePlayType).none
      end
    end
  end
  -- DECOMPILER ERROR at PC41: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).AnimationSub = LoadLocalData("AnimationSub", (AllEnum.BattleAnimSetting).DayOnce)
  -- DECOMPILER ERROR at PC52: Confused about usage of register: R0 in 'UnsetPending'

  if not (NovaAPI.IsMobilePlatform)() then
    (LocalSettingData.mapData).Mouse = LoadLocalData("Mouse", false)
    -- DECOMPILER ERROR at PC56: Confused about usage of register: R0 in 'UnsetPending'

    ;
    (UIGameSystemSetup.Instance).EnableMouseInputDir = (LocalSettingData.mapData).Mouse
  end
  -- DECOMPILER ERROR at PC62: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).JoyStick = LoadLocalData("JoyStick", true)
  -- DECOMPILER ERROR at PC66: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (UIGameSystemSetup.Instance).EnableFloatingJoyStick = (LocalSettingData.mapData).JoyStick
  -- DECOMPILER ERROR at PC72: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).Gizmos = LoadLocalData("Gizmos", true)
  -- DECOMPILER ERROR at PC76: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (UIGameSystemSetup.Instance).EnableAttackGizmos = (LocalSettingData.mapData).Gizmos
  -- DECOMPILER ERROR at PC82: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).AutoUlt = LoadLocalData("AutoUlt", true)
  -- DECOMPILER ERROR at PC86: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (UIGameSystemSetup.Instance).EnableAutoUlt = (LocalSettingData.mapData).AutoUlt
  -- DECOMPILER ERROR at PC99: Confused about usage of register: R0 in 'UnsetPending'

  if not (NovaAPI.IsMobilePlatform)() then
    (LocalSettingData.mapData).BattleHUD = LoadLocalData("BattleHUD", (AllEnum.BattleHudType).Horizontal)
  else
    -- DECOMPILER ERROR at PC108: Confused about usage of register: R0 in 'UnsetPending'

    ;
    (LocalSettingData.mapData).BattleHUD = LoadLocalData("BattleHUD", (AllEnum.BattleHudType).Sector)
  end
end

LocalSettingData.Init = function()
  -- function num : 0_4 , upvalues : LocalSettingData, LoadLocalData, LoadSoundData, LoadBattleData, InitCurSignInData
  LocalSettingData.mapData = {}
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (LocalSettingData.mapData).UseLive2D = LoadLocalData("UseLive2D", true)
  LoadSoundData()
  LoadBattleData()
  InitCurSignInData()
end

LocalSettingData.GetLocalSettingData = function(subKey)
  -- function num : 0_5 , upvalues : LocalSettingData
  return (LocalSettingData.mapData)[subKey]
end

LocalSettingData.SetLocalSettingData = function(subKey, value)
  -- function num : 0_6 , upvalues : _ENV, LocalData, LocalSettingData
  if type(subKey) ~= "string" or value == nil then
    return 
  end
  ;
  (LocalData.SetLocalData)("GameSystemSettingsData", subKey, value)
  -- DECOMPILER ERROR at PC14: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (LocalSettingData.mapData)[subKey] = value
end

return LocalSettingData

