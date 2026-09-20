Estado_juego = Class{__includes = maquina_estados}

function Estado_juego:init()
    -- Llamamos a la función para inicializar todo al crear el estado
    self:reiniciarJuego()
end

-- Sacamos reiniciarJuego de init y la convertimos en un método de la clase
function Estado_juego:reiniciarJuego()
    atrapado = false
    victoria = false
    tiempo_supervivencia = 15.0
    audio_final_reproducido = false

    love.audio.stop(sonido_derrota)
    love.audio.stop(sonido_victoria)
    musica:play()
    
    -- Instanciación de Objetos con class
    jugador_obj = Jugador(ventana.ancho / 2, ventana.alto / 2)
    
    -- Creación de la lista de enemigos utilizando polimorfismo
    lista_enemigos = {
        Enemigo(100, 100, 30, "assets/rojo.png"), -- Enemigo base
        EnemigoErratico(20, 120),             -- Variante errática (verde)
        EnemigoRapido(130, 40)            -- Variante rápida (azul)
    }
end

function Estado_juego:ingresar() end

function Estado_juego:salir() end

function Estado_juego:actualizar(dt)
    -- Pantallas de fin de juego
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
            self:reiniciarJuego() -- Ahora usamos self:reiniciarJuego()
        end
        return 
    end

    -- Actualizaciones de Entidades
    jugador_obj:Actualizar(dt)
    
    for _, e in ipairs(lista_enemigos) do
        e:Actualizar(dt, jugador_obj)
    end

    -- Chequeo de ataque del jugador a los enemigos
    if jugador_obj.atacando then
        for _, e in ipairs(lista_enemigos) do
            if e.activo then
                local golpear = comprobarColision(
                    jugador_obj.hitbox_ataque.x, jugador_obj.hitbox_ataque.y, 
                    jugador_obj.hitbox_ataque.ancho, jugador_obj.hitbox_ataque.alto,
                    e.hitbox_x, e.hitbox_y, e.ancho, e.alto
                )
                if golpear then
                    sonido_golpe:stop()
                    sonido_golpe:play()
                    e:RecibirGolpe(ventana.ancho, ventana.alto)
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
    for _, e in ipairs(lista_enemigos) do
        if e.activo then
            local colision = comprobarColision(
                jugador_obj.hitbox_x, jugador_obj.hitbox_y, jugador_obj.ancho, jugador_obj.alto,
                e.hitbox_x, e.hitbox_y, e.ancho_hitbox, e.alto_hitbox
            )
            if colision then
                atrapado = true
                break
            end
        end
    end
end

function Estado_juego:dibujar()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    
    -- Dibujar Entidades
    jugador_obj:Dibujar()
    for _, e in ipairs(lista_enemigos) do
        e:Dibujar()
    end
    
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