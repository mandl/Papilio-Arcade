
copy /B ckong_unzip\d05-07.bin + ckong_unzip\f05-08.bin + ckong_unzip\h05-09.bin + ckong_unzip\k05-10.bin + ckong_unzip\l05-11.bin + ckong_unzip\n05-12.bin prog.bin

copy /B gap_8192.bin + gap_8192.bin + gap_8192.bin + gap_8192.bin + gap_8192.bin gap_49152.bin

copy /B ckong_unzip\prom.v6 + ckong_unzip\prom.u6 ckong_palette.bin

copy /B ckong_unzip\n11-06.bin + ckong_unzip\l11-05.bin ckong_tile0.bin
copy /B ckong_unzip\k11-04.bin + ckong_unzip\h11-03.bin ckong_tile1.bin

copy /B ckong_unzip\c11-02.bin + ckong_unzip\a11-01.bin ckong_big_sprite_tiles.bin

copy /B ckong_unzip\cc13j.bin + ckong_unzip\cc12j.bin ckong_samples.bin

copy /B prog.bin + gap_49152.bin + ckong_tile0.bin + ckong_tile1.bin + ckong_big_sprite_tiles.bin ckong_sram_8bits.bin

duplicate_byte.exe ckong_sram_8bits.bin ckong_sram_16bits.bin

make_vhdl_prom prog.bin ckong_program.vhd
make_vhdl_prom ckong_tile0.bin ckong_tile_bit0.vhd
make_vhdl_prom ckong_tile1.bin ckong_tile_bit1.vhd
make_vhdl_prom ckong_unzip\c11-02.bin ckong_big_sprite_tile_bit0.vhd
make_vhdl_prom ckong_unzip\a11-01.bin ckong_big_sprite_tile_bit1.vhd
make_vhdl_prom ckong_palette.bin ckong_palette.vhd
make_vhdl_prom ckong_unzip\prom.t6 ckong_big_sprite_palette.vhd
make_vhdl_prom ckong_samples.bin ckong_samples.vhd

del prog.bin gap_49152.bin ckong_palette.bin ckong_tile0.bin ckong_tile1.bin ckong_big_sprite_tiles.bin ckong_samples.bin




