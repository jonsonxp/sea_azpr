/*
 -- ============================================================================
 -- FILE NAME	: rom.v
 -- DESCRIPTION : Read Only Memory
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
module rom (
	/********** Clock & Reset **********/
	input  wire				   clk,		// Clock
	input  wire				   reset,	// Asynchronous reset
	/********** Bus interface **********/
	input  wire				   cs_,		// Chip select
	input  wire				   as_,		// Address strobe
	input  wire [`RomAddrBus]  addr,	// Address
	output wire [`WordDataBus] rd_data, // Read data
	output reg				   rdy_		// Ready
);

	/********** Xilinx FPGA Block RAM : Single port ROM **********/
	x_s3e_sprom x_s3e_sprom (
		.clka  (clk),					// Clock
		.addra (addr),					// Address
		.douta (rd_data)				// Read data
	);

	/********** Generate ready **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			rdy_ <= #1 `DISABLE_;
		end else begin
			/* Generate ready */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
				rdy_ <= #1 `ENABLE_;
			end else begin
				rdy_ <= #1 `DISABLE_;
			end
		end
	end

endmodule
