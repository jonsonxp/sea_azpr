/*
 -- ============================================================================
 -- FILE NAME	: bus_addr_dec.v
 -- DESCRIPTION : Address decoder
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
module bus_addr_dec (
	/********** Address **********/
	input  wire [`WordAddrBus] s_addr, // Address
	/********** Chip select **********/
	output reg				   s0_cs_, // Bus slave 0
	output reg				   s1_cs_, // Bus slave 1
	output reg				   s2_cs_, // Bus slave 2
	output reg				   s3_cs_, // Bus slave 3
	output reg				   s4_cs_, // Bus slave 4
	output reg				   s5_cs_, // Bus slave 5
	output reg				   s6_cs_, // Bus slave 6
	output reg				   s7_cs_  // Bus slave 7
);

	/********** Bus slave index **********/
	wire [`BusSlaveIndexBus] s_index = s_addr[`BusSlaveIndexLoc];

	/********** Bus slave multiplexer **********/
	always @(*) begin
		/* Initiate chip select */
		s0_cs_ = `DISABLE_;
		s1_cs_ = `DISABLE_;
		s2_cs_ = `DISABLE_;
		s3_cs_ = `DISABLE_;
		s4_cs_ = `DISABLE_;
		s5_cs_ = `DISABLE_;
		s6_cs_ = `DISABLE_;
		s7_cs_ = `DISABLE_;
		/* Select slave according to address */
		case (s_index)
			`BUS_SLAVE_0 : begin // Bus slave 0
				s0_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_1 : begin // Bus slave 1
				s1_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_2 : begin // Bus slave 2
				s2_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_3 : begin // Bus slave 3
				s3_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_4 : begin // Bus slave 4
				s4_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_5 : begin // Bus slave 5
				s5_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_6 : begin // Bus slave 6
				s6_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_7 : begin // Bus slave 7
				s7_cs_	= `ENABLE_;
			end
		endcase
	end

endmodule
