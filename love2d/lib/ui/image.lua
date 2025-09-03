local image = {
  hh = love.graphics.getHeight(),
  ww = love.graphics.getWidth()
}
function image:new(txt,fil)
  return {
    type = "image",
    x = 0,
    y = 0,
    img = love.graphics.newImage(txt),
    height = 1
  }
end
function image:update()
  
end
function image:draw(v)
  if v.img then
  if v.width > v.height then
  love.graphics.draw(v.img,v.x+v.width/2,v.y+v.height/2,0,self.ww/v.width,nil,0.5)
  else
  love.graphics.draw(v.img,v.x+v.width/2,v.y+v.height/2,0,self.hh/v.height,nil,0.5)
  end
  end
end
function image:release(v)
  v.img:release()
end
return setmetatable({},{
  __index = image,
  __call = function(self,ui,txt,fil,...)
    local r = ui:newObj(self:new(txt,...),...)
    ui.ui[r].img:setFilter(fil or "linear")
    return r
    end
  })