/*
 -- ============================================================================
 -- FILE NAME	: uart_ctrl.v
 -- DESCRIPTION : UART control module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** Local header **********/
`include "uart.h"

/********** Module **********/
module uart_ctrl (
	/********** Clock & Reset **********/
	input  wire				   clk,		 
	input  wire				   reset,	 
	/********** Bus interface **********/
	input  wire				   cs_,		 // Chip select
	input  wire				   as_,		 // Address strobe
	input  wire				   rw,		 // Read / Write
	input  wire [`UartAddrBus] addr,	 // Address
	input  wire [`WordDataBus] wr_data,	 // Write data
	output reg	[`WordDataBus] rd_data,	 // Read data
	output reg				   rdy_,	 // Ready
	/********** Interrupt **********/
	output reg				   irq_rx,	 // End of receiving interrupt
	output reg				   irq_tx,	 // End of sending interrupt
	/********** Control signal **********/
	// RX control
	input  wire				   rx_busy,	 // Receiving flag
	input  wire				   rx_end,	 // End of receiving signal
	input  wire [`ByteDataBus] rx_data,	 // RX data
	// TX control
	input  wire				   tx_busy,	 // Sending flag
	input  wire				   tx_end,	 // End of send signal
	output reg				   tx_start, // Start sending signal
	output reg	[`ByteDataBus] tx_data	 // TX Data
);

	/********** Control register **********/
	// Control register 1: TX/RX data
	reg [`ByteDataBus]		   rx_buf;	 // RX buffer

	/********** UART control logic **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			rd_data	 <= #1 `WORD_DATA_W'h0;
			rdy_	 <= #1 `DISABLE_;
			irq_rx	 <= #1 `DISABLE;
			irq_tx	 <= #1 `DISABLE;
			rx_buf	 <= #1 `BYTE_DATA_W'h0;
			tx_start <= #1 `DISABLE;
			tx_data	 <= #1 `BYTE_DATA_W'h0;
	   end else begin
			/* Generate ready */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
				rdy_	 <= #1 `ENABLE_;
			end else begin
				rdy_	 <= #1 `DISABLE_;
			end
			/* Read access */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `READ)) begin
				case (addr)
					`UART_ADDR_STATUS	 : begin // Control register 0
						rd_data	 <= #1 {{`WORD_DATA_W-4{1'b0}}, 
										tx_busy, rx_busy, irq_tx, irq_rx};
					end
					`UART_ADDR_DATA		 : begin // Control register 1
						rd_data	 <= #1 {{`BYTE_DATA_W*2{1'b0}}, rx_buf};
					end
				endcase
			end else begin
				rd_data	 <= #1 `WORD_DATA_W'h0;
			end
			/* Write access */
			// Control register 0 : End of sending interrupt
			if (tx_end == `ENABLE) begin
				irq_tx<= #1 `ENABLE;
			end else if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && 
						 (rw == `WRITE) && (addr == `UART_ADDR_STATUS)) begin
				irq_tx<= #1 wr_data[`UartCtrlIrqTx];
			end
			// Control register 0 : End of receiving interrypt
			if (rx_end == `ENABLE) begin
				irq_rx<= #1 `ENABLE;
			end else if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && 
						 (rw == `WRITE) && (addr == `UART_ADDR_STATUS)) begin
				irq_rx<= #1 wr_data[`UartCtrlIrqRx];
			end
			// Control register 1
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && 
				(rw == `WRITE) && (addr == `UART_ADDR_DATA)) begin // Start sending
				tx_start <= #1 `ENABLE;
				tx_data	 <= #1 wr_data[`BYTE_MSB:`LSB];
			end else begin
				tx_start <= #1 `DISABLE;
				tx_data	 <= #1 `BYTE_DATA_W'h0;
			end
			/* Received data -> buffer */
			if (rx_end == `ENABLE) begin
				rx_buf	 <= #1 rx_data;
			end
		end
	end

endmodule
