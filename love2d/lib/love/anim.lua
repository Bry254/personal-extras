local anim = {}

---Crea un objeto de animación
---@param frames table
---@param img any
---@param orden table
---@return table
function anim:new(frames, img, orden)
    local r = {
        img = img,
        frames = {},
        timer = 1,
        index = 1,
        orden = orden
    }
    for i, v in ipairs(frames) do
        table.insert(v, img:getWidth())
        table.insert(v, img:getHeight())
        table.insert(r.frames, love.graphics.newQuad(unpack(v)))
    end
    return r
end

---Convierte un Csv a un objeto de Animacion
---@param data string
---@param img any
---@param orden table
---@return table
function anim:csv(data, img, orden)
    local frames = {}
    for line in data:gmatch("([^\n]+)") do
        local t = {}
        for v in line:gmatch("([^,]+)") do
            if tonumber(v) then
                table.insert(t, tonumber(v))
            end
        end
        table.insert(frames, t)
    end
    return anim:new(frames, img, orden)
end

---Actualiza un objeto anim
---@param an table
---@param dt integer
---@param speed integer
function anim:update(an, dt, speed)
    if an.timer > 0 then
        an.timer = an.timer - dt * speed
    else
        if an.index < #an.orden then
            an.index = an.index + 1
        else
            an.index = 1
        end
        an.timer = 1
    end
end

---Dibuja una animacion
---@param an table
---@param x integer
---@param y integer
---@param w integer
---@param h integer
function anim:draw(an, x, y, w, h)
    local _, _, ww, hh = an.frames[an.orden[an.index]]:getViewport()
    love.graphics.draw(
        an.img,
        an.frames[an.orden[an.index]],
        x or 0,
        y or 0,
        nil,
        (w / ww) or 1,
        (h / ww) or 1,
        (ww / 2), hh / 2
    )
end

---Dibuja un frame de una animacion
---@param an table
---@param index integer
---@param x integer
---@param y integer
---@param w integer
---@param h integer
function anim:framed(an, index, x, y, w, h)
    local _, _, ww, hh = an.frames[an.index]:getViewport()
    love.graphics.draw(
        an.img,
        an.frames[index],
        x or 0,
        y or 0,
        nil,
        (w / ww) or 1,
        (h / ww) or 1,
        ww / 2, hh / 2
    )
end

return anim
