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
echo e7e8c080cb6baf342ec637532e05d38129ae73cf earthinv.e
sha1sum $rom_path_src/searthin/earthinv.e

echo b8c1efb4251a1e690ff6936ec956d6f66136a085 earthinv.f
sha1sum $rom_path_src/searthin/earthinv.f

echo 8d9ca92405fbaf1d5a7138d400986616378d061e earthinv.g
sha1sum $rom_path_src/searthin/earthinv.g

echo 90bfa4ea06f38e67fe4286d37d151632439249d2 earthinv.h
sha1sum $rom_path_src/searthin/earthinv.h

cat $rom_path_src/searthin/earthinv.h $rom_path_src/searthin/earthinv.g  $rom_path_src/searthin/earthinv.f $rom_path_src/searthin/earthinv.e >> $rom_path/invaders_rom.bin


$romgen_path/romgen $rom_path/invaders_rom.bin INVADERS_ROM 13 a r > $rom_path/invaders_rom.vhd






