/*
 -- ============================================================================
 -- FILE NAME	: timer.h
 -- DESCRIPTION : Timer header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __TIMER_HEADER__
	`define __TIMER_HEADER__		 // Include guard

	/********** Bus **********/
	`define TIMER_ADDR_W		2	 // Address width
	`define TimerAddrBus		1:0	 // Address bus
	`define TimerAddrLoc		1:0	 // Address location
	/********** Address map **********/
	`define TIMER_ADDR_CTRL		2'h0 // Control register 0 : control
	`define TIMER_ADDR_INTR		2'h1 // Control register 1 : interrupt
	`define TIMER_ADDR_EXPR		2'h2 // Control register 2 : expired
	`define TIMER_ADDR_COUNTER	2'h3 // Control register 3 : count
	/********** Bit map **********/
	// Control register 0 : control
	`define TimerStartLoc		0	 // Start bit location
	`define TimerModeLoc		1	 // Mode bit location
	`define TIMER_MODE_ONE_SHOT 1'b0 // Mode: one shot timer
	`define TIMER_MODE_PERIODIC 1'b1 // Mode: periodic timer
	// Control register 1 : interrupt request
	`define TimerIrqLoc			0	 // Interrupt request bit location

`endif
