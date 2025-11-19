local AvgEditorPanel = class("AvgEditorPanel", BasePanel)
AvgEditorPanel._tbDefine = {
{sPrefabPath = "Avg/Avg_0_Stage.prefab", sCtrlName = "Game.UI.Avg.Avg_0_Stage"}
, 
{sPrefabPath = "Avg/Avg_2_CHAR.prefab", sCtrlName = "Game.UI.Avg.Avg_2_CharCtrl"}
, 
{sPrefabPath = "Avg/Avg_3_Transition.prefab", sCtrlName = "Game.UI.Avg.Avg_3_TransitionCtrl"}
, 
{sPrefabPath = "Avg/Avg_4_Talk.prefab", sCtrlName = "Game.UI.Avg.Avg_4_TalkCtrl"}
, 
{sPrefabPath = "Avg/Avg_6_Menu.prefab", sCtrlName = "Game.UI.Avg.Avg_6_MenuCtrl"}
, 
{sPrefabPath = "Avg/Avg_7_Choice.prefab", sCtrlName = "Game.UI.Avg.Avg_7_ChoiceCtrl"}
, 
{sPrefabPath = "Avg/Editor/AvgEditorUI.prefab", sCtrlName = "Game.UI.Avg.Editor.AvgEditorCtrl"}
, 
{sPrefabPath = "Avg/AvgEditorQuickPreview.prefab", sCtrlName = "Game.UI.Avg.AvgEditorQuickPreview"}
}
AvgEditorPanel.Awake = function(self)
  -- function num : 0_0
  self.nCurLanguageIdx = 1
end

AvgEditorPanel.OnEnable = function(self)
  -- function num : 0_1
  self.objAvgEditorCtrl = self:GetCtrlObj("AvgEditorCtrl")
end

AvgEditorPanel.GetAvgCharName = function(self, sAvgCharId)
  -- function num : 0_2
  return (self.objAvgEditorCtrl):GetAvgCharName(sAvgCharId)
end

AvgEditorPanel.PlayCharEmojiSound = function(self, sEmojiName)
  -- function num : 0_3 , upvalues : _ENV
  for i,v in ipairs((self.tbAvgPreset).CharEmoji) do
    if v[3] == sEmojiName then
      local sEmojiSound = v[4]
      if type(sEmojiSound) == "string" and sEmojiSound ~= "" then
        ((CS.WwiseAudioManager).Instance):PlaySound(sEmojiSound)
      end
      break
    end
  end
end

AvgEditorPanel.PlayFxSound = function(self, sFxName, bPlay)
  -- function num : 0_4 , upvalues : _ENV
  for _,v in ipairs((self.tbAvgPreset).FxResName) do
    if v[1] == sFxName then
      local sFxSound = v[2]
      if type(sFxSound) == "string" and sFxSound ~= "" then
        if bPlay ~= true then
          sFxSound = sFxSound .. "_stop"
        end
        ;
        ((CS.WwiseAudioManager).Instance):PlaySound(sFxSound)
      end
      break
    end
  end
end

AvgEditorPanel.GetBgCgFgResFullPath = function(self, sName)
  -- function num : 0_5 , upvalues : _ENV
  if sName == "BG_Black" then
    return "ImageAvg/AvgBg/BG_Black"
  else
    if (table.indexof)((self.tbAvgPreset).BgResName, sName) > 0 then
      return "ImageAvg/AvgBg/" .. sName
    else
      if (table.indexof)((self.tbAvgPreset).CgResName, sName) > 0 then
        return "ImageAvg/AvgCG/" .. sName
      else
        if (table.indexof)((self.tbAvgPreset).FgResName, sName) > 0 then
          return "ImageAvg/AvgFg/" .. sName
        else
          if (table.indexof)((self.tbAvgPreset).DiscResName, sName) > 0 then
            local sFolderName = (string.gsub)(sName, "_B", "")
            return "Disc/" .. sFolderName .. "/" .. sName
          else
            do
              do return nil end
            end
          end
        end
      end
    end
  end
end

AvgEditorPanel.GetAvgCharReuseRes = function(self, sAvgCharId)
  -- function num : 0_6
  return (self.objAvgEditorCtrl):GetAvgCharReuseRes(sAvgCharId)
end

AvgEditorPanel.GetCharEmojiIndex = function(self, sEmoji)
  -- function num : 0_7 , upvalues : _ENV
  if self.tbAvgPreset ~= nil then
    for i,v in ipairs((self.tbAvgPreset).CharEmoji) do
      if v[3] == sEmoji then
        return v[1]
      end
    end
  end
  do
    return 0
  end
end

AvgEditorPanel.GetCtrlObj = function(self, sCtrlName)
  -- function num : 0_8 , upvalues : _ENV
  local objCtrl = nil
  for i,v in ipairs(self._tbObjCtrl) do
    if v.__cname == sCtrlName then
      objCtrl = v
      break
    end
  end
  do
    return objCtrl
  end
end

return AvgEditorPanel

