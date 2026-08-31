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
musica = nil
sonido_derrota = nil
sonido_victoria = nil
sonido_golpe = nil
audio_final_reproducido = false

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
    audio_final_reproducido = false

    love.audio.stop(sonido_derrota)
    love.audio.stop(sonido_victoria)
    musica:play()
    
    jugador.Crear(ventana.ancho / 2, ventana.alto / 2)
    enemigoRojo = enemigo:Nuevo(100, 100, 30, "assets/rojo.png") 
    enemigo1 = enemigo:Nuevo(20, 120, 45, "assets/verde.png")
    enemigo2 = enemigo:Nuevo(130, 40, 60, "assets/azul.png")
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    musica = love.audio.newSource("assets/musica fondo.mp3","stream")
    musica:setLooping(true)
    love.audio.play(musica)

    sonido_derrota = love.audio.newSource("assets/derrota.mp3", "static")
    sonido_victoria = love.audio.newSource("assets/victoria.mp3", "static")
    sonido_golpe = love.audio.newSource("assets/golpe.mp3", "static")
    reiniciarJuego()
end

function love.update(dt)
    -- Tecla R para reiniciar
    if atrapado or victoria then
        if not audio_final_reproducido then
            musica:stop()
            
            if atrapado then
                sonido_derrota:play()
            elseif victoria then
                sonido_victoria:play()
            end
            
            audio_final_reproducido = true 
        end

        if love.keyboard.isDown("r") then
            reiniciarJuego()
        end
        return 
    end

    -- Actualizaciones
    jugador.Actualizar(dt)
    if enemigoRojo.activo then enemigoRojo:Actualizar(dt) end
    if enemigo1.activo then enemigo1:Actualizar(dt) end
    if enemigo2.activo then enemigo2:Actualizar(dt) end

    -- Chequeo de ataque del jugador a los enemigos
    if jugador.atacando then
        local lista_enemigos = { enemigoRojo, enemigo1, enemigo2 }
        for _, e in ipairs(lista_enemigos) do
            if e.activo then
                local golpear = comprobarColision(
                    jugador.hitbox_ataque.x, jugador.hitbox_ataque.y, 
                    jugador.hitbox_ataque.ancho, jugador.hitbox_ataque.alto,
                    e.hitbox_x, e.hitbox_y, e.ancho, e.alto
                )
                if golpear then
                    sonido_golpe:stop()
                    sonido_golpe:play()
                    e.x = math.random(10, ventana.ancho - 10)
                    e.y = math.random(10, ventana.alto - 10)
                    
                end
            end
        end
    end

    -- Temporizador (Condición de Victoria)
    tiempo_supervivencia = tiempo_supervivencia - dt
    if tiempo_supervivencia <= 0 then
        tiempo_supervivencia = 0
        victoria = true
    end

    -- Colisiones con el jugador (Condición de Derrota)
  local colision_rojo = enemigoRojo.activo and comprobarColision(
        jugador.hitbox_x, jugador.hitbox_y, jugador.ancho, jugador.alto,
        enemigoRojo.hitbox_x, enemigoRojo.hitbox_y, enemigoRojo.ancho_hitbox, enemigoRojo.alto_hitbox
    )
    local colision_verde = enemigo1.activo and comprobarColision(
        jugador.hitbox_x, jugador.hitbox_y, jugador.ancho, jugador.alto,
        enemigo1.hitbox_x, enemigo1.hitbox_y, enemigo1.ancho_hitbox, enemigo1.alto_hitbox
    )
    local colision_azul = enemigo2.activo and comprobarColision(
        jugador.hitbox_x, jugador.hitbox_y, jugador.ancho, jugador.alto,
        enemigo2.hitbox_x, enemigo2.hitbox_y, enemigo2.ancho_hitbox, enemigo2.alto_hitbox
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

    -- Interfaz de Usuario 
    love.graphics.print("Tiempo: " .. string.format("%.1f", tiempo_supervivencia), 20, 20)

    if atrapado then
        -- Derrota
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        
        love.graphics.print("¡GAME OVER!", 290, 250)
        love.graphics.print("Presiona 'R' para reiniciar", 250, 290)      
    elseif victoria then
        -- Victoria
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        
        love.graphics.print("¡VICTORIA!", 290, 250)
        love.graphics.print("Presiona 'R' para jugar de nuevo", 230, 290)
    end
end