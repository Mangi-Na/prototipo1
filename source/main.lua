ANCHO_VENTANA = 160
ALTO_VENTANA = 144
ESCALA = 4

x = 0
y = 0
img = love.graphics.newImage("assets/payaso.png")


enemigo_X = 100
enemigo_y = 100
enemigo_img = love.graphics.newImage("assets/rojo.png")

function love.load()
    love.window.setMode(ANCHO_VENTANA * ESCALA, ALTO_VENTANA * ESCALA)
    love.graphics.setDefaultFilter("nearest","nearest")
    lienzo = love.graphics.newCanvas(ANCHO_VENTANA, ALTO_VENTANA)
    
end

function love.draw()
    love.graphics.setCanvas(lienzo)
    love.graphics.draw(img,x,y)
    love.graphics.draw(enemigo_img, enemigo_X, enemigo_y, 0)
    love.graphics.setCanvas()

    love.graphics.draw(lienzo,0,0,0,ESCALA,ESCALA)
    
end