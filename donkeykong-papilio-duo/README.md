#Implementation of Donkey Kong on the Papilio-DUO board with ClassicComputingShield

http://www.papilio.cc/index.php?n=Papilio.ClassicComputingShield

Original Verilog source code by Katsumi Degawa
Translated to VHDL and adapted to the Papilio Board by Alex
Source code link https://code.google.com/p/donkeykong-papilioplus-fpga/


# Build under Linux for Papilio-DUO

* Copy your ROMs into the rom Folder
* run make_roms.sh 
* Upload the bitfile into the flash   *papilio-prog -v -b bscan_spi_lx9.bit -f ../build/fpga.bit*
* Power off/on your Papilio-DUO


Use Audio 1 and Joystick 1
