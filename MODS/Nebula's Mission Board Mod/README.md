# Nebula's Mission Board Mod
This mod adds a mission board to the base PMDO game, allowing players to embark in missions to gain special items and money and to gain experience.

Baked in this mod is a job generation library that can be easily extracted and included in other mods, with credits to MistressNebula.

### How to import
Take the missiongen_lib folder and move it inside your mod's Script folder. Use ``require("missiongen_lib.missiongen_lib")`` to store the library in
a global variable, and then write the name of that variable inside the missiongen_service.lua file, in the library_name variable situated at the top
of the file. Remember to also add ```require "missiongen_lib.missiongen_service"``` in your mod's main.lua file.

You will then need to hook all the library's necessary events to your mod. To do that it would be best to look at this mod's code for reference.

### How to customize
The missiongen_settings.lua file contains a table of settings that are used by the library to define its behavior. Every setting is documented individually,
describing its format, what it is used for and what kind of data it requires.

If you need more info, please look at the [library's page](https://wiki.pmdo.pmdcollab.org/Mod:Nebula%27s_Mission_Board) in PMDOWiki.
Feel free to leave issues on GitHub if you want to request some more specific guides that are not listed in the linked page yet!
