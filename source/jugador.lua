jugador = {
    y = 0,
    x = 0,
    alto,
    ancho,
    origen_x,
    origen_y,
    hitbox_x = 0,
    hitbox_y = 0,
    velocidad = 72,
    sprite = nil

}
--INICIALIZACION
function jugador.Crear(x,y)
    jugador.sprite = love.graphics.newImage("assets/payaso.png")
    jugador.ancho = jugador.sprite:getWidth() --alto y ancho
    jugador.alto = jugador.sprite:getHeight()
    jugador.origen_x = jugador.ancho / 2 --calcular centro
    jugador.origen_y = jugador.alto / 2    
    jugador.x = x
    jugador.y = y
end