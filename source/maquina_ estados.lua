maquina_estado = Class{}

function maquina_estado:init(estados)
    self.base = { dibujar = function () end,
                  actualizar = function () end,
                  ingresar = function () end,
                  salir = function () end

    }
    self.estados = estados or{}
    self.actual = self.base

end
function maquina_estado:cambiar(nombreEstado. parametrosIniciles)
    assert(self.estados[nombreEstado])
    self.actual:salir()
    self.actual = self.estados [nombreEstado]()
     self.actual:ingresar(parametrosIniciles)
end

function maquina_estado:actualizar(dt)
    self.actual:actualizar(dt)
end
function maquina_estado:dibujar()
    self.actual:dibujar()
end

