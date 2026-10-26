Jefe = Class{}

function Jefe:init(x, y, mundo)
    self.x = x
    self.y = y
    self.velocidad = 25
    self.proyectiles = {}

    self.sheet_combate = love.graphics.newImage("assets/jefe.png")
    self.sheet_llanto = love.graphics.newImage("assets/jefe2.png")

    -- Defino las texturas actuales desde el inicio
    self.spritesheet_actual = self.sheet_combate 
    
    self.total_cuadros = 5 
    self.ancho_frame = self.sheet_combate:getWidth() / self.total_cuadros
    self.alto_frame = self.sheet_combate:getHeight()
    
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
    
    self.quads_combate = {}
    for i = 0, self.total_cuadros - 1 do
        table.insert(self.quads_combate, love.graphics.newQuad(
            i * self.ancho_frame, 0, 
            self.ancho_frame, self.alto_frame, 
            self.sheet_combate:getDimensions()
        ))
    end

    self.total_cuadros_llanto = 5
    self.ancho_frame_llanto = self.sheet_llanto:getWidth() / self.total_cuadros_llanto
    self.alto_frame_llanto = self.sheet_llanto:getHeight()
    
    self.quads_llanto = {}
    for i = 0, self.total_cuadros_llanto - 1 do
        table.insert(self.quads_llanto, love.graphics.newQuad(
            i * self.ancho_frame_llanto, 0, 
            self.ancho_frame_llanto, self.alto_frame_llanto, 
            self.sheet_llanto:getDimensions()
        ))
    end
    
    -- Empieza usando los quads de combate
    self.quads_actuales = self.quads_combate
    
    self.vidas = 5
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
    self.hilo = coroutine.create(function(dt_inicial, jugador_inicial)
        local dt = dt_inicial
        local jugador = jugador_inicial

        while self.activo do
            self.spritesheet_actual = self.sheet_combate
            self.quads_actuales = self.quads_combate
            self.total_cuadros = 5
            self.cuadro_actual = 1

            -- Perseguir al jugador
            for i = 1, 250 do
                dt, jugador = coroutine.yield()
                
                if jugador then
                    local dx = jugador.x - self.x
                    local dy = jugador.y - self.y
                    local distancia = math.sqrt(dx * dx + dy * dy)
                    
                    if distancia > 15 then
                        self.x = self.x + (dx / distancia) * self.velocidad * dt
                        self.y = self.y + (dy / distancia) * self.velocidad * dt
                    end
                end
            end

            -- Cargar un ataque 
            for i = 1, 60 do
                dt, jugador = coroutine.yield()
            end

            if jugador then
                local dx = jugador.x - self.x
                local dy = jugador.y - self.y
                local distancia = math.sqrt(dx * dx + dy * dy)
                
                if distancia > 0 then
                    -- Calculamos el ángulo base hacia el jugador
                    local angulo_base = math.atan2(dy, dx)
                    local cantidad_proyectiles = 5
                    local dispersion = 0.5 -- Ancho del abanico en radianes
                    
                    for j = 1, cantidad_proyectiles do
                        -- Distribuimos los proyectiles en abanico alrededor del ángulo base
                        local offset = -dispersion / 2 + (dispersion / (cantidad_proyectiles - 1)) * (j - 1)
                        local angulo_final = angulo_base + offset
                        local velocidad_bala = 110
                        
                        table.insert(self.proyectiles, {
                            x = self.x,
                            y = self.y,
                            vx = math.cos(angulo_final) * velocidad_bala,
                            vy = math.sin(angulo_final) * velocidad_bala,
                            radio = 3
                        })
                    end
                end
            end

            -- Descanso del jefe
            self.spritesheet_actual = self.sheet_llanto
            self.quads_actuales = self.quads_llanto
            self.total_cuadros = self.total_cuadros_llanto
            self.cuadro_actual = 1
            
            for i = 1, 180 do
                dt, jugador = coroutine.yield()
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
    -- Actualizar proyectiles del jefe
    for i = #self.proyectiles, 1, -1 do
        local p = self.proyectiles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt

        -- Si el proyectil choca con el jugador, le quita vida 
        if jugador and math.sqrt((p.x - jugador.x)^2 + (p.y - jugador.y)^2) < 20 then
            if not jugador.invulnerable then
                jugador.invulnerable = true
                jugador.vidas = jugador.vidas - 1
                Timer.after(2, function() jugador.invulnerable = false end)
            end
            table.remove(self.proyectiles, i)
        end
        if jugador and self.activo then
        local distancia_cuerpo = math.sqrt((self.x - jugador.x)^2 + (self.y - jugador.y)^2)
        if distancia_cuerpo < (self.origen_hitbox_x + 10) then
            if jugador.RecibirDanio then
                jugador:RecibirDanio()
            elseif not jugador.invulnerable then
                jugador.vidas = jugador.vidas - 1
                jugador.invulnerable = true
                jugador.tiempo_invulnerable = 1.0
            end
        end
    end
    end

    -- Reanudamos la co-rutina pasándole el dt y el jugador
    if self.activo and coroutine.status(self.hilo) ~= "dead" then
        local success, err = coroutine.resume(self.hilo, dt, jugador)
        if not success then
            print("Error en co-rutina del Jefe: " .. tostring(err))
        end
    end

    -- Actualizar la animación del spritesheet 
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
    self.tiempo_invulnerable = 0.5 
    
    if self.vidas <= 0 then
        self.activo = false
        self.mundo:remove(self)
       
    end
end

function Jefe:Dibujar()
    if not self.activo then return end
    
    love.graphics.setColor(1, 1, 1, 1)
    local quad = self.quads_actuales[self.cuadro_actual]
    
    love.graphics.draw(
        self.spritesheet_actual, quad, 
        self.x, self.y, 
        0, 1.5, 1.5, 
        self.origen_x, self.origen_y
    )

    -- Dibujar los disparos
    love.graphics.setColor(0.55, 0.27, 0.07)
    for _, p in ipairs(self.proyectiles) do
        love.graphics.circle("fill", p.x, p.y, p.radio)
    end
    love.graphics.setColor(1, 1, 1, 1)
end
