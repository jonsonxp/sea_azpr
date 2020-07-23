/*
 -- ============================================================================
 -- FILE NAME	: x_s3e_dcm.v
 -- DESCRIPTION : Xilinx Spartan-3E DCM psuedo module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"

/********** Module **********/
module x_s3e_dcm (
	input  wire CLKIN_IN,		 // Reference clock
	input  wire RST_IN,			 // Reset
	output wire CLK0_OUT,		 // Clock(0)
	output wire CLK180_OUT,		 // Clock(180)
	output wire LOCKED_OUT		 // Lock
);

	/********** Clock output **********/
	assign CLK0_OUT	  = CLKIN_IN;
	assign CLK180_OUT = ~CLKIN_IN;
	assign LOCKED_OUT = ~RST_IN;
   
endmodule
