Jugador = Class{}

function Jugador:init(x, y, mundo)
    self.x = x
    self.y = y
    self.velocidad = 72
    
    -- CONFIGURACIÓN DEL SPRITESHEET ANIMADO DEL PAYASO (16 cuadros)
    self.sprite = love.graphics.newImage("assets/payaso.png")
    self.total_cuadros = 16
    
    -- 1. Calculamos el ancho y alto de cada cuadro ANTES de los quads
    self.ancho_frame = self.sprite:getWidth() / self.total_cuadros
    self.alto_frame = self.sprite:getHeight()
    
    self.ancho = self.ancho_frame
    self.alto = self.alto_frame
    self.origen_x = self.ancho / 2 
    self.origen_y = self.alto / 2    
    self.direccion = "down"

    -- Hitbox e integración con Bump
    self.hitbox_x = self.x - self.origen_x
    self.hitbox_y = self.y - self.origen_y
    self.vidas = 3
    self.invulnerable = false
     
    self.mundo = mundo
    self.mundo:add(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)

    -- 2. ANIMACIÓN DEL JUGADOR (Separada)
    self.cuadro_actual = 1
    self.tiempo_animacion = 0
    self.duracion_cuadro = 0.08

    self.quads_jugador = {}
    for i = 0, self.total_cuadros - 1 do
        table.insert(self.quads_jugador, love.graphics.newQuad(
            i * self.ancho_frame, 0, 
            self.ancho_frame, self.alto_frame, 
            self.sprite:getDimensions()
        ))
    end

    -- ATAQUE Y ANIMACIÓN DEL GUANTE (Variables independientes)
    self.atacando = false
    self.spritesheet_guante = love.graphics.newImage("assets/guante.png")
    self.guante_ancho_frame = self.spritesheet_guante:getWidth() / 4
    self.guante_alto_frame = self.spritesheet_guante:getHeight()
    
    self.guante_cuadro_actual = 1
    self.guante_tiempo_animacion = 0
    self.guante_duracion_cuadro = 0.08
    
    self.hitbox_ataque = { x = 0, y = 0, ancho = 16, alto = 16 }
    self.guante_rotacion = 0
    self.guante_scale_x = 1
    self.guante_scale_y = 1

    self.quads_guante = {}
    for i = 0, 3 do
        table.insert(self.quads_guante, love.graphics.newQuad(
            i * self.guante_ancho_frame, 0, self.guante_ancho_frame, self.guante_alto_frame,
            self.spritesheet_guante:getDimensions()
        ))
    end

    -- ATRIBUTOS DE COMBO Y FURIA
    self.combo = 0
    self.modo_furia = false
    self.velocidad_base = 72
    self.velocidad = self.velocidad_base

    -- Registrar oyentes de eventos
    Eventos.on('modo_furia', function(activo)
        self.modo_furia = activo
        if activo then
            self.velocidad = self.velocidad_base * 1.5
        else
            self.velocidad = self.velocidad_base
        end
    end)

    Eventos.on('combo_reiniciado', function()
        self.combo = 0
        if self.modo_furia then
            Eventos.emitir('modo_furia', false)
        end
    end)
end


function Jugador:Atacar()
    if not self.atacando then
        self.atacando = true
        self.guante_cuadro_actual = 1
        self.guante_tiempo_animacion = 0
    end
end

