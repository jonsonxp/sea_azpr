/*
 -- ============================================================================
 -- FILE NAME	: uart_rx.v
 -- DESCRIPTION : UART RX module
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
module uart_rx (
	/********** Clock & Reset **********/
	input  wire				   clk,		
	input  wire				   reset,	
	/********** Control signal **********/
	output wire				   rx_busy,
	output reg				   rx_end,	
	output reg	[`ByteDataBus] rx_data, 
	/********** UART RX signal **********/
	input  wire				   rx		
);

	/********** Internal register **********/
	reg [`UartStateBus]		   state;	 
	reg [`UartDivCntBus]	   div_cnt;	 
	reg [`UartBitCntBus]	   bit_cnt;	 

	/********** Generate receiving flag **********/
	assign rx_busy = (state != `UART_STATE_IDLE) ? `ENABLE : `DISABLE;

	/********** RX logic **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			rx_end	<= #1 `DISABLE;
			rx_data <= #1 `BYTE_DATA_W'h0;
			state	<= #1 `UART_STATE_IDLE;
			div_cnt <= #1 `UART_DIV_RATE / 2;
			bit_cnt <= #1 `UART_BIT_CNT_W'h0;
		end else begin
			/* RX status */
			case (state)
				`UART_STATE_IDLE : begin // Idle status
					if (rx == `UART_START_BIT) begin // RX start
						state	<= #1 `UART_STATE_RX;
					end
					rx_end	<= #1 `DISABLE;
				end
				`UART_STATE_RX	 : begin // Receiving
					if (div_cnt == {`UART_DIV_CNT_W{1'b0}}) begin // Full
						/* Receive next data */
						case (bit_cnt)
							`UART_BIT_CNT_STOP	: begin // Receive stop bit
								state	<= #1 `UART_STATE_IDLE;
								bit_cnt <= #1 `UART_BIT_CNT_START;
								div_cnt <= #1 `UART_DIV_RATE / 2;
								/* Framing error check */
								if (rx == `UART_STOP_BIT) begin
									rx_end	<= #1 `ENABLE;
								end
							end
							default				: begin // Receive data
								rx_data <= #1 {rx, rx_data[`BYTE_MSB:`LSB+1]};
								bit_cnt <= #1 bit_cnt + 1'b1;
								div_cnt <= #1 `UART_DIV_RATE;
							end
						endcase
					end else begin // Count down
						div_cnt <= #1 div_cnt - 1'b1;
					end
				end
			endcase
		end
	end

endmodule
