local room = {
  scenes = {},
  antes = "",
  actual = "",
}

---Crea una escena de un archivo
---@param file string
---@param ... any
function room:add(file, ...)
  table.insert(self.scenes, { scene = require(file), name = file, frezee = false, start = true })
  self.antes = self.actual
  self.actual = file
  self.scenes[#self.scenes].scene:load(...)
  self.scenes[#self.scenes].start = true
end

---Crea una escena de una tabla
---@param file string
---@param tab table
---@param ... any
function room:addlocal(file, tab, ...)
  table.insert(self.scenes, { scene = tab, name = file, frezee = false, start = true })
  self.antes = self.actual
  self.actual = file
  self.scenes[#self.scenes].scene:load(...)
  self.scenes[#self.scenes].start = true
end

---Congelar una escena
---@param file string
---@param a boolean
function room:frezee(file, a)
  for i, v in ipairs(self.scenes) do
    if v.name == file then
      v.frezee = a or false
    end
  end
end

---Elimina una escena
---@param file string
function room:remove(file)
  for i, v in ipairs(self.scenes) do
    if v.name == file then
      if v.scene.exit ~= nil then
        v.scene:exit()
      end
      table.remove(self.scenes, i)
      collectgarbage("collect")
    end
  end
end

---Cambiar a otra escena
---@param file string
---@param ... any
function room:next(file, ...)
  room:remove(self.actual)
  room:add(file, ...)
end

---@param dt integer
function room:update(dt)
  for i, v in ipairs(self.scenes) do
    if v.start and not v.frezee then
      v.scene:update(dt)
    end
  end
end

function room:draw()
  for i, v in ipairs(self.scenes) do
    if v.start then
      v.scene:draw()
    end
  end
end

return room
