/* 
 -- ============================================================================
 -- FILE NAME	: clk_gen.v
 -- DESCRIPTION : Clock generation module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** Module **********/
module clk_gen (
	/********** Clock & Reset **********/
	input wire	clk_ref,   // Reference clock
	input wire	reset_sw,  // Reset switch
	/********** Generated clock **********/
	output wire clk,	   // Clock
	output wire clk_,	   // Clock (180)
	/********** Chip reset **********/
	output wire chip_reset // Chip select
);

	/********** Internal singal **********/
	wire		locked;	   // lock
	wire		dcm_reset; // reset

	/********** Reset generation **********/
	// DCM reset
	assign dcm_reset  = (reset_sw == `RESET_ENABLE) ? `ENABLE : `DISABLE;
	// Chip select
	assign chip_reset = ((reset_sw == `RESET_ENABLE) || (locked == `DISABLE)) ?
							`RESET_ENABLE : `RESET_DISABLE;

	/********** Xilinx DCM (Digital Clock Manager) **********/
	x_s3e_dcm x_s3e_dcm (
		.CLKIN_IN		 (clk_ref),	  // Reference clock
		.RST_IN			 (dcm_reset), // DCM reset
		.CLK0_OUT		 (clk),		  // Clock
		.CLK180_OUT		 (clk_),	  // Clock (180)
		.LOCKED_OUT		 (locked)	  // Lock
   );

endmodule
