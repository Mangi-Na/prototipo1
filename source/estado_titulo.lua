estado_titulo = Class{__includes = maquina_estados}

function estado_titulo:init() end
function estado_titulo:ingresar() end
function estado_titulo:salir() end
function estado_titulo:actualizar(dt) end
function estado_titulo:dibujar()
    love.graphics.printf('ROGUELIKE',0,64,ventana.ancho * ventana.escala, 'center')
    love.graphics.printf('Presiona Enter',0,100,ventana.ancho * ventana.escala, 'center')
end

