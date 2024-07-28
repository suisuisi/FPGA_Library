#!/bin/env python
"""
-------------------------------------------------------------------------
 Cipher module for RSA on SASEBO-G and SASEBO-R 
 
 File name   : CipherModuleMashRSA.py
 Version     : Version 1.1
 Created     : JUN/8/2010
 Last update : APR/28/2011
 Designed by : Sho Endo
 
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

import copy
import CipherModule
import time
from utility import *

rev2_addr_list = { "ADDR_CONT"     : 0x0002,
                   "ADDR_IPSEL0"   : 0x0004,
                   "ADDR_IPSEL1"   : 0x0006,
                   "ADDR_OUTSEL0"  : 0x0008,
                   "ADDR_OUTSEL1"  : 0x000A,
                   "ADDR_MODE"     : 0x000C,
                   "ADDR_ENCDEC"   : 0x000C,
                   "ADDR_RSEL"     : 0x000E,
                   "ADDR_KEY0"     : 0x0100,
                   "ADDR_IV0"      : 0x0110,
                   "ADDR_ITEXT0"   : 0x0120,
                   "ADDR_RAND0"    : 0x0160,
                   "ADDR_OTEXT0"   : 0x0180,
                   "ADDR_RDATA0"   : 0x01C0,
                   "ADDR_RKEY0"    : 0x01D0,
                   "ADDR_EXP00"    : 0x0200,
                   "ADDR_MOD00"    : 0x0300,
                   "ADDR_PREDAT00" : 0x0340,
                   "ADDR_IDATA00"  : 0x0400,
                   "ADDR_ODATA00"  : 0x0500,
                   "ADDR_VERSION"  : 0xFFFC }

rev2_cipher_list_ipsel0 = { "AES_Comp"     : 0x0001,
                     "AES_TBL"      : 0x0002,
                     "AES_PPRM1"    : 0x0004,
                     "AES_PPRM3"    : 0x0008,
                     "AES_Comp_ENC" : 0x0010,
                     "AES_CTR_Pipe" : 0x0020,
                     "AES_FA"       : 0x0040,
                     "AES_PKG"      : 0x0080,
                     "AES_MAO"      : 0x0100,
                     "AES_MDPL"     : 0x0200,   
                     "AES_TI"       : 0x0400,
                     "AES_WDDL"     : 0x0800,
                     "AES_RSL"      : 0x1000,
                     "AES_RSL2"     : 0x2000, 
                     "RSA"          : 0x0000  }

rev2_cipher_list_ipsel1 = { "RSA" : 0x0080 }

params_addr_list = {"ADDR_WIDTH"     : 0x0000,
		    "ADDR_PERIOD"    : 0x0001,
		    "ADDR_POS"       : 0x0002,
		    "ADDR_POS_FINE"  : 0x0003,
		    "ADDR_GLITCH_EN" : 0x0004 }


class CipherModuleRSA(CipherModule.LocalBus):
    def __init__(self, interface="USB"):
        super(CipherModuleRSA, self).__init__(interface)
        #Dictionary of addresses
        self.cipher_list_ipsel0 = rev2_cipher_list_ipsel0
        self.cipher_list_ipsel1 = rev2_cipher_list_ipsel1
        self.addr_list = rev2_addr_list
        self.select("RSA")  # Set IP
        self.reset_lsi()    # Reset RSA IP
    
    def set_key(self, exp_list, mod_list):
        """ Store exponent e and modulus n """
        #Set exponent
        self.write_burst(self.addr_list["ADDR_EXP00"], exp_list)
        #Set modulus
        self.write_burst(self.addr_list["ADDR_MOD00"], mod_list)
        #Set KSET
        self.write(self.addr_list["ADDR_CONT"], 0x0002)
        #Wait until KSET is cleared
        while (self.read(self.addr_list["ADDR_CONT"]) == 0x0010):
            a = 1 #do nothing

    def reset_lsi(self):
        """Reset LSI"""
        self.write(self.addr_list["ADDR_CONT"], 0x0004)
        self.write(self.addr_list["ADDR_CONT"], 0x0000)

    def start_encdec(self, dat):
        """Start cryptographic operation"""
        self.write_burst(self.addr_list["ADDR_IDATA00"], dat)
        self.write(self.addr_list["ADDR_CONT"], 0x0001) # kick the cipher
        while ((self.read(self.addr_list["ADDR_CONT"]) & 0x0001) == 1):
            1 #do nothing
        return self.read_burst(self.addr_list["ADDR_ODATA00"], 64)

    def set_rsa_mode(self, rsa_mode):
        """
        Setting the mode of RSA core.
        set_rsa_mode(rsa_mode) 
        rsa_mode: 0: Left binary method
                  1: Right binary method
                  2: Left binary method with countermeasures
                  3: Left binary method with countermeasures
                  4: Montgomery Powering Ladder
                  5: Right binary method by M. Joye
        """
        reg = self.read(self.addr_list["ADDR_MODE"])
        reg = (reg & 0xffc7) | (rsa_mode << 3)
        self.write(self.addr_list["ADDR_MODE"], reg)
        print "Set RSA core to mode ", rsa_mode

    def set_rsa_crt(self, crt):
        """
        Turn on or off CRT mode. 
        set_rsa_crt(crt) crt: 1 enable/ 0 disable
        """
        reg = self.read(self.addr_list["ADDR_MODE"])
        reg = (reg & 0xffbf) | (crt << 6)
        self.write(self.addr_list["ADDR_MODE"], reg)
        print "CRT mode was set to ", crt
    
    def select(self, cipher):
        """ Select cryptographic cores """
        self.write(self.addr_list["ADDR_IPSEL0"], self.cipher_list_ipsel0[cipher])
        self.write(self.addr_list["ADDR_IPSEL1"], self.cipher_list_ipsel1[cipher])
        self.write(self.addr_list["ADDR_OUTSEL0"], self.cipher_list_ipsel0[cipher])
        self.write(self.addr_list["ADDR_OUTSEL1"], self.cipher_list_ipsel1[cipher])

    def encrypt(self, plaintext, exp, mod):
        """Encrypt or decrypt given plaintext"""
        # Convert multi-byte integer to list
        pt = intToUint16List(plaintext)
        e = intToUint16List(exp)
        n = intToUint16List(mod)
        # Set keys
        self.set_key(e, n)
        return self.start_encdec(pt) # Start encrytption and return the result

    def read_param(self, addr):
        buf = []
        buf.append(0x02) # Magic number for reading
        buf.append(addr / 256)
        buf.append(addr % 256)
        self.ctrlif.write(bytelistToStr(buf))
        
        tmp = self.ctrlif.read(2)
        #print "%.4x" % binstr_to_uint16(tmp)
        return binstr_to_uint16(tmp)

    def write_param(self, addr, dat):
        """Write parameters to the FPGA
        """
        buf = []
        buf.append(0x03) # Magic number of setting parameter
        buf.append( addr / 256)
        buf.append( addr % 256)
        buf.append( dat / 256)
        buf.append( dat % 256)
        self.ctrlif.write(bytelistToStr(buf))
        
