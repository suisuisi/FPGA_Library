/******************************************************************************
 * @file dynclk.h
 * Dynamic frequency generation for the axi_dynclk core
 *
 * @author Sam Bobrowicz
 *
 * @date 2015-Nov-25
 *
 * @copyright
 * (c) 2015 Copyright Digilent Incorporated
 * All Rights Reserved
 *
 * This program is free software; distributed under the terms of BSD 3-clause
 * license ("Revised BSD License", "New BSD License", or "Modified BSD License")
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
 *    of its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 * @desciption
 * Contains a driver for the Digilent axi_dynclk core. To use this driver:
 *
 * 1) Find the ClkMode struct for the frequency closest to your desired
 *    frequency using ClkFindParams.
 * 2) Pass the ClkMode struct to ClkFindReg to obtain the ClkConfig struct
 *    that contains the necessary register writes that need to be made.
 * 3) Call ClkWriteReg with the ClkConfig struct and the base address of the
 *    axi_dynclk core to configure the hardware to generate the desired
 *    frequency.
 * 4) Call ClkStart to start the clock.
 * 5) If you want to change the frequency, call ClkStop and then repeat steps
 *    1-4.
 *
 * Xilinx XAPP888 was referenced for information on reconfiguring the MMCM or PLL.
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who          Date         Changes
 * ----- ------------ -----------  -----------------------------------------------
 * 1.00  Sam Bobrowicz 2015-Nov-25 First Release, separated from display_ctrl
 *
 * </pre>
 *
 *****************************************************************************/


#ifndef DYNCLK_H_
#define DYNCLK_H_

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xil_types.h"

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

#define CLK_BIT_WEDGE 13
#define CLK_BIT_NOCOUNT 12

/*
 * WEDGE and NOCOUNT can't both be high, so this is used to signal an error state
 */
#define ERR_CLKDIVIDER (1 << CLK_BIT_WEDGE | 1 << CLK_BIT_NOCOUNT)

#define ERR_CLKCOUNTCALC 0xFFFFFFFF //This value is used to signal an error

#define OFST_DYNCLK_CTRL 0x0
#define OFST_DYNCLK_STATUS 0x4
#define OFST_DYNCLK_CLK_L 0x8
#define OFST_DYNCLK_FB_L 0x0C
#define OFST_DYNCLK_FB_H_CLK_H 0x10
#define OFST_DYNCLK_DIV 0x14
#define OFST_DYNCLK_LOCK_L 0x18
#define OFST_DYNCLK_FLTR_LOCK_H 0x1C

#define BIT_DYNCLK_START 0
#define BIT_DYNCLK_RUNNING 0

/* ------------------------------------------------------------ */
/*					General Type Declarations					*/
/* ------------------------------------------------------------ */

typedef struct {
		u32 clk0L;
		u32 clkFBL;
		u32 clkFBH_clk0H;
		u32 divclk;
		u32 lockL;
		u32 fltr_lockH;
} ClkConfig;

typedef struct {
		double freq;
		u32 fbmult;
		u32 clkdiv;
		u32 maindiv;
} ClkMode;

/* ------------------------------------------------------------ */
/*					Variable Declarations						*/
/* ------------------------------------------------------------ */

static const u64 lock_lookup[64] = {
   0b0011000110111110100011111010010000000001,
   0b0011000110111110100011111010010000000001,
   0b0100001000111110100011111010010000000001,
   0b0101101011111110100011111010010000000001,
   0b0111001110111110100011111010010000000001,
   0b1000110001111110100011111010010000000001,
   0b1001110011111110100011111010010000000001,
   0b1011010110111110100011111010010000000001,
   0b1100111001111110100011111010010000000001,
   0b1110011100111110100011111010010000000001,
   0b1111111111111000010011111010010000000001,
   0b1111111111110011100111111010010000000001,
   0b1111111111101110111011111010010000000001,
   0b1111111111101011110011111010010000000001,
   0b1111111111101000101011111010010000000001,
   0b1111111111100111000111111010010000000001,
   0b1111111111100011111111111010010000000001,
   0b1111111111100010011011111010010000000001,
   0b1111111111100000110111111010010000000001,
   0b1111111111011111010011111010010000000001,
   0b1111111111011101101111111010010000000001,
   0b1111111111011100001011111010010000000001,
   0b1111111111011010100111111010010000000001,
   0b1111111111011001000011111010010000000001,
   0b1111111111011001000011111010010000000001,
   0b1111111111010111011111111010010000000001,
   0b1111111111010101111011111010010000000001,
   0b1111111111010101111011111010010000000001,
   0b1111111111010100010111111010010000000001,
   0b1111111111010100010111111010010000000001,
   0b1111111111010010110011111010010000000001,
   0b1111111111010010110011111010010000000001,
   0b1111111111010010110011111010010000000001,
   0b1111111111010001001111111010010000000001,
   0b1111111111010001001111111010010000000001,
   0b1111111111010001001111111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001,
   0b1111111111001111101011111010010000000001
};

static const u32 filter_lookup_low[64] = {
	 0b0001011111,
	 0b0001010111,
	 0b0001111011,
	 0b0001011011,
	 0b0001101011,
	 0b0001110011,
	 0b0001110011,
	 0b0001110011,
	 0b0001110011,
	 0b0001001011,
	 0b0001001011,
	 0b0001001011,
	 0b0010110011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001010011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0001100011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010010011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011,
	 0b0010100011
};

/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

u32 ClkCountCalc(u32 divide);
u32 ClkDivider(u32 divide);
u32 ClkFindReg (ClkConfig *regValues, ClkMode *clkParams);
void ClkWriteReg (ClkConfig *regValues, u32 dynClkAddr);
double ClkFindParams(double freq, ClkMode *bestPick);
void ClkStart(u32 dynClkAddr);
void ClkStop(u32 dynClkAddr);


#endif /* DYNCLK_H_ */
