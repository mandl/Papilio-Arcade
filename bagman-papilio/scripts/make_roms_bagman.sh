#!/bin/sh

# SHA1 checksum 
export rom_path_src=../roms/bagman
export rom_path=../build
export tools_path=../build2/romgen
export rom_path_gap=../scripts
export romgen_path=../romgen_source
mkdir $rom_path

sha1sum $rom_path_src/e9_b05.bin 
sha1sum $rom_path_src/f9_b06.bin 
sha1sum $rom_path_src/f9_b07.bin
sha1sum $rom_path_src/f9_b07.bin
sha1sum $rom_path_src/k9_b08.bin
sha1sum $rom_path_src/m9_b09s.bin
sha1sum $rom_path_src/n9_b10.bin
sha1sum $rom_path_src/p3.bin
sha1sum $rom_path_src/r3.bin
sha1sum $rom_path_src/e1_b02.bin
sha1sum $rom_path_src/c1_b01.bin
sha1sum $rom_path_src/j1_b04.bin
sha1sum $rom_path_src/f1_b03s.bin 


cat $rom_path_src/e9_b05.bin $rom_path_src/f9_b06.bin $rom_path_src/f9_b07.bin $rom_path_src/k9_b08.bin $rom_path_src/m9_b09s.bin $rom_path_src/n9_b10.bin  >> $rom_path/prog.bin
cat $rom_path_src/p3.bin $rom_path_src/r3.bin >> $rom_path/bagman_palette.bin
cat $rom_path_src/e1_b02.bin $rom_path_src/c1_b01.bin  >> $rom_path/bagman_tile0.bin
cat $rom_path_src/j1_b04.bin $rom_path_src/f1_b03s.bin >> $rom_path/bagman_tile1.bin


$tools_path/make_vhdl_prom $rom_path/prog.bin $rom_path/bagman_program.vhd bagman_program
$tools_path/make_vhdl_prom $rom_path/bagman_tile0.bin $rom_path/bagman_tile_bit0.vhd bagman_tile_bit0
$tools_path/make_vhdl_prom $rom_path/bagman_tile1.bin $rom_path/bagman_tile_bit1.vhd bagman_tile_bit1
$tools_path/make_vhdl_prom $rom_path/bagman_palette.bin $rom_path/bagman_palette.vhd bagman_palette
$tools_path/make_vhdl_prom $rom_path_src/r9_b11.bin $rom_path/bagman_speech1.vhd bagman_speech1
$tools_path/make_vhdl_prom $rom_path_src/t9_b12.bin $rom_path/bagman_speech2.vhd bagman_speech2


