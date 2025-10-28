--Roguelike层数据处理：Editor测试
--  编辑器下流程所有层统一，无服务器通信
--  因为没有服务器数据,所以在编辑器下无宝箱和掉落



local TimerManager = require "GameCore.Timer.TimerManager"
local EditorFloor = {}
function EditorFloor:Init()
end
function EditorFloor:OnRoguelikeEnter(PlayerRoguelikeData)
    PlayerRoguelikeData:SetActorEffects()
    PlayerRoguelikeData:SetActorAttribute()
end
function EditorFloor:OnTouchPortal(PlayerRoguelikeData)
    PlayerRoguelikeData:CacheCharAttr()
    PlayerRoguelikeData:FloorEndEditor()
end
function EditorFloor:SettleCallback(PlayerRoguelikeData)
end
function EditorFloor:OnBossDied(PlayerRoguelikeData)
    safe_call_cs_func(CS.AdventureModuleHelper.Lua2CSharp_RoguelikeOpenTeleporter)
end

function EditorFloor:OnAbandon(PlayerRoguelikeData)
    PlayerRoguelikeData:FloorEndEditor()
end
return EditorFloor