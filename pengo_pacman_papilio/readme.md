The original source code was downloaded from:

( https://code.google.com/p/pengo-papilioplus-fpga/ )


(1) Build Ms PacMan

Copy your roms to /roms/mspacman

go to scripts an run

build_roms_mspacman.sh

edit papilio_top_arcade.vhd

	-- only set one of these
constant PENGO : std_logic := '0'; -- set to 1 when using Pengo ROMs, 0 otherwise
constant PACMAN : std_logic := '1'; -- set to 1 for all other Pacman hardware games
-- only set one of these when PACMAN is set
constant MRTNT : std_logic := '0'; -- set to 1 when using Mr TNT ROMs, 0 otherwise
constant LIZWIZ : std_logic := '0'; -- set to 1 when using Lizard Wizard ROMs, 0 otherwise
constant MSPACMAN : std_logic := '1'; -- set to 1 when using Ms Pacman ROMs, 0 otherwise


build paxman_arcade.ise

