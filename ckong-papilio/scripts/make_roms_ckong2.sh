#!/bin/sh

# SHA1 checksum 
export rom_path_src=../roms
export rom_path=../build
export tools_path=../build2/romgen
export rom_path_gap=../scripts
export romgen_path=../romgen_source
mkdir $rom_path





rm  $rom_path/prog.bin $rom_path/prog2.bin $rom_path/ckong_palette.bin $rom_path/ckong_tile0.bin $rom_path/ckong_tile1.bin $rom_path/ckong_big_sprite_tiles.bin $rom_path/ckong_samples.bin


cat $rom_path_src/d05-07.bin $rom_path_src/f05-08.bin $rom_path_src/h05-09.bin $rom_path_src/k05-10.bin >> $rom_path/prog.bin
cat $rom_path_src/l05-11.bin $rom_path_src/n05-12.bin  >> $rom_path/prog2.bin

cat $rom_path_src/prom.v6 $rom_path_src/prom.u6 >> $rom_path/ckong_palette.bin
cat $rom_path_src/n11-06.bin $rom_path_src/l11-05.bin >> $rom_path/ckong_tile0.bin
cat $rom_path_src/k11-04.bin $rom_path_src/h11-03.bin >> $rom_path/ckong_tile1.bin

cat $rom_path_src/c11-02.bin $rom_path_src/a11-01.bin >> $rom_path/ckong_big_sprite_tiles.bin
cat $rom_path_src/cc13j.bin $rom_path_src/cc12j.bin >> $rom_path/ckong_samples.bin


$romgen_path/romgen $rom_path/prog.bin ckong_program 14 l r > $rom_path/ckong_program.vhd
$romgen_path/romgen $rom_path/prog2.bin ckong_program2 13 l r > $rom_path/ckong_program2.vhd
$romgen_path/romgen $rom_path/ckong_tile0.bin ckong_tile_bit0 13 l r > $rom_path/ckong_tile_bit0.vhd 
$romgen_path/romgen $rom_path/ckong_tile1.bin ckong_tile_bit1 13 l r > $rom_path/ckong_tile_bit1.vhd 

$romgen_path/romgen $rom_path_src/c11-02.bin ckong_big_sprite_tile_bit0 11 l r > $rom_path/ckong_big_sprite_tile_bit0.vhd
$romgen_path/romgen $rom_path_src/a11-01.bin ckong_big_sprite_tile_bit1 11 l r > $rom_path/ckong_big_sprite_tile_bit1.vhd

$romgen_path/romgen $rom_path/ckong_palette.bin ckong_palette 6 l r > $rom_path/ckong_palette.vhd 
$romgen_path/romgen $rom_path_src/prom.t6 ckong_big_sprite_palette 5 l r > $rom_path/ckong_big_sprite_palette.vhd
$romgen_path/romgen $rom_path/ckong_samples.bin  ckong_samples 13 l r > $rom_path/ckong_samples.vhd





