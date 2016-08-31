#!/bin/sh

# SHA1 checksum 
export rom_path_src=../roms/galaxian
export rom_path=../build
export tools_path=../build2/romgen
export rom_path_gap=../scripts
export romgen_path=../romgen_source
mkdir $rom_path
rm $rom_path/main.bin
rm $rom_path/gfx1.bin

# SHA1 sums of files required

echo 4755609bd974976f04855d51e08ec0d62ab4bc07 1h.bin
sha1sum $rom_path_src/1h.bin
echo a9795d8b7388f404f3b0e2c6ce15d713a4c5bafa 1k.bin
sha1sum $rom_path_src/1k.bin
echo f382ad5a34d282056c78a5ec00c30ec43772bae2 6l.bpr
sha1sum $rom_path_src/6l.bpr
echo 8b44b0f74420871454e27894d0f004859f9e59a9 7l
sha1sum $rom_path_src/7l
echo e65f74e35b1bfaccd407e168ea55678ae9b68edf galmidw.u
sha1sum $rom_path_src/galmidw.u
echo 02fdcd95d8511e64c0d2b007b874112d53e41045 galmidw.v
sha1sum $rom_path_src/galmidw.v
echo 0046b9ed697a34d088de1aead8bd7cbe526a2396 galmidw.w
sha1sum $rom_path_src/galmidw.w
echo 18d8714e5ef52f63ba8888ecc5a25b17b3bf17d1 galmidw.y
sha1sum $rom_path_src/galmidw.y


# concatenate consecutive ROM regions
cat $rom_path_src/1h.bin  $rom_path_src/1k.bin >> $rom_path/gfx1.bin
cat $rom_path_src/galmidw.u $rom_path_src/galmidw.v $rom_path_src/galmidw.w $rom_path_src/galmidw.y  $rom_path_src/7l  >> $rom_path/main.bin


$romgen_path/romgen $rom_path_src/6l.bpr    GALAXIAN_6L  5 a r e     > $rom_path/galaxian_6l.vhd

# generate RAMB structures for larger ROMS
$romgen_path/romgen $rom_path/gfx1.bin        GFX1      12 a r  > $rom_path/gfx1.vhd
$romgen_path/romgen $rom_path/main.bin        ROM_PGM_0 14 a r  > $rom_path/rom0.vhd

$romgen_path/romgen $rom_path_src/1h.bin    GALAXIAN_1H 11 a r  > $rom_path/galaxian_1h.vhd
$romgen_path/romgen $rom_path_src/1k.bin    GALAXIAN_1K 11 a r  > $rom_path/galaxian_1k.vhd








