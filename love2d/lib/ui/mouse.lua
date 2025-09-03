return function(self)
  self._toques = {}
  if love.mouse.isDown(1) then
    self._toques = { { love.mouse.getPosition() } }
  end
end
