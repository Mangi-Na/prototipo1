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
    love.graphics.printf('GAME OVER',0,64,ventana.ancho * ventana.escala, 'center')
    love.graphics.printf('Presiona Enter para Continuar',0,100,ventana.ancho * ventana.escala, 'center')
end