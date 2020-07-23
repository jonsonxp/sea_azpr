/*
 -- ============================================================================
 -- FILE NAME	: stddef.h
 -- DESCRIPTION : Global macro
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/04/01  suito		 Created
 -- ============================================================================
*/

`ifndef __STDDEF_HEADER__				 // Include guard
	`define __STDDEF_HEADER__

// -----------------------------------------------------------------------------
// Value of signal
// -----------------------------------------------------------------------------
	/********** Signal level *********/
	`define HIGH				1'b1	 // High level
	`define LOW					1'b0	 // Low level
	/********** Enable/Disable *********/
	// Positive logic 
	`define DISABLE				1'b0
	`define ENABLE				1'b1
	// Negative logic
	`define DISABLE_			1'b1
	`define ENABLE_				1'b0
	/********** Read/Write *********/
	`define READ				1'b1
	`define WRITE				1'b0

// -----------------------------------------------------------------------------
// Data bus
// -----------------------------------------------------------------------------
	/********** Least significant bit *********/
	`define LSB					0
	/********** Byte (8 bit) *********/
	`define BYTE_DATA_W			8		 // Data width
	`define BYTE_MSB			7		 // Most significant bit
	`define ByteDataBus			7:0		 // Data bus
	/********** Word (32 bit) *********/
	`define WORD_DATA_W			32		 // Data width
	`define WORD_MSB			31		 // Most significant bit
	`define WordDataBus			31:0	 	 // Data bus

// -----------------------------------------------------------------------------
// Address bus
// -----------------------------------------------------------------------------
	/********** Word address *********/
	`define WORD_ADDR_W			30		 // Address width
	`define WORD_ADDR_MSB		29		 // Most significant bit
	`define WordAddrBus			29:0	 // Address bus
	/********** Byte offset *********/
	`define BYTE_OFFSET_W		2		 // Offset width
	`define ByteOffsetBus		1:0		 // Offset bus
	/********** Address location *********/
	`define WordAddrLoc			31:2	 // Word address location
	`define ByteOffsetLoc		1:0		 // Byte offset location
	/********** Value of byte offset *********/
	`define BYTE_OFFSET_WORD	2'b00	 // Word boundary

`endif
