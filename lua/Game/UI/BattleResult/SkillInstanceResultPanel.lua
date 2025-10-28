
local SkillInstanceResultPanel = class("SkillInstanceResultPanel", BasePanel)

SkillInstanceResultPanel._bAddToBackHistory = false

-- Panel 定义
SkillInstanceResultPanel._tbDefine = {
    {sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.SkillInstanceResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function SkillInstanceResultPanel:Awake()
end
function SkillInstanceResultPanel:OnEnable()
end
function SkillInstanceResultPanel:OnDisable()
end
function SkillInstanceResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return SkillInstanceResultPanel
