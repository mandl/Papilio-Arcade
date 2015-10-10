#!/bin/sh

# 85d13a9b78c47174cff7c869f52b30263bae575e 10-1.f4
# 4d7fea6d9ab31e5f280b1dc198a325f00c3826ef 10-2.k1
# 7cf59b7a37c156640d6ea91554d1c4276c1780e0 10-3.c4
# 83a5b745e58844b6dd7d05dfe9dbb5959aaf5c40 l0.h7
# ddc1f849cbcefb64b70a26c2a4c993f0516af814 l1.c4
# 193c9f90b7550020c0923cb158dff7d5faa53bc6 l2.d4
# 1960e9cd896b6a65197aefc3f10348103552b598 l3.e4
# 2a4b9533e61e265bdd38c126add8c26d5bc048d5 l4.h4
# 276275d56c725b9d90eeb44c317ceb06bac27ae7 l5.j4
# c05de7de4bd05d5c2af6aa752e057a9286f3effc l6.k4
# f8585a6fcf921e3e21f112dd2de474cb53cef290 l7.m7
# 0bc812cf872f04eacedb50feed53f1aa8a1f24b9 l8.l7
# 58cb82417396a3d96acfc864f091b1a5988f228d l9.f7

export rom_path_src=../roms/ladybug
export rom_path=../build
export romgen_path=../romgen_source
export data2mem_path=../build
export src_path=../src

mkdir $rom_path
echo 85d13a9b78c47174cff7c869f52b30263bae575e 10-1.f4
sha1sum $rom_path_src/10-1.f4 
echo 4d7fea6d9ab31e5f280b1dc198a325f00c3826ef 10-2.k1
sha1sum $rom_path_src/10-2.k1 
echo 7cf59b7a37c156640d6ea91554d1c4276c1780e0 10-3.c4
sha1sum $rom_path_src/10-3.c4
echo 83a5b745e58844b6dd7d05dfe9dbb5959aaf5c40 l0.h7
sha1sum $rom_path_src/l0.h7
echo ddc1f849cbcefb64b70a26c2a4c993f0516af814 l1.c4
sha1sum $rom_path_src/l1.c4

rm -f $rom_path/cpu1.bin
rm -f $rom_path/cpu2.bin
rm -f $rom_path/cpu3.bin

cat $rom_path_src/l1.c4 $rom_path_src/l2.d4 >> $rom_path/cpu1.bin
cat $rom_path_src/l3.e4 $rom_path_src/l4.h4 >> $rom_path/cpu2.bin
cat $rom_path_src/l5.j4 $rom_path_src/l6.k4 >> $rom_path/cpu3.bin
cp ../roms/dummy_prom_decrypt.vhd $rom_path/prom_decrypt.vhd


$romgen_path/romgen $rom_path_src/10-1.f4     prom_10_1     5 m r > $rom_path/prom_10_1.mem
$romgen_path/romgen $rom_path_src/10-2.k1     prom_10_2     5 m r > $rom_path/prom_10_2.men
$romgen_path/romgen $rom_path_src/10-3.c4     prom_10_3     5 m r > $rom_path/prom_10_3.mem
$romgen_path/romgen $rom_path/cpu1.bin        INST_ROM_CPU1     13 m r  > $rom_path/INST_ROM_CPU1.mem
$romgen_path/romgen $rom_path/cpu2.bin        INST_ROM_CPU2     13 m r  > $rom_path/INST_ROM_CPU2.mem
$romgen_path/romgen $rom_path/cpu3.bin        INST_ROM_CPU3     13 m r  > $rom_path/INST_ROM_CPU3.mem
$romgen_path/romgen $rom_path_src/l8.l7       rom_sprite_l 12 m r > $rom_path/rom_sprite_l.mem
$romgen_path/romgen $rom_path_src/l7.m7       rom_sprite_u 12 m r > $rom_path/rom_sprite_u.mem
$romgen_path/romgen $rom_path_src/l9.f7       rom_char_l   12 m r > $rom_path/rom_char_l.mem
$romgen_path/romgen $rom_path_src/l0.h7       rom_char_u   12 m r > $rom_path/rom_char_u.mem


$data2mem_path/data2mem -bm $src_path/ladybug_bd.bmm -bt $rom_path/papilio_ladybug.bit -bd $rom_path/INST_ROM_CPU1.mem  tag avrmap.INST_ROM_CPU1 -o b $rom_path/out1.bit
$data2mem_path/data2mem -bm $src_path/ladybug_bd.bmm -bt $rom_path/out1.bit -bd $rom_path/INST_ROM_CPU2.mem tag avrmap.INST_ROM_CPU2 -o b $rom_path/out2.bit
$data2mem_path/data2mem -bm $src_path/ladybug_bd.bmm -bt $rom_path/out2.bit -bd $rom_path/INST_ROM_CPU3.mem tag avrmap.INST_ROM_CPU3 -o b $rom_path/out3.bit
$data2mem_path/data2mem -bm $src_path/ladybug_bd.bmm -bt $rom_path/out3.bit -bd $rom_path/rom_sprite_l.mem tag avrmap.rom_sprite_l -o b $rom_path/out4.bit
$data2mem_path/data2mem -bm $src_path/ladybug_bd.bmm -bt $rom_path/out4.bit -bd $rom_path/rom_sprite_u.mem tag avrmap.rom_sprite_u -o b $rom_path/out5.bit
$data2mem_path/data2mem -bm $src_path/ladybug_bd.bmm -bt $rom_path/out5.bit -bd $rom_path/rom_char_l.mem tag avrmap.rom_char_l -o b $rom_path/out6.bit
$data2mem_path/data2mem -bm $src_path/ladybug_bd.bmm -bt $rom_path/out6.bit -bd $rom_path/rom_char_u.mem tag avrmap.rom_char_u -o b $rom_path/out7.bit
#$data2mem_path/data2mem -bm $rom_path/ladybug_bd.bmm -bt $rom_path/out7.bit -bd $rom_path/prom_10_1.mem tag avrmap.INST_ROM_CHARU -o b $rom_path/out8.bit
#$data2mem_path/data2mem -bm $rom_path/ladybug_bd.bmm -bt $rom_path/out8.bit -bd $rom_path/prom_10_2.mem tag avrmap.INST_ROM_CHARU -o b $rom_path/out9.bit
#$data2mem_path/data2mem -bm $rom_path/ladybug_bd.bmm -bt $rom_path/out9.bit -bd $rom_path/prom_10_3.mem tag avrmap.INST_ROM_CHARU -o b $rom_path/out10.bit


