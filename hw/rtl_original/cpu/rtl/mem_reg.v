/*
 -- ============================================================================
 -- FILE NAME	: mem_reg.v
 -- DESCRIPTION : MEM stage pipeline register
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
module mem_reg (
	/********** Clock & Reset **********/
	input  wire				   clk,			
	input  wire				   reset,		
	/********** Memory access result **********/
	input  wire [`WordDataBus] out,			 // Memory access result
	input  wire				   miss_align,	 // Misalignment
	/********** Pipeline control signal **********/
	input  wire				   stall,		 // Stall
	input  wire				   flush,		 // Flush
	/********** EX/MEM pipeline register **********/
	input  wire [`WordAddrBus] ex_pc,		 // Program counter
	input  wire				   ex_en,		 // Enable pipeline data
	input  wire				   ex_br_flag,	 // Branch flag
	input  wire [`CtrlOpBus]   ex_ctrl_op,	 // Control register operation
	input  wire [`RegAddrBus]  ex_dst_addr,	 // GPR write address
	input  wire				   ex_gpr_we_,	 // GPR register write enable
	input  wire [`IsaExpBus]   ex_exp_code,	 // Exception code
	/********** MEM/WB pipeline register **********/
	output reg	[`WordAddrBus] mem_pc,		 // Program counter
	output reg				   mem_en,		 // Enable pipeline data
	output reg				   mem_br_flag,	 // Branch flag
	output reg	[`CtrlOpBus]   mem_ctrl_op,	 // Control register operation
	output reg	[`RegAddrBus]  mem_dst_addr, // GPR write address
	output reg				   mem_gpr_we_,	 // GPR register write enable
	output reg	[`IsaExpBus]   mem_exp_code, // Exception code
	output reg	[`WordDataBus] mem_out		 // Processing result
);

	/********** Pipeline register **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin	 
			/* Asynchronous Reset */
			mem_pc		 <= #1 `WORD_ADDR_W'h0;
			mem_en		 <= #1 `DISABLE;
			mem_br_flag	 <= #1 `DISABLE;
			mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
			mem_dst_addr <= #1 `REG_ADDR_W'h0;
			mem_gpr_we_	 <= #1 `DISABLE_;
			mem_exp_code <= #1 `ISA_EXP_NO_EXP;
			mem_out		 <= #1 `WORD_DATA_W'h0;
		end else begin
			if (stall == `DISABLE) begin 
				/* Update pipeline register */
				if (flush == `ENABLE) begin				  // Flush
					mem_pc		 <= #1 `WORD_ADDR_W'h0;
					mem_en		 <= #1 `DISABLE;
					mem_br_flag	 <= #1 `DISABLE;
					mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
					mem_dst_addr <= #1 `REG_ADDR_W'h0;
					mem_gpr_we_	 <= #1 `DISABLE_;
					mem_exp_code <= #1 `ISA_EXP_NO_EXP;
					mem_out		 <= #1 `WORD_DATA_W'h0;
				end else if (miss_align == `ENABLE) begin // Misalignment exception
					mem_pc		 <= #1 ex_pc;
					mem_en		 <= #1 ex_en;
					mem_br_flag	 <= #1 ex_br_flag;
					mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
					mem_dst_addr <= #1 `REG_ADDR_W'h0;
					mem_gpr_we_	 <= #1 `DISABLE_;
					mem_exp_code <= #1 `ISA_EXP_MISS_ALIGN;
					mem_out		 <= #1 `WORD_DATA_W'h0;
				end else begin							  // Next data
					mem_pc		 <= #1 ex_pc;
					mem_en		 <= #1 ex_en;
					mem_br_flag	 <= #1 ex_br_flag;
					mem_ctrl_op	 <= #1 ex_ctrl_op;
					mem_dst_addr <= #1 ex_dst_addr;
					mem_gpr_we_	 <= #1 ex_gpr_we_;
					mem_exp_code <= #1 ex_exp_code;
					mem_out		 <= #1 out;
				end
			end
		end
	end

endmodule
