#!/bin/env python

"""
-------------------------------------------------------------------------
 Sample program of RSA encryption with glitchy-clock
 
 File name   : sample.py
 Version     : Version 1.0
 Created     : APR/28/2011
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

# Import requred modules

from CipherModuleMashRSA import CipherModuleRSA
from utility import *

#The list of address
addr_list = {"DELAY"      : 0x0000,
	     "PERIOD"     : 0x0001,
	     "POSITION"   : 0x0002,
	     "POS_FINE"   : 0x0003,
	     "GLITCH_EN"  : 0x0004,
	     "EXEC_TIME0" : 0x0005,
	     "EXEC_TIME1" : 0x0006 }

# Main program
if __name__ == '__main__':
    
    #Instantiate the cipher module
    cm = CipherModuleRSA(interface = "USB")
    # If you use serial port, specify the port.
    #cm = CipherModuleRSA(interface = "COM3")

    # Set RSA mode to Left-to-right binary method
    cm.set_rsa_mode(0)
    # Chinese Remainder Theorem is off
    cm.set_rsa_crt(0)

    # Configuration for glitchy-clock generator
    
    # Period of glitch = 15
    cm.write_param(addr_list["DELAY"], 15)
    # Period of glitch = 30
    cm.write_param(addr_list["PERIOD"], 30)
    # Position of glitch = 14
    cm.write_param(addr_list["POSITION"], 14)
    # Fine adjustment = 0
    cm.write_param(addr_list["POS_FINE"], 0)
    # Enable glitch injection
    cm.write_param(addr_list["GLITCH_EN"], 1)

    #Keys
    n = 0xcf545b72fc67f13131ed60472e5783e445ab8d83d559b9901619986b6c10e89362bfed436e8369c531f6d5e754b34a7c76ab97bfccc40d8b9a300b3e583f319dL
    key = 0x5b79599bc2f74d382a52141f73b7d30e3d1af2a60ed4b68576eab60ff72f029d70bb9c251d7eb633b3d13430afb5f64e5f4a2bf7ccb2e312b72127a00d62ba01L
    # Plaintext
    pt = 0x19c8826e116109f90ce5bd560c1aa529c94462c3865fcee1567501afc94ffb9817d5696ad0e3921d53b199f1d914ba38a2d312a1a02ee75b913458d9191f2932L
    # Correct ciphertext
    ct_correct = 0x119cc7894073cfb531aa0b7c4dc6604035ff2f9e572f04e68686f1637e322ace34c04edb881847643b10e40a91fcec5116ecfaba43dcc12dd9811a34a3fc5f6fL

    # Encryption
    res = cm.encrypt(pt, key, n)

    # Show result
    print "result             = 0x" +  hex_str_noseg(res)
    # Show result
    print "correct ciphertext = " + hex(ct_correct)

    
