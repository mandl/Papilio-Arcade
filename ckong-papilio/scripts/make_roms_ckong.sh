#!/bin/sh

# SHA1 checksum 
export rom_path_src=../roms
export rom_path=../build
export tools_path=../build2/romgen
export rom_path_gap=../scripts
export romgen_path=../romgen_source
mkdir $rom_path


rm  $rom_path/prog.bin $rom_path/prog2.bin $rom_path/ckong_palette.bin $rom_path/ckong_tile0.bin $rom_path/ckong_tile1.bin $rom_path/ckong_big_sprite_tiles.bin $rom_path/ckong_samples.bin


cat $rom_path_src/7.5d $rom_path_src/8.5e $rom_path_src/9.5h $rom_path_src/10.5k >> $rom_path/prog.bin
cat $rom_path_src/11.5l $rom_path_src/12.5n  >> $rom_path/prog2.bin

cat $rom_path_src/prom.v6 $rom_path_src/prom.u6 >> $rom_path/ckong_palette.bin
cat $rom_path_src/6.11n $rom_path_src/5.11l >> $rom_path/ckong_tile0.bin
cat $rom_path_src/4.11k $rom_path_src/3.11h >> $rom_path/ckong_tile1.bin

cat $rom_path_src/2.11c $rom_path_src/1.11a >> $rom_path/ckong_big_sprite_tiles.bin
cat $rom_path_src/13.5p $rom_path_src/14.5s >> $rom_path/ckong_samples.bin


$romgen_path/romgen $rom_path/prog.bin ckong_program 14 l r > $rom_path/ckong_program.vhd
$romgen_path/romgen $rom_path/prog2.bin ckong_program2 13 l r > $rom_path/ckong_program2.vhd
$romgen_path/romgen $rom_path/ckong_tile0.bin ckong_tile_bit0 13 l r > $rom_path/ckong_tile_bit0.vhd 
$romgen_path/romgen $rom_path/ckong_tile1.bin ckong_tile_bit1 13 l r > $rom_path/ckong_tile_bit1.vhd 

$romgen_path/romgen $rom_path_src/2.11c ckong_big_sprite_tile_bit0 11 l r > $rom_path/ckong_big_sprite_tile_bit0.vhd
$romgen_path/romgen $rom_path_src/1.11a ckong_big_sprite_tile_bit1 11 l r > $rom_path/ckong_big_sprite_tile_bit1.vhd

$romgen_path/romgen $rom_path/ckong_palette.bin ckong_palette 6 a r > $rom_path/ckong_palette.vhd 
$romgen_path/romgen $rom_path_src/prom.t6 ckong_big_sprite_palette 5 a r > $rom_path/ckong_big_sprite_palette.vhd
$romgen_path/romgen $rom_path/ckong_samples.bin  ckong_samples 13 l r > $rom_path/ckong_samples.vhd





