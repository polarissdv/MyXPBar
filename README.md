
DESCRIPTION
-----------
MyXPBar is a lightweight, standalone World of Warcraft addon 
designed specifically for Project Ascension (Client 3.3.5a).

It replicates the clean, modern look of popular WeakAuras but 
runs as a dedicated addon for better performance. It features 
a minimalist purple design with a "mobs-to-level" estimation.

FEATURES
--------
[+] Clean Visuals: 
    Minimalist Purple XP bar with a Blue overlay for Rested XP.

[+] Mobs-to-Level Estimation: 
    Automatically calculates how many kills are needed to level 
    up based on your last XP gain.

[+] Audio Feedback: 
    Plays a subtle sound effect every time you gain XP.

[+] Smart Hiding: 
    Automatically hides the bar when you reach Level 60 
    (Configurable in the Lua file).

[+] Detailed Stats: 
    - Current / Max XP.
    - Current Percentage.
    - Rested XP Percentage.

[+] Draggable: 
    Hold SHIFT + Left Click to move the bar anywhere.

INSTALLATION
------------
1. Download the repository.
2. Extract the folder into your WoW directory:
   \Ascension Launcher\resources\client\Interface\AddOns
3. Ensure the folder is named "MyXPBar".
   (It should look like: ...\AddOns\MyXPBar\MyXPBar.lua)
4. Launch the game.

CONTROLS
--------
To move the bar: 
Hold SHIFT and Left-Click drag the bar to your desired position.

CONFIGURATION
-------------
The addon is "Plug and Play". However, you can tweak settings 
by opening "MyXPBar.lua" with any text editor (Notepad, VS Code).

Look for the configuration section at the top of the file:

  local WIDTH = 500       -- Width of the bar
  local HEIGHT = 24       -- Height of the bar
  local MAX_LEVEL = 60    -- Level at which the bar disappears

COMPATIBILITY
-------------
- Client: World of Warcraft 3.3.5a (WotLK)
- Server: Designed for Project Ascension, but works on any 3.3.5a server.

============================================================
Author: [Polarz]
Version: 1.0
============================================================
