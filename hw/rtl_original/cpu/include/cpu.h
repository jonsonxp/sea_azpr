/* 
 -- ============================================================================
 -- FILE NAME	: cpu.h
 -- DESCRIPTION : CPU header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __CPU_HEADER__
	`define __CPU_HEADER__	// Include guard

//------------------------------------------------------------------------------
// Operation
//------------------------------------------------------------------------------
	/********** Register **********/
	`define REG_NUM				 32	  // Number of registers
	`define REG_ADDR_W			 5	  // Register address width
	`define RegAddrBus			 4:0  // Register address bus
	/********** Interrupt request signal **********/
	`define CPU_IRQ_CH			 8	  // IRQ width
	/********** ALU opcode **********/
	// Bus
	`define ALU_OP_W			 4	  // ALU opcode width
	`define AluOpBus			 3:0  // ALU opcode bus
	// Opcode
	`define ALU_OP_NOP			 4'h0 // No Operation
	`define ALU_OP_AND			 4'h1 // AND
	`define ALU_OP_OR			 4'h2 // OR
	`define ALU_OP_XOR			 4'h3 // XOR
	`define ALU_OP_ADDS			 4'h4 // Signed ADD
	`define ALU_OP_ADDU			 4'h5 // Unsigned ADD
	`define ALU_OP_SUBS			 4'h6 // Signed SUB
	`define ALU_OP_SUBU			 4'h7 // Unsigned SUB
	`define ALU_OP_SHRL			 4'h8 // Shift right
	`define ALU_OP_SHLL			 4'h9 // Shift left
	/********** MEM opcode **********/
	// Bus
	`define MEM_OP_W			 2	  // Memory opcode width
	`define MemOpBus			 1:0  // Memory opcode bus
	// Opcode
	`define MEM_OP_NOP			 2'h0 // No Operation
	`define MEM_OP_LDW			 2'h1 // Read word
	`define MEM_OP_STW			 2'h2 // Write word
	/********** Control opcode **********/
	// Bus
	`define CTRL_OP_W			 2	  // Control opcode width
	`define CtrlOpBus			 1:0  // Control opcode bus
	// Opcode
	`define CTRL_OP_NOP			 2'h0 // No Operation
	`define CTRL_OP_WRCR		 2'h1 // Write to control register
	`define CTRL_OP_EXRT		 2'h2 // Restore from exception

	/********** Execution mode **********/
	// Bus
	`define CPU_EXE_MODE_W		 1	  // Execution mode width
	`define CpuExeModeBus		 0:0  // Execution mode bus
	// Opcode
	`define CPU_KERNEL_MODE		 1'b0 // Kernel mode
	`define CPU_USER_MODE		 1'b1 // User mode

//------------------------------------------------------------------------------
// Control register
//------------------------------------------------------------------------------
	/********** Address map **********/
	`define CREG_ADDR_STATUS	 5'h0  // Status
	`define CREG_ADDR_PRE_STATUS 5'h1  // Previous status
	`define CREG_ADDR_PC		 5'h2  // Program counter
	`define CREG_ADDR_EPC		 5'h3  // Exception program counter
	`define CREG_ADDR_EXP_VECTOR 5'h4  // Exception header
	`define CREG_ADDR_CAUSE		 5'h5  // Exception cause register
	`define CREG_ADDR_INT_MASK	 5'h6  // Interrupt mask
	`define CREG_ADDR_IRQ		 5'h7  // Interrupt request
	// Read only region
	`define CREG_ADDR_ROM_SIZE	 5'h1d // ROM size
	`define CREG_ADDR_SPM_SIZE	 5'h1e // SPM size
	`define CREG_ADDR_CPU_INFO	 5'h1f // CPU information
	/********** Bit map **********/
	`define CregExeModeLoc		 0	   // Execution mode location
	`define CregIntEnableLoc	 1	   // Interrupt enable location
	`define CregExpCodeLoc		 2:0   // Exception code location
	`define CregDlyFlagLoc		 3	   // Delay slot flag location

//------------------------------------------------------------------------------
// Bus interface
//------------------------------------------------------------------------------
	/********** Status of bus interface **********/
	// Bus
	`define BusIfStateBus		 1:0   // Bus status
	// Status
	`define BUS_IF_STATE_IDLE	 2'h0  // Idle
	`define BUS_IF_STATE_REQ	 2'h1  // Bus request
	`define BUS_IF_STATE_ACCESS	 2'h2  // Bus access
	`define BUS_IF_STATE_STALL	 2'h3  // Stall

//------------------------------------------------------------------------------
// MISC
//------------------------------------------------------------------------------
	/********** Header **********/
	`define RESET_VECTOR		 30'h0 // Reset header
	/********** Shift amount **********/
	`define ShAmountBus			 4:0   // Shift amount bus
	`define ShAmountLoc			 4:0   // Shift amount location

	/********** CPU information *********/
	`define RELEASE_YEAR		 8'd41 // YEAR (YYYY - 1970)
	`define RELEASE_MONTH		 8'd7  // MONTH
	`define RELEASE_VERSION		 8'd1  // VERSION
	`define RELEASE_REVISION	 8'd0  // REVISION


`endif
