local toast = { msj = {} }
local ww, hh = love.graphics.getDimensions()
local font = love.graphics.getFont()
local fonth = font:getHeight()

---@param txt any
---@param time integer|nil
function toast:toast(txt, time)
  table.insert(self.msj, 1, { tostring(txt), time or 1, font:getWidth(tostring(txt)), time or 1 })
end

local msj
function toast:draw(dt)
  if #self.msj > 0 then
    msj = self.msj[#self.msj]
    love.graphics.setColor(0.2, 0.2, 0.2, msj[2] / msj[4])
    love.graphics.rectangle("fill", (ww - msj[3]) / 2 + 5, hh - 32, msj[3] + 10, fonth + 4, 4)
    love.graphics.setColor(1, 1, 1, msj[2] / msj[4])
    love.graphics.print(msj[1], (ww - msj[3]) / 2 + 10, hh - 30)
    love.graphics.setColor(1, 1, 1, 1)
    if msj[2] > 0 then
      msj[2] = msj[2] - dt
    else
      table.remove(self.msj, #self.msj)
    end
  end
end

return setmetatable(toast, {
  __call = function(s, txt, time)
    s:toast(txt, time)
  end
})
