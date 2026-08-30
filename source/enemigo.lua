enemigo = {}
enemigo.__index = enemigo -- ¡Esta línea es obligatoria para que funcione enemigo:Nuevo!

-- Función para crear cada enemigo individual
function enemigo:Nuevo(x, y, velocidad, ruta)
    local instancia = setmetatable({}, self)
    
    instancia.x = x
    instancia.y = y
    instancia.velocidad = velocidad
    instancia.sprite = love.graphics.newImage(ruta)
    
    instancia.ancho = instancia.sprite:getWidth() 
    instancia.alto = instancia.sprite:getHeight()
    instancia.origen_x = instancia.ancho / 2  
    instancia.origen_y = instancia.alto / 2
    instancia.hitbox_x = 0
    instancia.hitbox_y = 0
    
    return instancia
end

-- CORRECCIÓN CRÍTICA: Debe tener dos puntos ':' y NO debe llevar 'self' dentro del paréntesis
function enemigo:Actualizar(dt)
    -- Persecución
    local dist_x = math.abs(self.x - jugador.x)
    local dist_y = math.abs(self.y - jugador.y)
    
    if dist_x > dist_y then
        if dist_x > self.ancho then
            if self.x < jugador.x then
                self.x = self.x + (self.velocidad * dt)
            elseif self.x > jugador.x then
                self.x = self.x - (self.velocidad * dt)
            end
        end
    else
        if dist_y > jugador.alto then
            if self.y < jugador.y then
                self.y = self.y + (self.velocidad * dt)
            elseif self.y > jugador.y then
                self.y = self.y - (self.velocidad * dt)
            end
        end   
    end

    -- Hitbox propia para las colisiones
    self.hitbox_x = self.x - self.origen_x
    self.hitbox_y = self.y - self.origen_y
end

-- CORRECCIÓN CRÍTICA: Asegúrate de que se llame Dibujar y tenga dos puntos ':'
function enemigo:Dibujar()
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.origen_x, self.origen_y)
end
