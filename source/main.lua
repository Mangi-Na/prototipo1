require "dependencias"

ventana = {
    ancho = 160,
    alto = 144,
    escala = 4,
    camara_centro_x = 0,
    camara_centro_y = 0,
    mapa_ancho = 0,
    mapa_alto = 0,
}

-- Recursos globales (Audio y Lienzo)
musica = nil
sonido_derrota = nil
sonido_victoria = nil
sonido_golpe = nil
lienzo = nil
funte = nil
mapa = nil
camaraPrincipal = nil
mundo = nil

-- Función global auxiliar de colisiones
function comprobarColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return x1 < x2 + ancho2 and 
           x2 < x1 + ancho1 and  
           y1 < y2 + alto2  and
           y2 < y1 + alto1
end
function redondear(num)
    return math.floor(num + 0.5)
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)

   
    
    fuenteTitulo = love.graphics.newFont("fuentes/CordelCircoMambembe-Bold.ttf", 40)
    fuenteSubtitulo = love.graphics.newFont("fuentes/CordelCircoMambembe-Bold.ttf", 26)

    mundo = Bump.newWorld(16)
    mapa = STI("mapa/mapa.lua", { "bump" })
    mapa:bump_init(mundo)
    camaraPrincipal = Camara()

   
    if mapa.layers ["colisiones"] then
        for _, obj in ipairs(mapa.layers["colisiones"].objects) do
            obj.es_pared = true
            mundo:add(obj, obj.x, obj.y, obj.width, obj.height)
        end
    
    end  

   
    --limites de camara
    ventana.camara_centro_x = ventana.ancho * 0.5
    ventana.camara_centro_y = ventana.alto * 0.5 -- Usa 'alto' para el eje Y

    -- Acceso correcto a las propiedades de los tiles en STI
    ventana.mapa_ancho = mapa.width * mapa.tilewidth
    ventana.mapa_alto = mapa.height * mapa.tileheight
    -- Cargar Audio
    musica = love.audio.newSource("assets/musica fondo.mp3", "stream")
    musica:setLooping(true)

    sonido_derrota = love.audio.newSource("assets/derrota.mp3", "static")
    sonido_victoria = love.audio.newSource("assets/victoria.mp3", "static")
    sonido_golpe = love.audio.newSource("assets/golpe.mp3", "static")
    
    -- Inicialización de la Máquina de Estados
    maquinaEstadoGlobal = maquinaEstado({
        ['titulo'] = function() return estadoTitulo() end,
        ['jugar']  = function() return estadoJuego() end,
        ['Fin']  = function() return estadoFin() end
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