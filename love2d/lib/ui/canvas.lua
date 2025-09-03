local canvas = {}
function canvas:new(fun,up,p,width,height)
  return {
    peso = p or 1,
    type = "canvas",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    fun = fun or function() love.graphics.print(" Nada Aqui") end,
    update = up or false,
    canvas = love.graphics.newCanvas(width or love.graphics.getWidth(),height or love.graphics.getHeight()),
    active = false
  }
end
function canvas:update(v)
  if v.active then
    if v.update then
      v.canvas:renderTo(v.fun)
    end
  else
  v.canvas:renderTo(v.fun)
  v.active = true
  end
end
function canvas:draw(v,col)
  love.graphics.draw(v.canvas,v.x,v.y,0,v.width/v.canvas:getWidth(),v.height/v.canvas:getHeight())
end
return setmetatable({},{
  __index = canvas,
  __call = function(self,ui,fun,up,p,...)
    return ui:newObj(self:new(fun,up,p),...)
    end
  })