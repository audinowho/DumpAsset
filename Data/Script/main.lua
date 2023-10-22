--[[
  main.lua
  
  This file is loaded persistently.
  Its main purpose is to include anything that needs to stay persistently in the lua state.
  Things like services.
  If this file is modded, additional requires are added ON TOP of the base's requires.
  This is the only file with this behavior; everything else is overwrite!
]]--

--------------------------------------------------------------------------------------------------------------
-- Service Packages
--------------------------------------------------------------------------------------------------------------
require 'services.chatter'
require 'services.debug_tools'
require 'services.upgrade_tools'
--require 'services.example_service' --Uncommment to try out the ExampleService

math.randomseed(os.time())