function Jugador:Actualizar(dt)
    local dx, dy = 0, 0
    local moviendo = false

    -- Movimiento y dirección
    if not self.atacando then
        if love.keyboard.isDown("right") then
            dx = 1
            self.direccion = "right"
            moviendo = true
        elseif love.keyboard.isDown("left") then
            dx = -1
            self.direccion = "left"
            moviendo = true
        end

        if love.keyboard.isDown("down") then
            dy = 1
            self.direccion = "down"
            moviendo = true
        elseif love.keyboard.isDown("up") then
            dy = -1
            self.direccion = "up"
            moviendo = true
        end
    end

    -- Posición que desea alcanzar el personaje
    local objetivo_x = self.x + (dx * self.velocidad * dt)
    local objetivo_y = self.y + (dy * self.velocidad * dt)
    
    -- Restringir dentro de los límites del mapa ANTES de consultar a Bump
    if objetivo_x - self.origen_x < 0 then
        objetivo_x = self.origen_x
    elseif objetivo_x + self.origen_x > ventana.mapa_ancho then
        objetivo_x = ventana.mapa_ancho - self.origen_x
    end

    if objetivo_y - self.origen_y < 0 then
        objetivo_y = self.origen_y
    elseif objetivo_y + self.origen_y > ventana.mapa_alto then
        objetivo_y = ventana.mapa_alto - self.origen_y
    end

    local deseado_hitbox_x = objetivo_x - self.origen_x
    local deseado_hitbox_y = objetivo_y - self.origen_y

    local filtroJugador = function(item, otro)
        if otro.es_pared then
            return 'slide'
        end
        return nil
    end

    -- Mover con Bump
    if self.mundo then
        local real_hitbox_x, real_hitbox_y, colisiones, len = self.mundo:move(
            self, 
            deseado_hitbox_x, 
            deseado_hitbox_y, 
            filtroJugador
        )

        self.hitbox_x = real_hitbox_x
        self.hitbox_y = real_hitbox_y
        self.x = self.hitbox_x + self.origen_x
        self.y = self.hitbox_y + self.origen_y
    else
        self.x = objetivo_x
        self.y = objetivo_y
        self.hitbox_x = deseado_hitbox_x
        self.hitbox_y = deseado_hitbox_y
    end
    
    -- ANIMACIÓN DEL JUGADOR (PAYASO)
    if moviendo then
        self.tiempo_animacion = self.tiempo_animacion + dt
        if self.tiempo_animacion >= self.duracion_cuadro then
            self.tiempo_animacion = 0
            self.cuadro_actual = self.cuadro_actual + 1
            if self.cuadro_actual > self.total_cuadros then
                self.cuadro_actual = 1
            end
        end
    else
        self.cuadro_actual = 1 -- Vuelve al reposo si no se mueve
    end

    -- Iniciar Ataque
    if (love.keyboard.isDown("z") or love.keyboard.isDown("space")) and not self.atacando then
        self:Atacar()
    end

    -- ANIMACIÓN DEL GUANTE
    if self.atacando then
        self.guante_tiempo_animacion = self.guante_tiempo_animacion + dt
        if self.guante_tiempo_animacion >= self.guante_duracion_cuadro then
            self.guante_tiempo_animacion = 0
            self.guante_cuadro_actual = self.guante_cuadro_actual + 1
            if self.guante_cuadro_actual > #self.quads_guante then
                self.guante_cuadro_actual = 1
                self.atacando = false
            end
        end
    end

    -- Lógica de Hitbox de ataque 
    self.hitbox_x = self.x - self.origen_x
    self.hitbox_y = self.y - self.origen_y
    local offset = 12

    if self.direccion == "right" then
        self.hitbox_ataque.x, self.hitbox_ataque.y = self.x + offset, self.y - 8
        self.guante_rotacion, self.guante_scale_x, self.guante_scale_y = 0, 1, 1
    elseif self.direccion == "left" then
        self.hitbox_ataque.x, self.hitbox_ataque.y = self.x - offset - 16, self.y - 8
        self.guante_rotacion, self.guante_scale_x, self.guante_scale_y = 0, -1, 1
    elseif self.direccion == "up" then
        self.hitbox_ataque.x, self.hitbox_ataque.y = self.x - 8, self.y - offset - 16
        self.guante_rotacion, self.guante_scale_x, self.guante_scale_y = -math.pi / 2, 1, 1
    elseif self.direccion == "down" then
        self.hitbox_ataque.x, self.hitbox_ataque.y = self.x - 8, self.y + offset
        self.guante_rotacion, self.guante_scale_x, self.guante_scale_y = math.pi / 2, 1, 1
    end
    
    self.mundo:update(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
end

function Jugador:Dibujar()
    -- Prioridad de color (Invulnerable > Furia > Normal)
    if self.invulnerable then
        love.graphics.setColor(1, 0.3, 0.3, 1) 
    elseif self.modo_furia then
        love.graphics.setColor(1, 0.7, 0.2, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    -- Dibujar payaso con su respectivo cuadro de los 16
    local quad_jugador = self.quads_jugador[self.cuadro_actual]
    love.graphics.draw(self.sprite, quad_jugador, self.x, self.y, 0, 1, 1, self.origen_x, self.origen_y)
    
    -- Dibujar guante si está atacando
    if self.atacando then
        local quad_guante = self.quads_guante[self.guante_cuadro_actual]
        local centro_x = self.hitbox_ataque.x + (self.hitbox_ataque.ancho / 2)
        local centro_y = self.hitbox_ataque.y + (self.hitbox_ataque.alto / 2)
        local ox, oy = self.guante_ancho_frame / 2, self.guante_alto_frame / 2

        love.graphics.draw(self.spritesheet_guante, quad_guante, centro_x, centro_y, self.guante_rotacion, self.guante_scale_x, self.guante_scale_y, ox, oy)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end