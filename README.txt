Pokémon Mystery Dungeon: Origins

[CONTROLS - can be remapped]:

[ARROW KEYS] to move
[X] to confirm, or attack
[Z] to cancel
[ESC] to open the menu
[BACKSPACE] to toggle the minimap

Hold [A] and press [S/D/Z/X] to perform a move.
Hold [D] to move only diagonally
Hold [S] to show the grid and turn around
[Z+Arrow Keys] to run
[Z+X] to pass your turn

[1/2/3/4] to switch team leaders.
[C] to toggle Team Mode, which allows direct control of all party members' turns.

[TAB] for hotkey to open the message log.
[Q] for hotkey to open moves menu.
[W] for hotkey to open item menu.
[E] for hotkey to open tactics menu.
[R] for hotkey to open team menu.

Press [S] while viewing your Inventory to sort your items.

[F11] to mute/unmute the music.
[F1] to show FPS counter. and Build data

[TROUBLESHOOTING - for if the game fails to work]
If you're on Windows, and the game is unable to load certain DLLs, you may need to install Microsoft Visual C++ 2010 Redistributable Package (x86).
This most commonly occurs on newly installed computers.  You can find an installer at:
https://www.microsoft.com/en-us/download/details.aspx?id=5555
https://www.microsoft.com/en-us/download/details.aspx?id=52685

If you're on Windows, and the audio has a strange crunching sound, you will need the game to run with a different audio driver, most likely wasapi.  You can do this by running the game with "-audiodriver:wasapi" as a command line argument.

If you're on Mac, and encounter an error where it is unable to load DLL "libgdiplus", then you may need to install GDI+ using brew:
brew install mono-libgdiplus

If the game worked for you before but suddenly it won't start up, it is likely that the extraction directories are corrupted.  Please delete the specified files:
Windows: %TEMP%\.net
Unix:
  ${TMPDIR}/.net/${UID} if ${TMPDIR} is set; otherwise,
  /var/tmp/.net/${UID} if /var/tmp exists, and is writable; otherwise,
  /tmp/.net/${UID} if /tmp exists, and is writable; otherwise fail.

Editors Only: On linux distributions, opening up the Ground Editor may result in repeated errors that reference a "libgdiplus" not found. You will need to install libgdiplus.
Ubuntu/Debian: sudo apt-get install libgdiplus
CentOS: sudo yum install libgdiplus



[PLAYER TIPS - for if you want to win]
-When you go up a floor, there is no turning back.
-You will only gain EXP from defeating a Pokémon if you used a move or item on it.
-Recruit Pokémon by throwing Apricorns. Weakening the target can increase your chances of success, but statusing it WILL NOT.
-Wild Pokémon always start with 1/2 of their max PP and 50% fullness.
-There is ALWAYS a Plain Apricorn somewhere on the first floor of guildmaster trail.
-All Pokémon types, abilities, and movesets are up to date in accordance with Pokémon Omega Ruby and Alpha Sapphire.  Anything introduced later uses the set of the earliest generation it was introduced in.
-The statistics and effects of moves, items, abilities, and status conditions are tweaked can can be SIGNIFICANTLY DIFFERENT from how they are in main series Pokémon titles, and even Pokémon Mystery Dungeon titles.
-You can never miss twice in a row.  Thus if you miss an attack, you can be certain that the next one will hit.  The only exceptions are moves, abilities, etc. that allow 100% avoidance.
-Sticky items cannot be USED.  However, they can be HELD and still continue to give their held-item effects. You can't take off a sticky item if you've held it.
-Any wild Pokémon that faints will drop its item.
-Press Alt in text input to change the accent of the last letter you typed (ex. "e" becomes "é")
-Many traps (including Wonder Tiles) affect all tiles adjacent to them.  Keep this in mind when positioning.
-Pokémon that evolve by friendship need to have a certain number of evolved allies with them.
-Pokémon that evolve by location or regional variants need to be in the correct environment.
-If you throw held items at an enemy, they will catch it if they aren't holding one already.

[SERVER HOSTING TIPS - help other people trade/rescue]
To deploy the server on a windows machine, simply run the executable.
To deploy the server on a linux machine:
./WaypointServer > /dev/null 2>&1 & disown



