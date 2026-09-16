Class = require "class"

Jugador = Class{}

function Jugador:init(x, y, v)
    self.x = x
    self.y = y
    self.velocidad = 72
    self.sprite = love.graphics.newImage("assets/payaso.png")
    self.ancho = self.sprite:getWidth() 
    self.alto = self.sprite:getHeight()
    self.origen_x = self.ancho / 2 
    self.origen_y = self.alto / 2    
    self.direccion = "down"

    -- ATAQUE Y ANIMACIÓN
    self.atacando = false
    self.spritesheet_guante = love.graphics.newImage("assets/guante.png")
    self.guante_ancho_frame = self.spritesheet_guante:getWidth() / 4
    self.guante_alto_frame = self.spritesheet_guante:getHeight()
    self.cuadro_actual = 1
    self.tiempo_animacion = 0
    self.duracion_cuadro = 0.08
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
end

function Jugador:Atacar()
    if not self.atacando then
        self.atacando = true
        self.cuadro_actual = 1
        self.tiempo_animacion = 0
    end
end

function Jugador:Actualizar(dt)
    -- Movimiento y dirección
    if not self.atacando then
        if love.keyboard.isDown("right") then
            self.x = self.x + (self.velocidad * dt)
            self.direccion = "right"
        elseif love.keyboard.isDown("left") then
            self.x = self.x - (self.velocidad * dt)
            self.direccion = "left"
        elseif love.keyboard.isDown("down") then
            self.y = self.y + (self.velocidad * dt)
            self.direccion = "down"
        elseif love.keyboard.isDown("up") then
            self.y = self.y - (self.velocidad * dt)
            self.direccion = "up"
        end
    end

    -- Iniciar Ataque
    if (love.keyboard.isDown("z") or love.keyboard.isDown("space")) and not self.atacando then
        self:Atacar()
    end

    -- Animación
    if self.atacando then
        self.tiempo_animacion = self.tiempo_animacion + dt
        if self.tiempo_animacion >= self.duracion_cuadro then
            self.tiempo_animacion = 0
            self.cuadro_actual = self.cuadro_actual + 1
            if self.cuadro_actual > #self.quads_guante then
                self.cuadro_actual = 1
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
end

function Jugador:Dibujar()
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.origen_x, self.origen_y)

    if self.atacando then
        local quad = self.quads_guante[self.cuadro_actual]
        local centro_x = self.hitbox_ataque.x + (self.hitbox_ataque.ancho / 2)
        local centro_y = self.hitbox_ataque.y + (self.hitbox_ataque.alto / 2)
        local ox, oy = self.guante_ancho_frame / 2, self.guante_alto_frame / 2

        love.graphics.draw(self.spritesheet_guante, quad, centro_x, centro_y, self.guante_rotacion, self.guante_scale_x, self.guante_scale_y, ox, oy)
    end
end