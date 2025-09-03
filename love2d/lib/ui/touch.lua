return function(self)
	self._toques = {}
	for i, v in ipairs(love.touch.getTouches()) do
		table.insert(self._toques, { love.touch.getPosition(v) })
	end
end
