local ui = {
  path = { ... },
  x = 0,
  y = 0,
  width = love.graphics.getWidth(),
  height = love.graphics.getHeight(),
  ui = {},
  orientation = "vertical",
  grid = 2,
  pos = {},
  colors = { { 1, 1, 1, 1 }, { 1, 1, 1, 1 }, { 0, 0, 0, 0 } },
  cursor = function() end
}

ui.path = ui.path[1]
ui.split = require(ui.path .. ".split")
ui.boton = require(ui.path .. ".boton")
ui.label = require(ui.path .. ".label")
ui.image = require(ui.path .. ".image")
ui.canvas = require(ui.path .. ".canvas")
ui.sinput = require(ui.path .. ".sinput")
ui.input = require(ui.path .. ".input")
ui.cursor = require(ui.path .. ".mouse")

---true/false = touch/mosue
---@param bool boolean
function ui:setCursor(bool)
  if bool == 1 then
    self.cursor = require(self.path .. ".touch")
  else
    self.cursor = require(self.path .. ".mouse")
  end
end

function ui:setColors(c1, c2, c3)
  self.colors = { c1 or self.colors[1], c2 or self.colors[2], c3 or self.colors[3] }
end

function ui:newObj(o, ...)
  table.insert(self.ui, o)
  self:_pos(...)
  self:upd()
  return #self.ui
end

function ui:setOrientation(o, gr)
  self.orientation = o
  self.grid = gr or 2
  self:upd()
end

function ui:_pos(x, y, w, h)
  table.insert(self.pos, { x or self.x, y or self.y, w or math.random(100, self.width / 2), h or
  math.random(100, self.height / 2) })
end

function ui:setpos(x, y)
  self.x, self.y = x, y
end

function ui:setsize(w, h)
  self.width, self.height = w, h
end

function ui:remove(i)
  if self[self.ui[i].type].release then
    self[self.ui[i].type]:release(self.ui[i])
  end
  table.remove(self.ui, i)
  table.remove(self.pos, i)
end

function ui:upd()
  local peso = 0
  for i, v in ipairs(self.ui) do
    peso = peso + v.peso
  end
  if self.orientation == "vertical" then
    local exis = 0
    for i, v in ipairs(self.ui) do
      v.x = self.x
      v.y = self.y + exis
      v.height = math.floor(v.peso * 100 / peso) * self.height / 100
      v.width = self.width
      exis = exis + v.height
    end
  elseif self.orientation == "horizontal" then
    local exis = 0
    for i, v in ipairs(self.ui) do
      v.x = self.x + exis
      v.y = self.y
      v.width = math.floor(v.peso * 100 / peso) * self.width / 100
      v.height = self.height
      exis = exis + v.width
    end
  elseif self.orientation == "grid" then
    local pos = 1
    local pos2 = 1
    for i, v in ipairs(self.ui) do
      v.x = self.x + (pos - 1) * self.width / self.grid
      v.y = self.y + (pos2 - 1) * self.height / math.ceil(#self.ui / self.grid)
      v.width = self.width / self.grid
      v.height = self.height / math.ceil(#self.ui / self.grid)
      if pos < self.grid then
        pos = pos + 1
      else
        pos = 1
        pos2 = pos2 + 1
      end
    end
  elseif self.orientation == "float" then
    for i, v in ipairs(self.ui) do
      v.x, v.y, v.width, v.height = unpack(self.pos[i])
    end
  else
    self.orientation = "vertical"
    self:upd()
  end
end

function ui:update()
  self:cursor()
  for i, v in ipairs(self.ui) do
    if self[v.type].update then
      self[v.type]:update(v)
    end
    if v.click then
      v.touch = false
      for n, t in pairs(self._toques) do
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
  end
end

function ui:draw(c)
  love.graphics.setColor(self.colors[3])
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  love.graphics.setColor(1, 1, 1, 1)
  for i, v in ipairs(self.ui) do
    if self[v.type].draw then
      self[v.type]:draw(v, self.colors, c)
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function ui:textinput(k)
  for i, v in ipairs(self.ui) do
    if self[v.type].textinput then
      self[v.type]:textinput(v, k)
    end
  end
end

function ui:keypressed(k)
  for i, v in ipairs(self.ui) do
    if self[v.type].keypressed then
      self[v.type]:keypressed(v, k)
    end
  end
end

return ui
