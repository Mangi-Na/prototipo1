
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

-- Sobrescribo su Actualizar
-- Sobrescribo su Actualizar
function EnemigoErratico:Actualizar(dt, obj_jugador)
    if not self.activo then return end
    
    -- Temporizador para cambiar rumbo al azar
    self.tiempo_cambio_rumbo = self.tiempo_cambio_rumbo - dt
    if self.tiempo_cambio_rumbo <= 0 then
        self.dir_x = math.random(-1, 1)
        self.dir_y = math.random(-1, 1)
        self.tiempo_cambio_rumbo = math.random(1, 3) 
    end
    
    -- 1. Calcular la posición a la que intenta ir
    local deseado_x = self.x + (self.dir_x * self.velocidad * dt)
    local deseado_y = self.y + (self.dir_y * self.velocidad * dt)

    local deseado_hitbox_x = (deseado_x - self.origen_x) + 4
    local deseado_hitbox_y = (deseado_y - self.origen_y) + 4

    -- 2. Procesar la física con Bump
    if self.mundo then
        local filtroEnemigo = function(item, otro)
            if otro.es_pared then
                return 'slide'
            end
            return nil
        end

        -- Pedir a Bump que mueva el objeto resolviendo paredes
        local real_hitbox_x, real_hitbox_y, colisiones, len = self.mundo:move(
            self, deseado_hitbox_x, deseado_hitbox_y, filtroEnemigo
        )

        -- Si chocó con una pared, invertimos la dirección para que rebote
        for i = 1, len do
            if colisiones[i].other.es_pared then
                self.dir_x = -self.dir_x
                self.dir_y = -self.dir_y
                self.tiempo_cambio_rumbo = math.random(1, 3)
                break
            end
        end

        -- Actualizar posición real devuelta por Bump
        self.hitbox_x = real_hitbox_x
        self.hitbox_y = real_hitbox_y
        self.x = (self.hitbox_x - 4) + self.origen_x
        self.y = (self.hitbox_y - 4) + self.origen_y
    else
        self.x = deseado_x
        self.y = deseado_y
    end
end