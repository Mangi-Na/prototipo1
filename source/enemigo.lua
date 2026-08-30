enemigo = {
    y = 100,
    x = 100,
    alto = 0,
    ancho = 0,
    origen_x = 0,
    origen_y = 0,
    hitbox_x = 0,
    hitbox_y = 0,
    velocidad = 30,
    sprite = nil
}

-- INICIALIZACION
function enemigo.Crear(self, ruta)
    self.sprite = love.graphics.newImage(ruta)
    self.ancho = self.sprite:getWidth() 
    self.alto = self.sprite:getHeight()
    self.origen_x = self.ancho / 2  
    self.origen_y = self.alto / 2
end

-- CORREGIDO: Quitamos 'x, y, a' de los parámetros porque no los usabas
function enemigo.Actualizar(self, dt)
    -- persecucion
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

   
    self.hitbox_x = self.x - self.origen_x
    self.hitbox_y = self.y - self.origen_y
end

function enemigo.Dibujar(self)
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.origen_x, self.origen_y)
end
