jugador = {
    y = 0,
    x = 0,
    alto = 0,
    ancho = 0,
    origen_x = 0,
    origen_y = 0,
    hitbox_x = 0,
    hitbox_y = 0,
    velocidad = 72,
    sprite = nil
}

-- INICIALIZACION
function jugador.Crear(x, y)
    jugador.sprite = love.graphics.newImage("assets/payaso.png")
    jugador.ancho = jugador.sprite:getWidth() 
    jugador.alto = jugador.sprite:getHeight()
    jugador.origen_x = jugador.ancho / 2 
    jugador.origen_y = jugador.alto / 2    
    jugador.x = x
    jugador.y = y
end

-- MANEJA EL MOVIMIENTO
function jugador.Actualizar(dt)
    if love.keyboard.isDown("right") then
        jugador.x = jugador.x + (jugador.velocidad * dt)
    elseif love.keyboard.isDown("left") then
        jugador.x = jugador.x - (jugador.velocidad * dt)
    elseif love.keyboard.isDown("down") then
        jugador.y = jugador.y + (jugador.velocidad * dt)
    elseif love.keyboard.isDown("up") then
        jugador.y = jugador.y - (jugador.velocidad * dt)
    end

    -- hitbox 
    jugador.hitbox_x = jugador.x - jugador.origen_x
    jugador.hitbox_y = jugador.y - jugador.origen_y
end

function jugador.Dibujar()
    love.graphics.draw(jugador.sprite, jugador.x, jugador.y, 0, 1, 1, jugador.origen_x, jugador.origen_y)
end
