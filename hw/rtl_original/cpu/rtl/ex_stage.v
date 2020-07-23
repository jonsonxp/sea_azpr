/*
 -- ============================================================================
 -- FILE NAME	: ex_stage.v
 -- DESCRIPTION : EX Stage
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
module ex_stage (
	/********** Clock & Reset **********/
	input  wire				   clk,			   
	input  wire				   reset,		   
	/********** Pipeline control signal **********/
	input  wire				   stall,		   // Stal
	input  wire				   flush,		   // Flush
	input  wire				   int_detect,	   // Interrupt detection
	/********** Forwarding **********/
	output wire [`WordDataBus] fwd_data,	   // Forwarding
	/********** ID/EX pipeline register **********/
	input  wire [`WordAddrBus] id_pc,		   // Program counter
	input  wire				   id_en,		   // Enable pipeline data
	input  wire [`AluOpBus]	   id_alu_op,	   // ALU operation
	input  wire [`WordDataBus] id_alu_in_0,	   // ALU input 0
	input  wire [`WordDataBus] id_alu_in_1,	   // ALU input 1
	input  wire				   id_br_flag,	   // Branch flag
	input  wire [`MemOpBus]	   id_mem_op,	   // Memory operation
	input  wire [`WordDataBus] id_mem_wr_data, // Memory write data
	input  wire [`CtrlOpBus]   id_ctrl_op,	   // Control register operation
	input  wire [`RegAddrBus]  id_dst_addr,	   // GPR write address
	input  wire				   id_gpr_we_,	   // GPR write enable
	input  wire [`IsaExpBus]   id_exp_code,	   // Exception code
	/********** EX/MEM pipeline register **********/
	output wire [`WordAddrBus] ex_pc,		   // Program counter
	output wire				   ex_en,		   // Enable pipeline data
	output wire				   ex_br_flag,	   // Branch flag
	output wire [`MemOpBus]	   ex_mem_op,	   // Memory operation
	output wire [`WordDataBus] ex_mem_wr_data, // Memory write data
	output wire [`CtrlOpBus]   ex_ctrl_op,	   // Control register operation
	output wire [`RegAddrBus]  ex_dst_addr,	   // GPR write address
	output wire				   ex_gpr_we_,	   // GPR write enable
	output wire [`IsaExpBus]   ex_exp_code,	   // Exception code
	output wire [`WordDataBus] ex_out		   // Processing result
);

	/********** ALU's output **********/
	wire [`WordDataBus]		   alu_out;		   // Result
	wire					   alu_of;		   // Overflow

	/********** Forwarding result **********/
	assign fwd_data = alu_out;

	/********** ALU **********/
	alu alu (
		.in_0			(id_alu_in_0),	  // Input 0
		.in_1			(id_alu_in_1),	  // Input 1
		.op				(id_alu_op),	  // Operation
		.out			(alu_out),		  // Output
		.of				(alu_of)		  // Overflow
	);

	/********** Pipeline register **********/
	ex_reg ex_reg (
		/********** Clock & Reset **********/
		.clk			(clk),			  
		.reset			(reset),		  
		/********** ALU's output **********/
		.alu_out		(alu_out),		  
		.alu_of			(alu_of),		 
		/********** Pipeline control signal **********/
		.stall			(stall),		 
		.flush			(flush),		  
		.int_detect		(int_detect),	  
		/********** ID/EX pipeline register **********/
		.id_pc			(id_pc),		 
		.id_en			(id_en),		  
		.id_br_flag		(id_br_flag),	  
		.id_mem_op		(id_mem_op),	  
		.id_mem_wr_data (id_mem_wr_data), 
		.id_ctrl_op		(id_ctrl_op),	  
		.id_dst_addr	(id_dst_addr),	  
		.id_gpr_we_		(id_gpr_we_),	  
		.id_exp_code	(id_exp_code),	 
		/********** EX/MEM pipeline register **********/
		.ex_pc			(ex_pc),		
		.ex_en			(ex_en),		 
		.ex_br_flag		(ex_br_flag),	  
		.ex_mem_op		(ex_mem_op),	  
		.ex_mem_wr_data (ex_mem_wr_data), 
		.ex_ctrl_op		(ex_ctrl_op),	  
		.ex_dst_addr	(ex_dst_addr),	  
		.ex_gpr_we_		(ex_gpr_we_),	  
		.ex_exp_code	(ex_exp_code),	 
		.ex_out			(ex_out)		  
	);

endmodule
