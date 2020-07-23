/*
 -- ============================================================================
 -- FILE NAME	: mem_stage.v
 -- DESCRIPTION : MEM stage
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
module mem_stage (
	/********** Clock & Reset **********/
	input  wire				   clk,			 
	input  wire				   reset,		  
	/********** Pipeline control signal **********/
	input  wire				   stall,		   // Stall
	input  wire				   flush,		   // Flush
	output wire				   busy,		   // Busy signal
	/********** Forwarding **********/
	output wire [`WordDataBus] fwd_data,	   // Forwarding
	/********** SPM interface **********/
	input  wire [`WordDataBus] spm_rd_data,	   // Read data
	output wire [`WordAddrBus] spm_addr,	   // Address
	output wire				   spm_as_,		   // Address strobe
	output wire				   spm_rw,		   // Read/Write
	output wire [`WordDataBus] spm_wr_data,	   // Write data
	/********** Bus interface **********/
	input  wire [`WordDataBus] bus_rd_data,	   // Read data
	input  wire				   bus_rdy_,	   // Ready
	input  wire				   bus_grnt_,	   // Bus grant
	output wire				   bus_req_,	   // Bus request
	output wire [`WordAddrBus] bus_addr,	   // Address
	output wire				   bus_as_,		   // Address strobe
	output wire				   bus_rw,		   // Read/Write
	output wire [`WordDataBus] bus_wr_data,	   // Write data
	/********** EX/MEM pipeline register **********/
	input  wire [`WordAddrBus] ex_pc,		   // Program counter
	input  wire				   ex_en,		   // Enable pipeline data
	input  wire				   ex_br_flag,	   // Branch flag
	input  wire [`MemOpBus]	   ex_mem_op,	   // Memory opeartion
	input  wire [`WordDataBus] ex_mem_wr_data, // Data to write to memory
	input  wire [`CtrlOpBus]   ex_ctrl_op,	   // Control register operation
	input  wire [`RegAddrBus]  ex_dst_addr,	   // GPR write address
	input  wire				   ex_gpr_we_,	   // GPR write enable
	input  wire [`IsaExpBus]   ex_exp_code,	   // Exception code
	input  wire [`WordDataBus] ex_out,		   // Processing result
	/********** MEM/WB pipeline register **********/
	output wire [`WordAddrBus] mem_pc,		   // Program counter
	output wire				   mem_en,		   // Enable pipeline dataƒp
	output wire				   mem_br_flag,	   // Branch flag
	output wire [`CtrlOpBus]   mem_ctrl_op,	   // Control register opeartion
	output wire [`RegAddrBus]  mem_dst_addr,   // GPR write address
	output wire				   mem_gpr_we_,	   // GPR write enable
	output wire [`IsaExpBus]   mem_exp_code,   // Exception code
	output wire [`WordDataBus] mem_out		   // Processing result
);

	/********** Internal signal **********/
	wire [`WordDataBus]		   rd_data;		
	wire [`WordAddrBus]		   addr;		
	wire					   as_;		
	wire					   rw;		
	wire [`WordDataBus]		   wr_data;		  
	wire [`WordDataBus]		   out;			
	wire					   miss_align;	 

	/********** Result forwarding **********/
	assign fwd_data	 = out;

	/********** Memory access control unit **********/
	mem_ctrl mem_ctrl (
		/********** EX/MEM pipeline register **********/
		.ex_en			(ex_en),			
		.ex_mem_op		(ex_mem_op),		
		.ex_mem_wr_data (ex_mem_wr_data),	 
		.ex_out			(ex_out),		
		/********** Memory access interface **********/
		.rd_data		(rd_data),			
		.addr			(addr),			
		.as_			(as_),			
		.rw				(rw),		
		.wr_data		(wr_data),			
		/********** Memory access result **********/
		.out			(out),				
		.miss_align		(miss_align)		
	);

	/********** Bus interface **********/
	bus_if bus_if (
		/********** Clock & Reset **********/
		.clk		 (clk),				
		.reset		 (reset),				
		/********** Pipeline control signal **********/
		.stall		 (stall),				 
		.flush		 (flush),				
		.busy		 (busy),				 
		/********** CPU interface **********/
		.addr		 (addr),				
		.as_		 (as_),					 
		.rw			 (rw),				
		.wr_data	 (wr_data),				
		.rd_data	 (rd_data),				  
		/********** Scrachpad memory interface **********/
		.spm_rd_data (spm_rd_data),			  
		.spm_addr	 (spm_addr),			   
		.spm_as_	 (spm_as_),				  
		.spm_rw		 (spm_rw),				
		.spm_wr_data (spm_wr_data),			
		/********** Bus interface **********/
		.bus_rd_data (bus_rd_data),			 
		.bus_rdy_	 (bus_rdy_),			
		.bus_grnt_	 (bus_grnt_),			 
		.bus_req_	 (bus_req_),			 
		.bus_addr	 (bus_addr),			
		.bus_as_	 (bus_as_),				
		.bus_rw		 (bus_rw),				  
		.bus_wr_data (bus_wr_data)			   
	);

	/********** MEM stage pipeline register **********/
	mem_reg mem_reg (
		/********** Clock & Reset **********/
		.clk		  (clk),				
		.reset		  (reset),				
		/********** Memory access result **********/
		.out		  (out),				
		.miss_align	  (miss_align),			
		/********** Pipeline control signal **********/
		.stall		  (stall),				 
		.flush		  (flush),				 
		/********** EX/MEM pipeline register **********/
		.ex_pc		  (ex_pc),				  
		.ex_en		  (ex_en),				
		.ex_br_flag	  (ex_br_flag),			 
		.ex_ctrl_op	  (ex_ctrl_op),			 
		.ex_dst_addr  (ex_dst_addr),		  
		.ex_gpr_we_	  (ex_gpr_we_),			 
		.ex_exp_code  (ex_exp_code),		
		/********** MEM/WB pipeline register **********/
		.mem_pc		  (mem_pc),				 
		.mem_en		  (mem_en),				 
		.mem_br_flag  (mem_br_flag),		   
		.mem_ctrl_op  (mem_ctrl_op),		   
		.mem_dst_addr (mem_dst_addr),		  
		.mem_gpr_we_  (mem_gpr_we_),	
		.mem_exp_code (mem_exp_code),		  
		.mem_out	  (mem_out)				  
	);

endmodule
