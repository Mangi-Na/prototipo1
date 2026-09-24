
-- ENEMIGO RÁPIDO (Hereda de Enemigo)
EnemigoRapido = Class{__includes = Enemigo}

function EnemigoRapido:init(x, y, mundo)
    -- Llama al init 
    Enemigo.init(self, x, y, 60, "assets/azul.png", mundo)
end

-- ENEMIGO ERRÁTICO (Hereda de Enemigo)
EnemigoErratico = Class{__includes = Enemigo}

function EnemigoErratico:init(x, y, mundo)
    Enemigo.init(self, x, y, 45, "assets/verde.png", mundo)
    self.tiempo_cambio_rumbo = 0
    self.dir_x = 0
    self.dir_y = 0
end

-- Sobrescribimos su Actualizar
function EnemigoErratico:Actualizar(dt, obj_jugador)
    if not self.activo or not obj_jugador then return end
    
    self.tiempo_cambio_rumbo = self.tiempo_cambio_rumbo - dt
    if self.tiempo_cambio_rumbo <= 0 then
        self.dir_x = math.random(-1, 1)
        self.dir_y = math.random(-1, 1)
        self.tiempo_cambio_rumbo = math.random(1, 3) 
    end
    
    self.x = self.x + (self.dir_x * self.velocidad * dt)
    self.y = self.y + (self.dir_y * self.velocidad * dt)

    -- Límites de pantalla 
    -- Si toca un borde
    if self.x < 0 then
        self.x = 0
        self.dir_x = 1 -- Rebota a la derecha
    elseif self.x > ventana.ancho then
        self.x = ventana.ancho
        self.dir_x = -1 -- Rebota a la izquierda
    end
    
    if self.y < 0 then
        self.y = 0
        self.dir_y = 1 -- Rebota hacia abajo
    elseif self.y > ventana.alto then
        self.y = ventana.alto
        self.dir_y = -1 -- Rebota hacia arriba
    end
    
    Enemigo.Actualizar(self,x,y,dt, obj_jugador)
end