local util_JSONToTable = util.JSONToTable
local http_Fetch = http.Fetch
local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume

local function GetCountry( co, ip )
    http_Fetch('https://api.country.is/' .. ip, function(body, _, _, code)

        if code != 200 then 
            print('[SCOREBOARD-API-ERROR] ' .. body)
            co = nil
            return
        end
    
        local result = util_JSONToTable(body)
        coroutine_resume(co, result[country])
        
    end, function(err) 
        print('[SCOREBOARD-API-ERROR] ' .. err) 
        co = nil 
    end, {})
    
end

hook.Add( 'PlayerInitialSpawn', '!!scoreboard_country_checker', function(ply)

    coroutine_create(function(ply)
        ply:SetNW2String('scoreboard_country', '')
    end)

    local ip = ply:IPAddress()
    GetCountry(co, ip)

end )