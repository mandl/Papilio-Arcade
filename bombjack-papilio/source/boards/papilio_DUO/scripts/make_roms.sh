#!/bin/sh

export rom_path=../../../../roms/bombjack
export build_path=../../../../build

echo ---------- build bombjack_rom.bin ---------- 

rm $build_path/bombjack_rom.bin
cat $rom_path/01_h03t.bin >> $build_path/bombjack_rom.bin
cat $rom_path/02_p04t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/02_p04t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/03_e08t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/03_e08t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/04_h08t.bin >> $build_path/bombjack_rom.bin
cat $rom_path/04_h08t.bin >> $build_path/bombjack_rom.bin
cat $rom_path/05_k08t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/05_k08t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/06_l08t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/07_n08t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/08_r08t.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/09_j01b.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/10_l01b.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/11_m01b.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/12_n01b.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/13.1r >> $build_path/bombjack_rom.bin
cat $rom_path/14_j07b.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/15_l07b.bin >> $build_path/bombjack_rom.bin 
cat $rom_path/16_m07b.bin >> $build_path/bombjack_rom.bin

echo ---------- merge  bombjack_rom.bin into $build_path/PAPILIO_TOP.bit ---------- 
./bitmerge.py $build_path/PAPILIO_DUO_TOP.bit $build_path/bombjack_rom.bin $build_path/fpga.bit

#./papilio-prog -v -b bscan_spi_lx9.bit -f ../../../../build/fpga.bit


