local input = {}
function input:new(f, p, x, y, w, h)
  return {
    x = x or 0,
    y = y or 0,
    pos = { x = 0, y = 0 },
    width = w or 100,
    height = h or 100,
    text = { "" },
    cursor = { 0, 1 },
    font = f or love.graphics.getFont(),
    canvas = love.graphics.newCanvas(w, h),
    font_hh = false,
    active = false,
    peso = p or 1
  }
end

function input:release(i)
  i.font:release()
  i.canvas:release()
end

function input:insert(str1, str2, pos)
  if pos > 0 and pos < #str1 then
    return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
  elseif pos == 0 then
    return str2 .. str1
  elseif pos == #str1 then
    return str1 .. str2
  end
end

function input:rem(str1, pos)
  if pos == #str1 then
    return str1:sub(0, #str1 - 1)
  elseif pos < #str1 then
    return str1:sub(0, pos - 1) .. str1:sub(pos + 1, #str1)
  end
end

function input:update(v)
  if love.mouse.isDown(1) then
    local t = { love.mouse.getPosition() }
    local x2 = v.x + v.width
    local y2 = v.y + v.height
    if v.x <= t[1] and t[1] <= x2 and v.y <= t[2] and t[2] <= y2 then
      for i, b in ipairs(v.text) do
        if (v.font_hh * (i - 1)) + v.y + v.pos.y < t[2] then
          v.cursor[2] = i
          for w = 0, #b do
            if v.font:getWidth(b:sub(0, w)) + v.x + v.pos.x < t[1] then
              v.cursor[1] = w
            end
          end
        end
      end
      love.keyboard.setTextInput(true, v.x,
        v.y + v.pos.y + v.font_hh * v.cursor[2] - v.font_hh
        , v.width, v.font_hh)
      v.active = true
    else
      love.keyboard.setTextInput(false)
      v.active = false
    end
  end
end

function input:draw(i)
  if not i.font_hh then i.font_hh = i.font:getHeight("A") end
  love.graphics.rectangle("line", i.x - 1, i.y, i.width, i.height)
  local r = ""
  for m, v in ipairs(i.text) do
    r = r .. v .. "\n"
  end
  local pos = {
    x = i.x + i.font:getWidth(i.text[i.cursor[2]]:sub(0, i.cursor[1])) + i.pos.x,
    y = i.y + i.font_hh * (i.cursor[2] - 1) + i.pos.y
  }
  if i.active then
    love.graphics.setCanvas(i.canvas)
    love.graphics.clear()
    love.graphics.print(r, i.pos.x, i.pos.y)
    love.graphics.print("|", pos.x - i.x, pos.y - i.y)
    love.graphics.setCanvas()
  end
  love.graphics.draw(i.canvas, i.x, i.y)
  if pos.x > i.x + i.width - i.font_hh then
    i.pos.x = i.pos.x - 1
  elseif pos.x < i.x then
    i.pos.x = i.pos.x + 1
  elseif pos.y > i.y + i.height - i.font_hh then
    i.pos.y = i.pos.y - 1
  elseif pos.y < i.y then
    i.pos.y = i.pos.y + 1
  end
end

function input:textinput(i, txt)
  if i.active then
    if txt:byte() < 126 then
      i.text[i.cursor[2]] = self:insert(i.text[i.cursor[2]], txt, i.cursor[1])
      i.cursor[1] = i.cursor[1] + 1
    end
  end
end

function input:keypressed(i, k)
  if i.active then
    if k == "backspace" then
      if i.cursor[1] == 0 then
        if i.cursor[2] > 1 then
          i.cursor[2] = i.cursor[2] - 1
          i.cursor[1] = #i.text[i.cursor[2]]
          i.text[i.cursor[2]] = i.text[i.cursor[2]] .. i.text[i.cursor[2] + 1]
          table.remove(i.text, #i.text)
        end
      elseif #i.text[i.cursor[2]] > 0 and i.cursor[1] == 0 then
        if i.cursor[2] > 1 then
          i.text[i.cursor[2] - 1] = i.text[i.cursor[2] - 1] .. i.text[i.cursor[2]]
          i.cursor[2] = i.cursor[2] - 1
          table.remove(i.text, i.cursor[2] + 1)
        end
      else
        i.text[i.cursor[2]] = self:rem(i.text[i.cursor[2]], i.cursor[1])
        i.cursor[1] = i.cursor[1] - 1
      end
    elseif k == "return" then
      if i.cursor[1] == #i.text[i.cursor[2]] then
        table.insert(i.text, "")
      elseif i.cursor[1] == 0 then
        table.insert(i.text, i.cursor[2], "")
      else
        table.insert(i.text, i.cursor[2] + 1,
          i.text[i.cursor[2]]:sub(i.cursor[1] + 1, #i.text[i.cursor[2]])
        )
        i.text[i.cursor[2]] = i.text[i.cursor[2]]:sub(0, i.cursor[1])
      end
      i.cursor[1] = 0
      i.cursor[2] = i.cursor[2] + 1
    elseif k == "right" then
      if i.cursor[1] < #i.text[i.cursor[2]] then
        i.cursor[1] = i.cursor[1] + 1
      end
      if i.cursor[1] == #i.text[i.cursor[2]] and i.cursor[2] < #i.text then
        i.cursor[2] = i.cursor[2] + 1
        i.cursor[1] = 0
      end
    elseif k == "left" then
      if i.cursor[1] > 0 then
        i.cursor[1] = i.cursor[1] - 1
      elseif i.cursor[1] == 0 and i.cursor[2] > 1 then
        i.cursor[1] = #i.text[i.cursor[2] - 1]
        i.cursor[2] = i.cursor[2] - 1
      end
    elseif k == "up" then
      if i.cursor[2] > 1 then
        i.cursor[1] = math.min(#i.text[i.cursor[2] - 1], i.cursor[1])
        i.cursor[2] = i.cursor[2] - 1
      end
    elseif k == "down" then
      if i.cursor[2] < #i.text then
        i.cursor[1] = math.min(#i.text[i.cursor[2] + 1], i.cursor[1])
        i.cursor[2] = i.cursor[2] + 1
      end
    end
    love.keyboard.setTextInput(true, i.x,
      i.y + i.pos.y + i.font_hh * i.cursor[2] - i.font_hh
      , i.width, i.font_hh)
  end
end

return setmetatable({}, {
  __index = input,
  __tostring = function(self)
    local r = ""
    for i, v in ipairs(self.text) do
      r = r .. v .. "\n"
    end
    return r:sub(0, #r - 1)
  end,
  __call = function(self, ...)
    return self:new(...)
  end
})
