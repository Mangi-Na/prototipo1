enemigo = {
    y = 100,
    x = 100,
    alto,
    ancho,
    origen_x,
    origen_y,
    hitbox_x = 0,
    hitbox_y = 0,
    velocidad = 30,
    sprite = nil

}
--INICIALIZACION
function enemigo.Crear()
    enemigo.sprite = love.graphics.newImage("assets/rojo.png")
    enemigo.ancho = jugador.sprite:getWidth() --alto y ancho
    enemigo.alto = jugador.sprite:getHeight()
    enemigo.origen_x = jugador.ancho / 2  --calcular centro
    enemigo.origen_y = jugador.alto / 2

end