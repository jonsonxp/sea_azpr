/*
 -- ============================================================================
 -- FILE NAME	: gpio.h
 -- DESCRIPTION : General Purpose I/O header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __GPIO_HEADER__
   `define __GPIO_HEADER__			// Include guard

	/********** The number of ports **********/
	`define GPIO_IN_CH		   4	// The number of input ports
	`define GPIO_OUT_CH		   18	// The number of output ports
	`define GPIO_IO_CH		   16	// The number of inout ports
  
	/********** Bus **********/
	`define GpioAddrBus		   1:0	// Address bus
	`define GPIO_ADDR_W		   2	// Address width
	`define GpioAddrLoc		   1:0	// Address location
	/********** Address map **********/
	`define GPIO_ADDR_IN_DATA  2'h0 // Ctrl register 0 : input port
	`define GPIO_ADDR_OUT_DATA 2'h1 // Ctrl register 1 : output port
	`define GPIO_ADDR_IO_DATA  2'h2 // Ctrl register 2 : inout port
	`define GPIO_ADDR_IO_DIR   2'h3 // Ctrl register 3 : inout direction
	/********** Inout direction **********/
	`define GPIO_DIR_IN		   1'b0 // input
	`define GPIO_DIR_OUT	   1'b1 // output

`endif
