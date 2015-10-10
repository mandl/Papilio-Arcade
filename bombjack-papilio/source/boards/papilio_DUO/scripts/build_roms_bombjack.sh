#!/bin/sh

# SHA1 sums of files required
# 318face9f7a7ab6c7eeac773995040425e780aaf 01_h03t.bin
# ac18a8219f99ba9178b96c9564de3978e39c59fd 02_p04t.bin
# 94ef52ef47b4399a03528fe3efeac9c1d6983446 03_e08t.bin
# e29ba193f21aa898499187603b25d2e226a07c7b 04_h08t.bin
# a66808ef2d62fca2854396898b86bac9be5f17a3 05_k08t.bin
# 515128a3971fcb97b60c5b6bdd2b03026aec1921 06_l08t.bin
# 6db6006a6e20ff7c243d88293ca53681c4703ea5 07_n08t.bin
# e7897dca4c145f10b7d975b8ef0e4d8aa9354c25 08_r08t.bin
# 51dd6a2688b42e9f28f0882bd76f75be7ec3222a 09_j01b.bin
# e1cdc4b4efbc6c7a1e4fa65019486617f2acba1b 10_l01b.bin
# 43bae56494ac0202aaa8f1ed5c1ed1bff775b2b8 11_m01b.bin
# 8b3c49e21ea4952cae7042890d1be2115f7d6fda 12_n01b.bin
# 67654155e42821ea78a655f869fb81c8d6387f63 13.1r
# ed1746c15cdb04fae888601d940183d5c7702282 14_j07b.bin
# 20c64593ab9fcb04cefbce0cd5d17ce3ff26441b 15_l07b.bin
# de71bcd67f97d05527f2504fc8430be333fb9ec2 16_m07b.bin


export rom_path_src=../../../../roms/bombjack
export rom_path=../../../../build
export romgen_path=../../../../romgen_source
mkdir $rom_path
echo 318face9f7a7ab6c7eeac773995040425e780aaf 01_h03t.bin
sha1sum $rom_path_src/01_h03t.bin 
echo ac18a8219f99ba9178b96c9564de3978e39c59fd 02_p04t.bin
sha1sum $rom_path_src/02_p04t.bin 
echo 94ef52ef47b4399a03528fe3efeac9c1d6983446 03_e08t.bin
sha1sum $rom_path_src/03_e08t.bin
echo e29ba193f21aa898499187603b25d2e226a07c7b 04_h08t.bin
sha1sum $rom_path_src/04_h08t.bin
echo a66808ef2d62fca2854396898b86bac9be5f17a3 05_k08t.bin
sha1sum $rom_path_src/05_k08t.bin

# audiocpu
$romgen_path/romgen $rom_path_src/01_h03t.bin ROM_3H 13 l r e > $rom_path/ROM_3H.vhd
# ROM 3J not seen fitted on any board, just empty socket

# gfx4
$romgen_path/romgen $rom_path_src/02_p04t.bin ROM_4P 12 l r e > $rom_path/ROM_4P.vhd

# chars
$romgen_path/romgen $rom_path_src/03_e08t.bin ROM_8E 12 l r e > $rom_path/ROM_8E.vhd
$romgen_path/romgen $rom_path_src/04_h08t.bin ROM_8H 12 l r e > $rom_path/ROM_8H.vhd
$romgen_path/romgen $rom_path_src/05_k08t.bin ROM_8K 12 l r e > $rom_path/ROM_8K.vhd

# tiles
$romgen_path/romgen $rom_path_src/06_l08t.bin ROM_8L 13 l r e > $rom_path/ROM_8L.vhd
$romgen_path/romgen $rom_path_src/07_n08t.bin ROM_8N 13 l r e > $rom_path/ROM_8N.vhd
$romgen_path/romgen $rom_path_src/08_r08t.bin ROM_8R 13 l r e > $rom_path/ROM_8R.vhd

# ROMS 9 through 16 located on main board

# maincpu
$romgen_path/romgen $rom_path_src/09_j01b.bin ROM_1J 13 l r e > $rom_path/ROM_1J.vhd
$romgen_path/romgen $rom_path_src/10_l01b.bin ROM_1L 13 l r e > $rom_path/ROM_1L.vhd
$romgen_path/romgen $rom_path_src/11_m01b.bin ROM_1M 13 l r e > $rom_path/ROM_1M.vhd
$romgen_path/romgen $rom_path_src/12_n01b.bin ROM_1N 13 l r e > $rom_path/ROM_1N.vhd
$romgen_path/romgen $rom_path_src/13.1r       ROM_1R 13 l r e > $rom_path/ROM_1R.vhd

# sprites
$romgen_path/romgen $rom_path_src/16_m07b.bin ROM_7M 13 l r e > $rom_path/ROM_7M.vhd
$romgen_path/romgen $rom_path_src/15_l07b.bin ROM_7L 13 l r e > $rom_path/ROM_7L.vhd
$romgen_path/romgen $rom_path_src/14_j07b.bin ROM_7J 13 l r e > $rom_path/ROM_7J.vhd
