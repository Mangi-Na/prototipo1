jugador = {
    y = 0,
    x = 0,
    alto = 0,
    ancho = 0,
    origen_x = 0,
    origen_y = 0,
    hitbox_x = 0,
    hitbox_y = 0,
    velocidad = 72,
    sprite = nil,

    -- ATAQUE Y ANIMACIÓN
    atacando = false,
    spritesheet_guante = nil,
    quads_guante = {},
    cuadro_actual = 1,
    tiempo_animacion = 0,
    duracion_cuadro = 0.08, 
    hitbox_ataque = { x = 0, y = 0, ancho = 16, alto = 16 },
    direccion = "down",

    -- PROPIEDADES DE DIBUJO DEL GUANTE
    guante_ancho_frame = 0,
    guante_alto_frame = 0,
    guante_rotacion = 0,
    guante_scale_x = 1,
    guante_scale_y = 1
}

function jugador.Crear(x, y)
    jugador.sprite = love.graphics.newImage("assets/payaso.png")
    jugador.ancho = jugador.sprite:getWidth() 
    jugador.alto = jugador.sprite:getHeight()
    jugador.origen_x = jugador.ancho / 2 
    jugador.origen_y = jugador.alto / 2    
    jugador.x = x
    jugador.y = y
    jugador.direccion = "down"

    jugador.spritesheet_guante = love.graphics.newImage("assets/guante.png")
    jugador.guante_ancho_frame = jugador.spritesheet_guante:getWidth() / 4
    jugador.guante_alto_frame = jugador.spritesheet_guante:getHeight()

    jugador.quads_guante = {}
    for i = 0, 3 do
        table.insert(jugador.quads_guante, love.graphics.newQuad(
            i * jugador.guante_ancho_frame, 0, jugador.guante_ancho_frame, jugador.guante_alto_frame,
            jugador.spritesheet_guante:getDimensions()
        ))
    end
end

function jugador.Atacar()
    if not jugador.atacando then
        jugador.atacando = true
        jugador.cuadro_actual = 1
        jugador.tiempo_animacion = 0
    end
end

function jugador.Actualizar(dt)
    -- Movimiento y dirección
    if not jugador.atacando then
        if love.keyboard.isDown("right") then
            jugador.x = jugador.x + (jugador.velocidad * dt)
            jugador.direccion = "right"
        elseif love.keyboard.isDown("left") then
            jugador.x = jugador.x - (jugador.velocidad * dt)
            jugador.direccion = "left"
        elseif love.keyboard.isDown("down") then
            jugador.y = jugador.y + (jugador.velocidad * dt)
            jugador.direccion = "down"
        elseif love.keyboard.isDown("up") then
            jugador.y = jugador.y - (jugador.velocidad * dt)
            jugador.direccion = "up"
        end
    end

    -- Iniciar Ataque
    if (love.keyboard.isDown("z") or love.keyboard.isDown("space")) and not jugador.atacando then
        jugador.Atacar()
    end

    -- Animación
    if jugador.atacando then
        jugador.tiempo_animacion = jugador.tiempo_animacion + dt
        if jugador.tiempo_animacion >= jugador.duracion_cuadro then
            jugador.tiempo_animacion = 0
            jugador.cuadro_actual = jugador.cuadro_actual + 1
            
            if jugador.cuadro_actual > #jugador.quads_guante then
                jugador.cuadro_actual = 1
                jugador.atacando = false
            end
        end
    end

    -- Hitbox personaje
    jugador.hitbox_x = jugador.x - jugador.origen_x
    jugador.hitbox_y = jugador.y - jugador.origen_y

    -- POSICIÓN DE HITBOX, ROTACIÓN Y ESCALA SEGÚN DIRECCIÓN
    local offset = 12-- Distancia desde el centro del personaje
    
    if jugador.direccion == "right" then
        jugador.hitbox_ataque.x = jugador.x + offset
        jugador.hitbox_ataque.y = jugador.y - 8
        jugador.guante_rotacion = 0
        jugador.guante_scale_x = 1
        jugador.guante_scale_y = 1

    elseif jugador.direccion == "left" then
        jugador.hitbox_ataque.x = jugador.x - offset - 16
        jugador.hitbox_ataque.y = jugador.y - 8
        jugador.guante_rotacion = 0
        jugador.guante_scale_x = -1 -- Voltear horizontalmente
        jugador.guante_scale_y = 1

    elseif jugador.direccion == "up" then
        jugador.hitbox_ataque.x = jugador.x - 8
        jugador.hitbox_ataque.y = jugador.y - offset - 16
        jugador.guante_rotacion = -math.pi / 2 -- Rotar -90 grados
        jugador.guante_scale_x = 1
        jugador.guante_scale_y = 1

    elseif jugador.direccion == "down" then
        jugador.hitbox_ataque.x = jugador.x - 8
        jugador.hitbox_ataque.y = jugador.y + offset
        jugador.guante_rotacion = math.pi / 2 -- Rotar 90 grados
        jugador.guante_scale_x = 1
        jugador.guante_scale_y = 1
    end
end

function jugador.Dibujar()
    -- Dibujar Personaje
    love.graphics.draw(jugador.sprite, jugador.x, jugador.y, 0, 1, 1, jugador.origen_x, jugador.origen_y)

    -- Dibujar Guante con Rotación
    if jugador.atacando then
        local quad = jugador.quads_guante[jugador.cuadro_actual]
        local centro_guante_x = jugador.hitbox_ataque.x + (jugador.hitbox_ataque.ancho / 2)
        local centro_guante_y = jugador.hitbox_ataque.y + (jugador.hitbox_ataque.alto / 2)
        local ox = jugador.guante_ancho_frame / 2
        local oy = jugador.guante_alto_frame / 2

        love.graphics.draw(
            jugador.spritesheet_guante, 
            quad, 
            centro_guante_x, 
            centro_guante_y, 
            jugador.guante_rotacion, 
            jugador.guante_scale_x, 
            jugador.guante_scale_y, 
            ox, 
            oy
        )
    end
end