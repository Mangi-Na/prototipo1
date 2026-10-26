estadoJuego = Class{}

function estadoJuego:init()
    self:reiniciarJuego()
end

function estadoJuego:reiniciarJuego()
    -- LIMPIAR TODOS LOS EVENTOS REGISTRADOS ANTERIORMENTE
    Eventos.limpiar()
    atrapado = false
    victoria = false
   
    self.invulnerable = false   
    tiempo_supervivencia = 15.0 -- Tiempo inicial para sobrevivir a los comunes
    audio_final_reproducido = false

    love.audio.stop(sonido_derrota)
    love.audio.stop(sonido_victoria)
    musica:play()

    -- Instanciación de Objetos con class
    jugador_obj = Jugador(ventana.ancho / 2, ventana.alto / 2, mundo)
    self.hud = HUD(mundo)
    self.hud:actualizarVidas(jugador_obj.vidas)

    -- Creación de la lista de enemigos comunes
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

    -- Instanciamos al jefe  
    local mapa_centro_x = ventana.mapa_ancho / 2
    local mapa_centro_y = ventana.mapa_alto / 2

    jefe_obj = Jefe(mapa_centro_x, mapa_centro_y, mundo)
    jefe_obj.activo = false
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
            maquinaEstadoGlobal:cambiar('titulo')
        end
        return
    end

    if love.keyboard.isDown("escape") then
        maquinaEstadoGlobal:cambiar('titulo')
    end

    -- Actualizar Entidades y Cámara
    jugador_obj:Actualizar(dt)

    camaraPrincipal:lookAt(redondear(jugador_obj.x), redondear(jugador_obj.y))
    if camaraPrincipal.x < ventana.camara_centro_x then
        camaraPrincipal.x = ventana.camara_centro_x
    elseif camaraPrincipal.x > ventana.mapa_ancho - ventana.camara_centro_x then
        camaraPrincipal.x = ventana.mapa_ancho - ventana.camara_centro_x
    end

    if camaraPrincipal.y < ventana.camara_centro_y then
        camaraPrincipal.y = ventana.camara_centro_y
    elseif camaraPrincipal.y > ventana.mapa_alto - ventana.camara_centro_y then
        camaraPrincipal.y = ventana.mapa_alto - ventana.camara_centro_y
    end

    if not jefe_obj.activo then
        -- Actualizar enemigos comunes
        for _, e in ipairs(lista_enemigos) do
            e:Actualizar(dt, jugador_obj)
        end

        tiempo_supervivencia = tiempo_supervivencia - dt

        -- SI EL TIEMPO LLEGA A 0: Desaparecen comunes y aparece el Jefe
        if tiempo_supervivencia <= 0 then
            jefe_obj.activo = true
            tiempo_supervivencia = 20.0 -- Damos 20 segundos extras para derrotar al jefe

            -- Limpiar y remover del mundo de Bump a los enemigos comunes
            for _, e in ipairs(lista_enemigos) do
                e.activo = false
                if e.mundo then e.mundo:remove(e) end
            end
        end
    else
        -- El jefe está activo, avanza su co-rutina
        jefe_obj:Actualizar(dt, jugador_obj)

        -- Temporizador 2 (Tiempo extra para el jefe)
        tiempo_supervivencia = tiempo_supervivencia - dt
        if tiempo_supervivencia <= 0 then
            tiempo_supervivencia = 0
            victoria = true -- Si se acaba el tiempo extra y sigues vivo
        end
    end

    self.hud:actualizarTiempo(tiempo_supervivencia)

    -- CONTROLAR ATAQUE SEGÚN QUIÉN ESTÉ EN PANTALLA
    
    if jugador_obj.atacando then
        if not jefe_obj.activo then
            -- Golpear enemigos comunes
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
                    
                        jugador_obj.combo = jugador_obj.combo + 1
                        Eventos.emitir('enemigo_golpeado', jugador_obj.combo)

                        if jugador_obj.combo >= 3 and not jugador_obj.modo_furia then
                            Eventos.emitir('modo_furia', true)
                        end
                    end
                end
            end
        else
            -- Golpear al Jefe (cuando ya apareció)
            local golpearJefe = comprobarColision(
                jugador_obj.hitbox_ataque.x, jugador_obj.hitbox_ataque.y,
                jugador_obj.hitbox_ataque.ancho, jugador_obj.hitbox_ataque.alto,
                jefe_obj.hitbox_x, jefe_obj.hitbox_y, jefe_obj.ancho, jefe_obj.alto)

            if golpearJefe then
                sonido_golpe:stop()
                sonido_golpe:play()
                jefe_obj:RecibirGolpe()

                -- Si las vidas del jefe llegan a 0
                if not jefe_obj.activo then
                    victoria = true
                end
            end
        end
    end

    -- COLISIONES DE DERROTA (Daño del enemigo o del jefe al jugador)
    
    if not jefe_obj.activo then
        -- Colisión con enemigos comunes
        for _, e in ipairs(lista_enemigos) do
            if e.activo then
                local colision = comprobarColision(
                    jugador_obj.hitbox_x, jugador_obj.hitbox_y, jugador_obj.ancho, jugador_obj.alto,
                    e.hitbox_x, e.hitbox_y, e.ancho_hitbox, e.alto_hitbox
                )

                if colision then
                    if not jugador_obj.invulnerable then
                        jugador_obj.invulnerable = true
                        jugador_obj.vidas = jugador_obj.vidas - 1
                        self.hud:actualizarVidas(jugador_obj.vidas)
                        Eventos.emitir('combo_reiniciado')

                        if jugador_obj.vidas <= 0 then
                            atrapado = true
                        else
                            Timer.after(2, function() jugador_obj.invulnerable = false end)
                        end
                    end
                    break
                end
            end
        end
    else
        -- Colisión con el Jefe
        local colisionJefe = comprobarColision(
        jugador_obj.hitbox_x, jugador_obj.hitbox_y, jugador_obj.ancho, jugador_obj.alto,
        jefe_obj.hitbox_x, jefe_obj.hitbox_y, jefe_obj.ancho_hitbox, jefe_obj.alto_hitbox
        )

        if colisionJefe then
            if not jugador_obj.invulnerable then
                jugador_obj.invulnerable = true
                jugador_obj.vidas = jugador_obj.vidas - 1
                self.hud:actualizarVidas(jugador_obj.vidas)
                Eventos.emitir('combo_reiniciado')

                if jugador_obj.vidas <= 0 then
                    atrapado = true
                else
                    Timer.after(2, function() jugador_obj.invulnerable = false end)
                end
            end
        end
    end

    -- Consulta de paredes con Bump
    local x, y = jugador_obj.x, jugador_obj.y
    local ancho, alto = jugador_obj.ancho, jugador_obj.alto
    soloParedes = function(item)
        return item.es_pared == true
    end
    local paredes_tocadas, cantidad = mundo:queryRect(x, y, ancho, alto, soloParedes)
end

function estadoJuego:dibujar()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    camaraPrincipal:attach(0, 0, ventana.ancho, ventana.alto)
        
    mapa:drawLayer(mapa.layers["piso"])

    -- Dibujar Entidades
    jugador_obj:Dibujar()

    -- DIBUJAR COMUNES O DIBUJAR AL JEFE 
        if not jefe_obj.activo then
        for _, e in ipairs(lista_enemigos) do
            if e.activo then
                e:Dibujar()
            end
        end
    else
        jefe_obj:Dibujar()
    end

    mapa:drawLayer(mapa.layers["deco"])
    camaraPrincipal:detach()

    love.graphics.setCanvas()
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)
    self.hud:Draw()
    
end