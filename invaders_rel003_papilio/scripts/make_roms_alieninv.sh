#!/bin/sh

# SHA1 checksum 
export rom_path_src=../roms
export rom_path=../build
export tools_path=../build2/romgen
export rom_path_gap=../scripts
export romgen_path=../romgen_source
mkdir $rom_path

rm $rom_path/invaders_rom.bin

# SHA1 sums of files required
echo 8adcb7cd4492fa6649d9ee81172d8dff56621d64 1e.bin
sha1sum $rom_path_src/alieninv/1e.bin 

echo 7e02651692113db31fd469868ae5ffdb0f941ecf 1f.bin
sha1sum $rom_path_src/alieninv/1f.bin 

echo b693667656e5d8f44eeb2ea730f4d4db436da579 1g.bin
sha1sum $rom_path_src/alieninv/1g.bin 

echo eec34b3d5585bae03c7b80585daaa05ddfcc2164 1h.bin
sha1sum $rom_path_src/alieninv/1h.bin 

cat $rom_path_src/alieninv/1h.bin $rom_path_src/alieninv/1g.bin $rom_path_src/alieninv/1f.bin $rom_path_src/alieninv/1e.bin >> $rom_path/invaders_rom.bin


$romgen_path/romgen $rom_path/invaders_rom.bin INVADERS_ROM 13 a r > $rom_path/invaders_rom.vhd






