/*
 -- ============================================================================
 -- FILE NAME	: if_reg.v
 -- DESCRIPTION : IF stage pipeline register
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
`include "isa.h"
`include "cpu.h"

/********** Module **********/
module if_reg (
	/********** Clock & Reset **********/
	input  wire				   clk,		  
	input  wire				   reset,	   
	/********** Fetch data **********/
	input  wire [`WordDataBus] insn,	   // Fetched instruction
	/********** Pipeline control signal **********/
	input  wire				   stall,	   
	input  wire				   flush,	   
	input  wire [`WordAddrBus] new_pc,	   // New program counter
	input  wire				   br_taken,   // Branch taken
	input  wire [`WordAddrBus] br_addr,	   // Branch address
	/********** IF/ID pipeline register **********/
	output reg	[`WordAddrBus] if_pc,	   // Program counter
	output reg	[`WordDataBus] if_insn,	   // Instruction
	output reg				   if_en	   // Enable pipeline data
);

	/********** Pipeline register **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			/* Asynchronous reset */
			if_pc	<= #1 `RESET_VECTOR;
			if_insn <= #1 `ISA_NOP;
			if_en	<= #1 `DISABLE;
		end else begin
			/* Update pipeline register */
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin				// Flush
					if_pc	<= #1 new_pc;
					if_insn <= #1 `ISA_NOP;
					if_en	<= #1 `DISABLE;
				end else if (br_taken == `ENABLE) begin // Branch taken
					if_pc	<= #1 br_addr;
					if_insn <= #1 insn;
					if_en	<= #1 `ENABLE;
				end else begin							// Next address
					if_pc	<= #1 if_pc + 1'd1;
					if_insn <= #1 insn;
					if_en	<= #1 `ENABLE;
				end
			end
		end
	end

endmodule
