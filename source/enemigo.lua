Enemigo = Class{}

function Enemigo:init(x, y, velocidad, ruta)
    self.x = x
    self.y = y
    self.velocidad = velocidad
    self.sprite = love.graphics.newImage(ruta)
    self.activo = true
    
    self.ancho = self.sprite:getWidth() 
    self.alto = self.sprite:getHeight()
    self.origen_x = self.ancho / 2  
    self.origen_y = self.alto / 2
    self.ancho_hitbox = self.ancho - 8
    self.alto_hitbox = self.alto - 8
end

function Enemigo:Actualizar(dt, obj_jugador)
    if not self.activo then return end

    local dx = obj_jugador.x - self.x
    local dy = obj_jugador.y - self.y
    local distancia = math.sqrt(dx * dx + dy * dy)

    if distancia > 0 then
        local dir_x = dx / distancia
        local dir_y = dy / distancia

        if distancia > 40 then
            self.x = self.x + (dir_x * self.velocidad * dt)
            self.y = self.y + (dir_y * self.velocidad * dt)
        else
            self.x = self.x + (dir_x * (self.velocidad * 0.15) * dt)
            self.y = self.y + (dir_y * (self.velocidad * 0.15) * dt)
        end
    end

    self.hitbox_x = (self.x - self.origen_x) + 4
    self.hitbox_y = (self.y - self.origen_y) + 4
end

function Enemigo:Dibujar()
    if not self.activo then return end
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.origen_x, self.origen_y)
end

function Enemigo:RecibirGolpe(ancho_ventana, alto_ventana)
    self.x = math.random(10, ancho_ventana - 10)
    self.y = math.random(10, alto_ventana - 10)
end