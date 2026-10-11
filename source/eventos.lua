Eventos = {
    _oyentes = {}
}
--suscribir 
function Eventos.on (nombre_evento, callback)
    if not Eventos._oyentes[nombre_evento] then
        Eventos._oyentes [nombre_evento] = {}
        
    end
    table.insert(Eventos._oyentes[nombre_evento], callback)
end
-- Remover un callback específico
function Eventos.off(nombre_evento, callback)
    local lista = Eventos._oyentes[nombre_evento]
    if lista then
        for i = #lista, 1, -1 do
            if lista[i] == callback then
                table.remove(lista, i)
                break
            end
        end
    end
end
-- Limpiar todos los eventos 
function Eventos.limpiar()
    Eventos._oyentes = {}
end
--trigger
function Eventos.emitir (nombre_evento, ...)
    local lista = Eventos._oyentes[nombre_evento]
    if lista then
        for _, callback in ipairs(lista) do
            callback(...)
            
        end
        
    end
    
end