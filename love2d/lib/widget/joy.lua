local joy = {
  _toques = {},
  _activo = {},
  _time = 0
}

---@param x integer
---@param y integer
---@param w integer
---@param zone nil|integer
---@return table
function joy:new(x, y, w, zone)
  local r = {
    x = x + w / 2,
    y = y + w / 2,
    touch = false,
    ID = 0,
    radio = w / 2,
    radio2 = w / 6,
    fuera = false,
    dis = 0,
    angulo = 0,
    dir = 0,
    zone = zone or 3
  }
  return r
end

if love.system.getOS() == "Android" then
  function joy:update()
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
  function joy:update()
    self._toques = {}
    if love.mouse.isDown(1) then
      self._toques = { { love.mouse.getPosition() } }
      self._time = self._time + 1
    else
      self._time = 0
    end
  end
end

local _90 = math.rad(90)
function joy:scroll(v)
  v.touch = false
  for n, t in ipairs(self._toques) do
    local dis = math.sqrt((v.x - t[1]) ^ 2 + (v.y - t[2]) ^ 2)
    if dis <= (v.radio * v.zone) then
      v.touch = true
      v.ID = n
      v.dis = dis
      v.fuera = true
      v.angulo = -math.atan2(t[1] - v.x, t[2] - v.y) + _90
    end
    if dis <= v.radio then
      v.touch = true
      v.ID = n
      v.dis = dis
      v.fuera = false
      v.angulo = -math.atan2(self._toques[v.ID][1] - v.x, self._toques[v.ID][2] - v.y) + _90
    end
  end
  if not self.touch then
    v.dis = 0
    self.time = 0; self.ID = 0
  end
end

local dirx, diry
function joy:draw(v)
  if v.touch then
    if v.fuera then
      dirx, diry = math.cos(v.angulo) * v.radio, math.sin(v.angulo) * v.radio
      love.graphics.circle("line", dirx + v.x, diry + v.y, v.radio2)
    else
      love.graphics.circle("line", self._toques[v.ID][1], self._toques[v.ID][2], v.radio2)
    end
  else
    love.graphics.circle("line", v.x, v.y, v.radio2)
  end
  love.graphics.circle("line", v.x, v.y, v.radio)
end

local ang
function joy:getdir(v)
  if v.touch then
    local ang = math.deg(v.angulo) + 22.5
    if ang < 0 then
      ang = ang + 360
    end
    v.dir = math.floor((ang + 45) / 90) % 4 + 1
  else
    v.dir = 0
  end
end

function joy:getdir2(v)
  if v.touch then
    local ang = math.deg(v.angulo) + 20
    if ang < 0 then
      ang = 360 + ang
    end
    v.dir = math.floor((ang + 22.5) / 45) % 9 + 1
  else
    v.dir = 0
  end
end

function joy:normalize_ang(v)
  if v.touch then
    ang = math.deg(v.angulo)
    if ang < 0 then
      ang = ang + 360
    end
    return true, ang
  else
    return false
  end
end

function joy:debug(v, x)
  x = x or 0
  local ang = math.deg(v.angulo)
  love.graphics.print(v.angulo, x + 0, 15)
  if ang < 0 then
    ang = (90 + ang) + 270
  end
  love.graphics.circle("line", v.x, v.y, v.radio * v.zone)
  love.graphics.print(ang, x + 0, 30)
  self:getdir2(v)
  love.graphics.print(v.dir, x + 0, 45)
end

return joy
