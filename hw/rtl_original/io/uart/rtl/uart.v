/*
 -- ============================================================================
 -- FILE NAME	: uart.v
 -- DESCRIPTION : Universal Asynchronous Receiver and Transmitter
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
module uart (
	/********** Clock & Reset **********/
	input  wire				   clk,		 
	input  wire				   reset,	 
	/********** Bus interface **********/
	input  wire				   cs_,		 
	input  wire				   as_,		
	input  wire				   rw,		 
	input  wire [`UartAddrBus] addr,	 // Address
	input  wire [`WordDataBus] wr_data,	 // Write data
	output wire [`WordDataBus] rd_data,	 // Read data
	output wire				   rdy_,	 
	/********** Interrupt **********/
	output wire				   irq_rx,	 
	output wire				   irq_tx,	
	/********** UART TX/RX signal	**********/
	input  wire				   rx,		
	output wire				   tx		
);

	/********** Control signal **********/
	// RX control
	wire					   rx_busy;	 
	wire					   rx_end;	 
	wire [`ByteDataBus]		   rx_data;	 
	// TX control
	wire					   tx_busy;	 
	wire					   tx_end;	 
	wire					   tx_start; 
	wire [`ByteDataBus]		   tx_data;	

	/********** UART control module **********/
	uart_ctrl uart_ctrl (
		/********** Clock & Reset **********/
		.clk	  (clk),	   
		.reset	  (reset),	   
		/********** Host Interface **********/
		.cs_	  (cs_),	   
		.as_	  (as_),	   
		.rw		  (rw),		   
		.addr	  (addr),	  
		.wr_data  (wr_data),  
		.rd_data  (rd_data),   
		.rdy_	  (rdy_),	  
		/********** Interrupt  **********/
		.irq_rx	  (irq_rx),	   
		.irq_tx	  (irq_tx),	   
		/********** Control signal **********/
		// RX control
		.rx_busy  (rx_busy),   
		.rx_end	  (rx_end),	  
		.rx_data  (rx_data),   
		// TX control
		.tx_busy  (tx_busy),   
		.tx_end	  (tx_end),	   
		.tx_start (tx_start), 
		.tx_data  (tx_data)	   
	);

	/********** UART TX module **********/
	uart_tx uart_tx (
		/********** Clock & Reset **********/
		.clk	  (clk),	   
		.reset	  (reset),	   
		/********** Control signal **********/
		.tx_start (tx_start),  
		.tx_data  (tx_data),   
		.tx_busy  (tx_busy),   
		.tx_end	  (tx_end),	   
		/********** Transmit Signal **********/
		.tx		  (tx)		  
	);

	/********** UART RX module **********/
	uart_rx uart_rx (
		/********** Clock & Reset **********/
		.clk	  (clk),	  
		.reset	  (reset),	  
		/********** Control signal **********/
		.rx_busy  (rx_busy),  
		.rx_end	  (rx_end),	 
		.rx_data  (rx_data),   
		/********** Receive Signal **********/
		.rx		  (rx)		  
	);

endmodule
