/*
 -- ============================================================================
 -- FILE NAME	: spm.h
 -- DESCRIPTION : Scratchpad memory header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __SPM_HEADER__
	`define __SPM_HEADER__			  // Include guard

/*
 *  PM size calculation example:
 * If SPM's size is 16384Byte = 16KB,
 *	 SPM_DEPTH is 16384 / 4 = 4096,
 *	 SPM_ADDR_W is log2(4096) = 12.
 */

	`define SPM_SIZE   16384 // SPM's size
	`define SPM_DEPTH  4096	 // SPM's depth
	`define SPM_ADDR_W 12	 // address width
	`define SpmAddrBus 11:0	 // Address bus
	`define SpmAddrLoc 11:0	 // Address location

`endif
