require "dependencias"

ventana = {
    ancho = 160,
    alto = 144,
    escala = 4
}

-- Estados del juego
atrapado = false
victoria = false
tiempo_supervivencia = 15.0 
musica = nil
sonido_derrota = nil
sonido_victoria = nil
sonido_golpe = nil
audio_final_reproducido = false
maquina_estados = nil


-- Entidades del juego
jugador_obj = nil
lista_enemigos = {}

function comprobarColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return x1 < x2 + ancho2 and 
           x2 < x1 + ancho1 and  
           y1 < y2 + alto2  and
           y2 < y1 + alto1
end

function reiniciarJuego()
    atrapado = false
    victoria = false
    tiempo_supervivencia = 15.0
    audio_final_reproducido = false

    love.audio.stop(sonido_derrota)
    love.audio.stop(sonido_victoria)
    musica:play()
    
    -- Instanciación de Objetos con class
    jugador_obj = Jugador(ventana.ancho / 2, ventana.alto / 2)
    
    -- Creación de la lista de enemigos utilizando polimorfismo
    lista_enemigos = {
        Enemigo(100, 100, 30, "assets/rojo.png"), -- Enemigo base
        EnemigoErratico(20, 120),             -- Variante errática (verde)
        EnemigoRapido(130, 40)            -- Variante rápida (azul)
        }

end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    
    musica = love.audio.newSource("assets/musica fondo.mp3", "stream")
    musica:setLooping(true)
    love.audio.play(musica)

    sonido_derrota = love.audio.newSource("assets/derrota.mp3", "static")
    sonido_victoria = love.audio.newSource("assets/victoria.mp3", "static")
    sonido_golpe = love.audio.newSource("assets/golpe.mp3", "static")
    --maquina_estados = Estado_juego()
    maquina_estados = estado_titulo()
    reiniciarJuego()
end

function love.update(dt)
    maquina_estados:actualizar(dt)
   
end

function love.draw()
    maquina_estados:dibujar()

end