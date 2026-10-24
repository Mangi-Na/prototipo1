Jefe = Class{}

function Jefe:init(x, y, mundo)
    self.x = x
    self.y = y
    self.velocidad = 50
    self.spritesheet = love.graphics.newImage("assets/jefe.png")
    self.total_cuadros = 5 
    self.ancho_frame = self.spritesheet:getWidth() / self.total_cuadros
    self.alto_frame = self.spritesheet:getHeight()
    
    self.ancho = self.ancho_frame
    self.alto = self.alto_frame
    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2

    self.ancho_hitbox = self.ancho * 0.6
    self.alto_hitbox = self.alto * 0.6
    self.origen_hitbox_x = self.ancho_hitbox / 2
    self.origen_hitbox_y = self.alto_hitbox / 2
    
    -- Control de animación
    self.cuadro_actual = 1
    self.tiempo_animacion = 0
    self.duracion_cuadro = 0.15
    
    self.quads = {}
    for i = 0, self.total_cuadros - 1 do
        table.insert(self.quads, love.graphics.newQuad(
            i * self.ancho_frame, 0, 
            self.ancho_frame, self.alto_frame, 
            self.spritesheet:getDimensions()
        ))
    end
    
    self.vidas = 10
    self.activo = true
    self.mundo = mundo
    self.invulnerable = false
    self.tiempo_invulnerable = 0

    -- Hitbox e integración con Bump
    self.hitbox_x = self.x - self.origen_hitbox_x
    self.hitbox_y = self.y - self.origen_hitbox_y
    self.mundo:add(self, self.hitbox_x, self.hitbox_y, self.ancho_hitbox, self.alto_hitbox)
    self.es_pared = false

    -- Inicializar la co-rutina del jefe
    self.hilo = coroutine.create(function()
        while self.activo do
            -- FASE 1: Esperar / Acechar al jugador
            print("Jefe: Buscando al jugador...")
            for i = 1, 60 do 
                coroutine.yield()
            end

            -- FASE 2: Cargar un ataque 
            print("Jefe: ¡to poop!")
            for i = 1, 30 do
                coroutine.yield()
            end

            -- FASE 3: Descanso del jefe (Ventana de oportunidad para golpearlo)
            print("Jefe: llorando...")
            for i = 1, 90 do 
                coroutine.yield()
            end
        end
    end)
end

function Jefe:Actualizar(dt, jugador)
    -- Si está invulnerable, restamos tiempo
    if self.invulnerable then
        self.tiempo_invulnerable = self.tiempo_invulnerable - dt
        if self.tiempo_invulnerable <= 0 then
            self.invulnerable = false
        end
    end

    -- Si la co-rutina sigue viva, la reanudamos
    if self.activo and coroutine.status(self.hilo) ~= "dead" then
        local success, err = coroutine.resume(self.hilo)
        if not success then
            print("Error en co-rutina del Jefe: " .. tostring(err))
        end
    end

    -- Actualizar la animación del spritesheet fotograma a fotograma
    self.tiempo_animacion = self.tiempo_animacion + dt
    if self.tiempo_animacion >= self.duracion_cuadro then
        self.tiempo_animacion = 0
        self.cuadro_actual = self.cuadro_actual + 1
        if self.cuadro_actual > self.total_cuadros then
            self.cuadro_actual = 1
        end
    end

    -- Actualizar hitbox en Bump
    self.hitbox_x = self.x - self.origen_hitbox_x
    self.hitbox_y = self.y - self.origen_hitbox_y
    self.mundo:update(self, self.hitbox_x, self.hitbox_y, self.ancho_hitbox, self.alto_hitbox)
end

function Jefe:RecibirGolpe()
    if self.invulnerable then return end -- Si es invulnerable, ignorar el golpe

    self.vidas = self.vidas - 1
    self.invulnerable = true
    self.tiempo_invulnerable = 0.5 -- 0.5 segundos de inmunidad tras recibir un golpe
    
    if self.vidas <= 0 then
        self.activo = false
        self.mundo:remove(self)
        print("¡ZZZ!")
    end
end

function Jefe:Dibujar()
    if not self.activo then return end
    
    love.graphics.setColor(1, 1, 1, 1)
    local quad = self.quads[self.cuadro_actual]
    
    -- Dibujamos usando el quad correspondiente del spritesheet
    love.graphics.draw(
        self.spritesheet, quad, 
        self.x, self.y, 
        0, 1.5, 1.5, 
        self.origen_x, self.origen_y
    )
end