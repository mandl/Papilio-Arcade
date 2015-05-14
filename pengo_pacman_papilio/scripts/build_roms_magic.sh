#!/bin/sh
#
# build romgen and copy data2men in data2mem_path
#
# extract romfiles to rom_path_src
#

export rom_path_src=../roms/PacManicMinerMan
export rom_path=../build
export romgen_path=../romgen_source

mkdir $rom_path

echo 9bfb71e71f7f61e26d23e6370d684cdc6c910899 pacmmm.5e
sha1sum $rom_path_src/pacmmm.5e 
echo 3a089696bab9f3ff39e09c84117d22b861ddec40 pacmmm.5f
sha1sum $rom_path_src/pacmmm.5f 
echo 1aeb94299a33daa9b51fdab3c0abea98858cc7dd pacmmm.6e
sha1sum $rom_path_src/pacmmm.6e
echo 84233296683321f71fdef604ca19bfffd97e993c pacmmm.6f
sha1sum $rom_path_src/pacmmm.6f

rm -f $rom_path/gfx1.bin
rm -f $rom_path/main.bin


#concatenate consecutive ROM regions
cat $rom_path_src/pacmmm.5e $rom_path_src/pacmmm.5f >> $rom_path/gfx1.bin
cat $rom_path_src/pacmmm.6e $rom_path_src/pacmmm.6f $rom_path_src/pacmmm.6h $rom_path_src/pacmmm.6j >> $rom_path/main.bin

#generate RTL code for small PROMS
$romgen_path/romgen $rom_path_src/82s126.1m     PROM1_DST  8 a r e > $rom_path/prom1_dst.vhd
$romgen_path/romgen $rom_path_src/82s126.3m     PROM3_DST  7 a     > $rom_path/prom3_dst.vhd
$romgen_path/romgen $rom_path_src/82s126.4a     PROM4_DST 10 a     > $rom_path/prom4_dst.vhd
$romgen_path/romgen $rom_path_src/82s123.7f     PROM7_DST  5 a r e > $rom_path/prom7_dst.vhd

#generate RAMB structures for larger ROMS
$romgen_path/romgen $rom_path/gfx1.bin          GFX1      14 l r e > $rom_path/gfx1.vhd
$romgen_path/romgen $rom_path/main.bin          ROM_PGM_0 14 l r e > $rom_path/rom0.vhd

#this ROM area is not used but is required for synthesis
$romgen_path/romgen $rom_path/main.bin          ROM_PGM_1 14 l r e > $rom_path/rom1.vhd

