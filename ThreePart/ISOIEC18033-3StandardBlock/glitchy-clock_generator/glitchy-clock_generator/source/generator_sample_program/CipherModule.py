#!/bin/env python
"""
-------------------------------------------------------------------------
 Cipher module
 
 File name   : CipherModuleMashRSA.py
 Version     : Version 1.1
 Created     : JUL/2/2010
 Last update : APR/28/2011
 Designed by : Takeshi Sugawara
 Modified by : Sho Endo
 
-----------------------------------------------------------------
 Copyright (C) 2010 Tohoku University
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by Tohoku University ("us").
 
 Permission is hereby granted to copy, reproduce, redistribute or
 otherwise use this code as long as: there is no monetary profit gained
 specifically from the use or reproduction of this code, it is not sold,
 rented, traded or otherwise marketed, and this copyright notice is
 included prominently in any copy made.
 
 We shall not be liable for any damages, including without limitation
 direct, indirect, incidental, special or consequential damages arising
 from the use of this code.
 
 When you publish any results arising from the use of this code, we will
 appreciate it if you can cite our webpage
 (http://www.rcis.aist.go.jp/special/SASEBO/).
-------------------------------------------------------------------------
"""

import time
from utility import *

# Addresses for ASIC version 1
rev1_cipher_list = {"AES_Comp"     : 0x0001,
                    "AES_Comp_ENC" : 0x0002,
                    "AES_TBL"      : 0x0004,
                    "AES_PPRM1"    : 0x0008,
                    "AES_PPRM3"    : 0x0010,
                    "DES"          : 0x0020,
                    "MISTY1"       : 0x0040,
                    "Camellia"     : 0x0080,
                    "SEED"         : 0x0100,
                    "CAST128"      : 0x0200,
                    "RSA"          : 0x0400,
                    "AES_SSS1"     : 0x0800,
                    "AES_S"        : 0x1000 }

rev1_addr_list = { "ADDR_CONT"    : 0x0002,
                   "ADDR_IPSEL"   : 0x0004,
                   "ADDR_OUTSEL"  : 0x0008,
                   "ADDR_ENCDEC"  : 0x000C,
                   "ADDR_RSEL"    : 0x000E,
                   "ADDR_KEY0"    : 0x0100,
                   "ADDR_ITEXT0"  : 0x0140,
                   "ADDR_OTEXT0"  : 0x0180,
                   "ADDR_RDATA0"  : 0x01C0,
                   "ADDR_EXP00"   : 0x0200,
                   "ADDR_MOD00"   : 0x0300,
                   "ADDR_IDATA00" : 0x0400,
                   "ADDR_ODATA00" : 0x0500,
                   "ADDR_VERSION" : 0xFFFC }

class LocalBus(object):
    """
    Module for communication between PC and control FPGA 
    """
    def __init__(self, interface):
        # Switching between USB and RS232C interfaces
        if interface == "USB":
            import d2xx
            self.ctrlif = d2xx.open(0)
        else:
            # Here, interface is expected to be like "COM1"
            # In this case, port number for pySecial should be 0
            import serial
            portNum = int(interface[3:]) - 1
            try:
                self.ctrlif = serial.Serial(port=portNum, baudrate=19200,timeout=1)
            except serial.serialutil.SerialException:
                import sys
                sys.exit("Cannot open port: " + interface)
        self.cipher_list = rev1_cipher_list
        self.addr_list = rev1_addr_list
        
    def __del__(self):
        if self.ctrlif:
            self.ctrlif.close()

    def write(self, addr, dat):
        buf = []
        buf.append(0x01) # Magic number of writing
        buf.append( addr / 256)
        buf.append( addr % 256)
        buf.append( dat / 256)
        buf.append( dat % 256)
        self.ctrlif.write(bytelistToStr(buf))

    def write_burst(self, addr, dat):
        buf = []
        counter = 0
        for chunk in dat: # chunk is a 16-bit (positive) integer
            buf.append(0x01) # Magic number of writing
            buf.append( (addr + counter) / 256)
            buf.append( (addr + counter) % 256)
            buf.append( chunk / 256)
            buf.append( chunk % 256)
            counter += 2
        self.ctrlif.write(bytelistToStr(buf))

    def read(self, addr):
        buf = []
        buf.append(0x00) # Magic number for reading
        buf.append(addr / 256)
        buf.append(addr % 256)
        self.ctrlif.write(bytelistToStr(buf))
        
        tmp = self.ctrlif.read(2)
        #print "%.4x" % binstr_to_uint16(tmp)
        return binstr_to_uint16(tmp)

    def read_burst(self, addr, len=2):
        buf = []
        for offset in range(0, len, 2):
            buf.append(0x00)
            buf.append( (addr+offset) / 256 )
            buf.append( (addr+offset) % 256 )
        self.ctrlif.write(bytelistToStr(buf))
        tmp = self.ctrlif.read(len)
        return strToUint16List(tmp)
    
