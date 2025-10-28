-- PlayerInfoPanel
local PlayerInfoPanel = class("PlayerInfoPanel", BasePanel)
PlayerInfoPanel._sSortingLayerName = AllEnum.SortingLayerName.Overlay
PlayerInfoPanel._bAddToBackHistory = false
PlayerInfoPanel._bIsMainPanel = false
-- Panel 定义
PlayerInfoPanel._tbDefine = {
    {sPrefabPath = "PlayerInfo/PlayerInfoPanel.prefab", sCtrlName = "Game.UI.PlayerInfo.PlayerInfoCtrl"},
}
return PlayerInfoPanel