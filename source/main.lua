require "dependencias"

ventana = {
    ancho = 160,
    alto = 144,
    escala = 4
}

-- Recursos globales (Audio y Lienzo)
musica = nil
sonido_derrota = nil
sonido_victoria = nil
sonido_golpe = nil
lienzo = nil

-- Función global auxiliar de colisiones
function comprobarColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return x1 < x2 + ancho2 and 
           x2 < x1 + ancho1 and  
           y1 < y2 + alto2  and
           y2 < y1 + alto1
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    
    -- Cargar Audio
    musica = love.audio.newSource("assets/musica fondo.mp3", "stream")
    musica:setLooping(true)

    sonido_derrota = love.audio.newSource("assets/derrota.mp3", "static")
    sonido_victoria = love.audio.newSource("assets/victoria.mp3", "static")
    sonido_golpe = love.audio.newSource("assets/golpe.mp3", "static")
    
    -- Inicialización de la Máquina de Estados
    maquinaEstadoGlobal = maquinaEstado({
        ['titulo'] = function() return estadoTitulo() end,
        ['jugar']  = function() return estadoJuego() end
    })
    
    -- Iniciar en la pantalla de título
    maquinaEstadoGlobal:cambiar('titulo')
end

function love.update(dt)
    maquinaEstadoGlobal:actualizar(dt)
end

function love.draw()
    maquinaEstadoGlobal:dibujar()
end