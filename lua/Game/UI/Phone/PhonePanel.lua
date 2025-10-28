-- 手机界面
local PhonePanel = class("PhonePanel", BasePanel)
-- Panel 定义
PhonePanel._nSnapshotPrePanel = 4

PhonePanel._tbDefine = {
    {sPrefabPath = "Phone/PhonePanel.prefab", sCtrlName = "Game.UI.Phone.PhoneCtrl"},
}
-------------------- local function --------------------
function PhonePanel:GetAvgContactsData(sContactsId)
    local tbContacts = PlayerData.Phone:GetAvgContactsData(sContactsId)
    if tbContacts == nil then
        return sContactsId
    else
        return tbContacts
    end
end
-------------------- base function --------------------
function PhonePanel:Awake()
    self.nCurTog = nil
    self.nSelectCharId = nil

    self.sTxtLan = Settings.sCurrentTxtLanguage
    self.sVoLan = Settings.sCurrentVoLanguage
    self.bIsPlayerMale = PlayerData.Base:GetPlayerSex() == true
end
function PhonePanel:OnEnable()
end
function PhonePanel:OnAfterEnter()
end
function PhonePanel:OnDisable()
end
function PhonePanel:OnDestroy()
end
function PhonePanel:OnRelease()
end
-------------------- callback function --------------------
return PhonePanel
