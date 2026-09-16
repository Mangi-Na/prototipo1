Class = require "class"
require "jugador"
require "enemigo"
require "enemigos_variantes"

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

-- Entidades del juego
jugador_obj = nil
lista_enemigos = {}

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
    
    -- Instanciación de Objetos con class
    jugador_obj = Jugador(ventana.ancho / 2, ventana.alto / 2)
    
    -- Creación de la lista de enemigos utilizando polimorfismo
    lista_enemigos = {
        Enemigo(100, 100, 30, "assets/rojo.png"), -- Enemigo base
        EnemigoErratico(20, 120),             -- Variante errática (verde)
        EnemigoRapido(130, 40)             -- Variante rápida (azul)
    }
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    
    musica = love.audio.newSource("assets/musica fondo.mp3", "stream")
    musica:setLooping(true)
    love.audio.play(musica)

    sonido_derrota = love.audio.newSource("assets/derrota.mp3", "static")
    sonido_victoria = love.audio.newSource("assets/victoria.mp3", "static")
    sonido_golpe = love.audio.newSource("assets/golpe.mp3", "static")
    
    reiniciarJuego()
end

function love.update(dt)
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
            reiniciarJuego()
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

function love.draw()
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