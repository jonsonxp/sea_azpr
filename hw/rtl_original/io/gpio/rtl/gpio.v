/*
 -- ============================================================================
 -- FILE NAME	: gpio.v
 -- DESCRIPTION :  General Purpose I/O
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

/********** Module **********/
module gpio (
	/********** Clock & Reset **********/
	input  wire						clk,	 // clock
	input  wire						reset,	 // reset
	/********** Bus interface **********/
	input  wire						cs_,	 // chip select
	input  wire						as_,	 // address strobe
	input  wire						rw,		 // Read / Write
	input  wire [`GpioAddrBus]		addr,	 // Address
	input  wire [`WordDataBus]		wr_data, // Write data
	output reg	[`WordDataBus]		rd_data, // Read data
	output reg						rdy_	 // Ready
	/********** GPIO port **********/
`ifdef GPIO_IN_CH	 // Input port implement
	, input wire [`GPIO_IN_CH-1:0]	gpio_in	 // Input port (Ctrl register 0)
`endif
`ifdef GPIO_OUT_CH	 // Output port implement
	, output reg [`GPIO_OUT_CH-1:0] gpio_out // Output port (Ctrl register 1)
`endif
`ifdef GPIO_IO_CH	 // Inout port implement
	, inout wire [`GPIO_IO_CH-1:0]	gpio_io	 // Inout port (Ctrl register 2)
`endif
);

`ifdef GPIO_IO_CH	 // I/O port control
	/********** I/O signal **********/
	wire [`GPIO_IO_CH-1:0]			io_in;	 // Input data
	reg	 [`GPIO_IO_CH-1:0]			io_out;	 // Output data
	reg	 [`GPIO_IO_CH-1:0]			io_dir;	 // Inout direction (Ctrl register 3)
	reg	 [`GPIO_IO_CH-1:0]			io;		 // Inout
	integer							i;		 // Iterator
   
	/********** I/O signal continuous assignment **********/
	assign io_in	   = gpio_io;			 // Input data
	assign gpio_io	   = io;				 // Inout

	/********** I/O direction control **********/
	always @(*) begin
		for (i = 0; i < `GPIO_IO_CH; i = i + 1) begin : IO_DIR
			io[i] = (io_dir[i] == `GPIO_DIR_IN) ? 1'bz : io_out[i];
		end
	end

`endif
   
	/********** GPIO control **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			rd_data	 <= #1 `WORD_DATA_W'h0;
			rdy_	 <= #1 `DISABLE_;
`ifdef GPIO_OUT_CH	 // Output port reset
			gpio_out <= #1 {`GPIO_OUT_CH{`LOW}};
`endif
`ifdef GPIO_IO_CH	 // Inout port reset
			io_out	 <= #1 {`GPIO_IO_CH{`LOW}};
			io_dir	 <= #1 {`GPIO_IO_CH{`GPIO_DIR_IN}};
`endif
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
`ifdef GPIO_IN_CH	// Read input port
					`GPIO_ADDR_IN_DATA	: begin // Ctrl register 0
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IN_CH{1'b0}}, 
										gpio_in};
					end
`endif
`ifdef GPIO_OUT_CH	// Read output port
					`GPIO_ADDR_OUT_DATA : begin // Ctrl register 1
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_OUT_CH{1'b0}}, 
										gpio_out};
					end
`endif
`ifdef GPIO_IO_CH	// Read inout port
					`GPIO_ADDR_IO_DATA	: begin // Ctrl register 2
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IO_CH{1'b0}}, 
										io_in};
					 end
					`GPIO_ADDR_IO_DIR	: begin // Ctrl register 3
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IO_CH{1'b0}}, 
										io_dir};
					end
`endif
				endcase
			end else begin
				rd_data	 <= #1 `WORD_DATA_W'h0;
			end
			/* Write access */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `WRITE)) begin
				case (addr)
`ifdef GPIO_OUT_CH	// Write output port
					`GPIO_ADDR_OUT_DATA : begin // Ctrl register 1
						gpio_out <= #1 wr_data[`GPIO_OUT_CH-1:0];
					end
`endif
`ifdef GPIO_IO_CH	// Write inout port
					`GPIO_ADDR_IO_DATA	: begin // Ctrl register 2
						io_out	 <= #1 wr_data[`GPIO_IO_CH-1:0];
					 end
					`GPIO_ADDR_IO_DIR	: begin // Ctrl register 3
						io_dir	 <= #1 wr_data[`GPIO_IO_CH-1:0];
					end
`endif
				endcase
			end
		end
	end

endmodule
