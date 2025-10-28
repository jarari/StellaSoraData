
local Actor2DEditorPanel = class("Actor2DEditorPanel", BasePanel)
--[[ Panel 定义
    Actor2DEditorPanel._bIsMainPanel = true
    Actor2DEditorPanel._bAddToBackHistory = true
    Actor2DEditorPanel._nSnapshotPrePanel = 0
    
    Actor2DEditorPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
Actor2DEditorPanel._tbDefine = {
    {sPrefabPath = "Actor2DEditor/Actor2DEditor.prefab", sCtrlName = "Game.Actor2D.Editor.Actor2DEditorCtrl"}
}
return Actor2DEditorPanel
