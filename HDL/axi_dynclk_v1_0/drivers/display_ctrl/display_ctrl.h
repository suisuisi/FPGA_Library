/************************************************************************/
/*																		*/
/*	display_ctrl.h	--	Digilent Display Controller Driver				*/
/*																		*/
/************************************************************************/
/*	Author: Sam Bobrowicz												*/
/*	Copyright 2014, Digilent Inc.										*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*		This module provides an easy to use API for controlling a    	*/
/*		Display attached to a Digilent system board via VGA or HDMI. 	*/
/*		run-time resolution setting and seamless framebuffer-swapping 	*/
/*		for tear-free animation. 										*/
/*																		*/
/*		To use this driver, you must have a Xilinx Video Timing 		*/
/* 		Controller core (vtc), Xilinx axi_vdma core, a Digilent 		*/
/*		axi_dynclk core, a Xilinx AXI Stream to Video core, and either  */
/*		a Digilent RGB2VGA or RGB2DVI core all present in your design.  */
/*		See the Video in or Display out reference projects for your     */
/*		system board to see how they need to be connected. Digilent     */
/*		reference projects and IP cores can be found at 				*/
/*		www.github.com/Digilent.			 							*/
/*																		*/
/*		The following steps should be followed to use this driver:		*/
/*		1) Create a DisplayCtrl object and pass a pointer to it to 		*/
/*		   DisplayInitialize.											*/
/*		2) Call DisplaySetMode to set the desired mode					*/
/*		3) Call DisplayStart to begin outputting data to the display	*/
/*		4) To create a seamless animation, draw the next image to a		*/
/*		   framebuffer currently not being displayed. Then call 		*/
/*		   DisplayChangeFrame to begin displaying that frame.			*/
/*		   Repeat as needed, only ever modifying inactive frames.		*/
/*		5) To change the resolution, call DisplaySetMode, followed by	*/
/*		   DisplayStart again.											*/
/*																		*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/* 																		*/
/*		2/20/2014(SamB): Created										*/
/*		11/25/2015(SamB): Changed from axi_dispctrl to Xilinx cores		*/
/*						  Separated Clock functions into dynclk library */
/*																		*/
/************************************************************************/

#ifndef DISPLAY_CTRL_H_
#define DISPLAY_CTRL_H_

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xil_types.h"
#include "xaxivdma.h"
#include "xvtc.h"
#include "../dynclk/dynclk.h"
#include "lcd_modes.h"

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

#define BIT_DISPLAY_RED 16
#define BIT_DISPLAY_GREEN 8
#define BIT_DISPLAY_BLUE 0

/*
 * This driver currently supports frames.
 */
#define DISPLAY_NUM_FRAMES 1

/* ------------------------------------------------------------ */
/*					General Type Declarations					*/
/* ------------------------------------------------------------ */

typedef enum {
	DISPLAY_STOPPED = 0,
	DISPLAY_RUNNING = 1
} DisplayState;

typedef struct {
		u32 	 dynClkAddr;/*Physical Base address of the dynclk core*/
		XAxiVdma *vdma;     /*VDMA driver struct*/
		XAxiVdma_DmaSetup vdmaConfig; /*VDMA channel configuration*/
		XVtc vtc;		 	/*VTC driver struct*/
		VideoMode vMode; 	/*Current Video mode*/
		u8 *framePtr[DISPLAY_NUM_FRAMES]; /* Array of pointers to the framebuffers */
		u32 stride; 		/* The line stride of the framebuffers, in bytes */
		double pxlFreq;		/* Frequency of clock currently being generated */
		u32 curFrame; 		/* Current frame being displayed */
		DisplayState state; /* Indicates if the Display is currently running */
} DisplayCtrl;

/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

int DisplayStop(DisplayCtrl *dispPtr);
int DisplayStart(DisplayCtrl *dispPtr);
int DisplayInitialize(DisplayCtrl *dispPtr, XAxiVdma *vdma, u16 vtcId, u32 dynClkAddr, u8 *framePtr[DISPLAY_NUM_FRAMES], u32 stride);
int DisplaySetMode(DisplayCtrl *dispPtr, const VideoMode *newMode);
int DisplayChangeFrame(DisplayCtrl *dispPtr, u32 frameIndex);

/* ------------------------------------------------------------ */

/************************************************************************/

#endif /* DISPLAY_CTRL_H_ */

