HUD = Class{}

function HUD:init(mundo)
    self.texto_vida = "x3"
    self.tiempo = 15.0
    self.mundo = mundo
    self.depurar = false
end

function HUD:actualizarVidas(vidas)
    self.texto_vida = "x" .. (vidas or 0)
end

function HUD:actualizarTiempo(tiempo)
    self.tiempo = tiempo
end

function HUD:DrawGameData()
    love.graphics.setColor(1, 1, 1, 1) -- Color blanco normal
    
    -- Vidas
    love.graphics.print(self.texto_vida, 300, 10)
    
    -- Tiempo
    love.graphics.print("Tiempo: " .. string.format("%.1f", math.max(0, self.tiempo)), 20, 20)
end

function HUD:Draw()
    self:DrawGameData()

end
return HUD