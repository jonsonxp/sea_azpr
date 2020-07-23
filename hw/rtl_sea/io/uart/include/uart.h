/*
 -- ============================================================================
 -- FILE NAME	: uart.h
 -- DESCRIPTION : UART header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __UART_HEADER__
	`define __UART_HEADER__			// Include guard

/*
 *
 * Frequency division example:
 *  If UART's baud rate is 38,400, and the reference clock freq. is 10MHz.
 *	 UART_DIV_RATE is 10,000,000 / 38,400 = 260,
 *	 UART_DIV_CNT_W is log2(260) = 9.
 *
 */

	/********** Frequency division counter *********/
	`define UART_DIV_RATE	   9'd260  // Division rate
	`define UART_DIV_CNT_W	   9	   // Division counter width
	`define UartDivCntBus	   8:0	   // Division counter bus
	/********** Address bus **********/
	`define UartAddrBus		   0:0	// Addrss bus
	`define UART_ADDR_W		   1	// Address width
	`define UartAddrLoc		   0:0	// Address location
	/********** Address map **********/
	`define UART_ADDR_STATUS   1'h0 // Control register 0: status
	`define UART_ADDR_DATA	   1'h1 // Control register 1: data
	/********** Bit map **********/
	`define UartCtrlIrqRx	   0	// End of receive interrupt
	`define UartCtrlIrqTx	   1	// End of send interrupt
	`define UartCtrlBusyRx	   2	// Receiving flag
	`define UartCtrlBusyTx	   3	// Sending flag
	/********** TX RX status **********/
	`define UartStateBus	   0:0	// Status bus
	`define UART_STATE_IDLE	   1'b0 // Status: idle
	`define UART_STATE_TX	   1'b1 // Status: Sending
	`define UART_STATE_RX	   1'b1 // Status: Receiving
	/********** Bit counter **********/
	`define UartBitCntBus	   3:0	// Bit counter bus
	`define UART_BIT_CNT_W	   4	// Bit counter width
	`define UART_BIT_CNT_START 4'h0 // Count: start bit
	`define UART_BIT_CNT_MSB   4'h8 // Count: MSB of data
	`define UART_BIT_CNT_STOP  4'h9 // Count: Stop bit
	/********** Bit level **********/
	`define UART_START_BIT	   1'b0 // Start bit
	`define UART_STOP_BIT	   1'b1 // Stop bit

`endif
