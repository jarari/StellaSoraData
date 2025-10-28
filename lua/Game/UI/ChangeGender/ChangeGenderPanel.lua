local ChangeGenderPanel = class("ChangeGenderPanel", BasePanel)
ChangeGenderPanel._bAddToBackHistory = false
ChangeGenderPanel._tbDefine = {
    {sPrefabPath = "ChangeGender/ChangeGender.prefab", sCtrlName = "Game.UI.ChangeGender.ChangeGenderCtrl"},
    -- {sPrefabPath = "0_Test/0_TestUI.prefab", sCtrlName = "Game.UI.0_Test.TestCtrl"}, -- test StoryData
}
return ChangeGenderPanel
