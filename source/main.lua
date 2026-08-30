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
    
    -- SOLUCIÓN: Cambiamos 'enemigo' por 'enemigoRojo' para no borrar la plantilla original
    enemigoRojo = enemigo:Nuevo(100, 100, 30, "assets/rojo.png") 
    enemigo1 = enemigo:Nuevo(20, 120, 45, "assets/verde.png")
    enemigo2 = enemigo:Nuevo(130, 40, 60, "assets/azul.png")
end

function love.update(dt)
    jugador.Actualizar(dt)
    
    -- Actualizamos cada variable individual
    enemigoRojo:Actualizar(dt)
    enemigo1:Actualizar(dt)
    enemigo2:Actualizar(dt)

    -- Comprobamos colisiones usando 'enemigoRojo'
    local colision_rojo = comprobarColision(
        jugador.hitbox_x, jugador.hitbox_y, jugador.ancho, jugador.alto,
        enemigoRojo.hitbox_x, enemigoRojo.hitbox_y, enemigoRojo.ancho, enemigoRojo.alto
    )
    
    local colision_verde = comprobarColision(
        jugador.hitbox_x, jugador.hitbox_y, jugador.ancho, jugador.alto,
        enemigo1.hitbox_x, enemigo1.hitbox_y, enemigo1.ancho, enemigo1.alto
    )
    
    local colision_azul = comprobarColision(
        jugador.hitbox_x, jugador.hitbox_y, jugador.ancho, jugador.alto,
        enemigo2.hitbox_x, enemigo2.hitbox_y, enemigo2.ancho, enemigo2.alto
    )

    atrapado = colision_rojo or colision_verde or colision_azul
end

function love.draw()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    
    jugador.Dibujar()
    
    -- Dibujamos los tres clones individuales
    enemigoRojo:Dibujar()
    enemigo1:Dibujar()
    enemigo2:Dibujar()
    
    love.graphics.setCanvas()
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)

    if atrapado then
        love.graphics.print("ATRAPADO", 10, 10)       
    end
end
