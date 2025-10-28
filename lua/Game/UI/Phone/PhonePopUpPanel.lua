-- 手机弹窗界面
local PhonePopUpPanel = class("PhonePopUpPanel", BasePanel)
PhonePopUpPanel._bIsMainPanel = false

PhonePopUpPanel._tbDefine = {
    {sPrefabPath = "Phone/PhonePopUpPanel.prefab", sCtrlName = "Game.UI.Phone.PhonePopUpCtrl"},
}
-------------------- local function --------------------
function PhonePopUpPanel:GetAvgContactsData(sContactsId)
    local tbContacts = PlayerData.Phone:GetAvgContactsData(sContactsId)
    if tbContacts == nil then
        return sContactsId
    else
        return tbContacts
    end
end
-------------------- base function --------------------
function PhonePopUpPanel:Awake()
end
function PhonePopUpPanel:OnEnable()
end
function PhonePopUpPanel:OnAfterEnter()
end
function PhonePopUpPanel:OnDisable()
end
function PhonePopUpPanel:OnDestroy()
end
function PhonePopUpPanel:OnRelease()
end
-------------------- callback function --------------------
return PhonePopUpPanel
