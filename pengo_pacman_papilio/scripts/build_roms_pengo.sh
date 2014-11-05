#!/bin/sh
#
# build romgen
#
# extract romfiles to rom_path_src
#

export rom_path_src=../roms/pengo
export rom_path=../build
export romgen_path=../romgen_source

mkdir $rom_path

echo 680eab0e1204c9b74adc11588461651b474021bb pr1633.78
sha1sum $rom_path_src/pr1633.78
echo 3fcd66610fcaee814953a115bf5e04788923181f pr1634.88
sha1sum $rom_path_src/pr1634.88
echo 563c9770028fe39188e62630711589d6ed242a66 pr1635.51
sha1sum $rom_path_src/pr1635.51
echo 0c4d0bee858b97632411c440bea6948a74759746 pr1636.70
sha1sum $rom_path_src/pr1636.70
echo e542bcc28f292be9a0a29d949de726e0b55e654a ep1640.92
sha1sum $rom_path_src/ep1640.92
echo 0930de17a763a527057f60783a92662b09554426 ep1689c.8
echo 4c97529e61eeca5d94938b1dfbeac41bf8cbaf7d ep1690b.7
echo c8949fbdbfe5023ee17a789ef60205e834a76c81 ep1691b.15
echo 7079769d14dfe3873ffe29623ba0a93413706c6d ep1692b.14
echo c0508951c2ad8dc31481be8b3bfee2063e3fb0d7 ep1693b.21
echo 7b47aec61593efd758e2a031f72a854bb0ba8af1 ep1694b.20
echo bdec535e486b43a8f5550334beff423eeace10b2 ep1695.105
echo 207ed466546f40ca60a38031b83aef61446902e2 ep5118b.32
echo fec7236b3dee2ea6e39c68440a6d2d9e3f72675a ep5119c.31



rm -f $rom_path/gfx1.bin
rm -f $rom_path/main1.bin
rm -f $rom_path/main2.bin

# concatenate consecutive ROM regions
cat $rom_path_src/ep1640.92 $rom_path_src/ep1695.105 >> $rom_path/gfx1.bin
cat $rom_path_src/ep1689c.8 $rom_path_src/ep1690b.7 $rom_path_src/ep1691b.15 $rom_path_src/ep1692b.14 >> $rom_path/main1.bin
cat $rom_path_src/ep1693b.21 $rom_path_src/ep1694b.20 $rom_path_src/ep5118b.32 $rom_path_src/ep5119c.31 >> $rom_path/main2.bin

# generate RTL code for small PROMS
$romgen_path/romgen $rom_path_src/pr1635.51     PROM1_DST  8 a r e > $rom_path/prom1_dst.vhd
$romgen_path/romgen $rom_path_src/pr1636.70     PROM3_DST  7 a     > $rom_path/prom3_dst.vhd
$romgen_path/romgen $rom_path_src/pr1634.88     PROM4_DST 10 a     > $rom_path/prom4_dst.vhd
$romgen_path/romgen $rom_path_src/pr1633.78     PROM7_DST  5 a r e > $rom_path/prom7_dst.vhd

# generate RAMB structures for larger ROMS
$romgen_path/romgen $rom_path/gfx1.bin          GFX1      14 l r e > $rom_path/gfx1.vhd
$romgen_path/romgen $rom_path/main1.bin         ROM_PGM_0 14 l r e > $rom_path/rom0.vhd
$romgen_path/romgen $rom_path/main2.bin         ROM_PGM_1 14 l r e > $rom_path/rom1.vhd

