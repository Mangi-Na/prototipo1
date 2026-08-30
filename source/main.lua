require "jugador"
require "enemigo"

ventana = {
    ancho = 160,
    alto = 144,
    escala = 4
}

-- Estados del juego
atrapado = false
victoria = false
tiempo_supervivencia = 15.0 

function comprobarColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return x1 < x2 + ancho2 and 
           x2 < x1 + ancho1 and  
           y1 < y2 + alto2  and
           y2 < y1 + alto1
end

function reiniciarJuego()
    atrapado = false
    victoria = false
    tiempo_supervivencia = 15.0
    
    jugador.Crear(ventana.ancho / 2, ventana.alto / 2)
    enemigoRojo = enemigo:Nuevo(100, 100, 30, "assets/rojo.png") 
    enemigo1 = enemigo:Nuevo(20, 120, 45, "assets/verde.png")
    enemigo2 = enemigo:Nuevo(130, 40, 60, "assets/azul.png")
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    
    reiniciarJuego()
end

function love.update(dt)
    --la tecla R para reiniciar
    if atrapado or victoria then
        if love.keyboard.isDown("r") then
            reiniciarJuego()
        end
        return 
    end

    -- Actualizar 
    jugador.Actualizar(dt)
    enemigoRojo:Actualizar(dt)
    enemigo1:Actualizar(dt)
    enemigo2:Actualizar(dt)

    --Temporizador (Condición de Victoria)
    tiempo_supervivencia = tiempo_supervivencia - dt
    if tiempo_supervivencia <= 0 then
        tiempo_supervivencia = 0
        victoria = true
    end

    -- Colisiones (Condición de Derrota)
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

    if colision_rojo or colision_verde or colision_azul then
        atrapado = true
    end
end

function love.draw()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    
    jugador.Dibujar()
    enemigoRojo:Dibujar()
    enemigo1:Dibujar()
    enemigo2:Dibujar()
    
    love.graphics.setCanvas()
    
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)

    --Interfaz de Usuario y Retroalimentación Visual
    love.graphics.print("Tiempo: " .. string.format("%.1f", tiempo_supervivencia), 20, 20)

    if atrapado then
        -- Derrota
        love.graphics.setColor(1, 0, 0, 0.3) -- Filtro rojo transparente de fondo
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1) -- Resetear color a blanco para el texto
        
        love.graphics.print("¡GAME OVER!",290 , 250)
        love.graphics.print("Presiona 'R' para reiniciar", 250, 290)       
    elseif victoria then
        -- Victoria
        love.graphics.setColor(0, 1, 0, 0.3) -- Filtro verde transparente de fondo
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        
        love.graphics.print("¡VICTORIA!", 290, 250)
        love.graphics.print("Presiona 'R' para jugar de nuevo", 230, 290)
    end
end
