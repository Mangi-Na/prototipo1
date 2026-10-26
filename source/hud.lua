HUD = Class{}

function HUD:init(mundo)
    self.texto_vida = "x3"
    self.tiempo = 15.0
    self.puntos = 0
    self.mundo = mundo

    self.combo = 0
    self.modo_furia = false

    self.imagen_corazon = love.graphics.newImage("assets/corazon.png")

    -- Suscribirse a los eventos de Combo y Furia
    Eventos.on('enemigo_golpeado', function(nuevo_combo)
        self.combo = nuevo_combo
    end)

    Eventos.on('modo_furia', function(activo)
        self.modo_furia = activo
    end)

    Eventos.on('combo_reiniciado', function()
        self.combo = 0
        self.modo_furia = false
    end)
    Eventos.on('enemigo_derrotado', function(valor)
        local puntos_base = valor or 100
        -- Si el combo es 0 o 1, multiplica por 1. Si es mayor, multiplica por el nivel del combo.
        local multiplicador = math.max(1, self.combo) 
        
        -- Si está en modo furia, ¡bonus extra!
        if self.modo_furia then
            multiplicador = multiplicador * 2 
        end

        self.puntos = self.puntos + (puntos_base * multiplicador)
    end)
end

function HUD:actualizarVidas(vidas)
   self.vidas = tonumber(vidas) or 0
end

function HUD:actualizarTiempo(tiempo)
    self.tiempo = tiempo
end

function HUD:actualizarPuntos(puntos)
    self.puntos = puntos
end

function HUD:DrawGameData()
    love.graphics.setColor(1, 1, 1, 1)
   
    --Vidas
    love.graphics.setColor(1, 0.2, 0.3, 1) -- Color rojo rosado 
    local texto_corazones = ""

    love.graphics.setColor(1, 1, 1, 1) -- Blanco para que la imagen mantenga sus colores originales
    local vidas_num = tonumber(self.vidas) or 0
    local x_inicial = 500
    local separacion = 30

    -- Dibujamos un icono de corazón por cada vida que tenga el jugador
    for i = 1, vidas_num do
        love.graphics.draw(self.imagen_corazon, x_inicial + (i - 1) * separacion, 8)
    end
    love.graphics.print("PUNTOS: " .. self.puntos, 10, 10)

    -- Tiempo
    love.graphics.print("Tiempo: " .. string.format("%.1f", math.max(0, self.tiempo)), 230, 10)

    -- Dibujar Contador de Combo
    if self.combo > 1 then
        love.graphics.setColor(1, 0.8, 0.2, 1) -- Dorado
        love.graphics.print("COMBO x" .. self.combo, 20, 40)
    end

    -- Indicador de Modo Furia
    if self.modo_furia then
        if math.floor(love.timer.getTime() * 8) % 2 == 0 then
            love.graphics.setColor(1, 0.2, 0.2, 1)
        else
            love.graphics.setColor(1, 0.5, 0, 1)
        end
        love.graphics.print("¡MODO FURIA!", 20, 60)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function HUD:Draw()
    self:DrawGameData()
end

return HUD