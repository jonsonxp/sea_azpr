/* 
 -- ============================================================================
 -- FILE NAME	: gpr.v
 -- DESCRIPTION : General purpose register (GPR)
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Local header **********/
`include "cpu.h"

/********** Module **********/
module gpr (
	/********** Clock & Reset **********/
	input  wire				   clk,				   
	input  wire				   reset,			   
	/********** Read port 0 **********/
	input  wire [`RegAddrBus]  rd_addr_0,		   // Read address
	output wire [`WordDataBus] rd_data_0,		   // Read data
	/********** Read port 1 **********/
	input  wire [`RegAddrBus]  rd_addr_1,		   // Read address
	output wire [`WordDataBus] rd_data_1,		   // Read data
	/********** Write port **********/
	input  wire				   we_,				   // Write enable
	input  wire [`RegAddrBus]  wr_addr,			   // Write address
	input  wire [`WordDataBus] wr_data			   // Write data
);

	/********** Internal signal **********/
	reg [`WordDataBus]		   gpr [`REG_NUM-1:0]; // Register array
	integer					   i;				   // iterator

	/********** Read access (Write After Read) **********/
	// Read port 0
	assign rd_data_0 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_0)) ? 
					   wr_data : gpr[rd_addr_0];
	// Read port 1
	assign rd_data_1 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_1)) ? 
					   wr_data : gpr[rd_addr_1];
   
	/********** Write access **********/
	always @ (posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			/* Asynchronous reset */
			for (i = 0; i < `REG_NUM; i = i + 1) begin
				gpr[i]		 <= #1 `WORD_DATA_W'h0;
			end
		end else begin
			/* Write access */
			if (we_ == `ENABLE_) begin 
				gpr[wr_addr] <= #1 wr_data;
			end
		end
	end

endmodule 