[TESTER TIPS - for if you want to help]
*To help report a bug, zip up YOUR ENTIRE LOGS FOLDER to allow for easier debugging!


[CREDITS AND ATTRIBUTIONS - for the indespensible contributors]
For modifications of this software, these attributions are not to be removed.
https://github.com/PsyCommando PsyCommando, for code contributions and PMD insight
https://github.com/AntyMew AntyMew, for code contributions and platform compatibility insight
https://github.com/purpasmart96 Rev, for code contributions
https://github.com/fa6ex Rings, for code contributions
https://github.com/Buwwet Buwwet, for code contributions
https://github.com/DoubleTrio Trio~, for code contributions
Discord:touhou_project TouhouProject, for code contributions 
Alexander Groeger, for code contributions 
https://twitter.com/_palika_ Palika, for script contributions
https://github.com/Parakoopa Parakoopa, for tiles dtef parsing
Discord:mistressnebula MistressNebula, for code contributions and item design
https://github.com/Deeshura Deeshura, for item design
Discord:shitpost_sunkern Shitpost Sunkern, for item design
https://twitter.com/EthanLac13 FlowerSnek, for item design
http://musicalcombusken.deviantart.com/ MusicalCombusken, for the title logo
https://www.reddit.com/user/SilverDeoxys563 SilverDeoxys563, for various Trap graphics
http://fable-amare.deviantart.com/ Fable, for custom portraits
http://poyo-journal.tumblr.com/ Lurils, for custom map edits
https://twitter.com/RaoKurai Rao Kurai, for custom sprites, music
https://soundcloud.com/skelothan Skelothan, for custom music
Chi, Lovi, Zefa, Reppamon, and 3 Anonymous, for custom sprites and portraits


Translation:
[DE] https://twitter.com/dsgamer93 DSgamer93
[DE] https://twitter.com/LarsPreston Lars Preston
[DE] https://twitter.com/Scout_1942 Scout
[DE] https://www.reddit.com/user/P1ka-/ P1ka
[DE] https://athaleprime.wixsite.com/athaleprimegames AthalePrime
[DE] https://twitter.com/NanashiRikai Mario Brand
[DE] Discord:komischertypus KomischerTypus
[ES] Discord:glaiver. Glaiver
[ES] https://twitter.com/lagpu1 lagpu1
[ES] https://www.reddit.com/u/thedask Dask
[ES] https://discord.gg/PokemonRP Vioshim
[FR] https://www.vg-resource.com/user-25643.html Van-Tazen
[FR] https://www.twitter.com/Kuramarts Kurama
[FR] https://www.twitter.com/Vladcik Aligatueur
[FR] Tabarnak
[FR] Buxrart
[FR] Alicia
[FR] Blackun
[FR] Discord:youka0 Youka
[FR] Discord:veemaru Mathieu "Maru" V
[IT] Discord:digital_hazard Digital Hazard
[IT] Discord:saiphdeer Saiph
[JA] https://www.pixiv.net/users/75745630 ｷﾇ
[KO] https://www.reddit.com/user/Bashful_Barry/ Barry
[PT] https://twitter.com/SquishyTheMew Squishy
[ZH] Discord:lazychehra Chehra
[ZH] https://twitter.com/Dewpoleon Dew
[ZH] kaitensekai@qq.com 域外創音(IkigaiSouon)
[ZH] https://sites.google.com/view/daniel-lee-site/home PikaNiko
[ZH] Rockdu
And 1 Anonymous

http://www.spike-chunsoft.co.jp/ Chunsoft, for the Pokémon Mystery Dungeon Red, Blue, Time, Darkness, and Sky resources
http://www.creatures.co.jp/ Creatures inc, for the Pokémon Ranger: Guardian Signs resources
http://www.nintendo.com/ Nintendo, Creatures inc, http://www.gamefreak.co.jp/ GAME FREAK inc, for Pokémon, and the Pokémon RSE/DP resources
http://pokeapi.co/ used for database import
http://www.falcom.co.jp/ Falcom, for the Zwei!! resources
Kevin Penkin, for the Made in Abyss track


See Licenses for more details
View sprite_credits.txt for full sprite and portrait credits.