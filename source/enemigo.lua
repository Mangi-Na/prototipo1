enemigo = {}
enemigo.__index = enemigo 

function enemigo:Nuevo(x, y, velocidad, ruta)
    local instancia = setmetatable({}, self)
    
    instancia.x = x
    instancia.y = y
    instancia.velocidad = velocidad
    instancia.sprite = love.graphics.newImage(ruta)
    instancia.activo = true
    
    instancia.ancho = instancia.sprite:getWidth() 
    instancia.alto = instancia.sprite:getHeight()
    instancia.origen_x = instancia.ancho / 2  
    instancia.origen_y = instancia.alto / 2
    instancia.ancho_hitbox = instancia.ancho - 8
    instancia.alto_hitbox = instancia.alto - 8
    
    return instancia
end
function enemigo:Reaparecer(nueva_x, nueva_y)
    self.x = nueva_x
    self.y = nueva_y
    self.activo = true
end
function enemigo:Actualizar(dt)
    if not self.activo then return end

    -- Vector de dirección hacia el jugador
    local dx = jugador.x - self.x
    local dy = jugador.y - self.y
    local distancia = math.sqrt(dx * dx + dy * dy)

    -- DISTANCIA DE SEGURIDAD 
    local distancia_minima = 40 

    if distancia > 0 then
        local dir_x = dx / distancia
        local dir_y = dy / distancia

        if distancia > distancia_minima then
            -- Avanza a velocidad normal si está lejos
            self.x = self.x + (dir_x * self.velocidad * dt)
            self.y = self.y + (dir_y * self.velocidad * dt)
        else
            -- Si entra en la zona, sigue moviéndose hacia el jugador 
            self.x = self.x + (dir_x * (self.velocidad * 0.15) * dt)
            self.y = self.y + (dir_y * (self.velocidad * 0.15) * dt)
        end
    end

    -- Actualización de la hitbox
    local margen = 4 -- caja de colisión -4 píxeles
    self.hitbox_x = (self.x - self.origen_x) + margen
    self.hitbox_y = (self.y - self.origen_y) + margen
end

function enemigo:Dibujar()
    if not self.activo then return end
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.origen_x, self.origen_y)
end