require("utils")
;
(NovaAPI.SetTouchScreenSupport)(true)
;
(NovaAPI.SetNormalSupport)(true)
local TimerManager = require("GameCore.Timer.TimerManager")
local ModuleManager = require("GameCore.Module.ModuleManager")
local ConfigData = require("GameCore.Data.ConfigData")
local LocalSettingData = require("GameCore.Data.LocalSettingData")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local AvgManager = require("GameCore.Module.AvgManager")
local MessageBoxManager = require("GameCore.Module.MessageBoxManager")
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
local LampNoticeManager = require("GameCore.Module.LampNoticeManager")
RedDotManager = require("GameCore.RedDot.RedDotManager")
;
(EventManager.Init)()
;
(TimerManager.Init)()
;
(ModuleManager.Init)()
;
(HttpNetHandler.Init)()
;
(ConfigData.Load)(Settings.sCurrentTxtLanguage)
-- DECOMPILER ERROR at PC63: Confused about usage of register: R9 in 'UnsetPending'

;
((CS.ClientManager).Instance).serverTimeZone = (ConfigTable.GetConfigValue)("TimeZone")
;
(PlayerData.Init)()
;
(LocalSettingData.Init)()
;
(PanelManager.Init)()
;
(Actor2DManager.Init)()
;
(AvgManager.Init)()
;
(MessageBoxManager.Init)()
;
(GamepadUIManager.Init)()
;
(LampNoticeManager.Init)()
;
(RedDotManager.Init)()
;
(PopUpManager.Init)()
OnCSLuaManagerUpdate = function()
  -- function num : 0_0 , upvalues : TimerManager
  (TimerManager.MonoUpdate)()
end

OnCSLuaManagerShutdown = function()
  -- function num : 0_1 , upvalues : _ENV
  print("---------- LuaManager.cs invoke Shutdown() in Mono.OnDestroy() ----------")
  ;
  (EventManager.Hit)(EventId.CSLuaManagerShutdown)
  if Settings.bDebugLua == true then
    local xLuaUtil = require("xlua.util")
    ;
    (xLuaUtil.print_func_ref_by_csharp)()
  end
end

CsPushToLua = function(sEventName, ...)
  -- function num : 0_2 , upvalues : _ENV
  local nEventId = EventId[sEventName]
  if nEventId == nil then
    (EventManager.Hit)(sEventName, ...)
  else
    ;
    (EventManager.Hit)(nEventId, ...)
  end
end

CsPushEntityEventToLua = function(sEventName, nEntityId, ...)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.HitEntityEvent)(sEventName, nEntityId, ...)
end


