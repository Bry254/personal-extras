local sinput = {}
function sinput:new(f,fun,p,w,h)
  return {
  peso = p or 1,
  type = "sinput",
  x = 0,
  y = 0,
  pos = 0,
  width = 100,
  height = 100,
  text = "",
  cursor = 0,
  font = f or love.graphics.getFont(),
  canvas = love.graphics.newCanvas(w,h),
  active = false,
  enter = fun or function() end
 }
end
function sinput:insert(str1, str2, pos)
  if pos > 0 and pos < #str1 then
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
  elseif pos == 0 then
    return str2..str1
  elseif pos == #str1 then
    return str1..str2
  end
end
function sinput:rem(str1,pos)
  if pos == #str1 then
    return str1:sub(0,#str1-1)
  elseif pos < #str1 then
    return str1:sub(0,pos-1)..str1:sub(pos+1,#str1)
  end
end
function sinput:release(i)
  i.font:release()
  i.canvas:release()
end
function sinput:update(v)
  if v.canvas:getWidth() ~= v.width or v.canvas:getHeight() ~= v.height then
    v.canvas:release()
    v.canvas = love.graphics.newCanvas(v.width,v.height)
  end
 if love.mouse.isDown(1) then
  local t = {love.mouse.getPosition()}
  local x2 = v.x + v.width
  local y2 = v.y + v.height
  if v.x <= t[1] and t[1] <= x2 and v.y <= t[2] and t[2] <= y2 then 
    for w=0,#v.text do
      if v.font:getWidth(v.text:sub(0,w))+v.x+v.pos < t[1] then
        v.cursor = w
      end
    end
   love.keyboard.setTextInput(true,v.x,v.y,v.width,v.height)
   v.active = true
 else
   love.keyboard.setTextInput(false) 
   v.active = false end
end
end

function sinput:draw(i,col,c)
love.graphics.setColor(col[1])
 love.graphics.rectangle("line", i.x,i.y,i.width,i.height,c or 0)
local pos = i.x+i.font:getWidth(i.text:sub(0,i.cursor))+i.pos
love.graphics.setCanvas(i.canvas)
love.graphics.clear()
love.graphics.print(i.text,i.pos)
love.graphics.print("|",pos-i.x)
love.graphics.setCanvas()
love.graphics.draw(i.canvas,i.x,i.y)

 if pos > i.x+i.width-i.font:getHeight("A") then
   i.pos = i.pos - 1
 elseif pos  < i.x then
  i.pos = i.pos + 1
 end
end
function sinput:textinput(i,txt)
  if i.active then
  if txt:byte() < 126 then
    i.text = self:insert(i.text,txt,i.cursor)
    i.cursor = i.cursor + 1
  end
  end
end
function sinput:keypressed(i,k)
  if i.active then
  if k == "backspace" and i.cursor > 1 then
    i.text = self:rem(i.text,i.cursor)
    i.cursor = i.cursor - 1
  elseif k == "return" then
    i:enter()
  elseif k == "right" and i.cursor < #i.text then
    i.cursor = i.cursor + 1
  elseif k == "left" and i.cursor > 0 then
    i.cursor = i.cursor - 1
  elseif k == "up" then
    i.cursor = 0
  elseif k == "down" then
    i.cursor = #i.text
  end
end
end
return setmetatable({},{
 __index = sinput,
 __call = function(self,ui,f,fun,p,...)
  return ui:newObj(self:new(f,fun,p),...)
 end})
