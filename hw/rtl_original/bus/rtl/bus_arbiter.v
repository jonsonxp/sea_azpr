/*
 -- ============================================================================
 -- FILE	 : bus_arbiter.v
 -- SYNOPSIS : Bus arbiter
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
`include "bus.h"

/********** Module **********/
module bus_arbiter (
	/********** Clock & Reset **********/
	input  wire		   clk,		 // Clock
	input  wire		   reset,	 // Asynchronous reset
	/********** Arbiter selection signal **********/
	// Bus master 0
	input  wire		   m0_req_,	 // Bus request
	output reg		   m0_grnt_, // Bus grant
	// Bus master 1
	input  wire		   m1_req_,	 // Bus request
	output reg		   m1_grnt_, // Bus grant
	// Bus master 2
	input  wire		   m2_req_,	 // Bus request
	output reg		   m2_grnt_, // Bus grant
	// Bus master 3
	input  wire		   m3_req_,	 // Bus request
	output reg		   m3_grnt_	 // Bus grant
);

	/********** Internal signal **********/
	reg [`BusOwnerBus] owner;	 // Bus owner
   
	/********** Generate bus grant **********/
	always @(*) begin
		/* Initial bus grant */
		m0_grnt_ = `DISABLE_;
		m1_grnt_ = `DISABLE_;
		m2_grnt_ = `DISABLE_;
		m3_grnt_ = `DISABLE_;
		/* Generate bus grant */
		case (owner)
			`BUS_OWNER_MASTER_0 : begin // Bus master 0
				m0_grnt_ = `ENABLE_;
			end
			`BUS_OWNER_MASTER_1 : begin // Bus master 1
				m1_grnt_ = `ENABLE_;
			end
			`BUS_OWNER_MASTER_2 : begin // Bus master 2
				m2_grnt_ = `ENABLE_;
			end
			`BUS_OWNER_MASTER_3 : begin // Bus master 3
				m3_grnt_ = `ENABLE_;
			end
		endcase
	end
   
	/********** Arbitration of bus ownership **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* Asynchronous reset */
			owner <= #1 `BUS_OWNER_MASTER_0;
		end else begin
			/* Arbitration */
			case (owner)
				`BUS_OWNER_MASTER_0 : begin // Bus owner: bus master 0
					/* Next master owner */
					if (m0_req_ == `ENABLE_) begin			
						owner <= #1 `BUS_OWNER_MASTER_0;
					end else if (m1_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_1;
					end else if (m2_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_2;
					end else if (m3_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_3;
					end
				end
				`BUS_OWNER_MASTER_1 : begin // Bus owner: bus master 1
					/* Next master owner */
					if (m1_req_ == `ENABLE_) begin			
						owner <= #1 `BUS_OWNER_MASTER_1;
					end else if (m2_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_2;
						owner <= #1 `BUS_OWNER_MASTER_3;
					end else if (m0_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_0;
					end
				end
				`BUS_OWNER_MASTER_2 : begin // Bus owner: bus master 2
					/* Next master owner */
					if (m2_req_ == `ENABLE_) begin			
						owner <= #1 `BUS_OWNER_MASTER_2;
					end else if (m3_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_3;
					end else if (m0_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_0;
					end else if (m1_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_1;
					end
				end
				`BUS_OWNER_MASTER_3 : begin // Bus owner: bus master 3
					/* Next master owner */
					if (m3_req_ == `ENABLE_) begin			
						owner <= #1 `BUS_OWNER_MASTER_3;
					end else if (m0_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_0;
					end else if (m1_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_1;
					end else if (m2_req_ == `ENABLE_) begin 
						owner <= #1 `BUS_OWNER_MASTER_2;
					end
				end
			endcase
		end
	end

endmodule
