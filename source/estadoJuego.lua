estadoJuego = Class{}

function estadoJuego:init()

    self:reiniciarJuego()

end

function estadoJuego:reiniciarJuego()
    atrapado = false
    victoria = false
    tiempo_supervivencia = 15.0
    audio_final_reproducido = false

    love.audio.stop(sonido_derrota)
    love.audio.stop(sonido_victoria)
    musica:play()
      -- Instanciación de Objetos con class
    jugador_obj = Jugador(ventana.ancho / 2, ventana.alto / 2, mundo)

       -- Creación de la lista de enemigos utilizando polimorfismo
    lista_enemigos = {}
  
    if mapa and mapa.layers["generadores"] then
        for _, obj in ipairs(mapa.layers["generadores"].objects) do
            if obj.name == "verde" then
                table.insert(lista_enemigos, EnemigoErratico(obj.x, obj.y, mundo))
            elseif obj.name == "rojo" then
                table.insert(lista_enemigos, Enemigo(obj.x, obj.y, 30, "assets/rojo.png", mundo))
            elseif obj.name == "azul" then
                table.insert(lista_enemigos, EnemigoRapido(obj.x, obj.y, mundo))
            end
        end
    end
end


function estadoJuego:ingresar()

    self:reiniciarJuego()

end

function estadoJuego:salir() end

function estadoJuego:actualizar(dt)
    -- Pantallas de fin de juego
    if atrapado or victoria then
        if not audio_final_reproducido then
            musica:stop()
           
            if atrapado then

                sonido_derrota:play()

            elseif victoria then

                sonido_victoria:play()

            end

            maquinaEstadoGlobal:cambiar('fin', { victoria = victoria })

            audio_final_reproducido = true

        end

        if love.keyboard.isDown("r") then

            self:reiniciarJuego()

        elseif love.keyboard.isDown("escape") then
            --SI EL JUGADOR PRESIONA ESC
            maquinaEstadoGlobal:cambiar('titulo')
        end

        return

    end

    if love.keyboard.isDown("escape") then

        maquinaEstadoGlobal:cambiar('titulo')

    end
    -- Actualizaciones de Entidades
    jugador_obj:Actualizar(dt)

    camaraPrincipal:lookAt(redondear(jugador_obj.x), redondear(jugador_obj.y))
        --límites de la camara
        -- Eje X (izquierda y derecha))
    if camaraPrincipal.x < ventana.camara_centro_x then
        camaraPrincipal.x = ventana.camara_centro_x
    elseif camaraPrincipal.x > ventana.mapa_ancho - ventana.camara_centro_x then
        camaraPrincipal.x = ventana.mapa_ancho - ventana.camara_centro_x
    end

    -- Eje Y (arriba y abajo)
    if camaraPrincipal.y < ventana.camara_centro_y then
        camaraPrincipal.y = ventana.camara_centro_y
    elseif camaraPrincipal.y > ventana.mapa_alto - ventana.camara_centro_y then
        camaraPrincipal.y = ventana.mapa_alto - ventana.camara_centro_y

    end

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
                    e.hitbox_x, e.hitbox_y, e.ancho, e.alto)

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
    local x, y = jugador_obj.x, jugador_obj.y
    local ancho, alto = jugador_obj.ancho, jugador_obj.alto

    -- Filtro para buscar SOLO paredes del mapa
    soloParedes = function(item)

      return item.es_pared == true

    end
   -- Consulta en el mundo de Bump
   local paredes_tocadas, cantidad = mundo:queryRect(x, y, ancho, alto, soloParedes)

end

function estadoJuego:dibujar()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    camaraPrincipal:attach(0, 0, ventana.ancho, ventana.alto)
       
    mapa:drawLayer(mapa.layers["piso"])

    -- Dibujar Entidades
    jugador_obj:Dibujar()

    for _, e in ipairs(lista_enemigos) do
        e:Dibujar()

    end

    mapa:drawLayer(mapa.layers["deco"])
    camaraPrincipal:detach()

    love.graphics.setCanvas()
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)

    -- Interfaz de Usuario
    love.graphics.print("Tiempo: " .. string.format("%.1f", tiempo_supervivencia), 20, 20)
  

end 