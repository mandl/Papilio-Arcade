#!/bin/sh

#
# Donkey Kong ROM builder
#
# SHA1 checksums of the ROMs required:
# f9c872da2fe8e800574ae3bf483fb3ccacc92eb3  c-2j.bpr
# b50ec9e1837c00c20fb2a4369ec7dd0358321127  c-2k.bpr
# 3fe3599f6fa7c496f782053ddf7bacb453d197c4  c_5at_g.bin
# c7966261f3a1d3296927e0b6ee1c58039fc53c1f  c_5bt_g.bin
# acb11a8fbdbb3ab46068385fe465f681e3c824bd  c_5ct_g.bin
# d76ebecfea1af098d843ee7e578e480cd658ac1a  c_5et_g.bin
# 793dba9bf5a5fe76328acdfb90815c243d2a65f1  l_4m_b.bin
# 92e5d379f4838ac1fa44d448ce7d142dae42102f  l_4n_b.bin
# ecf95db5a20098804fc8bd59232c66e2e0ed3db4  l_4r_b.bin
# 3bc482a38bf579033f50082748ee95205b0f673d  l_4s_b.bin
# 144d24464c1f9f01894eb12f846952290e6e32ef  s_3i_b.bin
# 6c82b57637c0212a580591397e6a5a1718f19fd2  s_3j_b.bin
# c2bdccbf2654b64ea55cd589fd21323a9178a660  v-5e.bpr
# 976eb1e18c74018193a35aa86cff482ebfc5cc4e  v_3pt.bin
# a57ff5a231c45252a63b354137c920a1379b70a3  v_5h_b.bin

export rom_path=../roms
export build_path=../build
export bitfile_path=../bitfile


echo f9c872da2fe8e800574ae3bf483fb3ccacc92eb3  c-2j.bpr
sha1sum $rom_path/c-2j.bpr
echo b50ec9e1837c00c20fb2a4369ec7dd0358321127  c-2k.bpr
sha1sum $rom_path/c-2k.bpr
echo  3fe3599f6fa7c496f782053ddf7bacb453d197c4  c_5at_g.bin
sha1sum $rom_path/c_5at_g.bin

echo ---------- build PROM data ---------- 
rm $build_path/dkong_rom.bin
cat $rom_path/c_5et_g.bin  >> $build_path/dkong_rom.bin
cat $rom_path/c_5ct_g.bin >> $build_path/dkong_rom.bin
cat $rom_path/c_5bt_g.bin >> $build_path/dkong_rom.bin
cat $rom_path/c_5at_g.bin >> $build_path/dkong_rom.bin
cat $rom_path/c_5at_g.bin >> $build_path/dkong_rom.bin
cat $rom_path/c_5at_g.bin >> $build_path/dkong_rom.bin
cat $rom_path/v_3pt.bin >> $build_path/dkong_rom.bin
cat $rom_path/v_3pt.bin >> $build_path/dkong_rom.bin
cat $rom_path/v_5h_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/v_5h_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/c_5at_g.bin >> $build_path/dkong_rom.bin
cat $rom_path/c_5at_g.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4m_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4m_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4n_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4n_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4r_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4r_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4s_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/l_4s_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/s_3i_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/s_3j_b.bin >> $build_path/dkong_rom.bin
cat $rom_path/c-2k.bpr >> $build_path/dkong_rom.bin
cat $rom_path/c-2j.bpr >> $build_path/dkong_rom.bin
cat $rom_path/v-5e.bpr >> $build_path/dkong_rom.bin
cat ./0xd00.bin >> $build_path/dkong_rom.bin
cat ./dk_wave.bin >> $build_path/dkong_rom.bin

echo ---------- add rom to bitfile ---------- 

./bitmerge.py $build_path/dkong_papilio.bit $build_path/dkong_rom.bin $build_path/fpga.bit

#./papilio-prog -v -b bscan_spi_lx9.bit -f ../build/fpga.bit


