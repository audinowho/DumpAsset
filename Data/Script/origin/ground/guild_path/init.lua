require 'origin.common'

local guild_path = {}

-- Tables for the junctions on this map
guild_path.junction = {}

guild_path.junction.east = {
  dungeons = {},
  groundmaps={{Flag=true,Zone="guildmaster_island", ID=1, Entry=2}}
}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function guild_path.Init(map)
DEBUG.EnableDbgCoro() --Enable debugging this coroutine
PrintInfo("=>> Init_guild_path")

GROUND:RefreshPlayer()
end

function guild_path.Enter(map)
DEBUG.EnableDbgCoro() --Enable debugging this coroutine

GAME:FadeIn(20)
end

function guild_path.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function guild_path.East_Exit_Touch(obj, activator)
DEBUG.EnableDbgCoro() --Enable debugging this coroutine

if((#guild_path.junction.east.dungeons == 0) and (#guild_path.junction.east.groundmaps == 1)) then
  GAME:FadeOut(false, 20)
  GAME:EnterGroundMap("base_camp", "entrance_west")
  else
    COMMON.ShowDestinationMenu(guild_path.junction.east.dungeons, guild_path.junction.east.groundmaps)
    end
    end

    function guild_path.Hut_Entrance_Touch(obj, activator)
    DEBUG.EnableDbgCoro() --Enable debugging this coroutine
    GAME:FadeOut(false, 20)
    GAME:EnterGroundMap("guild_hut", "entrance_south")
    end

    return guild_path
