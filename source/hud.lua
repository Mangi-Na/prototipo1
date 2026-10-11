HUD = Class{}

function HUD:init(mundo)
    self.texto_vida = "x3"
    self.tiempo = 15.0
    self.mundo = mundo

    self.combo = 0
    self.modo_furia = false

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
end

function HUD:actualizarVidas(vidas)
    self.texto_vida = "x" .. (vidas or 0)
end

function HUD:actualizarTiempo(tiempo)
    self.tiempo = tiempo
end

function HUD:DrawGameData()
    love.graphics.setColor(1, 1, 1, 1)

    -- Vidas y Tiempo
    love.graphics.print(self.texto_vida, 300, 10)
    love.graphics.print("Tiempo: " .. string.format("%.1f", math.max(0, self.tiempo)), 20, 20)

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