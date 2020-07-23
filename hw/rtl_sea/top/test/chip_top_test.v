/* 
 -- ============================================================================
 -- FILE NAME	: chip_top_test.v
 -- DESCRIPTION : Testbench
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2012/04/02  suito		 Created
 -- ============================================================================
*/

/********** Time scale **********/
`timescale 1ns/1ps					 // Time scale

/********** Global header **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** Local header **********/
`include "bus.h"
`include "cpu.h"
`include "gpio.h"

`define ROM_PRG "test_binary.dat"
`define SPM_PRG ""
`define SIM_CYCLE 10000

/********** Module **********/
module chip_top_test;
	/********** I/O signal **********/
	// Clock & Reset
	reg						clk_ref;	   // Reference clock
	reg						reset_sw;	   // Global reset
	// UART
`ifdef IMPLEMENT_UART // UART implementation
	wire					uart_rx;	   // UART RX
	wire					uart_tx;	   // UART TX
`endif
	// GPIO
`ifdef IMPLEMENT_GPIO // GPIO implementation
`ifdef GPIO_IN_CH	 // Input port implementation
	wire [`GPIO_IN_CH-1:0]	gpio_in = {`GPIO_IN_CH{1'b0}}; 
`endif
`ifdef GPIO_OUT_CH	 // Output port implementation
	wire [`GPIO_OUT_CH-1:0] gpio_out;					
`endif
`ifdef GPIO_IO_CH	 // Inout port implementation
	wire [`GPIO_IO_CH-1:0]	gpio_io = {`GPIO_IO_CH{1'bz}};
`endif
`endif
						 
	/********** UART model **********/
`ifdef IMPLEMENT_UART // UART implementation
	wire					 rx_busy;		  // Busy flag
	wire					 rx_end;		  // End of receive
	wire [`ByteDataBus]		 rx_data;		  // Received data
`endif

	/********** Simulation cycles **********/
	parameter				 STEP = 100.0000; // 10 M

	/********** Clock generation **********/
	always #( STEP / 2 ) begin
		clk_ref <= ~clk_ref;
	end

	/********** chip_top instance **********/  
	chip_top chip_top (
		/********** Clock & Reset **********/
		.clk_ref	(clk_ref), 
		.reset_sw	(reset_sw)
		/********** UART **********/
`ifdef IMPLEMENT_UART // UART
		, .uart_rx	(uart_rx)
		, .uart_tx	(uart_tx)
`endif
	/********** GPIO **********/
`ifdef IMPLEMENT_GPIO // GPIO
`ifdef GPIO_IN_CH			   
		, .gpio_in	(gpio_in)  
`endif
`ifdef GPIO_OUT_CH	 
		, .gpio_out (gpio_out) 
`endif
`ifdef GPIO_IO_CH	 
		, .gpio_io	(gpio_io)  
`endif
`endif
);

	/********** Monitoring GPIO **********/	
`ifdef IMPLEMENT_GPIO
`ifdef GPIO_IN_CH
	always @(gpio_in) begin	 // Print gpio_in if its value is changed
		$display($time, " gpio_in changed  : %b", gpio_in);
	end
`endif
`ifdef GPIO_OUT_CH
	always @(gpio_out) begin // Print gpio_out if its value is changed
		$display($time, " gpio_out changed : %b", gpio_out);
	end
`endif
`ifdef GPIO_IO_CH
	always @(gpio_io) begin  //Print gpio_io if its value is changed
		$display($time, " gpio_io changed  : %b", gpio_io);
	end
`endif
`endif

	/********** UART module instance **********/	
`ifdef IMPLEMENT_UART
	/********** RX **********/  
	assign uart_rx = `HIGH;		// Idle
//	  assign uart_rx = uart_tx; // Loopback

	/********** UART module **********/	
	uart_rx uart_model (
		/********** Clock & Reset **********/
		.clk	  (chip_top.clk),		
		.reset	  (chip_top.chip_reset),
		/********** Control signal **********/
		.rx_busy  (rx_busy),			
		.rx_end	  (rx_end),				
		.rx_data  (rx_data),			
		/********** Receive Signal **********/
		.rx		  (uart_tx)				
	);

	/********** Monitoring communication **********/	
	always @(posedge chip_top.clk) begin
		if (rx_end == `ENABLE) begin // Print rx_data if data received
			$write("%c", rx_data);
		end
	end
`endif

	/********** Test sequence **********/  
	initial begin
		# 0 begin
			clk_ref	 <= `HIGH;
			reset_sw <= `RESET_ENABLE;
		end
		# ( STEP / 2 )
		# ( STEP / 4 ) begin		  // Read memory image
			//$readmemh(`ROM_PRG, chip_top.chip.rom.x_s3e_sprom.mem);
			//$readmemh(`SPM_PRG, chip_top.chip.cpu.spm.x_s3e_dpram.mem);
		end
		# ( STEP * 20 ) begin		  // Release reset
			reset_sw <= `RESET_DISABLE;
		end
		# ( STEP * `SIM_CYCLE ) begin // Run simulation
			$finish;
		end
	end

	/********** Output waveform **********/	
	initial begin
		$dumpfile("chip_top.vcd");
		$dumpvars(0, chip_top);
	end
  
endmodule	
