/* 
 -- ============================================================================
 -- FILE NAME	: chip_top.v
 -- DESCRIPTION : Top module
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
`include "gpio.h"

/********** Model **********/
module chip_top (
	/********** Clock & Reset **********/
	input wire				   clk_ref,		  // Reference clock
	input wire				   reset_sw		  // Global reset
	/********** UART **********/
`ifdef IMPLEMENT_UART // UART implementation
	, input wire			   uart_rx		  // UART RX signal
	, output wire			   uart_tx		  // UART TX signal
`endif
	/********** GPIO port **********/
`ifdef IMPLEMENT_GPIO // GPIO implementation
`ifdef GPIO_IN_CH	 // Input port implementation
	, input wire [`GPIO_IN_CH-1:0]	 gpio_in  // Input port
`endif
`ifdef GPIO_OUT_CH	 // Output port implementation
	, output wire [`GPIO_OUT_CH-1:0] gpio_out // Output port
`endif
`ifdef GPIO_IO_CH	 // Inout port implementation
	, inout wire [`GPIO_IO_CH-1:0]	 gpio_io  // Inout port
`endif
`endif
);

	/********** Clock & Reset **********/
	wire					   clk;			  // Clock
	wire					   clk_;		  // Clock (180)
	wire					   chip_reset;	  // Chip select
   
	/********** Clock module **********/
	clk_gen clk_gen (
		/********** Clock & Reset **********/
		.clk_ref	  (clk_ref),			  // Reference clock
		.reset_sw	  (reset_sw),			  // Global reset
		/********** Generate clock **********/
		.clk		  (clk),				  // Clock
		.clk_		  (clk_),				  // Clock (180)
		/********** Chip reset **********/
		.chip_reset	  (chip_reset)			  // Chip reset
	);

	/********** Chip **********/
	chip chip (
		/********** Clock & Reset **********/
		.clk	  (clk),					  // Clock
		.clk_	  (clk_),					  // Clock (180)
		.reset	  (chip_reset)				  // Reset
		/********** UART **********/
`ifdef IMPLEMENT_UART
		, .uart_rx	(uart_rx)				  // UART RX
		, .uart_tx	(uart_tx)				  // UART TX
`endif
		/********** GPIO port **********/
`ifdef IMPLEMENT_GPIO
`ifdef GPIO_IN_CH  // Implement input port
		, .gpio_in (gpio_in)				  // Input port
`endif
`ifdef GPIO_OUT_CH // Implement output port
		, .gpio_out (gpio_out)				  // Output port
`endif
`ifdef GPIO_IO_CH  // Implement inout port
		, .gpio_io	(gpio_io)				  // Inout port
`endif
`endif
	);

endmodule
