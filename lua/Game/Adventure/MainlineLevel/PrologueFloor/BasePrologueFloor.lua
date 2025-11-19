local BasePrologueFloor = class("BasePrologueFloor")
BasePrologueFloor.ctor = function(self, parentData)
  -- function num : 0_0
  self.parent = parentData
end

BasePrologueFloor.Enter = function(self)
  -- function num : 0_1
  self:_BindEventCallback()
end

BasePrologueFloor._BindEventCallback = function(self)
  -- function num : 0_2 , upvalues : _ENV
  if type(self._mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(self._mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
end

BasePrologueFloor._UnbindEventCallback = function(self)
  -- function num : 0_3 , upvalues : _ENV
  if type(self._mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(self._mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
end

BasePrologueFloor.Exit = function(self)
  -- function num : 0_4
  self:_UnbindEventCallback()
end

return BasePrologueFloor

