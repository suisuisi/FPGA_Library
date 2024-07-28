#!/bin/env python

"""
-------------------------------------------------------------------------
 Utility functions for 
 
 File name   : utility.py
 Version     : Version 1.1
 Created     : JUL/30/2010
 Last update : APR/28/2011
 Desgined by : Takeshi Sugawara
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

# Converting a list of bytes into a string
def bytelistToStr(byteList):
    tmp = map(chr, byteList)
    return "".join(tmp)

def strTobyteList(str):
    return [ord(i) for i in list(str)]

def strToUint16List(str):
    tmp = strTobyteList(str)
    buf = []
    for i in range(len(tmp)/2):
        buf.append( tmp[2*i] * 256 + tmp[2*i+1] )
    return buf

def binstr_to_uint16(binstr):
    """
    Convert binary string to the corresponding uint16 value.
    Example:
    IN: print '%x' % binstr_to_uint('\xfc\xff')
    OUT: fcff
    """    
    tmp = map(ord, list(binstr))
    return (tmp[0] << 8) + tmp[1]

def hex_str(uint16List):
    tmp = ["%.4x" % i for i in uint16List]
    return "_".join(tmp)
    
#Added by Sho Endo
#Jun/10/2010

def intToUint16List(x):
    import copy
    a = copy.copy(x)
    list = []
    for i in range(32):
        list.append(a % 65536)
        a = a >> 16
    list.reverse()
    return list

#Added by Sho Endo
# APR/28/2011

def hex_str_noseg(uint16List):
    tmp = ["%.4x" % i for i in uint16List]
    return "".join(tmp)