maquinaEstado = Class{}

function maquinaEstado:init(estados)
    self.base = { dibujar = function () end,
                  actualizar = function () end,
                  ingresar = function () end,
                  salir = function () end

    }
    self.estados = estados or{}
    self.actual = self.base

end
function maquinaEstado:cambiar(nombreEstado, parametrosIniciles)
    assert(self.estados[nombreEstado])
    self.actual:salir()
    self.actual = self.estados [nombreEstado]()
     self.actual:ingresar(parametrosIniciles)
end

function maquinaEstado:actualizar(dt)
    self.actual:actualizar(dt)
end
function maquinaEstado:dibujar()
    self.actual:dibujar()
end

