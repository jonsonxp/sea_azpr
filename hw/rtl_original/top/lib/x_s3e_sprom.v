/*
 -- ============================================================================
 -- FILE NAME	: x_s3e_sprom.v
 -- DESCRIPTION : Xilinx Spartan-3E Single Port ROM psuedo module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** Local header **********/
`include "rom.h"

/********** Module **********/
module x_s3e_sprom (
	input wire				  clka,	 // Clock
	input wire [`RomAddrBus]  addra, // Address
	output reg [`WordDataBus] douta	 // Read data
);

	/********** Memory **********/
	reg [`WordDataBus] mem [0:`ROM_DEPTH-1];

	/********** Read access **********/
	always @(posedge clka) begin
		douta <= #1 mem[addra];
	end

endmodule
