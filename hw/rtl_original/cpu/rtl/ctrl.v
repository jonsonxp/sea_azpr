/*
 -- ============================================================================
 -- FILE NAME	: ctrl.v
 -- DESCRIPTION : Control unit
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
`include "rom.h"
`include "spm.h"

/********** Module **********/
module ctrl (
	/********** Clock & Reset **********/
	input  wire					  clk,			
	input  wire					  reset,		
	/********** Control register interface **********/
	input  wire [`RegAddrBus]	  creg_rd_addr, // Read address
	output reg	[`WordDataBus]	  creg_rd_data, // Read data
	output reg	[`CpuExeModeBus]  exe_mode,		// Execution mode
	/********** Interrupt **********/
	input  wire [`CPU_IRQ_CH-1:0] irq,			// Interrupt request
	output reg					  int_detect,	// Interrupt detection
	/********** ID/EX pipeline register **********/
	input  wire [`WordAddrBus]	  id_pc,		// Program counter
	/********** MEM/WB pipeline register **********/
	input  wire [`WordAddrBus]	  mem_pc,		// Program counter
	input  wire					  mem_en,		// Enable pipeline data
	input  wire					  mem_br_flag,	// Branch flag
	input  wire [`CtrlOpBus]	  mem_ctrl_op,	// Control register operation
	input  wire [`RegAddrBus]	  mem_dst_addr, // Write address
	input  wire [`IsaExpBus]	  mem_exp_code, // Exception code
	input  wire [`WordDataBus]	  mem_out,		// Processing result
	/********** Pipeline control signal **********/
	// Pipeline status
	input  wire					  if_busy,		// IF stage busy
	input  wire					  ld_hazard,	// Load hazard
	input  wire					  mem_busy,		// MEM stage busy
	// Stall signal
	output wire					  if_stall,		// IF stage stall
	output wire					  id_stall,		// ID stage stall
	output wire					  ex_stall,		// EX stage stall
	output wire					  mem_stall,	// MEM stage stall
	// Flush signal
	output wire					  if_flush,		// IF stage flush
	output wire					  id_flush,		// ID stage flush
	output wire					  ex_flush,		// EX stage flush
	output wire					  mem_flush,	// MEM stage flush
	output reg	[`WordAddrBus]	  new_pc		// New program counter
);

	/********** Control register **********/
	reg							 int_en;		// #0 : Interrupt enable
	reg	 [`CpuExeModeBus]		 pre_exe_mode;	// #1 : Execution mode
	reg							 pre_int_en;	// #2 : Interrupt enable
	reg	 [`WordAddrBus]			 epc;			// #3 : Exception program counter
	reg	 [`WordAddrBus]			 exp_vector;	// #4 : Exception vector
	reg	 [`IsaExpBus]			 exp_code;		// #5 : Exception code
	reg							 dly_flag;		// #6 : Delay slot flag
	reg	 [`CPU_IRQ_CH-1:0]		 mask;			// #7 : Interrupt mask

	/********** Internal signal **********/
	reg [`WordAddrBus]		  pre_pc;			// Previous program counter
	reg						  br_flag;			// Branch flag

	/********** Pipeline control signal **********/
	// Stall signal
	wire   stall	 = if_busy | mem_busy;
	assign if_stall	 = stall | ld_hazard;
	assign id_stall	 = stall;
	assign ex_stall	 = stall;
	assign mem_stall = stall;
	// Flush signal
	reg	   flush;
	assign if_flush	 = flush;
	assign id_flush	 = flush | ld_hazard;
	assign ex_flush	 = flush;
	assign mem_flush = flush;

	/********** Pipeline flush control **********/
	always @(*) begin
		/* Default value */
		new_pc = `WORD_ADDR_W'h0;
		flush  = `DISABLE;
		/* Pipeline flush */
		if (mem_en == `ENABLE) begin // Enable pipeline data
			if (mem_exp_code != `ISA_EXP_NO_EXP) begin		 // Exception happed
				new_pc = exp_vector;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin // EXRT instruction
				new_pc = epc;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin // WRCR instruction
				new_pc = mem_pc;
				flush  = `ENABLE;
			end
		end
	end

	/********** Interrupt detection **********/
	always @(*) begin
		if ((int_en == `ENABLE) && ((|((~mask) & irq)) == `ENABLE)) begin
			int_detect = `ENABLE;
		end else begin
			int_detect = `DISABLE;
		end
	end
   
	/********** Read access **********/
	always @(*) begin
		case (creg_rd_addr)
		   `CREG_ADDR_STATUS	 : begin // #0:Status
			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, int_en, exe_mode};
		   end
		   `CREG_ADDR_PRE_STATUS : begin // #1: Status before exception happened
			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, 
							   pre_int_en, pre_exe_mode};
		   end
		   `CREG_ADDR_PC		 : begin // #2: Program counter
			   creg_rd_data = {id_pc, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_EPC		 : begin // #3: Exception program counter
			   creg_rd_data = {epc, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_EXP_VECTOR : begin // #4: Exception vector
			   creg_rd_data = {exp_vector, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_CAUSE		 : begin // #5: Exception cause
			   creg_rd_data = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}}, 
							   dly_flag, exp_code};
		   end
		   `CREG_ADDR_INT_MASK	 : begin // #6: Interrupt mask
			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, mask};
		   end
		   `CREG_ADDR_IRQ		 : begin // #6: Interrupt cause
			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, irq};
		   end
		   `CREG_ADDR_ROM_SIZE	 : begin // #7:ROM's size
			   creg_rd_data = $unsigned(`ROM_SIZE);
		   end
		   `CREG_ADDR_SPM_SIZE	 : begin // #8:SPM's size
			   creg_rd_data = $unsigned(`SPM_SIZE);
		   end
		   `CREG_ADDR_CPU_INFO	 : begin // #9:CPU information
			   creg_rd_data = {`RELEASE_YEAR, `RELEASE_MONTH, 
							   `RELEASE_VERSION, `RELEASE_REVISION};
		   end
		   default				 : begin // Default value
			   creg_rd_data = `WORD_DATA_W'h0;
		   end
		endcase
	end

	/********** CPU control **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			exe_mode	 <= #1 `CPU_KERNEL_MODE;
			int_en		 <= #1 `DISABLE;
			pre_exe_mode <= #1 `CPU_KERNEL_MODE;
			pre_int_en	 <= #1 `DISABLE;
			exp_code	 <= #1 `ISA_EXP_NO_EXP;
			mask		 <= #1 {`CPU_IRQ_CH{`ENABLE}};
			dly_flag	 <= #1 `DISABLE;
			epc			 <= #1 `WORD_ADDR_W'h0;
			exp_vector	 <= #1 `WORD_ADDR_W'h0;
			pre_pc		 <= #1 `WORD_ADDR_W'h0;
			br_flag		 <= #1 `DISABLE;
		end else begin
			/* Update CPU status */
			if ((mem_en == `ENABLE) && (stall == `DISABLE)) begin
				/* Save PC and brach flag */
				pre_pc		 <= #1 mem_pc;
				br_flag		 <= #1 mem_br_flag;
				/* CPU status control */
				if (mem_exp_code != `ISA_EXP_NO_EXP) begin		 // Exception happened
					exe_mode	 <= #1 `CPU_KERNEL_MODE;
					int_en		 <= #1 `DISABLE;
					pre_exe_mode <= #1 exe_mode;
					pre_int_en	 <= #1 int_en;
					exp_code	 <= #1 mem_exp_code;
					dly_flag	 <= #1 br_flag;
					epc			 <= #1 pre_pc;
				end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin // EXRT instruction
					exe_mode	 <= #1 pre_exe_mode;
					int_en		 <= #1 pre_int_en;
				end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin // WRCR instruction
				   /* Write control register */
					case (mem_dst_addr)
						`CREG_ADDR_STATUS	  : begin // Status
							exe_mode	 <= #1 mem_out[`CregExeModeLoc];
							int_en		 <= #1 mem_out[`CregIntEnableLoc];
						end
						`CREG_ADDR_PRE_STATUS : begin // Status before exception happened
							pre_exe_mode <= #1 mem_out[`CregExeModeLoc];
							pre_int_en	 <= #1 mem_out[`CregIntEnableLoc];
						end
						`CREG_ADDR_EPC		  : begin // Exception program
							epc			 <= #1 mem_out[`WordAddrLoc];
						end
						`CREG_ADDR_EXP_VECTOR : begin // Exception vector
							exp_vector	 <= #1 mem_out[`WordAddrLoc];
						end
						`CREG_ADDR_CAUSE	  : begin // Exception cause
							dly_flag	 <= #1 mem_out[`CregDlyFlagLoc];
							exp_code	 <= #1 mem_out[`CregExpCodeLoc];
						end
						`CREG_ADDR_INT_MASK	  : begin // Interrupt mask
							mask		 <= #1 mem_out[`CPU_IRQ_CH-1:0];
						end
					endcase
				end
			end
		end
	end

endmodule
