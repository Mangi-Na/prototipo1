require "jugador"
require "enemigo"

ventana = {
    ancho = 160,
    alto = 144,
    escala = 4
}

atrapado = false

-- Función del sistema de colisiones 
function comprobarColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return x1 < x2 + ancho2 and 
           x2 < x1 + ancho1 and  
           y1 < y2 + alto2  and
           y2 < y1 + alto1
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    
    jugador.Crear(ventana.ancho / 2, ventana.alto / 2)
    enemigo.Crear(enemigo, "assets/rojo.png") 
end

function love.update(dt)
    
    jugador.Actualizar(dt)
    enemigo.Actualizar(enemigo, dt)

        
    atrapado = comprobarColision(
        jugador.hitbox_x,
        jugador.hitbox_y,
        jugador.ancho,
        jugador.alto,
        enemigo.hitbox_x,
        enemigo.hitbox_y,
        enemigo.ancho,
        enemigo.alto
    )
end

function love.draw()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    
    jugador.Dibujar()
    enemigo.Dibujar(enemigo)
    
    love.graphics.setCanvas()
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)

    if atrapado then
        love.graphics.print("ATRAPADO", 10, 10)       
    end
end
