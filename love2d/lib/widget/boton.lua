local boton = {
  _toques = {},
  _activo = {},
  _time = 0
}

---Crea un boton
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@return table
function boton:new(x, y, w, h)
  return {
    x = x or 0,
    y = y or 0,
    width = w or 100,
    height = h or 100,
    touch = false,
    time = 0,
    ID = 0
  }
end

if love.system.getOS() == "Android" then
  function boton:update()
    self._toques = {}
    for i, v in ipairs(love.touch.getTouches()) do
      table.insert(self._toques, { love.touch.getPosition(v) })
    end
    if #self._toques > 0 then
      self._time = self._time + 1
    else
      self._time = 0
    end
  end
else
  function boton:update()
    self._toques = {}
    if love.mouse.isDown(1) then
      self._toques = { { love.mouse.getPosition() } }
      self._time = self._time + 1
    else
      self._time = 0
    end
  end
end

function boton:scroll(v)
  v.touch = false
  for n, t in ipairs(self._toques) do
    local x2 = v.x + v.width
    local y2 = v.y + v.height
    if v.x <= t[1] and t[1] <= x2 and v.y <= t[2] and t[2] <= y2 then
      v.touch = true
      v.time = v.time + 1
      v.ID = n
    end
  end
  if not v.touch then
    v.time = 0; v.ID = 0
  end
end

function boton:draw(v, c)
  if v.touch then
    love.graphics.rectangle("fill", v.x, v.y, v.width, v.height, c or 0)
  else
    love.graphics.rectangle("line", v.x, v.y, v.width, v.height, c or 0)
  end
end

return setmetatable(boton,
  {
    __call = function(s, ...)
      return s:new(...)
    end
  }
)
