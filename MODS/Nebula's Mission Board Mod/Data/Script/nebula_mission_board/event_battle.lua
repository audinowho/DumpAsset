--- Reuse origin code
local base_game_escort_interact = BATTLE_SCRIPT.EscortInteract
function BATTLE_SCRIPT.EscortInteract(owner, ownerChar, context, args)
    if (context.Target.LuaData.JobReference) then
        MissionGen:EscortInteract(owner, ownerChar, context, args)
    else
        base_game_escort_interact(owner, ownerChar, context, args)
    end
end

function BATTLE_SCRIPT.EscortReached(owner, ownerChar, context, args)
    MissionGen:EscortReached(owner, ownerChar, context, args)
end

function BATTLE_SCRIPT.RescueReached(owner, ownerChar, context, args)
    MissionGen:RescueReached(owner, ownerChar, context, args)
end