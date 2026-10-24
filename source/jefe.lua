Jefe = Class{}

function Jefe:init(x, y, mundo)
    self.x = x
    self.y = y
    self.velocidad = 50
    self.sprite = love.graphics.newImage("assets/jefe.png") 
    self.ancho = self.sprite:getWidth()
    self.alto = self.sprite:getHeight()
    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2
    
    self.vidas = 10
    self.activo = true
    self.mundo = mundo

    -- Hitbox e integración con Bump
    self.hitbox_x = self.x - self.origen_x
    self.hitbox_y = self.y - self.origen_y
    self.mundo:add(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
    self.es_pared = false

    -- Inicializar la co-rutina del jefe
    self.hilo = coroutine.create(function()
        while self.activo do
            -- FASE 1: Esperar / Acechar al jugador
            print("Jefe: Buscando al jugador...")
            for i = 1, 60 do -- Esperar aprox 1 segundo (dependiendo del update)
                coroutine.yield()
            end

            -- FASE 2: Cargar un ataque 
            print("Jefe: ¡to poop!")
            -- Aquí podrías cambiar el color o reproducir un sonido de advertencia
            for i = 1, 30 do
                coroutine.yield()
            end

            -- FASE 3: Descanso del jefe (Ventana de oportunidad para golpearlo)
            print("Jefe: llorando...")
            for i = 1, 90 do -- 1.5 segundos de descanso
                coroutine.yield()
            end
        end
    end)
end

function Jefe:Actualizar(dt, jugador)
    -- Si la co-rutina sigue viva, la reanudamos
    if self.activo and coroutine.status(self.hilo) ~= "dead" then
        local success, err = coroutine.resume(self.hilo)
        if not success then
            print("Error en co-rutina del Jefe: " .. tostring(err))
        end
    end

    -- Actualizar hitbox en Bump
    self.hitbox_x = self.x - self.origen_x
    self.hitbox_y = self.y - self.origen_y
    self.mundo:update(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
end

function Jefe:RecibirGolpe()
    self.vidas = self.vidas - 1
    if self.vidas <= 0 then
        self.activo = false
        self.mundo:remove(self)
        print("¡zzz!")
    end
end

function Jefe:Dibujar()
    if not self.activo then return end
    love.graphics.setColor(0.8, 0.2, 0.2) -- Un tono rojizo para diferenciarlo
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1.5, 1.5, self.origen_x, self.origen_y)
    love.graphics.setColor(1, 1, 1, 1)
end