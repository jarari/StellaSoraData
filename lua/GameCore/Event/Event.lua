local Event = class("Event")
Event.ctor = function(self, listener, callback)
  -- function num : 0_0 , upvalues : _ENV
  self._listener = listener
  if type(callback) == "function" then
    self._callback = callback
  else
    if type(callback) == "string" then
      local cb = listener[callback]
      if type(cb) == "function" then
        self._callback = cb
      else
        self._callback = nil
      end
    else
      do
        self._callback = nil
      end
    end
  end
end

return Event

