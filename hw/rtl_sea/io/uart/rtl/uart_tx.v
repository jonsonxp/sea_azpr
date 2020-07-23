/*
 -- ============================================================================
 -- FILE NAME	: uart_tx.v
 -- DESCRIPTION : UART TX module
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
module uart_tx (
	/********** Clock & Reset **********/
	input  wire				   clk,		 
	input  wire				   reset,	
	/********** Control signal **********/
	input  wire				   tx_start, 
	input  wire [`ByteDataBus] tx_data,	 
	output wire				   tx_busy,	
	output reg				   tx_end,	
	/********** UART TX signal **********/
	output reg				   tx		
);

	/********** Internal signal **********/
	reg [`UartStateBus]		   state;	
	reg [`UartDivCntBus]	   div_cnt;	
	reg [`UartBitCntBus]	   bit_cnt;	 
	reg [`ByteDataBus]		   sh_reg;	

	/********** Generate sending flag **********/
	assign tx_busy = (state == `UART_STATE_TX) ? `ENABLE : `DISABLE;

	/********** Sending logic **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			state	<= #1 `UART_STATE_IDLE;
			div_cnt <= #1 `UART_DIV_RATE;
			bit_cnt <= #1 `UART_BIT_CNT_START;
			sh_reg	<= #1 `BYTE_DATA_W'h0;
			tx_end	<= #1 `DISABLE;
			tx		<= #1 `UART_STOP_BIT;
		end else begin
			/* Sending state */
			case (state)
				`UART_STATE_IDLE : begin // Idle
					if (tx_start == `ENABLE) begin // Start sending
						state	<= #1 `UART_STATE_TX;
						sh_reg	<= #1 tx_data;
						tx		<= #1 `UART_START_BIT;
					end
					tx_end	<= #1 `DISABLE;
				end
				`UART_STATE_TX	 : begin // Sending
					if (div_cnt == {`UART_DIV_CNT_W{1'b0}}) begin // Full
						/* Send next data */
						case (bit_cnt)
							`UART_BIT_CNT_MSB  : begin // Send stop bit
								bit_cnt <= #1 `UART_BIT_CNT_STOP;
								tx		<= #1 `UART_STOP_BIT;
							end
							`UART_BIT_CNT_STOP : begin // End of sending
								state	<= #1 `UART_STATE_IDLE;
								bit_cnt <= #1 `UART_BIT_CNT_START;
								tx_end	<= #1 `ENABLE;
							end
							default			   : begin // Send data
								bit_cnt <= #1 bit_cnt + 1'b1;
								sh_reg	<= #1 sh_reg >> 1'b1;
								tx		<= #1 sh_reg[`LSB];
							end
						endcase
						div_cnt <= #1 `UART_DIV_RATE;
					end else begin // Count down
						div_cnt <= #1 div_cnt - 1'b1 ;
					end
				end
			endcase
		end
	end

endmodule
