

local HudPanel = class("HudPanel", BasePanel)

HudPanel._bAddToBackHistory = false
HudPanel._bIsMainPanel = false
HudPanel._sSortingLayerName = AllEnum.SortingLayerName.HUD
HudPanel._tbDefine = 
{
    -- 定义当前 Panel 由哪些 prefab 组成，以及每个 prefab 分别由哪个 ctrl 关联控制
    {
        sPrefabPath = "HUD/HUDROOT.prefab", 
        sCtrlName = "Game.UI.Hud.HudMainCtrl",
    },
}

-------------------- base function --------------------


-------------------- callback function --------------------

return HudPanel