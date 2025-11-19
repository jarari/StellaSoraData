local FillMaterialPanel = class("FillMaterialPanel", BasePanel)
FillMaterialPanel._bIsMainPanel = false
FillMaterialPanel._tbDefine = {
{sPrefabPath = "FillMaterial/FillMaterialPanel.prefab", sCtrlName = "Game.UI.FillMaterial.FillMaterialCtrl"}
}
FillMaterialPanel.Awake = function(self)
  -- function num : 0_0
end

FillMaterialPanel.OnEnable = function(self)
  -- function num : 0_1
end

FillMaterialPanel.OnDisable = function(self)
  -- function num : 0_2
end

FillMaterialPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return FillMaterialPanel

