local ser = {}

---Convertir de tabla a string
---@param t table
---@param str string|any
---@param tab string|any
---@return string
ser.to_str = function(t, str, tab)
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
      return ser.to_str(v, str or '\t', (tab or 1) + 1) or ('"%s"'):format(v)
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

---Convertir de string a tabla
---@param str string
---@return table
ser.to_table = function(str)
  return assert(loadstring("return" .. str))()
end
return ser
