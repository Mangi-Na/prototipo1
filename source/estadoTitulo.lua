estadoTitulo = Class{}

function estadoTitulo:init() end
function estadoTitulo:ingresar() end
function estadoTitulo:salir() end
function estadoTitulo:actualizar(dt)
    function estadoTitulo:actualizar(dt)
    if love.keyboard.isDown("return") or love.keyboard.isDown("space") then
        -- CAMBIA DE TÍTULO A JUEGO
        maquinaEstadoGlobal:cambiar('jugar')
    end
end
end
function estadoTitulo:dibujar()
    love.graphics.setFont(fuenteTitulo)
    love.graphics.setColor(0,1,0)
    love.graphics.printf('ROGUELIKE',0,200,ventana.ancho * ventana.escala, 'center')
    love.graphics.setColor(0,1,1)
    love.graphics.setFont(fuenteSubtitulo)
    love.graphics.printf('Presiona Enter',0,264,ventana.ancho * ventana.escala, 'center')
    love.graphics.setColor(1, 1, 1, 1)
end

