/*
 -- ============================================================================
 -- FILE NAME	: bus.v
 -- DESCRIPTION : Bus
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
module bus (
	/********** Clock & Reset **********/
	input  wire				   clk,		   // Clock
	input  wire				   reset,	   // Asynchronous reset
	/********** Bus master signal **********/
	// Bus master common signal
	output wire [`WordDataBus] m_rd_data,  // Read data
	output wire				   m_rdy_,	   // Ready
	// Bus master 0
	input  wire				   m0_req_,	   // Bus request
	input  wire [`WordAddrBus] m0_addr,	   // Address
	input  wire				   m0_as_,	   // Address strobe
	input  wire				   m0_rw,	   // Read/Write
	input  wire [`WordDataBus] m0_wr_data, // Write data
	output wire				   m0_grnt_,  
	// Bus master 1
	input  wire				   m1_req_,
	input  wire [`WordAddrBus] m1_addr,	  
	input  wire				   m1_as_,	  
	input  wire				   m1_rw,	 
	input  wire [`WordDataBus] m1_wr_data, 
	output wire				   m1_grnt_,   
	// Bus master 2
	input  wire				   m2_req_,	   
	input  wire [`WordAddrBus] m2_addr,	  
	input  wire				   m2_as_,	   
	input  wire				   m2_rw,	  
	input  wire [`WordDataBus] m2_wr_data,
	output wire				   m2_grnt_,   
	// Bus master 3
	input  wire				   m3_req_,	   
	input  wire [`WordAddrBus] m3_addr,	  
	input  wire				   m3_as_,	   
	input  wire				   m3_rw,	  
	input  wire [`WordDataBus] m3_wr_data,
	output wire				   m3_grnt_,
	/********** Bus salve singals **********/
	// Bus slave common signals
	output wire [`WordAddrBus] s_addr,	   // Address
	output wire				   s_as_,	   // Address strobe
	output wire				   s_rw,	   // Read/Write
	output wire [`WordDataBus] s_wr_data,  // Write data
	// Bus salve 0
	input  wire [`WordDataBus] s0_rd_data, // Read data
	input  wire				   s0_rdy_,	   // Read
	output wire				   s0_cs_,	   // Chip select
	// Bus salve 1
	input  wire [`WordDataBus] s1_rd_data,
	input  wire				   s1_rdy_,	   
	output wire				   s1_cs_,	   
	// Bus salve 2
	input  wire [`WordDataBus] s2_rd_data, 
	input  wire				   s2_rdy_,	  
	output wire				   s2_cs_,	   
	// Bus salve 3
	input  wire [`WordDataBus] s3_rd_data,
	input  wire				   s3_rdy_,	   
	output wire				   s3_cs_,	   
	// Bus salve 4
	input  wire [`WordDataBus] s4_rd_data, 
	input  wire				   s4_rdy_,	   
	output wire				   s4_cs_,	   
	// Bus salve 5
	input  wire [`WordDataBus] s5_rd_data, 
	input  wire				   s5_rdy_,	   
	output wire				   s5_cs_,	   
	// Bus salve 6
	input  wire [`WordDataBus] s6_rd_data, 
	input  wire				   s6_rdy_,	   
	output wire				   s6_cs_,	   
	// Bus salve 7
	input  wire [`WordDataBus] s7_rd_data, 
	input  wire				   s7_rdy_,	   
	output wire				   s7_cs_	   
);

	/********** Bus arbiter **********/
	bus_arbiter bus_arbiter (
		/********** Clock & Reset **********/
		.clk		(clk),		  // Clock
		.reset		(reset),	  // Asynchronous reset
		/********** Arbitration signal **********/
		// Bus master 0
		.m0_req_	(m0_req_),	  // Bus request
		.m0_grnt_	(m0_grnt_),	  // Bus grant
		// Bus master 1
		.m1_req_	(m1_req_),	  
		.m1_grnt_	(m1_grnt_),	  
		// Bus master 2
		.m2_req_	(m2_req_),	  
		.m2_grnt_	(m2_grnt_),	 
		// Bus master 3
		.m3_req_	(m3_req_),	  
		.m3_grnt_	(m3_grnt_)	  
	);

	/********** Bus master multiplexer **********/
	bus_master_mux bus_master_mux (
		/********** Bus master signal **********/
		// Bus master 0
		.m0_addr	(m0_addr),	  // Address
		.m0_as_		(m0_as_),	  // Address stobe
		.m0_rw		(m0_rw),	  // Read/Write
		.m0_wr_data (m0_wr_data), 	  // Write data
		.m0_grnt_	(m0_grnt_),	  // Bus grant
		// Bus master 1
		.m1_addr	(m1_addr),	  
		.m1_as_		(m1_as_),	  
		.m1_rw		(m1_rw),	 
		.m1_wr_data (m1_wr_data),
		.m1_grnt_	(m1_grnt_),	  
		// Bus master 2
		.m2_addr	(m2_addr),	  
		.m2_as_		(m2_as_),	  
		.m2_rw		(m2_rw),	 
		.m2_wr_data (m2_wr_data), 
		.m2_grnt_	(m2_grnt_),	  
		// Bus master 3
		.m3_addr	(m3_addr),	  
		.m3_as_		(m3_as_),	  
		.m3_rw		(m3_rw),	  
		.m3_wr_data (m3_wr_data),
		.m3_grnt_	(m3_grnt_),	  
		/********** Bus slave common singal **********/
		.s_addr		(s_addr),	  // Address
		.s_as_		(s_as_),	  // Address stobe
		.s_rw		(s_rw),		  // Read/Write
		.s_wr_data	(s_wr_data)	  // Write data
	);

	/********** Address decoder **********/
	bus_addr_dec bus_addr_dec (
		/********** Address **********/
		.s_addr		(s_addr),	  // Address
		/********** Chip select **********/
		.s0_cs_		(s0_cs_),	  // Bus slave 0
		.s1_cs_		(s1_cs_),	  // Bus slave 1
		.s2_cs_		(s2_cs_),	  // Bus slave 2
		.s3_cs_		(s3_cs_),	  // Bus slave 3
		.s4_cs_		(s4_cs_),	  // Bus slave 4
		.s5_cs_		(s5_cs_),	  // Bus slave 5
		.s6_cs_		(s6_cs_),	  // Bus slave 6
		.s7_cs_		(s7_cs_)	  // Bus slave 7
	);

	/********** Bus strobe multiplexer **********/
	bus_slave_mux bus_slave_mux (
		/********** Chip select **********/
		.s0_cs_		(s0_cs_),	  // Bus slave 0
		.s1_cs_		(s1_cs_),	  // Bus slave 1
		.s2_cs_		(s2_cs_),	  // Bus slave 2
		.s3_cs_		(s3_cs_),	  // Bus slave 3
		.s4_cs_		(s4_cs_),	  // Bus slave 4
		.s5_cs_		(s5_cs_),	  // Bus slave 5
		.s6_cs_		(s6_cs_),	  // Bus slave 6
		.s7_cs_		(s7_cs_),	  // Bus slave 7
		/********** Bus slave signal **********/
		// Bus slave 0
		.s0_rd_data (s0_rd_data), // Read data
		.s0_rdy_	(s0_rdy_),	  // Ready
		// Bus slave 1
		.s1_rd_data (s1_rd_data), 
		.s1_rdy_	(s1_rdy_),	  
		// Bus slave 2
		.s2_rd_data (s2_rd_data), 
		.s2_rdy_	(s2_rdy_),	  
		// Bus slave 3
		.s3_rd_data (s3_rd_data), 
		.s3_rdy_	(s3_rdy_),	 
		// Bus slave 4
		.s4_rd_data (s4_rd_data), 
		.s4_rdy_	(s4_rdy_),	  
		// Bus slave 5
		.s5_rd_data (s5_rd_data), 
		.s5_rdy_	(s5_rdy_),	  
		// Bus slave 6
		.s6_rd_data (s6_rd_data), 
		.s6_rdy_	(s6_rdy_),	  
		// Bus slave 7
		.s7_rd_data (s7_rd_data), 
		.s7_rdy_	(s7_rdy_),	  
		/********** Bus master common signal **********/
		.m_rd_data	(m_rd_data),  // Read data
		.m_rdy_		(m_rdy_)	  // Ready
	);

endmodule
