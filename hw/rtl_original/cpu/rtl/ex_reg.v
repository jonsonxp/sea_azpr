/*
 -- ============================================================================
 -- FILE NAME	: ex_reg.v
 -- DESCRIPTION : EX stage pipeline register
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
module ex_reg (
	/********** Clock & Reset **********/
	input  wire				   clk,			   
	input  wire				   reset,		  
	/********** ALU's output **********/
	input  wire [`WordDataBus] alu_out,		   // Calculation result
	input  wire				   alu_of,		   // Overflow
	/********** Pipeline control signal **********/
	input  wire				   stall,		   // Stall
	input  wire				   flush,		   // Flush
	input  wire				   int_detect,	   // Interrupt detection
	/********** ID/EX pipeline register **********/
	input  wire [`WordAddrBus] id_pc,		   // Program counter
	input  wire				   id_en,		   // Enable pipeline data
	input  wire				   id_br_flag,	   // Branch flag
	input  wire [`MemOpBus]	   id_mem_op,	   // Memory operation
	input  wire [`WordDataBus] id_mem_wr_data, // Data to write to memory
	input  wire [`CtrlOpBus]   id_ctrl_op,	   // Control operation
	input  wire [`RegAddrBus]  id_dst_addr,	   // GPR write address
	input  wire				   id_gpr_we_,	   // GPR register write enable
	input  wire [`IsaExpBus]   id_exp_code,	   // Exception code
	/********** EX/MEM pipeline register **********/
	output reg	[`WordAddrBus] ex_pc,		   // Program counter
	output reg				   ex_en,		   // Enable pipeline data
	output reg				   ex_br_flag,	   // Branch flag
	output reg	[`MemOpBus]	   ex_mem_op,	   // Memory operation
	output reg	[`WordDataBus] ex_mem_wr_data, // Data to write to memory
	output reg	[`CtrlOpBus]   ex_ctrl_op,	   // Control operation
	output reg	[`RegAddrBus]  ex_dst_addr,	   // GPR write address
	output reg				   ex_gpr_we_,	   // GPR register write enable
	output reg	[`IsaExpBus]   ex_exp_code,	   // Exception code
	output reg	[`WordDataBus] ex_out		   // Processing result
);

	/********** Pipeline register **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		/* Asynchronous Reset */
		if (reset == `RESET_ENABLE) begin 
			ex_pc		   <= #1 `WORD_ADDR_W'h0;
			ex_en		   <= #1 `DISABLE;
			ex_br_flag	   <= #1 `DISABLE;
			ex_mem_op	   <= #1 `MEM_OP_NOP;
			ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
			ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
			ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
			ex_gpr_we_	   <= #1 `DISABLE_;
			ex_exp_code	   <= #1 `ISA_EXP_NO_EXP;
			ex_out		   <= #1 `WORD_DATA_W'h0;
		end else begin
			/* Update pipeline register */
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin				  // Flush
					ex_pc		   <= #1 `WORD_ADDR_W'h0;
					ex_en		   <= #1 `DISABLE;
					ex_br_flag	   <= #1 `DISABLE;
					ex_mem_op	   <= #1 `MEM_OP_NOP;
					ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
					ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
					ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
					ex_gpr_we_	   <= #1 `DISABLE_;
					ex_exp_code	   <= #1 `ISA_EXP_NO_EXP;
					ex_out		   <= #1 `WORD_DATA_W'h0;
				end else if (int_detect == `ENABLE) begin // Interrupt detected
					ex_pc		   <= #1 id_pc;
					ex_en		   <= #1 id_en;
					ex_br_flag	   <= #1 id_br_flag;
					ex_mem_op	   <= #1 `MEM_OP_NOP;
					ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
					ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
					ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
					ex_gpr_we_	   <= #1 `DISABLE_;
					ex_exp_code	   <= #1 `ISA_EXP_EXT_INT;
					ex_out		   <= #1 `WORD_DATA_W'h0;
				end else if (alu_of == `ENABLE) begin	  // Arithmetic overflow
					ex_pc		   <= #1 id_pc;
					ex_en		   <= #1 id_en;
					ex_br_flag	   <= #1 id_br_flag;
					ex_mem_op	   <= #1 `MEM_OP_NOP;
					ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
					ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
					ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
					ex_gpr_we_	   <= #1 `DISABLE_;
					ex_exp_code	   <= #1 `ISA_EXP_OVERFLOW;
					ex_out		   <= #1 `WORD_DATA_W'h0;
				end else begin							  // Next data
					ex_pc		   <= #1 id_pc;
					ex_en		   <= #1 id_en;
					ex_br_flag	   <= #1 id_br_flag;
					ex_mem_op	   <= #1 id_mem_op;
					ex_mem_wr_data <= #1 id_mem_wr_data;
					ex_ctrl_op	   <= #1 id_ctrl_op;
					ex_dst_addr	   <= #1 id_dst_addr;
					ex_gpr_we_	   <= #1 id_gpr_we_;
					ex_exp_code	   <= #1 id_exp_code;
					ex_out		   <= #1 alu_out;
				end
			end
		end
	end

endmodule
