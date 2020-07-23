/*
 -- ============================================================================
 -- FILE NAME	: bus.h
 -- DESCRIPTION : Bus header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

`ifndef __BUS_HEADER__
	`define __BUS_HEADER__			 // Include gauard

	/********** Master *********/
	`define BUS_MASTER_CH	   4	 // The number of bus master channels
	`define BUS_MASTER_INDEX_W 2	 // The width of bus master index

	/********** Bus owner *********/
	`define BusOwnerBus		   1:0	 // Status of bus owner
	`define BUS_OWNER_MASTER_0 2'h0	 // Bus owner: Bus master 0
	`define BUS_OWNER_MASTER_1 2'h1	 // Bus owner: Bus master 1
	`define BUS_OWNER_MASTER_2 2'h2	 // Bus owner: Bus master 2
	`define BUS_OWNER_MASTER_3 2'h3	 // Bus owner: Bus master 3

	/********** Bus slave *********/
	`define BUS_SLAVE_CH	   8	 // The number of bus slave channels
	`define BUS_SLAVE_INDEX_W  3	 // The width of bus slave index
	`define BusSlaveIndexBus   2:0	 // Status of bus slave
	`define BusSlaveIndexLoc   29:27 // Index of bus slave location

	`define BUS_SLAVE_0		   0	 // Bus slave 0
	`define BUS_SLAVE_1		   1	 // Bus slave 1
	`define BUS_SLAVE_2		   2	 // Bus slave 2
	`define BUS_SLAVE_3		   3	 // Bus slave 3
	`define BUS_SLAVE_4		   4	 // Bus slave 4
	`define BUS_SLAVE_5		   5	 // Bus slave 5
	`define BUS_SLAVE_6		   6	 // Bus slave 6
	`define BUS_SLAVE_7		   7	 // Bus slave 7

`endif
