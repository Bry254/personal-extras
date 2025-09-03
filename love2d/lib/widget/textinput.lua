local textinput = {}
function textinput:new(f, fun, x, y, w, h)
  return {
    x = x,
    y = y,
    pos = 0,
    width = w,
    height = h,
    text = "",
    cursor = 0,
    font = f or love.graphics.getFont(),
    canvas = love.graphics.newCanvas(w, h),
    active = false,
    enter = fun or function() end
  }
end

function textinput:insert(str1, str2, pos)
  if pos > 0 and pos < #str1 then
    return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
  elseif pos == 0 then
    return str2 .. str1
  elseif pos == #str1 then
    return str1 .. str2
  end
end

function textinput:rem(str1, pos)
  if pos == #str1 then
    return str1:sub(0, #str1 - 1)
  elseif pos < #str1 then
    return str1:sub(0, pos - 1) .. str1:sub(pos + 1, #str1)
  end
end

function textinput:release(i)
  i.font:release()
  i.canvas:release()
end

function textinput:update(v)
  if love.mouse.isDown(1) then
    local t = { love.mouse.getPosition() }
    local x2 = v.x + v.width
    local y2 = v.y + v.height
    if v.x <= t[1] and t[1] <= x2 and v.y <= t[2] and t[2] <= y2 then
      for w = 0, #v.text do
        if v.font:getWidth(v.text:sub(0, w)) + v.x + v.pos < t[1] then
          v.cursor = w
        end
      end
      love.keyboard.setTextInput(true, v.x, v.y, v.width, v.height)
      v.active = true
    else
      love.keyboard.setTextInput(false)
      v.active = false
    end
  end
end

function textinput:draw(i)
  love.graphics.rectangle("line", i.x - 1, i.y, i.width, i.height)
  local pos = i.x + i.font:getWidth(i.text:sub(0, i.cursor)) + i.pos
  if i.active then
    love.graphics.setCanvas(i.canvas)
    love.graphics.clear()
    love.graphics.print(i.text, i.pos)
    love.graphics.print("|", pos - i.x)
    love.graphics.setCanvas()
  end
  love.graphics.draw(i.canvas, i.x, i.y)

  if pos > i.x + i.width - i.font:getHeight("A") then
    i.pos = i.pos - 1
  elseif pos < i.x then
    i.pos = i.pos + 1
  end
end

function textinput:textinput(i, txt)
  if i.active then
    if txt:byte() < 126 then
      i.text = self:insert(i.text, txt, i.cursor)
      i.cursor = i.cursor + 1
    end
  end
end

function textinput:keypressed(i, k)
  if i.active then
    if k == "backspace" and i.cursor > 1 then
      i.text = self:rem(i.text, i.cursor)
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

return setmetatable({}, {
  __index = textinput,
  __call = function(self, ...)
    return self:new(...)
  end
})
