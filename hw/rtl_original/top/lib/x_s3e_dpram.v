/*
 -- ============================================================================
 -- FILE NAME	: x_s3e_dpram.v
 -- DESCRIPTION : Xilinx Spartan-3E Dual Port RAM psuedo module
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
`include "spm.h"

/********** Module **********/
module x_s3e_dpram (
	/********** Port A **********/
	input  wire				   clka,  // Clock
	input  wire [`SpmAddrBus]  addra, // Address
	input  wire [`WordDataBus] dina,  // Write data
	input  wire				   wea,	  // Write enable
	output reg	[`WordDataBus] douta, // Read data
	/********** Port B **********/
	input  wire				   clkb,  // Clock
	input  wire [`SpmAddrBus]  addrb, // Address
	input  wire [`WordDataBus] dinb,  // Write data
	input  wire				   web,	  // Write enable
	output reg	[`WordDataBus] doutb  // Read data
);

	/********** Memory **********/
	reg [`WordDataBus] mem [0:`SPM_DEPTH-1];

	/********** Memory access Port A **********/
	always @(posedge clka) begin
		// Read access
		if ((web == `ENABLE) && (addra == addrb)) begin
			douta	  <= #1 dinb;
		end else begin
			douta	  <= #1 mem[addra];
		end
		// Write access
		if (wea == `ENABLE) begin
			mem[addra]<= #1 dina;
		end
	end

	/********** Memory access (Port B) **********/
	always @(posedge clkb) begin
		// Read access
		if ((wea == `ENABLE) && (addrb == addra)) begin
			doutb	  <= #1 dina;
		end else begin
			doutb	  <= #1 mem[addrb];
		end
		// Write access
		if (web == `ENABLE) begin
			mem[addrb]<= #1 dinb;
		end
	end

endmodule
