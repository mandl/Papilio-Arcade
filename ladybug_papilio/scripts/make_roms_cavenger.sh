#!/bin/sh
# SHA1 checksum                            Filename
# bc8c52c6ba919287773ff6a4ec793ebd95176130 0.h7
# f23bd6b9f427c26ac996a5c8ba29f356cf45c78a 1.c4
# 170e3f8be592dcccb8868474f40f8f2223e8a8b5 2.d4
# 4b0f1b38a5837b7ffc9aec6c28c6eb72cfa46226 3.e4
# f8a7ea799d8ff9b4f830d064bb2f34a76729c336 4.h4
# 622c90a6c3f0adc24fe8a1d4969075cbd55add4e 5.j4
# ec4981fe34abf992acbd6325b2c756c58ff80b04 6.k4
# 85f78d5a1e5782587bb66ad101a94fd0d62fb790 8.l7
# 20eaa866b7700535312fd415edaea94408ff3e3d 9.f7
# 4c9c76826f3a2a631d01fd2531d55318172b0c12 10-1.f4
# 03175ee7f8e11896a89d7cc0d614a78a49923627 10-2.k1
# 7cf59b7a37c156640d6ea91554d1c4276c1780e0 10-3.c4

export rom_path_src=../roms/cavenger
export rom_path=../build
export romgen_path=../romgen_source
#mkdir $rom_path
echo bc8c52c6ba919287773ff6a4ec793ebd95176130 0.h7
sha1sum $rom_path_src/0.h7 
echo f23bd6b9f427c26ac996a5c8ba29f356cf45c78a 1.c4
sha1sum $rom_path_src/1.c4 
echo 170e3f8be592dcccb8868474f40f8f2223e8a8b5 2.d4
sha1sum $rom_path_src/2.d4
echo 4b0f1b38a5837b7ffc9aec6c28c6eb72cfa46226 3.e4
sha1sum $rom_path_src/3.e4
echo f8a7ea799d8ff9b4f830d064bb2f34a76729c336 4.h4
sha1sum $rom_path_src/4.h4

cat $rom_path_src/1.c4 $rom_path_src/2.d4 >> $rom_path/cpu1.bin
cat $rom_path_src/3.e4 $rom_path_src/4.h4 >> $rom_path/cpu2.bin
cat $rom_path_src/5.j4 $rom_path_src/6.k4 >> $rom_path/cpu3.bin

cp ../roms/dummy_prom_decrypt.vhd $rom_path/prom_decrypt.vhd


$romgen_path/romgen $rom_path_src/10-1.f4     prom_10_1     5 a r > $rom_path/prom_10_1.vhd
$romgen_path/romgen $rom_path_src/10-2.k1     prom_10_2     5 a r > $rom_path/prom_10_2.vhd
$romgen_path/romgen $rom_path_src/10-3.c4     prom_10_3     5 a r > $rom_path/prom_10_3.vhd
$romgen_path/romgen $rom_path/cpu1.bin        rom_cpu1     13 l r > $rom_path/cpu1.vhd
$romgen_path/romgen $rom_path/cpu2.bin        rom_cpu2     13 l r > $rom_path/cpu2.vhd
$romgen_path/romgen $rom_path/cpu3.bin        rom_cpu3     13 l r > $rom_path/cpu3.vhd
$romgen_path/romgen $rom_path_src/8.l7       rom_sprite_l 12 l r > $rom_path/rom_sprite_l.vhd
$romgen_path/romgen $rom_path_src/8.l7       rom_sprite_u 12 l r > $rom_path/rom_sprite_u.vhd
$romgen_path/romgen $rom_path_src/9.f7       rom_char_l   12 l r > $rom_path/rom_char_l.vhd
$romgen_path/romgen $rom_path_src/0.h7       rom_char_u   12 l r > $rom_path/rom_char_u.vhd

