/*
 -- ============================================================================
 -- FILE NAME	: cpu.v
 -- DESCRIPTION : CPU top module
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
`include "bus.h"
`include "spm.h"

/********** Module **********/
module cpu (
	/********** Clock & Reset **********/
	input  wire					  clk,			   // Clock
	input  wire					  clk_,			   // Clock (180)
	input  wire					  reset,		   // Asynchronous reset
	/********** Bus interface **********/
	// IF Stage
	input  wire [`WordDataBus]	  if_bus_rd_data,  // Read data
	input  wire					  if_bus_rdy_,	   // Ready
	input  wire					  if_bus_grnt_,	   // Bus grant
	output wire					  if_bus_req_,	   // Bus request
	output wire [`WordAddrBus]	  if_bus_addr,	   // Address
	output wire					  if_bus_as_,	   // Address strobe
	output wire					  if_bus_rw,	   // Read/Write
	output wire [`WordDataBus]	  if_bus_wr_data,  // Write data
	// MEM Stage
	input  wire [`WordDataBus]	  mem_bus_rd_data, // Read data
	input  wire					  mem_bus_rdy_,	   // Ready
	input  wire					  mem_bus_grnt_,   // Bus grant
	output wire					  mem_bus_req_,	   // Bus reqeuest
	output wire [`WordAddrBus]	  mem_bus_addr,	   // Address
	output wire					  mem_bus_as_,	   // Address strobe
	output wire					  mem_bus_rw,	   // Read/Write
	output wire [`WordDataBus]	  mem_bus_wr_data, // Write data
	/********** Interrupt **********/
	input  wire [`CPU_IRQ_CH-1:0] cpu_irq		   // Interrupt request
);

	/********** Pipeline register **********/
	// IF/ID
	wire [`WordAddrBus]			 if_pc;			 
	wire [`WordDataBus]			 if_insn;		 
	wire						 if_en;			
	// ID/EX pipeline register
	wire [`WordAddrBus]			 id_pc;			 
	wire						 id_en;			
	wire [`AluOpBus]			 id_alu_op;		
	wire [`WordDataBus]			 id_alu_in_0;	
	wire [`WordDataBus]			 id_alu_in_1;	 
	wire						 id_br_flag;	
	wire [`MemOpBus]			 id_mem_op;		
	wire [`WordDataBus]			 id_mem_wr_data;
	wire [`CtrlOpBus]			 id_ctrl_op;	
	wire [`RegAddrBus]			 id_dst_addr;	
	wire						 id_gpr_we_;
	wire [`IsaExpBus]			 id_exp_code;
	// EX/MEM pipeline register
	wire [`WordAddrBus]			 ex_pc;	
	wire						 ex_en;			 
	wire						 ex_br_flag;	 
	wire [`MemOpBus]			 ex_mem_op;		 
	wire [`WordDataBus]			 ex_mem_wr_data; 
	wire [`CtrlOpBus]			 ex_ctrl_op;	 
	wire [`RegAddrBus]			 ex_dst_addr;	 
	wire						 ex_gpr_we_;	
	wire [`IsaExpBus]			 ex_exp_code;	
	wire [`WordDataBus]			 ex_out;		
	// MEM/WB pipeline register
	wire [`WordAddrBus]			 mem_pc;		
	wire						 mem_en;		
	wire						 mem_br_flag;	 
	wire [`CtrlOpBus]			 mem_ctrl_op;	
	wire [`RegAddrBus]			 mem_dst_addr;	 
	wire						 mem_gpr_we_;	 
	wire [`IsaExpBus]			 mem_exp_code;	 
	wire [`WordDataBus]			 mem_out;		 
	/********** Pipeline control signal **********/
	// Stall signal
	wire						 if_stall;		 // IF stage
	wire						 id_stall;		 // ID stage
	wire						 ex_stall;		 // EX stage
	wire						 mem_stall;		 // MEM stage
	// Flush signal
	wire						 if_flush;		 // IF stage
	wire						 id_flush;		 // ID stage
	wire						 ex_flush;		 // EX stage
	wire						 mem_flush;		 // MEM stage
	// Busy signal
	wire						 if_busy;		 // IF stage
	wire						 mem_busy;		 // MEM stage
	// Other control signal
	wire [`WordAddrBus]			 new_pc;		 // New program counter
	wire [`WordAddrBus]			 br_addr;		 // Branch address
	wire						 br_taken;		 // Branch taken
	wire						 ld_hazard;		 // Load hazard
	/********** GPR signal **********/
	wire [`WordDataBus]			 gpr_rd_data_0;	
	wire [`WordDataBus]			 gpr_rd_data_1;	
	wire [`RegAddrBus]			 gpr_rd_addr_0;	
	wire [`RegAddrBus]			 gpr_rd_addr_1;	
	/********** Control register signal **********/
	wire [`CpuExeModeBus]		 exe_mode;		
	wire [`WordDataBus]			 creg_rd_data;	 
	wire [`RegAddrBus]			 creg_rd_addr;	 
	/********** Interrupt Request **********/
	wire						 int_detect;	
	/********** Scratchpad memory signal **********/
	// IF stage
	wire [`WordDataBus]			 if_spm_rd_data; 
	wire [`WordAddrBus]			 if_spm_addr;	 
	wire						 if_spm_as_;	
	wire						 if_spm_rw;		
	wire [`WordDataBus]			 if_spm_wr_data;
	// MEM stage
	wire [`WordDataBus]			 mem_spm_rd_data; 
	wire [`WordAddrBus]			 mem_spm_addr;	  
	wire						 mem_spm_as_;	 
	wire						 mem_spm_rw;
	wire [`WordDataBus]			 mem_spm_wr_data; 
	/********** Forwarding signal **********/
	wire [`WordDataBus]			 ex_fwd_data;	  // EX stage
	wire [`WordDataBus]			 mem_fwd_data;	  // MEM stage

	/********** IF stage **********/
	if_stage if_stage (
		/********** Clock & Reset **********/
		.clk			(clk),				
		.reset			(reset),			
		/********** SPM interface **********/
		.spm_rd_data	(if_spm_rd_data),	
		.spm_addr		(if_spm_addr),		
		.spm_as_		(if_spm_as_),		
		.spm_rw			(if_spm_rw),		
		.spm_wr_data	(if_spm_wr_data),	
		/********** Bus interface **********/
		.bus_rd_data	(if_bus_rd_data),	
		.bus_rdy_		(if_bus_rdy_),	
		.bus_grnt_		(if_bus_grnt_),	
		.bus_req_		(if_bus_req_),		
		.bus_addr		(if_bus_addr),		
		.bus_as_		(if_bus_as_),		
		.bus_rw			(if_bus_rw),		
		.bus_wr_data	(if_bus_wr_data),	
		/********** Pipeline control signal **********/
		.stall			(if_stall),			
		.flush			(if_flush),			
		.new_pc			(new_pc),			
		.br_taken		(br_taken),			
		.br_addr		(br_addr),			
		.busy			(if_busy),		
		/********** IF/ID pipeline register **********/
		.if_pc			(if_pc),			
		.if_insn		(if_insn),			
		.if_en			(if_en)				
	);

	/********** ID stage **********/
	id_stage id_stage (
		/********** Clock & Reset **********/
		.clk			(clk),				
		.reset			(reset),			
		/********** GPR interface **********/
		.gpr_rd_data_0	(gpr_rd_data_0),	
		.gpr_rd_data_1	(gpr_rd_data_1),	
		.gpr_rd_addr_0	(gpr_rd_addr_0),	
		.gpr_rd_addr_1	(gpr_rd_addr_1),	
		/********** Forwarding **********/
		// Forwarding from EX stage
		.ex_en			(ex_en),			
		.ex_fwd_data	(ex_fwd_data),		
		.ex_dst_addr	(ex_dst_addr),		
		.ex_gpr_we_		(ex_gpr_we_),		
		// Forwarding from MEM stage
		.mem_fwd_data	(mem_fwd_data),		
		/********** Control register interface **********/
		.exe_mode		(exe_mode),		
		.creg_rd_data	(creg_rd_data),	
		.creg_rd_addr	(creg_rd_addr),		
		/********** Pipeline control signal **********/
	   .stall		   (id_stall),	
		.flush			(id_flush),			
		.br_addr		(br_addr),			
		.br_taken		(br_taken),			
		.ld_hazard		(ld_hazard),		
		/********** IF/ID pipeline register **********/
		.if_pc			(if_pc),			
		.if_insn		(if_insn),			
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

	/********** EX stage **********/
	ex_stage ex_stage (
		/********** Clock & Reset **********/
		.clk			(clk),				
		.reset			(reset),			
		/********** Pipeline control signal **********/
		.stall			(ex_stall),			
		.flush			(ex_flush),			
		.int_detect		(int_detect),		
		/********** Forwarding **********/
		.fwd_data		(ex_fwd_data),		
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

	/********** MEM Stage **********/
	mem_stage mem_stage (
		/********** Clock & Reset **********/
		.clk			(clk),				
		.reset			(reset),			
		/********** Pipeline control signal **********/
		.stall			(mem_stall),		
		.flush			(mem_flush),		
		.busy			(mem_busy),			
		/********** Forwarding **********/
		.fwd_data		(mem_fwd_data),		
		/********** SPM interface **********/
		.spm_rd_data	(mem_spm_rd_data),	
		.spm_addr		(mem_spm_addr),		
		.spm_as_		(mem_spm_as_),		
		.spm_rw			(mem_spm_rw),		
		.spm_wr_data	(mem_spm_wr_data),	
		/********** Bus interface **********/
		.bus_rd_data	(mem_bus_rd_data),	
		.bus_rdy_		(mem_bus_rdy_),		
		.bus_grnt_		(mem_bus_grnt_),	
		.bus_req_		(mem_bus_req_),		
		.bus_addr		(mem_bus_addr),		
		.bus_as_		(mem_bus_as_),		
		.bus_rw			(mem_bus_rw),		
		.bus_wr_data	(mem_bus_wr_data),	
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
		.ex_out			(ex_out),			
		/********** MEM/WB pipeline register **********/
		.mem_pc			(mem_pc),			
		.mem_en			(mem_en),			
		.mem_br_flag	(mem_br_flag),		
		.mem_ctrl_op	(mem_ctrl_op),		
		.mem_dst_addr	(mem_dst_addr),		
		.mem_gpr_we_	(mem_gpr_we_),		
		.mem_exp_code	(mem_exp_code),		
		.mem_out		(mem_out)			
	);

	/********** Control unit **********/
	ctrl ctrl (
		/********** Clock & Reset **********/
		.clk			(clk),				
		.reset			(reset),			
		/********** Control register interface **********/
		.creg_rd_addr	(creg_rd_addr),		
		.creg_rd_data	(creg_rd_data),		
		.exe_mode		(exe_mode),			
		/********** Interrupt **********/
		.irq			(cpu_irq),			
		.int_detect		(int_detect),		
		/********** ID/EX pipeline register **********/
		.id_pc			(id_pc),			
		/********** MEM/WB pipeline register **********/
		.mem_pc			(mem_pc),			
		.mem_en			(mem_en),			
		.mem_br_flag	(mem_br_flag),		
		.mem_ctrl_op	(mem_ctrl_op),		
		.mem_dst_addr	(mem_dst_addr),		
		.mem_exp_code	(mem_exp_code),		
		.mem_out		(mem_out),			
		/********** Pipeline control signal **********/
		// Status of pipeline
		.if_busy		(if_busy),			
		.ld_hazard		(ld_hazard),		
		.mem_busy		(mem_busy),			
		// stall singal
		.if_stall		(if_stall),			
		.id_stall		(id_stall),			
		.ex_stall		(ex_stall),			
		.mem_stall		(mem_stall),		
		// Flush signal
		.if_flush		(if_flush),			
		.id_flush		(id_flush),			
		.ex_flush		(ex_flush),		
		.mem_flush		(mem_flush),		
		// New program counter
		.new_pc			(new_pc)			
	);

	/********** GPR **********/
	gpr gpr (
		/********** Clock & Reset **********/
		.clk	   (clk),					
		.reset	   (reset),					
		/********** Read port 0 **********/
		.rd_addr_0 (gpr_rd_addr_0),			
		.rd_data_0 (gpr_rd_data_0),			
		/********** Read port 1 **********/
		.rd_addr_1 (gpr_rd_addr_1),			
		.rd_data_1 (gpr_rd_data_1),			
		/********** Write port **********/
		.we_	   (mem_gpr_we_),			
		.wr_addr   (mem_dst_addr),			
		.wr_data   (mem_out)				
	);

	/********** Scratchpad memory **********/
	spm spm (
		/********** Clock **********/
		.clk			 (clk_),					 
		/********** PortA : IF stage **********/
		.if_spm_addr	 (if_spm_addr[`SpmAddrLoc]), 
		.if_spm_as_		 (if_spm_as_),				  
		.if_spm_rw		 (if_spm_rw),				
		.if_spm_wr_data	 (if_spm_wr_data),			 
		.if_spm_rd_data	 (if_spm_rd_data),			  
		/********** PortB : MEM stage **********/
		.mem_spm_addr	 (mem_spm_addr[`SpmAddrLoc]), 
		.mem_spm_as_	 (mem_spm_as_),				
		.mem_spm_rw		 (mem_spm_rw),				 
		.mem_spm_wr_data (mem_spm_wr_data),			  
		.mem_spm_rd_data (mem_spm_rd_data)			 
	);

endmodule
