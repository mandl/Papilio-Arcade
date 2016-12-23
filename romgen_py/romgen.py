#!/usr/bin/env python3
#
# Copyright (C) 2016  Stefan Mandl
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301 USA.

import argparse
from binascii import hexlify
import binascii
import logging
import os
import sys
import time
import traceback
import random

def main():


    parser = argparse.ArgumentParser(description='Generate a vhdl rom from a binary file', prog='romgen')
    parser.add_argument('romfile', type=argparse.FileType('rb'))
    parser.add_argument('--address','-a', help='Address wide',type=int, default=13)
    parser.add_argument('--filename', '-f', help='filename', default='ext_rom')
    parser.add_argument('--vhdlname', '-n', help='vhdl name', default='ext_rom')
    parser.add_argument('--prgmode', help='skip first two bytes', action="store_true")
    parser.add_argument('--random', help='fill with random data', action="store_true")
  
    args = parser.parse_args()
    
    myrom = open(args.filename + ".vhdl", 'w')
    
    st = os.stat(args.romfile.name)
    file_size = st.st_size
        
    # calculate rom size
    rom_size = 2 ** args.address 
    
    #readrom = open(args.romfile, 'rb')
    readrom = args.romfile
    
    if args.prgmode == True:
        print("PRG Filemode is aktiv. Skip the first 2 bytes ")
        readrom.read(2)
        
    
    if rom_size < file_size:
        print ("Rom size is to small. Skip {0:d} bytes".format(file_size - rom_size))
    # create a empty buffer    
    datarom = bytearray(rom_size)
    
    # read rom file
    alldata = readrom.read(rom_size)
    
    pos = 0
    
    # copy romfile
    datarom[pos:pos+len(alldata)] = alldata
    
    print("Filename:     {0:s}.vhdl ".format(args.filename))
    print("VHDL:         {0:s} ".format(args.vhdlname))
    print("Read romfile: {0:s} ".format(args.romfile.name))
    
    print("Romfile size: 0x{0:x} ".format(file_size))
    print("Rom size:     0x{0:x} ".format(rom_size))
  
    print("Address wide: {0:d}".format(args.address))
      
    myrom.write("-- generated with python romgen version 1.0\n")
    myrom.write("-- romfile: " + args.romfile.name + "\n")
    myrom.write("\n")
    
    if args.random == True:
        print("Random mode is active")
        myrom.write("-- fill rom with random content.\n-- So the XSL optimizer can not remove the rom \n\n") 
    myrom.write("library ieee;\n")
    myrom.write("use ieee.std_logic_1164.all;\n")
    myrom.write("use ieee.numeric_std.all;\n\n")

    myrom.write("entity " + args.vhdlname + " is\n")
    myrom.write("port (\n")
    myrom.write("  CLK  : in  std_logic;\n")
    myrom.write("  ADDR : in  std_logic_vector(" + str(args.address - 1) + " downto 0);\n")
    myrom.write("  DATA : out std_logic_vector(7 downto 0)\n")
    myrom.write(");\n")
    myrom.write("end;\n\n")

    myrom.write("architecture RTL of " + args.vhdlname + " is\n\n")

    myrom.write("type ROM_ARRAY is array(0 to " + str(rom_size - 1) + ") of std_logic_vector(7 downto 0);\n")
    myrom.write("signal ROM : ROM_ARRAY := (\n")
    
    
    for i in range (0, rom_size):
        if ((i % 8) == 0):
            myrom.write("        ")
        if args.random == False:
            mybyte = binascii.hexlify(datarom[i:i+1])
            myrom.write("x\"" + mybyte.decode("ascii") + "\"")
        else:
            mybyte = random.randint(0,255)
            myrom.write("x\"{0:02x}\"".format(mybyte))
        
        if (i < (rom_size - 1)):
            myrom.write(",")
        
        if (i == (rom_size - 1)):
            myrom.write(" ");
        if (i % 8 == 7):
            myrom.write(str(" -- 0x{0:04x}\n").format(i))
    
    myrom.write("\n")
                
    myrom.write(");\n\n")
    myrom.write("-- tell XST. Use block ram. So we can use data2mem\n")
    
    myrom.write("attribute ram_style : string;\n")
    myrom.write("attribute ram_style of ROM : signal is \"block\";\n\n")

    myrom.write("begin\n")
    myrom.write("    p_rom : process(CLK,ADDR)\n")
    myrom.write("    begin\n")
    myrom.write("       if (rising_edge(CLK)) then\n")
    myrom.write("          DATA <= ROM(to_integer(unsigned(ADDR)));\n")
    myrom.write("       end if;\n")
    myrom.write("   end process;\n")
    myrom.write("end RTL;\n")          


if __name__ == '__main__':
    try:
        main()
       
    except Exception:
        # sys.stderr.write('ERROR: %s\n' % str(err))
        traceback.print_exc()
