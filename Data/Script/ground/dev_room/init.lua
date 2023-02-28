require 'common'

local dev_room = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function dev_room.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_dev_room")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
end

function dev_room.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  GAME:FadeIn(20)
end

function dev_room.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function dev_room.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  UI:ChoiceMenuYesNo("Return to Base Camp?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if ch then
    GAME:FadeOut(false, 20)
    GAME:EnterZone('guildmaster_island',-1,1,0)
  end
end


function dev_room.Dev_Note_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker(false)
  UI:WaitShowDialogue("It's a note from the developer...")
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue("Thank you for playing the demo for Pokémon Mystery Dungeon: Origins.")
  UI:WaitShowDialogue("We hope you look forward to the full release,[scroll] but while you wait, there are several things you can try out in this demo!")
  
  UI:ChoiceMenuYesNo("Continue reading?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if not ch then
    return
  end
  
  UI:WaitShowDialogue("There are currently 8 dungeons available.[pause=0] Have you found them all?[scroll] Some of them can be pretty tough.[pause=0] Those are considered the ultimate dungeons even for the full game!")
  UI:WaitShowDialogue("Guildmaster Trail in particular was designed before anything else.[scroll]This was done to cover every feature intended for the full game.")
  
  UI:ResetSpeaker(false)
  UI:ChoiceMenuYesNo("Continue reading?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if not ch then
    return
  end
  
  
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue("This game has a developer mode, available for anyone to mess around with.[scroll] Run dev.bat to start the game with it enabled.[scroll]I won't judge if you cheat or datamine,[pause=0] play how you want!")
  UI:WaitShowDialogue("The entire game is moddable through the dev panel, and you can even make a standalone fangame!")
  UI:WaitShowDialogue("Another developer is using this engine already.[pause=0] Their project's called Halcyon.")
  UI:WaitShowDialogue("Want to make a mod?[pause=0] Visit https://wiki.pmdo.pmdcollab.org/Main_Page for tutorials.")
  
  UI:ResetSpeaker(false)
  UI:ChoiceMenuYesNo("Continue reading?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if not ch then
    return
  end
  
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue("By the way...[scroll] If you're playing in a non-English language, what did you think of the translation?")
  UI:WaitShowDialogue("All translations were provided by community volunteers![scroll] If you see any errors, let us know in the thread or on Discord.")
  
  UI:ResetSpeaker(false)
  UI:ChoiceMenuYesNo("Continue reading?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if not ch then
    return
  end
  
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue("This game is open-source,[pause=0] released under the MIT License.[scroll]You can fork it at https://github.com/audinowho/PMDODump[scroll] ")
  
end


function dev_room.Assembly_1_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end


function dev_room.Assembly_1_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end


function dev_room.Assembly_2_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function dev_room.Assembly_3_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function dev_room.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end


return dev_room