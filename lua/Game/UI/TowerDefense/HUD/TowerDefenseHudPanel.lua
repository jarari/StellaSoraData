

local TowerDefenseHudPanel = class("TowerDefenseHudPanel", BasePanel)

TowerDefenseHudPanel._bAddToBackHistory = false
TowerDefenseHudPanel._bIsMainPanel = false
TowerDefenseHudPanel._sSortingLayerName = AllEnum.SortingLayerName.HUD
TowerDefenseHudPanel._tbDefine = 
{
    -- 定义当前 Panel 由哪些 prefab 组成，以及每个 prefab 分别由哪个 ctrl 关联控制
    {sPrefabPath = "Play_TowerDefence/HUD/HUDROOT.prefab", sCtrlName = "Game.UI.TowerDefense.HUD.TowerDefenseHUDCtrl"},
}

-------------------- base function --------------------


-------------------- callback function --------------------

return TowerDefenseHudPanel