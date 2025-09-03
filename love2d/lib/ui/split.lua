local split = {
  arg = ...
}
function split:new(path,ori,p,colors)
local r = {
  type = "split",
  path = path,
  x = 0,
  peso = p or 1,
  y = 0,
  width = 100,
  height = 100,
  ui = {},
  orientation = ori or "vertical",
  grid = 2,
  grid2 = 2,
  pos = {}
  }
r.boton = require(path..".boton")
r.label = require(path..".label")
r.image = require(path..".image")
r.canvas = require(path..".canvas")
r.split = require(path..".split")
r.input = require(path..".input")
r.sinput = require(path..".sinput")
r.cursor = require(path..".mouse")
function r:setCursor(str)
	if str == 1 then
		self.cursor = require(self.path..".touch")
	else
		self.cursor = require(self.path..".mouse")
	end
end
function r:setColors(a,b,c)
  self.colors[1] = a or self.colors[1]
  self.colors[2] = b or self.colors[2]
  self.colors[3] = c or self.colors[3]
end
function r:setOrientation(o,gr)
  r.orientation = o
  r.grid2 = gr or 2
  r:upd()
end
function r:newObj(o,...)
  table.insert(self.ui,o)
  self:_pos(...)
  self:upd()
  return #self.ui
end
function r:_pos(x,y,w,h)
  table.insert(self.pos,{x or self.x,y or self.y,w or math.random(100,self.width/2),h or math.random(100,self.height/2)})
end
function r:remove(i)
  if r[r.ui[i].type].release then
    r[r.ui[i].type]:release(r.ui[i])
  end
  table.remove(r.ui,i)
  table.remove(r.pos,i)
end
function r:upd()
    local peso = 0
  for i,v in ipairs(self.ui) do
    peso = peso + v.peso
  end
  if self.orientation == "vertical" then
    local exis = 0
    for i,v in ipairs(self.ui) do
      v.x = self.x
      v.y = self.y+exis
      v.height = math.floor(v.peso*100/peso)*self.height/100
      v.width = self.width
      exis = exis + v.height
    end
  elseif self.orientation == "horizontal" then
    local exis = 0
    for i,v in ipairs(self.ui) do
      v.x = self.x+exis
      v.y = self.y
      v.width = math.floor(v.peso*100/peso)*self.width/100
      v.height = self.height
      exis = exis + v.width
    end
  elseif self.orientation == "grid" then
    local pos = 1
    local pos2 = 1
    for i,v in ipairs(self.ui) do
      v.x = self.x+ (pos-1)*self.width/self.grid
      v.y = self.y+ (pos2-1)*self.height/math.ceil(#self.ui/self.grid)
      v.width = self.width/self.grid
      v.height = self.height/math.ceil(#self.ui/self.grid)
      if pos < self.grid then pos = pos + 1
      else pos = 1
        pos2 = pos2 + 1 end
    end
  elseif self.orientation == "float" then
    for i,v in ipairs(self.ui) do
      v.x,v.y,v.width,v.height = unpack(self.pos[i])
    end
  else
    self.orientation = "vertical"
    self:upd()
  end
end
return r
end
function split:update(s)
	s:cursor()
  for i,v in ipairs(s.ui) do
    if s[v.type].update then
      s[v.type]:update(v)
    end
    if v.click then
    	 v.touch = false
		  for n,t in pairs(s._toques) do
		    local x2 = v.x + v.width
		    local y2 = v.y + v.height
		    if v.x <= t[1] and t[1] <= x2 and v.y <= t[2] and t[2] <= y2 then
		      v.touch = true
		      v.time = v.time + 1
		      v.ID = n
		    end
		  end
			if not v.touch then v.time = 0; v.ID = 0 end
    	end
  end
end
function split:draw(s,colors,c)
  for i,v in ipairs(s.ui) do
  love.graphics.setColor(colors[1])
  love.graphics.rectangle("line",v.x,v.y,v.width,v.height,c)
    if s[v.type].draw then
      s[v.type]:draw(v,colors)
    end
  end
end
function split:textinput(s,k)
  for i,v in ipairs(s.ui) do
    if s[v.type].textinput then
      s[v.type]:textinput(v,k)
    end
  end
end
function split:keypressed(s,k)
  for i,v in ipairs(s.ui) do
    if s[v.type].keypressed then
      s[v.type]:keypressed(v,k)
    end
  end
end
return setmetatable({},{
  __index = split,
  __call = function(self,ui,ori,p,g,...)
      return ui:newObj(self:new(ui.path,ori,p,g ),...)
    end
  })