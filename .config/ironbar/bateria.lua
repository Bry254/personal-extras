local args = {...}
local file = io.open("/sys/class/power_supply/BAT1/capacity", "r")
local data = file:read("*a")

local num = tonumber(data)

local int1 = string.sub(data, 1, 1)
local int2 = string.sub(data, 2, #data)
local function mul(word, numero)
  local r = ""
  for i=1, numero do
    r = r .. word
  end
  return r
end

if num == 100 then
  print("["..mul("█", 10).. "]")
else
  local unidades = {" ", "▁", "▂", "▃", "▄", "▅" , "▆", "▆", "▇", "█"}
  print("["..mul("█", tonumber(int1)) .. unidades[tonumber(int2+1)].. mul(" ", 10- tonumber(int1)).."]")
end

