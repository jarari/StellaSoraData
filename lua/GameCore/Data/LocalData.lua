local RapidJson = require("rapidjson")
local String = (CS.System).String
local PlayerPrefs = (CS.UnityEngine).PlayerPrefs
local LocalData = {}
LocalData.SetLocalData = function(sMainKey, sSubKey, sValue)
  -- function num : 0_0 , upvalues : PlayerPrefs, String, RapidJson
  local sJson = ((PlayerPrefs.GetString)(sMainKey))
  local mapData = nil
  if (String.IsNullOrEmpty)(sJson) == true then
    mapData = {}
    mapData[sSubKey] = sValue
  else
    mapData = (RapidJson.decode)(sJson)
    mapData[sSubKey] = sValue
  end
  sJson = (RapidJson.encode)(mapData)
  ;
  (PlayerPrefs.SetString)(sMainKey, sJson)
  ;
  (PlayerPrefs.Save)()
end

LocalData.GetLocalData = function(sMainKey, sSubKey)
  -- function num : 0_1 , upvalues : PlayerPrefs, String, RapidJson
  local sJson = (PlayerPrefs.GetString)(sMainKey)
  if (String.IsNullOrEmpty)(sJson) == true then
    return nil
  else
    local mapData = (RapidJson.decode)(sJson)
    return mapData[sSubKey]
  end
end

LocalData.DelLocalData = function(sMainKey, sSubKey)
  -- function num : 0_2 , upvalues : PlayerPrefs, String, RapidJson
  local sJson = (PlayerPrefs.GetString)(sMainKey)
  if (String.IsNullOrEmpty)(sJson) == false then
    local mapData = (RapidJson.decode)(sJson)
    mapData[sSubKey] = nil
    sJson = (RapidJson.encode)(mapData)
    ;
    (PlayerPrefs.SetString)(sMainKey, sJson)
    ;
    (PlayerPrefs.Save)()
  end
end

LocalData.SetPlayerLocalData = function(sKey, sValue)
  -- function num : 0_3 , upvalues : _ENV, LocalData
  local nPlayerId = (PlayerData.Base):GetPlayerId()
  if type(nPlayerId) == "number" then
    (LocalData.SetLocalData)(tostring(nPlayerId), sKey, sValue)
  end
end

LocalData.GetPlayerLocalData = function(sKey)
  -- function num : 0_4 , upvalues : _ENV, LocalData
  local nPlayerId = (PlayerData.Base):GetPlayerId()
  if type(nPlayerId) == "number" then
    return (LocalData.GetLocalData)(tostring(nPlayerId), sKey)
  end
end

LocalData.DelPlayerLocalData = function(sKey)
  -- function num : 0_5 , upvalues : _ENV, LocalData
  local nPlayerId = (PlayerData.Base):GetPlayerId()
  if type(nPlayerId) == "number" then
    (LocalData.DelLocalData)(tostring(nPlayerId), sKey)
  end
end

return LocalData

