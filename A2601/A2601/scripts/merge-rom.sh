#!/bin/sh
#
# sample 
# http://atariage.com/2600/programming/bankswitch_sizes.txt
#  
# ./merge-rom.sh ../roms/IkariWarriors.bin BANKF6.mem  

export rom_path_src=../roms
export rom_path=../build
export romgen_path=../romgen_source


echo "Using ROM file: $1"
echo "Using bankswitch config: $2"

$romgen_path/romgen $1 cart_rom 14 m  > $rom_path/cart_rom.mem
$romgen_path/data2mem -bm ../build/A2601_bd.bmm -bt ../build/A2601NoFlash.bit -bd ../build/cart_rom.mem tag avrmap.rom_code -o b ../build/A2601NoFlash_rom_temp.bit

# config bankswitching and superchip
$romgen_path/data2mem -bm ../build/A2601_bd.bmm -bt ../build/A2601NoFlash_rom_temp.bit -bd $rom_path_src/$2 tag avrmap.config_rom -o b ../build/A2601NoFlash_rom.bit

# Debug the bitfile
$romgen_path/data2mem -bm ../build/A2601_bd.bmm -bt ../build/A2601NoFlash_rom.bit -d > debug_mem.txt


