/*
 -- ============================================================================
 -- FILE NAME	: bus_slave_mux.v
 -- DESCRIPTION : Bus slave multiplexer
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
module bus_slave_mux (
	/********** Multiplexer **********/
	input  wire				   s0_cs_,	   // Bus slave 0
	input  wire				   s1_cs_,	   // Bus slave 1
	input  wire				   s2_cs_,	   // Bus slave 2
	input  wire				   s3_cs_,	   // Bus slave 3
	input  wire				   s4_cs_,	   // Bus slave 4
	input  wire				   s5_cs_,	   // Bus slave 5
	input  wire				   s6_cs_,	   // Bus slave 6
	input  wire				   s7_cs_,	   // Bus slave 7
	/********** Bus slave signals **********/
	// Bus slave 0
	input  wire [`WordDataBus] s0_rd_data, // Read data
	input  wire				   s0_rdy_,	   // Ready
	// Bus slave 1
	input  wire [`WordDataBus] s1_rd_data, // Read data
	input  wire				   s1_rdy_,	   // Ready
	// Bus slave 2
	input  wire [`WordDataBus] s2_rd_data, // Read data
	input  wire				   s2_rdy_,	   // Ready
	// Bus slave 3
	input  wire [`WordDataBus] s3_rd_data, // Read data
	input  wire				   s3_rdy_,	   // Ready
	// Bus slave 4
	input  wire [`WordDataBus] s4_rd_data, // Read data
	input  wire				   s4_rdy_,	   // Ready
	// Bus slave 5
	input  wire [`WordDataBus] s5_rd_data, // Read data
	input  wire				   s5_rdy_,	   // Ready
	// Bus slave 6
	input  wire [`WordDataBus] s6_rd_data, // Read data
	input  wire				   s6_rdy_,	   // Ready
	// Bus slave 7
	input  wire [`WordDataBus] s7_rd_data, // Read data
	input  wire				   s7_rdy_,	   // Ready
	/********** Bus master common signals **********/
	output reg	[`WordDataBus] m_rd_data,  // Read data
	output reg				   m_rdy_	   // Ready
);

	/********** Bus slave multiplexer **********/
	always @(*) begin
		/* Select according to chip select (CS) */
		if (s0_cs_ == `ENABLE_) begin		   // Bus slave 0
			m_rd_data = s0_rd_data;
			m_rdy_	  = s0_rdy_;
		end else if (s1_cs_ == `ENABLE_) begin // Bus slave 1
			m_rd_data = s1_rd_data;
			m_rdy_	  = s1_rdy_;
		end else if (s2_cs_ == `ENABLE_) begin // Bus slave 2
			m_rd_data = s2_rd_data;
			m_rdy_	  = s2_rdy_;
		end else if (s3_cs_ == `ENABLE_) begin // Bus slave 3
			m_rd_data = s3_rd_data;
			m_rdy_	  = s3_rdy_;
		end else if (s4_cs_ == `ENABLE_) begin // Bus slave 4
			m_rd_data = s4_rd_data;
			m_rdy_	  = s4_rdy_;
		end else if (s5_cs_ == `ENABLE_) begin // Bus slave 5
			m_rd_data = s5_rd_data;
			m_rdy_	  = s5_rdy_;
		end else if (s6_cs_ == `ENABLE_) begin // Bus slave 6
			m_rd_data = s6_rd_data;
			m_rdy_	  = s6_rdy_;
		end else if (s7_cs_ == `ENABLE_) begin // Bus slave 7
			m_rd_data = s7_rd_data;
			m_rdy_	  = s7_rdy_;
		end else begin						   // Default value
			m_rd_data = `WORD_DATA_W'h0;
			m_rdy_	  = `DISABLE_;
		end
	end

endmodule
