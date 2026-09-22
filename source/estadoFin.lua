estadoFin = Class{}

function estadoFin:init() end

function estadoFin:ingresar(params)
    -- si fue victoria o derrota (si no recibe nada, asume false/derrota)
    self.victoria = params and params.victoria or false
end

function estadoFin:salir() end

function estadoFin:actualizar(dt)
    -- Presionar R o Enter para volver a jugar
    if love.keyboard.isDown("r") or love.keyboard.isDown("return") then
        maquinaEstadoGlobal:cambiar('jugar')
    -- Presionar ESC para ir al menú principal
    elseif love.keyboard.isDown("escape") then
        maquinaEstadoGlobal:cambiar('titulo')
    end
end

function estadoFin:dibujar()
    if self.victoria then
        -- Mensaje de Victoria (Verde)
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(fuenteTitulo)
        love.graphics.printf('¡VICTORIA!', 0, 200, ventana.ancho * ventana.escala, 'center')
    else
        -- Mensaje de Game Over (Rojo)
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(fuenteTitulo)
        love.graphics.printf('GAME OVER', 0, 200, ventana.ancho * ventana.escala, 'center')
    end

    -- Subtítulo común
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fuenteSubtitulo)
    love.graphics.printf('Presiona Enter para Continuar', 0, 264, ventana.ancho * ventana.escala, 'center')
    love.graphics.setColor(1, 1, 1, 1)
end