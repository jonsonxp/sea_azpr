/*
 -- ============================================================================
 -- FILE NAME	: if_stage.v
 -- DESCRIPTION : IF stage
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
module if_stage (
	/********** Clock & Reset **********/
	input  wire				   clk,			
	input  wire				   reset,		
	/********** SPM interface **********/
	input  wire [`WordDataBus] spm_rd_data, // Read data
	output wire [`WordAddrBus] spm_addr,	// Address
	output wire				   spm_as_,		// Address strobe
	output wire				   spm_rw,		// Read/Write
	output wire [`WordDataBus] spm_wr_data, // Write data
	/********** Bus interface **********/
	input  wire [`WordDataBus] bus_rd_data, // Read data
	input  wire				   bus_rdy_,	// Ready
	input  wire				   bus_grnt_,	// Bus grant
	output wire				   bus_req_,	// Bus request
	output wire [`WordAddrBus] bus_addr,	// Address
	output wire				   bus_as_,		//Address strobe
	output wire				   bus_rw,		// Read/Write
	output wire [`WordDataBus] bus_wr_data, // Write data
	/********** Pipeline control signal **********/
	input  wire				   stall,		// Stall
	input  wire				   flush,		// Flush
	input  wire [`WordAddrBus] new_pc,		// New program counter
	input  wire				   br_taken,	// Branch taken
	input  wire [`WordAddrBus] br_addr,		// Branch address
	output wire				   busy,		// Busy signal
	/********** IF/ID pipeline register **********/
	output wire [`WordAddrBus] if_pc,		// Program counter
	output wire [`WordDataBus] if_insn,		// Instruction
	output wire				   if_en		// Enable pipeline data
);

	/********** Internal signal **********/
	wire [`WordDataBus]		   insn;		// Fetched instruction

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
		.addr		 (if_pc),				
		.as_		 (`ENABLE_),			
		.rw			 (`READ),				
		.wr_data	 (`WORD_DATA_W'h0),		
		.rd_data	 (insn),				
		/********** Scratchpad memory interface **********/
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
   
	/********** IF stage pipeline register **********/
	if_reg if_reg (
		/********** Clock & Reset **********/
		.clk		 (clk),					
		.reset		 (reset),				
		/********** Fetch data **********/
		.insn		 (insn),				// Fetched instruction
		/********** Pipeline control signal **********/
		.stall		 (stall),				
		.flush		 (flush),				
		.new_pc		 (new_pc),				
		.br_taken	 (br_taken),			
		.br_addr	 (br_addr),				
		/********** IF/ID pipeline register **********/
		.if_pc		 (if_pc),				
		.if_insn	 (if_insn),				
		.if_en		 (if_en)				
	);

endmodule
