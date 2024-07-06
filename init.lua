local S = minetest.get_translator("atl_randomtp")

local function randomSpawnPosition()
    local x = math.random(-31000, 31000)
    local z = math.random(-31000, 31000)
    return {x = x, y = 0, z = z}
end

local function isAir(pos)
    local node = minetest.get_node(pos)
    return node.name == "air"
end

local function teleportPlayer(player, pos)
    player:set_pos(pos)
end

local function teleportToRandomSpawn(player)
    local spawnPos = randomSpawnPosition()
    teleportPlayer(player, spawnPos)
    return spawnPos
end

minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    if meta:get_string("old_player") ~= "" then
        return
    end

    teleportToRandomSpawn(player)

    local function adjustPlayerPosition()
        local playerPos = player:get_pos()

        local posAbovePlayer = {x = playerPos.x, y = playerPos.y + 1, z = playerPos.z}
        if not isAir(posAbovePlayer) then
            player:set_pos({x = playerPos.x, y = playerPos.y + 1.5, z = playerPos.z})
        else
            return true
        end
    end

    local adjusted = false

    local function globalstepFunction(dtime)
        if not adjusted then
            if adjustPlayerPosition() then
                minetest.chat_send_player(player:get_player_name(), S("-!- You have just been randomly teleported into the world."))
                adjusted = true
                meta:set_string("old_player", "true")
            end
        end
    end

    minetest.register_globalstep(globalstepFunction)
end)

minetest.register_on_respawnplayer(function(player)
    local meta = player:get_meta()
    local oldSpawnPos = meta:get_string("old_spawn_pos")

    if oldSpawnPos ~= "" then
        local pos = minetest.string_to_pos(oldSpawnPos)
        player:set_pos(pos)
    else
        local spawnPos = teleportToRandomSpawn(player)
        meta:set_string("old_spawn_pos", minetest.pos_to_string(spawnPos))
        meta:set_string("old_player", "true")
    end
end)
