local AdventureModuleHelper = CS.AdventureModuleHelper
local ModuleManager = {}
local bAdventure, curModuleName = nil, nil
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
local actor2dManager = require("Game.Actor2D.Actor2DManager")
local OnEvent_EnterModule = function(moduleMgr, sExitModuleName, sEnterModuleName)
  -- function num : 0_0 , upvalues : bAdventure, _ENV, actor2dManager
  bAdventure = false
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R3 in 'UnsetPending'

  if sEnterModuleName == "MainMenuModuleScene" then
    if PlayerData.back2Login then
      PlayerData.back2Login = false
      ;
      (PanelManager.OnConfirmBackToLogIn)()
    else
      -- DECOMPILER ERROR at PC19: Confused about usage of register: R3 in 'UnsetPending'

      if PlayerData.back2Home then
        PlayerData.back2Home = false
        ;
        (PanelManager.Home)()
      else
        ;
        (EventManager.Hit)(EventId.OpenPanel, PanelId.MainView)
      end
    end
    ;
    (PlayerData.Base):OnBackToMainMenuModule()
  else
    if sEnterModuleName == "AdventureModuleScene" then
      (NovaAPI.ShutdownDirtyWords)()
      bAdventure = true
      ;
      (PanelManager.Release)()
      ;
      (actor2dManager.ClearAll)()
      ;
      (PanelManager.ClearInputState)()
    end
  end
end

local OnEvent_ExitModule = function(moduleMgr, sExitModuleName, sEnterModuleName)
  -- function num : 0_1 , upvalues : _ENV
  if sExitModuleName == "AdventureModuleScene" then
    (EventManager.Hit)(EventId.ClosePanel, PanelId.Hud)
  end
end

local OnEvent_AfterEnterModule = function(moduleMgr, sEnterModuleName)
  -- function num : 0_2 , upvalues : curModuleName, _ENV
  curModuleName = sEnterModuleName
  if sEnterModuleName == "LoginModuleScene" then
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Login)
  else
    if sEnterModuleName == "MainMenuModuleScene" then
      (EventManager.Hit)(EventId.AfterEnterMain)
      ;
      ((CS.WwiseAudioManager).Instance):PostEvent("ui_loading_combatSFX_active", nil, false)
    else
      if sEnterModuleName == "AdventureModuleScene" then
        if PlayerData.nCurGameType == (AllEnum.WorldMapNodeType).Mainline then
          (EventManager.Hit)(EventId.EnterMainline)
        else
          if PlayerData.nCurGameType == (AllEnum.WorldMapNodeType).Roguelike then
            (EventManager.Hit)(EventId.EnterRoguelike)
          end
        end
      end
    end
  end
  collectgarbage("collect")
end

local OnEvent_AdventureModuleEnter = function()
  -- function num : 0_3
end

local Uninit = function(moduleMgr)
  -- function num : 0_4 , upvalues : _ENV, ModuleManager, Uninit, OnEvent_ExitModule, OnEvent_EnterModule, OnEvent_AfterEnterModule, OnEvent_AdventureModuleEnter
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, ModuleManager, Uninit)
  ;
  (EventManager.Remove)("ExitModule", ModuleManager, OnEvent_ExitModule)
  ;
  (EventManager.Remove)("EnterModule", ModuleManager, OnEvent_EnterModule)
  ;
  (EventManager.Remove)("AfterEnterModule", ModuleManager, OnEvent_AfterEnterModule)
  ;
  (EventManager.Remove)("AdventureModuleEnter", ModuleManager, OnEvent_AdventureModuleEnter)
end

ModuleManager.Init = function()
  -- function num : 0_5 , upvalues : _ENV, ModuleManager, Uninit, OnEvent_ExitModule, OnEvent_EnterModule, OnEvent_AfterEnterModule, OnEvent_AdventureModuleEnter
  (EventManager.Add)(EventId.CSLuaManagerShutdown, ModuleManager, Uninit)
  ;
  (EventManager.Add)("ExitModule", ModuleManager, OnEvent_ExitModule)
  ;
  (EventManager.Add)("EnterModule", ModuleManager, OnEvent_EnterModule)
  ;
  (EventManager.Add)("AfterEnterModule", ModuleManager, OnEvent_AfterEnterModule)
  ;
  (EventManager.Add)("AdventureModuleEnter", ModuleManager, OnEvent_AdventureModuleEnter)
end

ModuleManager.GetIsAdventure = function()
  -- function num : 0_6 , upvalues : bAdventure
  return bAdventure
end

ModuleManager.GetCurModuleName = function()
  -- function num : 0_7 , upvalues : curModuleName
  return curModuleName
end

return ModuleManager

