/*
 -- ============================================================================
 -- FILE NAME	: rom.h
 -- DESCRIPTION : ROM header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __ROM_HEADER__
	`define __ROM_HEADER__			  // Include guard

/*
 *  ROM's size calculation example:
 *   If ROM is 8192Byte = 4KB, then
 *	 ROM_DEPTH is 8192 / 4 = 2048, 
 *	 ROM_ADDR_W is log2(2048) = 11.
 */

	`define ROM_SIZE   8192	// ROM's size
	`define ROM_DEPTH  2048	// ROM's depth
	`define ROM_ADDR_W 11	// Address width
	`define RomAddrBus 10:0 // Address bus
	`define RomAddrLoc 10:0 // Address location

`endif
