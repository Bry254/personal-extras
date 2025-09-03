local code = {}
code.ww = love.graphics.getWidth()
code.hh = love.graphics.getHeight()

-- TODO STRING

---Convertir a texto de url
---@param str string
---@return string
function string.urlencode(str)
  if (str) then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w ])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

---Ejecuta un texto como codigo
---@param str string
---@return unknown
function string.exec(str)
  return assert((loadstring or load)(str))()
end

function string.insert(str1, str2, pos)
  local r = ""
  if pos > 0 and pos < #str1 then
    r = str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
  elseif pos == 0 then
    r = str2 .. str1
  elseif pos == #str1 then
    r = str1 .. str2
  end
  return r
end

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

---Junta cadenas de texto con un string
---@param dl string
---@vararg string
---@return string
function string.unir(dl, ...)
  return table.concat({ ... }, dl)
end

-- TODO MATH
function math.round(number, d)
  local decimals = d or 1
  local power = 10 ^ decimals
  return math.floor(number * power) / power
end

-- TODO TABLE
function table.clone(original)
  local clone = {}
  for key, value in pairs(original) do
    if type(value) == "table" then
      clone[key] = table.clone(value)
    else
      clone[key] = value
    end
  end
  return clone
end

function table.view(tab)
  local r = ""
  for i, v in pairs(tab) do
    r = r .. ('%s : %s\n'):format(i, v)
  end
  return r
end

function table.serialize(t, str, tab)
  if #t == 0 then
    return '{}'
  end
  local tab = string.rep(str or "\t", tab or 1)
  local r = tab:sub(0, #tab - 1) .. "{\n"
  local function tipo(v)
    local _exp_0 = type(v)
    if "string" == _exp_0 then
      return ('"%s"'):format(v)
    elseif "table" == _exp_0 then
      return table.serialize(v, str or '\t', (tab or 1) + 1) or ('"%s"'):format(v)
    else
      return tostring(v)
    end
  end
  local num = true
  for i, _ in pairs(t) do
    if type(i) ~= "number" then
      num = false
    end
  end
  if num then
    r = r:sub(0, #r - 1)
    for i, v in ipairs(t) do
      r = r .. (" %s,"):format(v)
    end
    return r:sub(0, #r - 1) .. "}"
  else
    for i, v in pairs(t) do
      if type(i) == "number" then
        r = r .. ("%s%s,\n"):format(tab, tipo(v))
      else
        r = r .. ('%s[%s] = %s,\n'):format(tab, tipo(i), tipo(v))
      end
    end
    return r:sub(0, #r - 2) .. "\n" .. tostring(tab:sub(0, #tab - 1)) .. "}"
  end
end

function table.find(tabla, valor)
  local exist, index = false, 0
  for i, v in ipairs(tabla) do
    if v[1] .. "," .. v[2] == valor[1] .. "," .. valor[2] then
      exist, index = true, i
    end
  end
  return exist, index
end

-- TODO COLORES
function rgb(r, g, b, a)
  return r / 255, g / 255, b / 255, a
end

function rgba(r, g, b, a)
  return r / 255, g / 255, b / 255, a
end

function setcolor(r, g, b, a)
  love.graphics.setColor(rgb(r or 255, g or 255, b or 255, a or 1))
end

-- TODO GEOMETRIA
function code.speed(o, x, y)
  o.x = o.x + x * love.timer.getDelta()
  o.y = o.y + y * love.timer.getDelta()
end

function code.vector(o, x, y)
  o.x = x + o.x
  o.y = y + o.y
end

---@param b table
---@param a table
---@param n number
---@param v number|nil
function code.seguir(b, a, n, v)
  local angulo = math.atan2(a.y - b.y, a.x - b.x)
  if math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) >= n then
    b.x = b.x + (v or b.speed or 100) * math.cos(angulo) * love.timer.getDelta()
    b.y = b.y + (v or b.speed or 100) * math.sin(angulo) * love.timer.getDelta()
  end
end

---Obtener distancia entre 2 puntos
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function code.getDist(x1, y1, x2, y2)
  return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

---Colision entre 2 rectangulos
---@param a table
---@param v table
---@return boolean
function code.colision(a, v)
  return v.x <= a.x and a.x <= (v.x + v.width) and v.y <= a.y and a.y <= (v.y + v.height)
end

---Colision entre 2 circulos
---@param p1 table
---@param p2 table
---@return boolean
function code.colisionc(p1, p2)
  return math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2) < p1.radio + p2.radio
end

-- TODO DRAW
function code.img(img, x, y, width, height)
  love.graphics.draw(img, x or 0, y or 0, nil, (width / img:getWidth()) or 1, (height / img:getHeight()) or 1)
end

-- TODO FILES
---@param img love.ImageData
---@param path1 string
function code.saveimg(img, path1)
  local imagedata = love.image.newImageData(img)
  local path2 = path1 or img
  local file = love.filesystem.newFile(path2)
  file:open('w')
  file:write(imagedata:encode("png"))
  file:close()
  imagedata:release()
end

---Carga una imagen de una ruta
---@param ruta any
---@return love.Image
function code.loadimg(ruta)
  return love.graphics.newImage(love.image.newImageData(ruta))
end

function code.loadaudio(ruta)
  return love.audio.newSource(love.sound.newSoundData(ruta), "stream")
end

---Ejecuta un archivo desde el filesystem
---@param ruta string
---@return any
function code.loadfile(ruta)
  local file = love.filesystem.load(ruta)
  return file()
end

-- TODO EXTRAS
function code.switch(cases, value)
  if cases[value] ~= nil then
    return cases[value]()
  else
    return false
  end
end

-- TODO Internet
local http = require("socket.http")

---Descarga un archivo
---@param link string
---@param name string
function code.down(link, name)
  local b, _, _ = http.request(link)
  love.filesystem.write(name or "file.txt", b or "No found")
end

---Hacer un request a una pagina web
---@param link string
---@return string|boolean
function code.request(link)
  local b, _, _ = http.request(link)
  return b or false
end

return code
