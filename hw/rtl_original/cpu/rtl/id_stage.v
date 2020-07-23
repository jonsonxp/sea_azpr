/*
 -- ============================================================================
 -- FILE NAME	: id_stage.v
 -- DESCRIPTION : ID stage
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
module id_stage (
	/********** Clock & Reset **********/
	input  wire					 clk,			 
	input  wire					 reset,			 
	/********** GPR interface **********/
	input  wire [`WordDataBus]	 gpr_rd_data_0,	 // Read data 0
	input  wire [`WordDataBus]	 gpr_rd_data_1,	 // Read data 1
	output wire [`RegAddrBus]	 gpr_rd_addr_0,	 // Read Address 0
	output wire [`RegAddrBus]	 gpr_rd_addr_1,	 // Read Address 1
	/********** Forwarding **********/
	// Forwarding from EX stage
	input  wire					 ex_en,			// Enable pipeline data
	input  wire [`WordDataBus]	 ex_fwd_data,	 // Forwarding data
	input  wire [`RegAddrBus]	 ex_dst_addr,	 // Write address
	input  wire					 ex_gpr_we_,	 // Write enable
	// Forwarding from MEM stage
	input  wire [`WordDataBus]	 mem_fwd_data,	 // Forwarding
	/********** Control register interface **********/
	input  wire [`CpuExeModeBus] exe_mode,		 // Execution mode
	input  wire [`WordDataBus]	 creg_rd_data,	 // Read data
	output wire [`RegAddrBus]	 creg_rd_addr,	 // Read address
	/********** Pipeline control signal **********/
	input  wire					 stall,			 
	input  wire					 flush,			 
	output wire [`WordAddrBus]	 br_addr,		 // Branch address
	output wire					 br_taken,		 // Branch taken
	output wire					 ld_hazard,		 // Load hazard
	/********** IF/ID pipeline register **********/
	input  wire [`WordAddrBus]	 if_pc,			 // Program counter
	input  wire [`WordDataBus]	 if_insn,		 // Instruction
	input  wire					 if_en,			 // Enable pipeline data
	/********** ID/EX pipeline register **********/
	output wire [`WordAddrBus]	 id_pc,			 // Program counter
	output wire					 id_en,			 // Enable pipeline data
	output wire [`AluOpBus]		 id_alu_op,		 // ALU operation
	output wire [`WordDataBus]	 id_alu_in_0,	 // ALU input 0
	output wire [`WordDataBus]	 id_alu_in_1,	 // ALU input 1
	output wire					 id_br_flag,	 // Branch flag
	output wire [`MemOpBus]		 id_mem_op,		 // Memory opeartion
	output wire [`WordDataBus]	 id_mem_wr_data, // Data to write to memory
	output wire [`CtrlOpBus]	 id_ctrl_op,	 // Control operation
	output wire [`RegAddrBus]	 id_dst_addr,	 // GPR write address
	output wire					 id_gpr_we_,	 // GPR write enable
	output wire [`IsaExpBus]	 id_exp_code	 // Exception code
);

	/********** Decode signal **********/
	wire  [`AluOpBus]			 alu_op;		 // ALU operation
	wire  [`WordDataBus]		 alu_in_0;		 // ALU input 0
	wire  [`WordDataBus]		 alu_in_1;		 // ALU input 1
	wire						 br_flag;		 // Branch flag
	wire  [`MemOpBus]			 mem_op;		 // Memory operation
	wire  [`WordDataBus]		 mem_wr_data;	 // Data to write to memory
	wire  [`CtrlOpBus]			 ctrl_op;		 // Control operation
	wire  [`RegAddrBus]			 dst_addr;		 // GPR write address
	wire						 gpr_we_;		 // GPR write enable
	wire  [`IsaExpBus]			 exp_code;		 // Exception code

	/********** Decoder **********/
	decoder decoder (
		/********** IF/ID pipeline register **********/
		.if_pc			(if_pc),		  // Program counter
		.if_insn		(if_insn),		  // Instruction
		.if_en			(if_en),		  // Enable pipeline data
		/********** GPR interface **********/
		.gpr_rd_data_0	(gpr_rd_data_0),  // Read data 0
		.gpr_rd_data_1	(gpr_rd_data_1),  // Read data 1
		.gpr_rd_addr_0	(gpr_rd_addr_0),  // Read address 0
		.gpr_rd_addr_1	(gpr_rd_addr_1),  // Read address 1
		/********** Forwarding **********/
		// Forwarding form ID stage
		.id_en			(id_en),		  
		.id_dst_addr	(id_dst_addr),	  
		.id_gpr_we_		(id_gpr_we_),	  
		.id_mem_op		(id_mem_op),	 
		// Forwarding form EX stage
		.ex_en			(ex_en),		  
		.ex_fwd_data	(ex_fwd_data),	  
		.ex_dst_addr	(ex_dst_addr),	  
		.ex_gpr_we_		(ex_gpr_we_),	  
		// Forwarding form MEM stage
		.mem_fwd_data	(mem_fwd_data),	  
		/********** Control register interface **********/
		.exe_mode		(exe_mode),		  
		.creg_rd_data	(creg_rd_data),	  
		.creg_rd_addr	(creg_rd_addr),	  
		/********** Decode signal **********/
		.alu_op			(alu_op),		  
		.alu_in_0		(alu_in_0),		 
		.alu_in_1		(alu_in_1),		  
		.br_addr		(br_addr),		
		.br_taken		(br_taken),		 
		.br_flag		(br_flag),		 
		.mem_op			(mem_op),		  
		.mem_wr_data	(mem_wr_data),	 
		.ctrl_op		(ctrl_op),		 
		.dst_addr		(dst_addr),		  
		.gpr_we_		(gpr_we_),		
		.exp_code		(exp_code),		 
		.ld_hazard		(ld_hazard)		 
	);

	/********** Pipeline register **********/
	id_reg id_reg (
		/********** Clock & Reset **********/
		.clk			(clk),			 
		.reset			(reset),		  
		/********** Decode result **********/
		.alu_op			(alu_op),		  
		.alu_in_0		(alu_in_0),		 
		.alu_in_1		(alu_in_1),		  
		.br_flag		(br_flag),		  
		.mem_op			(mem_op),		  
		.mem_wr_data	(mem_wr_data),	
		.ctrl_op		(ctrl_op),		
		.dst_addr		(dst_addr),		  
		.gpr_we_		(gpr_we_),		  
		.exp_code		(exp_code),		  
		/********** Pipeline control signal **********/
		.stall			(stall),		
		.flush			(flush),		  
		/********** IF/ID pipeline register **********/
		.if_pc			(if_pc),		 
		.if_en			(if_en),		 
		/********** ID/EX pipeline register **********/
		.id_pc			(id_pc),		  
		.id_en			(id_en),		  
		.id_alu_op		(id_alu_op),	  
		.id_alu_in_0	(id_alu_in_0),	  
		.id_alu_in_1	(id_alu_in_1),	  
		.id_br_flag		(id_br_flag),	  
		.id_mem_op		(id_mem_op),	  
		.id_mem_wr_data (id_mem_wr_data),
		.id_ctrl_op		(id_ctrl_op),	 
		.id_dst_addr	(id_dst_addr),	  
		.id_gpr_we_		(id_gpr_we_),	  
		.id_exp_code	(id_exp_code)	 
	);

endmodule
