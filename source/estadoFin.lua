estadoFin = Class{}

function estadoFin:init() end
function estadoFin:ingresar() end
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
    love.graphics.setColor(1,0,0)
    love.graphics.setFont(fuenteTitulo)
    love.graphics.printf('GAME OVER',0,200,ventana.ancho * ventana.escala, 'center')
    love.graphics.setFont(fuenteSubtitulo)
    love.graphics.printf('Presiona Enter para Continuar',0,264,ventana.ancho * ventana.escala, 'center')
    love.graphics.setColor(1, 1, 1, 1)
end