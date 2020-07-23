/*
 -- ============================================================================
 -- FILE NAME	: bus_if.v
 -- DESCRIPTION : Bus interface
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Local header **********/
`include "cpu.h"
`include "bus.h"

/********** Module **********/
module bus_if (
	/********** Clock & Reset **********/
	input  wire				   clk,			  
	input  wire				   reset,		   
	/********** Pipeline control signal **********/
	input  wire				   stall,		   
	input  wire				   flush,		  
	output reg				   busy,		 
	/********** CPU interface **********/
	input  wire [`WordAddrBus] addr,		  
	input  wire				   as_,			   // Address enable
	input  wire				   rw,			   // Read/Write
	input  wire [`WordDataBus] wr_data,		   
	output reg	[`WordDataBus] rd_data,		   
	/********** SPM interface **********/
	input  wire [`WordDataBus] spm_rd_data,	   // Read data
	output wire [`WordAddrBus] spm_addr,	   // Address
	output reg				   spm_as_,		   // Address strobe
	output wire				   spm_rw,		   // Read/Write
	output wire [`WordDataBus] spm_wr_data,	   // Write data
	/********** Bus interface **********/
	input  wire [`WordDataBus] bus_rd_data,	   // Read data
	input  wire				   bus_rdy_,	   // Ready
	input  wire				   bus_grnt_,	   // Bus grant
	output reg				   bus_req_,	   // Bus request
	output reg	[`WordAddrBus] bus_addr,	   // Address
	output reg				   bus_as_,		   // Address strobe
	output reg				   bus_rw,		   // Read/Write
	output reg	[`WordDataBus] bus_wr_data	   // Write data
);

	/********** Internal signal **********/
	reg	 [`BusIfStateBus]	   state;		   // Status of bus interface
	reg	 [`WordDataBus]		   rd_buf;		   // Read buffer
	wire [`BusSlaveIndexBus]   s_index;		   // Bus slave index

	/********** Bus slave index **********/
	assign s_index	   = addr[`BusSlaveIndexLoc];

	/********** Assign output **********/
	assign spm_addr	   = addr;
	assign spm_rw	   = rw;
	assign spm_wr_data = wr_data;
						 
	/********** Memory access control **********/
	always @(*) begin
		/* Default */
		rd_data	 = `WORD_DATA_W'h0;
		spm_as_	 = `DISABLE_;
		busy	 = `DISABLE;
		/* Status of bus interface */
		case (state)
			`BUS_IF_STATE_IDLE	 : begin // Idle
				/* Memory access */
				if ((flush == `DISABLE) && (as_ == `ENABLE_)) begin
					/* Select access target */
					if (s_index == `BUS_SLAVE_1) begin // Access SPM
						if (stall == `DISABLE) begin // Stall check
							spm_as_	 = `ENABLE_;
							if (rw == `READ) begin // Read access
								rd_data	 = spm_rd_data;
							end
						end
					end else begin					   // Access bus
						busy	 = `ENABLE;
					end
				end
			end
			`BUS_IF_STATE_REQ	 : begin // Bus request
				busy	 = `ENABLE;
			end
			`BUS_IF_STATE_ACCESS : begin // Bus access
				/* Wait for ready */
				if (bus_rdy_ == `ENABLE_) begin // Ready arrived
					if (rw == `READ) begin // Read access
						rd_data	 = bus_rd_data;
					end
				end else begin					// Ready unarrived
					busy	 = `ENABLE;
				end
			end
			`BUS_IF_STATE_STALL	 : begin // Stall
				if (rw == `READ) begin // Read access
					rd_data	 = rd_buf;
				end
			end
		endcase
	end

   /********** Control bus interface status **********/ 
   always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			state		<= #1 `BUS_IF_STATE_IDLE;
			bus_req_	<= #1 `DISABLE_;
			bus_addr	<= #1 `WORD_ADDR_W'h0;
			bus_as_		<= #1 `DISABLE_;
			bus_rw		<= #1 `READ;
			bus_wr_data <= #1 `WORD_DATA_W'h0;
			rd_buf		<= #1 `WORD_DATA_W'h0;
		end else begin
			/* Status of bus interface */
			case (state)
				`BUS_IF_STATE_IDLE	 : begin // Idle
					/* Memory access */
					if ((flush == `DISABLE) && (as_ == `ENABLE_)) begin 
						/* Select access target */
						if (s_index != `BUS_SLAVE_1) begin // Access bus
							state		<= #1 `BUS_IF_STATE_REQ;
							bus_req_	<= #1 `ENABLE_;
							bus_addr	<= #1 addr;
							bus_rw		<= #1 rw;
							bus_wr_data <= #1 wr_data;
						end
					end
				end
				`BUS_IF_STATE_REQ	 : begin // Bus request
					/* Wait for bus grant */
					if (bus_grnt_ == `ENABLE_) begin // Bus granted
						state		<= #1 `BUS_IF_STATE_ACCESS;
						bus_as_		<= #1 `ENABLE_;
					end
				end
				`BUS_IF_STATE_ACCESS : begin // Bus access
					/* Negate address strobe */
					bus_as_		<= #1 `DISABLE_;
					/* Wait for ready */
					if (bus_rdy_ == `ENABLE_) begin // Ready arrived
						bus_req_	<= #1 `DISABLE_;
						bus_addr	<= #1 `WORD_ADDR_W'h0;
						bus_rw		<= #1 `READ;
						bus_wr_data <= #1 `WORD_DATA_W'h0;
						/* Save read data */
						if (bus_rw == `READ) begin // Read access
							rd_buf		<= #1 bus_rd_data;
						end
						/* Stall check */
						if (stall == `ENABLE) begin // Stall happened
							state		<= #1 `BUS_IF_STATE_STALL;
						end else begin				// Stall not happened
							state		<= #1 `BUS_IF_STATE_IDLE;
						end
					end
				end
				`BUS_IF_STATE_STALL	 : begin // Stall
					/* Stall check */
					if (stall == `DISABLE) begin // Disable stall
						state		<= #1 `BUS_IF_STATE_IDLE;
					end
				end
			endcase
		end
	end

endmodule
