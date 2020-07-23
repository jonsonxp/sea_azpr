/*
 -- ============================================================================
 -- FILE NAME	: bus_master_mux.v
 -- DESCRIPTION : Bus master multiplexer
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
module bus_master_mux (
	/********** Bus master signal **********/
	// Bus master 0
	input  wire [`WordAddrBus] m0_addr,	   // Address
	input  wire				   m0_as_,	   // Address strobe
	input  wire				   m0_rw,	   // Read/Write
	input  wire [`WordDataBus] m0_wr_data, // Write data
	input  wire				   m0_grnt_,   // Bus grant
	// Bus master 1
	input  wire [`WordAddrBus] m1_addr,	   // Address
	input  wire				   m1_as_,	   // Address strobe
	input  wire				   m1_rw,	   // Read/Write
	input  wire [`WordDataBus] m1_wr_data, // Write data
	input  wire				   m1_grnt_,   // Bus grant
	// Bus master 2
	input  wire [`WordAddrBus] m2_addr,	   // Address
	input  wire				   m2_as_,	   // Address strobe
	input  wire				   m2_rw,	   // Read/Write
	input  wire [`WordDataBus] m2_wr_data, // Write data
	input  wire				   m2_grnt_,   // Bus grant
	// Bus master 3
	input  wire [`WordAddrBus] m3_addr,	   // Address
	input  wire				   m3_as_,	   // Address strobe
	input  wire				   m3_rw,	   // Read/Write
	input  wire [`WordDataBus] m3_wr_data, // Write data
	input  wire				   m3_grnt_,   // Bus grant
	/********** Bus slave common signal **********/
	output reg	[`WordAddrBus] s_addr,	   // Address
	output reg				   s_as_,	   // Address strobe
	output reg				   s_rw,	   // Read/Write
	output reg	[`WordDataBus] s_wr_data   // Write data
);

	/********** Bus master multiplexer **********/
	always @(*) begin
		/* Select master with bus owner */
		if (m0_grnt_ == `ENABLE_) begin			 // Bus master 0
			s_addr	  = m0_addr;
			s_as_	  = m0_as_;
			s_rw	  = m0_rw;
			s_wr_data = m0_wr_data;
		end else if (m1_grnt_ == `ENABLE_) begin // Bus master 1
			s_addr	  = m1_addr;
			s_as_	  = m1_as_;
			s_rw	  = m1_rw;
			s_wr_data = m1_wr_data;
		end else if (m2_grnt_ == `ENABLE_) begin // Bus master 2
			s_addr	  = m2_addr;
			s_as_	  = m2_as_;
			s_rw	  = m2_rw;
			s_wr_data = m2_wr_data;
		end else if (m3_grnt_ == `ENABLE_) begin // Bus master 3
			s_addr	  = m3_addr;
			s_as_	  = m3_as_;
			s_rw	  = m3_rw;
			s_wr_data = m3_wr_data;
		end else begin							 // Default value
			s_addr	  = `WORD_ADDR_W'h0;
			s_as_	  = `DISABLE_;
			s_rw	  = `READ;
			s_wr_data = `WORD_DATA_W'h0;
		end
	end

endmodule
