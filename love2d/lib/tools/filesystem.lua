---@diagnostic disable: need-check-nil
local fs = {}
function fs.append(txt, dat)
  local file = io.open(txt, "a+")
  local data = file:write(dat)
  file:flush()
  file:close()
end

function fs.shell(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

function fs:split(inputstr, sep)
  if sep == nil then sep = "%s" end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function fs.exist(name)
  return fs.shell("find  " .. name) == name
end

function fs.getDirectoryItems(ruta)
  local t = {}
  data = fs.shell("cd " .. ruta .. " && ls")
  for str in data:gmatch("([^\n]+)") do
    table.insert(t, str)
  end
  return t
end

function fs.getSize(self, name, mb)
  if mb then
    return self:shell("find '" .. name .. [[' -printf "%s"]]) / 1000000
  else
    return self:shell("find '" .. name .. [[' -printf "%s"]])
  end
end

function fs.isDirectory(name)
  return fs.shell("file -b " .. name) == "directory"
end

function fs.isFile(name)
  return fs.shell("file -b " .. name) ~= "directory"
end

function fs.lines(name)
  local file = io.open(name, "r")
  local t = {}
  for line in file:lines() do
    table.insert(t, line)
  end
  file:close()
  return t
end

function fs.mkdir(ruta)
  return fs.shell("mkdir " .. ruta)
end

function fs.newFile(name, edit)
  fs.shell("touch " .. name)
  if edit then
    return io.open(name, edit)
  end
end

function fs.read(name)
  local file = io.open(name)
  local data = file:read("*a")
  file:close()
  return data
end

function fs.remove(filename)
  os.remove(filename)
end

function fs.write(txt, dat)
  local file = io.open(txt, "w+")
  local _ = file:write(dat)
  file:flush()
  file:close()
end

return fs
