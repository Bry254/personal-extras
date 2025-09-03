boton = {
  _toques = {},
  _activo = {},
  _time = 0,
}

function boton:new(txt, p)
  return setmetatable({}, {
    __index = {
      click = true,
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      touch = false,
      time = 0,
      ID = 0,
      type = "boton",
      text = txt or "",
      peso = p or 1
    },
    __call = function(self)
      return self.time
    end
  })
end

function boton:draw(v, col, c)
  love.graphics.setColor(col[2])
  if v.touch then
    love.graphics.rectangle("fill", v.x, v.y, v.width, v.height, c)
  end
  love.graphics.setColor(col[1])
  love.graphics.print(v.text, v.x + v.width / 2, v.y + v.height / 2)
end

return setmetatable({}, {
  __index = boton,
  __call = function(self, ui, txt, p, ...)
    return ui:newObj(self:new(txt, p), ...)
  end
})
