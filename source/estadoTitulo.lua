estadoTitulo = Class{}

function estadoTitulo:init() end
function estadoTitulo:ingresar() end
function estadoTitulo:salir() end
function estadoTitulo:actualizar(dt)
    function estadoTitulo:actualizar(dt)
    if love.keyboard.isDown("return") or love.keyboard.isDown("space") then
        -- AQUÍ CAMBIAS DE TÍTULO A JUEGO
        maquinaEstadoGlobal:cambiar('jugar')
    end
end
end
function estadoTitulo:dibujar()
    love.graphics.printf('ROGUELIKE',0,64,ventana.ancho * ventana.escala, 'center')
    love.graphics.printf('Presiona Enter',0,100,ventana.ancho * ventana.escala, 'center')
end

