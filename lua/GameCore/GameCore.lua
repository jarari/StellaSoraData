require "utils"
NovaAPI.SetTouchScreenSupport(true)
NovaAPI.SetNormalSupport(true)
local TimerManager = require "GameCore.Timer.TimerManager"
local ModuleManager = require "GameCore.Module.ModuleManager"
local ConfigData = require "GameCore.Data.ConfigData"
local LocalSettingData = require "GameCore.Data.LocalSettingData"
local Actor2DManager = require "Game.Actor2D.Actor2DManager"
local AvgManager = require "GameCore.Module.AvgManager"
local MessageBoxManager = require "GameCore.Module.MessageBoxManager"
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"
local LampNoticeManager= require "GameCore.Module.LampNoticeManager"
RedDotManager = require "GameCore.RedDot.RedDotManager"
EventManager.Init() -- 初始化Lua侧专用的事件管理器（C#侧也有但约定不在Lua侧使用）
TimerManager.Init() -- 初始化Lua侧专用的计时管理器（C#侧也有但约定不在Lua侧使用）
ModuleManager.Init() -- 模块管理器初始化（主要监听c#侧模块切换事件，用来触发Lua侧界面切换）
HttpNetHandler.Init() -- 初始化网络
ConfigData.Load(Settings.sCurrentTxtLanguage) -- 加载静态数据（配置表数据）
CS.ClientManager.Instance.serverTimeZone = ConfigTable.GetConfigValue("TimeZone")  -- 设置时区
PlayerData.Init() -- 初始化动态数据（服务器发来的玩家数据）
LocalSettingData.Init() -- 初始化本地设置
PanelManager.Init() -- 初始化界面管理器
Actor2DManager.Init() -- 初始化2D角色Live2D、静态立绘屏外绘制管理器
AvgManager.Init() -- 初始化Avg管理器
MessageBoxManager.Init() -- 初始化通用的提示对话框弹窗和飘字提示管理器
GamepadUIManager.Init() -- 初始化手柄适配相关UI管理器
LampNoticeManager.Init() --初始化走马灯UI管理类
RedDotManager.Init() -- 初始化红点事件监听
PopUpManager.Init() -- 初始化弹窗管理器
if Settings.bGMToolOpen == true then 
    local GMToolManager = require "GameCore.Module.GMToolManager"
    if GMToolManager ~= nil then
        GMToolManager.Init() -- 初始化GM工具
    end
end
function OnCSLuaManagerUpdate()
    TimerManager.MonoUpdate()
end
function OnCSLuaManagerShutdown()
    print("---------- LuaManager.cs invoke Shutdown() in Mono.OnDestroy() ----------")
    EventManager.Hit(EventId.CSLuaManagerShutdown)
    if Settings.bDebugLua == true then
        local xLuaUtil = require "xlua.util"
        xLuaUtil.print_func_ref_by_csharp()
    end
end
function CsPushToLua(sEventName, ...)
    local nEventId = EventId[sEventName]
    if nEventId == nil then
        EventManager.Hit(sEventName, ...) -- c# push event to lua by LuaManager.FireEvent()
    else
        EventManager.Hit(nEventId, ...) -- c# push event to lua by EventDispatchManager.
    end
end
function CsPushEntityEventToLua(sEventName, nEntityId, ...)
    EventManager.HitEntityEvent(sEventName, nEntityId, ...)
end
