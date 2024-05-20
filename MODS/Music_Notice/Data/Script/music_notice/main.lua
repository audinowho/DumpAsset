--[[
  main.lua
  
  This file is loaded persistently.
  Its main purpose is to include anything that needs to stay persistently in the lua state.
  Things like services.
]]--

--------------------------------------------------------------------------------------------------------------
-- Service Packages
--------------------------------------------------------------------------------------------------------------
require 'music_notice.services.music_service'

math.randomseed(os.time())