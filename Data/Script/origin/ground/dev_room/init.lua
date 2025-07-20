require 'origin.common'

local dev_room = {}

--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function dev_room.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_dev_room")

end

function dev_room.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  GAME:UnlockDungeon('tropical_path')
  SV.base_camp.ExpositionComplete = true
  SV.base_camp.FirstTalkComplete = true
  if not SV.test_grounds.DemoComplete then
    GROUND:Hide("Dev_Note_2")
  end
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
  UI:WaitShowDialogue("I hope you look forward to the full release,[scroll] but while you wait, there are several things you can try out in this demo!")
  
  UI:ResetSpeaker(false)
  UI:ChoiceMenuYesNo("Continue reading?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if not ch then
    return
  end
  
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue("There are currently 16 dungeons available![pause=0] Have you found them all?")
  UI:WaitShowDialogue("Some of them are only accessible through secret stairs...")
  UI:WaitShowDialogue("Don't feel pressured to beat them all, though.[scroll]Some of them are meant to be the ultimate dungeons of the full game!")
  
  UI:ResetSpeaker(false)
  UI:ChoiceMenuYesNo("Continue reading?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if not ch then
    return
  end
  
  
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue("This game has a developer mode, available for anyone to mess around with.[scroll] Run dev.bat to start the game with it enabled.[pause=0] I won't judge if you cheat or datamine,[pause=0] play how you want!")
  
  UI:ResetSpeaker(false)
  UI:ChoiceMenuYesNo("Continue reading?", false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if not ch then
    return
  end
  
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue("You can use the dev panel to mod any aspect of the game,[pause=0] even make an entirely new fangame if you go far enough!")
  UI:WaitShowDialogue("Another developer is using this engine already.[pause=0] Their project is called Halcyon.")
  UI:WaitShowDialogue("Want to try it yourself?[pause=0] Visit https://wiki.pmdo.pmdcollab.org/Main_Page for tutorials.")
  
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
  UI:WaitShowDialogue("This game is open-source,[pause=0] released under the MIT License. You can fork it at https://github.com/audinowho/PMDODump")
  UI:WaitShowDialogue("I started this project out of a desire for there to be more PMD fangames.[scroll]This is a contribution to the community,[pause=0] and to those within it that share the same desire.")
  
end

function dev_room.Dev_Note_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:ResetSpeaker(true)
  UI:WaitShowDialogue(STRINGS:Format("To the player,[scroll]If you are reading this note,[pause=0] then congratulations on clearing all 30 floors of Guildmaster Trail!"))
  UI:WaitShowDialogue("I hope it provided an exciting challenge for you,[pause=0] one that fully explored the potential of roguelike PMD.")
  UI:WaitShowDialogue("This game was originally going to feature just Guildmaster Trail itself.[scroll]I wanted it to condense every mechanic within a single dungeon,[pause=0] like Shiren.")
  UI:WaitShowDialogue("Since then the project has grown to include editors,[pause=30] cutscene scripting,[pause=30] and modding support.")
  UI:WaitShowDialogue("All of that will be leveraged to complete a main story campaign,[pause=0] reminiscient of the Sky Peak arc.")
  UI:WaitShowDialogue("When that is complete,[pause=30] this room will disappear...[scroll] and you will see the finale on the summit as originally intended.")
  
  
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