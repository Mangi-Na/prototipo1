ANCHO_VENTANA = 160
ALTO_VENTANA = 144
ESCALA = 4

x = 0
y = 0
img = love.graphics.newImage("assets/payaso.png")

jugador = {
    y = 0,
    x = 0,
    sprite = nil

}


enemigo_X = 100
enemigo_y = 100
enemigo_img = love.graphics.newImage("assets/rojo.png")

enemigo = {
    y = 100,
    x = 100,
    sprite = nil

}


function love.load()
    love.window.setMode(ANCHO_VENTANA * ESCALA, ALTO_VENTANA * ESCALA)
    love.graphics.setDefaultFilter("nearest","nearest")
    lienzo = love.graphics.newCanvas(ANCHO_VENTANA, ALTO_VENTANA)
    jugador.sprite = love.graphics.newImage("assets/payaso.png")
    enemigo.sprite = love.graphics.newImage("assets/rojo.png")
    
end

function love.draw()
    love.graphics.setCanvas(lienzo)
    love.graphics.draw(jugador.sprite,jugador.x, jugador.y, 0)
    love.graphics.draw(enemigo.sprite, enemigo.x, enemigo.y, 0)
    love.graphics.setCanvas()

    love.graphics.draw(lienzo,0,0,0,ESCALA,ESCALA)
    
end