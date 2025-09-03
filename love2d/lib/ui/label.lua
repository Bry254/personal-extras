local label = {}
function label:new(txt,center,p)
  return {
    peso = p or 1,
    type = "label",
    x = 0,
    y = 0,
    text = txt or "",
    center = center or false,
    width = 10,
    height = 10
  }
end
function label:draw(v,col)
  love.graphics.setColor(col[1])
  if v.center then
  love.graphics.print(v.text,v.x,v.y)
  else
  love.graphics.printf(v.text,v.x,v.y,v.width,"center") 
  end
end
return setmetatable({},{
  __index = label,
  __call = function(self,ui,txt,center,p,...)
    return ui:newObj(self:new(txt,center,p),...)
    end
  })