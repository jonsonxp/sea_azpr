/* 
 -- ============================================================================
 -- FILE NAME	: id_reg.v
 -- DESCRIPTION : ID stage pipeline register
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
module id_reg (
	/********** Clock & Reset **********/
	input  wire				   clk,			   
	input  wire				   reset,		   
	/********** Decode result **********/
	input  wire [`AluOpBus]	   alu_op,		   // ALU operation
	input  wire [`WordDataBus] alu_in_0,	   // ALU input 0
	input  wire [`WordDataBus] alu_in_1,	   // ALU input 1
	input  wire				   br_flag,		   // Branch flag
	input  wire [`MemOpBus]	   mem_op,		   // Memory operation
	input  wire [`WordDataBus] mem_wr_data,	   // Data to write to memory
	input  wire [`CtrlOpBus]   ctrl_op,		   // Control operation
	input  wire [`RegAddrBus]  dst_addr,	   // GPR write address
	input  wire				   gpr_we_,		   // GPR register write enable
	input  wire [`IsaExpBus]   exp_code,	   // Exception code
	/********** Pipeline control signal **********/
	input  wire				   stall,		   // Stall
	input  wire				   flush,		   // Flush
	/********** IF/ID pipeline register **********/
	input  wire [`WordAddrBus] if_pc,		   // Program counter
	input  wire				   if_en,		   // Enable pipeline data
	/********** ID/EX pipeline register **********/
	output reg	[`WordAddrBus] id_pc,		   // Program counter
	output reg				   id_en,		   // Enable pipeline data
	output reg	[`AluOpBus]	   id_alu_op,	   // ALU operation
	output reg	[`WordDataBus] id_alu_in_0,	   // ALU input 0
	output reg	[`WordDataBus] id_alu_in_1,	   // ALU input 1
	output reg				   id_br_flag,	   // Branch flag
	output reg	[`MemOpBus]	   id_mem_op,	   // Memory operation
	output reg	[`WordDataBus] id_mem_wr_data, // Data to write to memory
	output reg	[`CtrlOpBus]   id_ctrl_op,	   // Control operation
	output reg	[`RegAddrBus]  id_dst_addr,	   // GPR write address
	output reg				   id_gpr_we_,	   // GPR register write enable
	output reg [`IsaExpBus]	   id_exp_code	   // Exception code
);

	/********** Pipeline register **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			/* Asynchronous Reset */
			id_pc		   <= #1 `WORD_ADDR_W'h0;
			id_en		   <= #1 `DISABLE;
			id_alu_op	   <= #1 `ALU_OP_NOP;
			id_alu_in_0	   <= #1 `WORD_DATA_W'h0;
			id_alu_in_1	   <= #1 `WORD_DATA_W'h0;
			id_br_flag	   <= #1 `DISABLE;
			id_mem_op	   <= #1 `MEM_OP_NOP;
			id_mem_wr_data <= #1 `WORD_DATA_W'h0;
			id_ctrl_op	   <= #1 `CTRL_OP_NOP;
			id_dst_addr	   <= #1 `REG_ADDR_W'd0;
			id_gpr_we_	   <= #1 `DISABLE_;
			id_exp_code	   <= #1 `ISA_EXP_NO_EXP;
		end else begin
			/* Update pipeline register */
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin // Flush
				   id_pc		  <= #1 `WORD_ADDR_W'h0;
				   id_en		  <= #1 `DISABLE;
				   id_alu_op	  <= #1 `ALU_OP_NOP;
				   id_alu_in_0	  <= #1 `WORD_DATA_W'h0;
				   id_alu_in_1	  <= #1 `WORD_DATA_W'h0;
				   id_br_flag	  <= #1 `DISABLE;
				   id_mem_op	  <= #1 `MEM_OP_NOP;
				   id_mem_wr_data <= #1 `WORD_DATA_W'h0;
				   id_ctrl_op	  <= #1 `CTRL_OP_NOP;
				   id_dst_addr	  <= #1 `REG_ADDR_W'd0;
				   id_gpr_we_	  <= #1 `DISABLE_;
				   id_exp_code	  <= #1 `ISA_EXP_NO_EXP;
				end else begin				// Next data
				   id_pc		  <= #1 if_pc;
				   id_en		  <= #1 if_en;
				   id_alu_op	  <= #1 alu_op;
				   id_alu_in_0	  <= #1 alu_in_0;
				   id_alu_in_1	  <= #1 alu_in_1;
				   id_br_flag	  <= #1 br_flag;
				   id_mem_op	  <= #1 mem_op;
				   id_mem_wr_data <= #1 mem_wr_data;
				   id_ctrl_op	  <= #1 ctrl_op;
				   id_dst_addr	  <= #1 dst_addr;
				   id_gpr_we_	  <= #1 gpr_we_;
				   id_exp_code	  <= #1 exp_code;
				end
			end
		end
	end

endmodule
