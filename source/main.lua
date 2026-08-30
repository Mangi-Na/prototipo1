require "jugador"
require "enemigo"

ventana = {
    ancho = 160,
    alto = 144,
    escala = 4
}

atrapado = false

function comprobarColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return x1 < x2 + ancho2 and 
           x2 < x1 + ancho1 and  
           y1 < y2 + alto2  and
           y2 < y1 + alto1
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest","nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    jugador.Crear(ventana.ancho/2, ventana.alto/2)
    enemigo.Crear() 
end

function love.update(dt)
    if love.keyboard.isDown("right") then
        jugador.x = jugador.x + (jugador.velocidad * dt)
    elseif love.keyboard.isDown("left") then
        jugador.x = jugador.x - (jugador.velocidad * dt)
    elseif love.keyboard.isDown("down") then
        jugador.y = jugador.y + (jugador.velocidad * dt)
    elseif love.keyboard.isDown("up") then
        jugador.y = jugador.y - (jugador.velocidad * dt)
    end
    
    --persecucion

    local dist_x = math.abs(enemigo.x - jugador.x)
    local dist_y = math.abs(enemigo.y - jugador.y)
    
    if dist_x > dist_y then
       if dist_x > jugador.ancho then
          if enemigo.x < jugador.x then
              enemigo.x = enemigo.x + (enemigo.velocidad * dt)
              elseif enemigo.x > jugador.x then
              enemigo.x = enemigo.x - (enemigo.velocidad * dt)
          end
      end
        
      if dist_y > jugador.alto then
           if enemigo.y < jugador.y then
             enemigo.y = enemigo.y + (enemigo.velocidad * dt)
             elseif enemigo.y > jugador.y then
             enemigo.y = enemigo.y - (enemigo.velocidad * dt)
          end
        end   
    end

    -- Calcular hitboxes
    jugador.hitbox_x = jugador.x - jugador.origen_x
    jugador.hitbox_y = jugador.y - jugador.origen_y
    enemigo.hitbox_x = enemigo.x - enemigo.origen_x
    enemigo.hitbox_y = enemigo.y - enemigo.origen_y

    -- Verificar colision AABB
    atrapado = comprobarColision(
        jugador.hitbox_x,
        jugador.hitbox_y,
        jugador.ancho,
        jugador.alto,
        enemigo.hitbox_x,
        enemigo.hitbox_y,
        enemigo.ancho,
        enemigo.alto
    )
    
end



function love.draw()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    love.graphics.draw(jugador.sprite,jugador.x, jugador.y, 0,1,1,jugador.origen_x, jugador.origen_y)
    love.graphics.draw(enemigo.sprite, enemigo.x, enemigo.y, 0,1,1,enemigo.origen_x, enemigo.origen_y)
    love.graphics.setCanvas()

    love.graphics.draw(lienzo,0,0,0,ventana.escala,ventana.escala)

    if atrapado then
        love.graphics.print("ATRAPADO",100,10)        
    end
    
end