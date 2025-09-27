-- resolve_docroot.lua
-- Script Lua simple para determinar docroot dinámico

require "apache2"

function silly_mapper(r)
    local dev_domain = os.getenv("DEV_DOMAIN") 
    local host = r.hostname
    local docroot = "/home/devuser/public_html"
    
    -- Debug inicial
    r:err(string.format("DEBUG LUA: Processing hostname: %s", host))
    r:err(string.format("DEBUG LUA: DEV_DOMAIN: %s", dev_domain or "NOT_SET"))
    
    -- Si DEV_DOMAIN no está configurada, salir
    if not dev_domain then
        r:err("ERROR: DEV_DOMAIN environment variable not set")
        return apache2.DECLINED
    end
    
    local path_only = nil
    
    -- Primero intentar capturar con sufijo PHP (-p[numero])
    path_only = host:match("^(.*)%-%-p[0-9][0-9]%." .. dev_domain:gsub("%.", "%%.") .. "$")
    
    if not path_only then
        -- Si no tiene sufijo PHP, capturar el subdominio completo
        path_only = host:match("^(.*)%." .. dev_domain:gsub("%.", "%%.") .. "$")
    end
    
    r:err(string.format("DEBUG LUA: path_only extracted: %s", path_only or "nil"))
    
    if path_only and path_only ~= "" then
        -- Manejar la lógica de reemplazo
        local final_path = path_only
        
        r:err(string.format("DEBUG LUA: Before replacement: %s", final_path))
        
        -- Reemplazar -- con /
        final_path = final_path:gsub("%-%-", "/")
        r:err(string.format("DEBUG LUA: After -- replacement: %s", final_path))
        
        -- Reemplazar . con / (pero solo los puntos del subdominio, no del dominio)
        final_path = final_path:gsub("%.", "/")
        r:err(string.format("DEBUG LUA: After . replacement: %s", final_path))
        
        -- Construir la ruta final
        docroot = docroot .. "/" .. final_path
        r:err(string.format("DEBUG LUA: Final docroot: %s", docroot))
        
        -- Opcional: Verificar si el directorio existe
        local file = io.open(docroot, "r")
        if file then
            file:close()
            r:err(string.format("DEBUG LUA: Directory exists: %s", docroot))
        else
            r:err(string.format("DEBUG LUA: Directory may not exist: %s", docroot))
            -- Podrías decidir usar el docroot base aquí si quieres
            -- docroot = "/home/devuser/public_html"
        end
    else
        r:info("DEBUG LUA: No path_only found, using base docroot")
    end
    
    -- Debug info
    r:err(string.format("DEBUG LUA: hostname: %s", r.hostname))
    r:err(string.format("DEBUG LUA: uri: %s", r.uri))
    r:err(string.format("DEBUG LUA: original document_root: %s", r.document_root))
    
    -- Establecer el nuevo document root
    r:set_document_root(docroot)
    r:err(string.format("DEBUG LUA: new document_root: %s", r.document_root))
    
    return apache2.DECLINED
end