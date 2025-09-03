--  sistema de archivos para android
local files = {
  ruta = "storage/emulated/0/",
  exp = ""
}
if love == nil then
  files.exp = "storage/emulated/0/"
else
  files.exp = love.filesystem.getSaveDirectory() .. "/"
end

function files:shell(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

---@param inputstr string
---@param sep string
---@return table
function files:split(inputstr, sep)
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function files:ls(ruta)
  return self:split(self:shell(string.format('cd "%s%s" && ls', self.ruta, ruta), true), '\n')
end

function files:mkdir(name)
  return self:shell("mkdir " .. self.ruta .. name)
end

function files:add(name, str)
  return self:shell("echo '" .. str .. "' >> " .. self.ruta .. name)
end

function files:write(name, str)
  return self:shell("echo '" .. str .. "' > " .. self.ruta .. name)
end

function files:read(name)
  return self:shell("cat " .. self.ruta .. name, true)
end

function files:lines(name)
  return files:split("\n", files:read(name))
end

function files:rm(name)
  return self:shell("rm " .. self.ruta .. name)
end

function files:rmdir(name)
  return self:shell("rm -R " .. self.ruta .. name)
end

function files:copy(name, dir)
  return self.shell(string.format('cp "%s%s" "%s"', self.ruta, name, self.ruta, dir))
end

function files:move(name, dir)
  return self.shell(string.format('mv "%s%s" "%s"', self.ruta, name, self.ruta, dir))
end

function files:exist(name)
  return self:shell("file -b " .. self.ruta .. name) ~=
      "cannot open: No such file or directory"
end

function files:export(name, dir)
  return self:shell(string.format('cp "%s%s" "%s%s"', self.exp, name, self.ruta, dir))
end

function files:import(name, dir)
  return self:shell(string.format('cp "%s%s" "%s%s"', self.ruta, name, self.exp, dir or ""))
end

function files:getsize(name, mb)
  if mb then
    return self:shell("find '" .. self.ruta .. name .. [[' -printf "%s"]]) / 1000000
  else
    return self:shell("find '" .. self.ruta .. name .. [[' -printf "%s"]])
  end
end

function files:newfile(name)
  return self:shell("touch " .. self.ruta .. name)
end

function files:isfile(name)
  if self:exist(name) then
    return not self:shell("file -b " .. self.ruta .. name) == "directory"
  end
end

return files
