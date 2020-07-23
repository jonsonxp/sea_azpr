/*
 -- ============================================================================
 -- FILE NAME	: global_config.h
 -- DESCRIPTION : Global configuration
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __GLOBAL_CONFIG_HEADER__
	`define __GLOBAL_CONFIG_HEADER__	// Include guard

//------------------------------------------------------------------------------
// Setup 
//------------------------------------------------------------------------------
	/********** Target device (choose one) **********/
//	`define TARGET_DEV_MFPGA_SPAR3E		// Marutsu evaluation board
	`define TARGET_DEV_AZPR_EV_BOARD	// AZPR original board

	/********** Polarity of reset (choose one) **********/
//	`define POSITIVE_RESET				// Active High
	`define NEGATIVE_RESET				// Active Low

	/********** Polarity of memory ctrl signal (choose one) **********/
	`define POSITIVE_MEMORY				// Active High
//	`define NEGATIVE_MEMORY				// Active Low

	/********** I/O setup : setup I/O for implementation**********/
	`define IMPLEMENT_TIMER				// Timer
	`define IMPLEMENT_UART				// UART
	`define IMPLEMENT_GPIO				// General Purpose I/O

//------------------------------------------------------------------------------
// Generate parameters according to setup
//------------------------------------------------------------------------------
	/********** Polarity of reset *********/
	// Active Low
	`ifdef POSITIVE_RESET
		`define RESET_EDGE	  posedge	// Reset edge
		`define RESET_ENABLE  1'b1		// Reset enable
		`define RESET_DISABLE 1'b0		// Reset disable
	`endif
	// Active High
	`ifdef NEGATIVE_RESET
		`define RESET_EDGE	  negedge	// Reset edge
		`define RESET_ENABLE  1'b0		// Reset enable
		`define RESET_DISABLE 1'b1		// Reset disable
	`endif

	/********** Polarity of memory ctrl signal *********/
	// Actoive High
	`ifdef POSITIVE_MEMORY
		`define MEM_ENABLE	  1'b1		// Memory enable
		`define MEM_DISABLE	  1'b0		// Memory disable
	`endif
	// Active Low
	`ifdef NEGATIVE_MEMORY
		`define MEM_ENABLE	  1'b0		// Memory enable
		`define MEM_DISABLE	  1'b1		// Memory disable
	`endif

`endif
