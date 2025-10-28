local Settings = {} -- 配置开关及常量
Settings.tbServerUrl = -- 调试用的服务器列表（另：客户端启动时，会查询服务器列表，然后与此列表合并一起显示于登录界面）
{
    --{"版本服", "http://47.100.202.166/agent-zone-1/"},
    --{"UWA服", "http://nova.c1448349de9054dbca49ea12a6ee53f2e.cn-shanghai.alicontainer.com/agent-zone-1/"},
    --{"内网一区", "nova.develop.gmgate.net/agent-zone-1/"},
    --{"傅渊服", "http://10.155.120.223:8888"},
    --{"杨清涛服", "http://10.155.120.234:8888"},
    --{"余子涵服", "http://10.155.120.139:8888"},
    --{"杨成", "http://10.155.121.231:8888"},
    --{"郑天宇", "http://10.155.121.14:8888"},
    --{"内网体验区", "http://10.155.2.48:10008"},
}
Settings.sCurrentTxtLanguage = NovaAPI.GetCur_TextLanguage() -- 当前使用的文本语言
Settings.sCurrentVoLanguage = NovaAPI.GetCur_VoiceLanguage() -- 当前使用的语音语言
Settings.AB_ROOT_PATH = "Assets/AssetBundles/"
Settings.DESIGN_SCREEN_RESOLUTION_WIDTH = 2160 -- 屏幕设计分辨率 宽
Settings.DESIGN_SCREEN_RESOLUTION_HEIGHT = 1080 -- 屏幕设计分辨率 高
--[[ Settings.CURRENT_SCREEN_WIDTH = CS.UnityEngine.Screen.width -- 运行设备的屏宽
Settings.CURRENT_SCREEN_HEIGHT = CS.UnityEngine.Screen.height -- 运行设备的屏高 ]]
Settings.CURRENT_CANVAS_FULL_RECT_WIDTH = 2160 -- 当前运行设备屏幕的宽经过 Canvas Scaler 缩放过后的宽
Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT = 1080 -- 当前运行设备屏幕的高经过 Canvas Scaler 缩放过后的高
Settings.CANVAS_SCALE = 0.01
Settings.RENDERTEXTURE_SIZE_FACTOR = 1 -- 创建 RT 时，宽高都乘以一个系数，合理优化使用内存，移动设备上系数为0.5。
if NovaAPI.IsMobilePlatform() == true then
    Settings.RENDERTEXTURE_SIZE_FACTOR = 0.8
end

Settings.bDestroyHistoryUIInstance = CS.ClientManager.Instance:GetMemoryType() -- 是否销毁进入回退历史的 UI 实例

Settings.sPrologueAvgId1 = "STm00_01" -- 序章最后个演出房间结束后播的那个AVG ID1
Settings.sPrologueVideo = "Prologue/Prologue_P4.mp4" -- AVG1 播完接着播全屏视频
Settings.sPrologueAvgId2 = "STm00_02" -- 视频播完后接着播的 AVG ID2

if CS.ClientManager.Instance:isOpenGM() == true then
    Settings.ENABLE_DEBUGGER = false -- 是否开启Debugger

    local bDebugLuaPanda = false  -- 是否启用 luaPanda 的插件断点调试 Lua
    if bDebugLuaPanda == true then require("Debugger.LuaPanda").start("127.0.0.1", 8818) end

    Settings.bGMToolOpen = true -- 是否开启GM工具

    Settings.bManualJump = true -- 是否手动选择跳过
    Settings.bJumpPrologue = true -- 是否跳过新账号序章演出
    Settings.bJumpGuide = true -- 是否跳过新手引导
    Settings.bOpenClientDebug = false -- 客户端调试模式（程序用，打印详细堆栈信息）
end

return Settings
