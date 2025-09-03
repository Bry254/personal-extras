local scroll = {
  timer = 0,
  v = {},
  h = {},
  mouse = {0,0}
}
function scroll:new(x,y,w,h)
  return setmetatable({}
  ,{
  __index = {
    x = x,
    y = y,
    width = w,
    height = h,
    min = y,
    max = y+h,
    touch = false,
    cursor = {
      x = x,
      y = y
    }
  },
  __call =
    function(s,val)
      if val then
      return math.floor((s.cursor.x-s.x)*100/s.width)
      else
      return math.floor((s.cursor.y-s.y)*100/s.height)
      end
    end
  })
end
function scroll:update(v,val)
  v.touch = false
  if love.mouse.isDown(1) then
    self.timer = self.timer + 1
    self.mouse = {love.mouse.getPosition()}
    local x2 = v.x + v.width
    local y2 = v.y + v.height
    if v.x <= self.mouse[1] and self.mouse[1] <= x2 and v.y <= self.mouse[2] and self.mouse[2] <= y2 then
      v.time = v.time + 1
      v.touch = true
      if val then
        v.cursor.x = self.mouse[1]
      else
      v.cursor.y = self.mouse[2]
      end
    end
  else
    self.timer = 0
  end
  if not v.touch then v.time = 0 end
end

function scroll.v:draw(o)
  love.graphics.line(o.x+o.width/2,o.y,o.x+o.width/2,o.y+o.height)
  love.graphics.circle("fill",o.x+o.width/2,o.cursor.y,o.width/2)
end
function scroll.h:draw(o)
  love.graphics.line(o.x,o.y+o.height/2,o.x+o.width,o.y+o.height/2)
  love.graphics.circle("fill",o.cursor.x,o.y+o.height/2,o.height/2)
end 
return scroll