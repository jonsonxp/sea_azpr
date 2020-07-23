/*
 -- ============================================================================
 -- FILE NAME	: spm.v
 -- DESCRIPTION : Scratchpad memory
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
`include "spm.h"

/********** Module **********/
module spm (
	/********** Clock **********/
	input  wire				   clk,				
	/********** PortA : IF stage **********/
	input  wire [`SpmAddrBus]  if_spm_addr,		// Address
	input  wire				   if_spm_as_,		// Address strobe
	input  wire				   if_spm_rw,		// Read/Write
	input  wire [`WordDataBus] if_spm_wr_data,	// Write data
	output wire [`WordDataBus] if_spm_rd_data,	// Read data
	/********** PortB : MEM stage **********/
	input  wire [`SpmAddrBus]  mem_spm_addr,	// Address
	input  wire				   mem_spm_as_,		// Address strobe
	input  wire				   mem_spm_rw,		// Read/Write
	input  wire [`WordDataBus] mem_spm_wr_data, // Write data
	output wire [`WordDataBus] mem_spm_rd_data	// Read data
);

	/********** Write enable signal **********/
	reg						   wea;			// Port A
	reg						   web;			// Port B

	/********** Generate write enable signal **********/
	always @(*) begin
		/* Port A */
		if ((if_spm_as_ == `ENABLE_) && (if_spm_rw == `WRITE)) begin   
			wea = `MEM_ENABLE;	// Write enable
		end else begin
			wea = `MEM_DISABLE; // Write disable
		end
		/* Port B */
		if ((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `WRITE)) begin
			web = `MEM_ENABLE;	// Write enable
		end else begin
			web = `MEM_DISABLE; // Write disable
		end
	end

	/********** Xilinx FPGA Block RAM : Dual port RAM **********/
	x_s3e_dpram x_s3e_dpram (
        /********** Port A : IF stage **********/
        .clka  (clk),        
        .addra (if_spm_addr),
        .dia  (if_spm_wr_data),  
        .ena   (wea),        
        .wea   (wea),        
        .doa (if_spm_rd_data),  
        /********** Port B : MEM stage **********/
        .clkb  (clk),        
        .addrb (mem_spm_addr),      
        .dib  (mem_spm_wr_data), 
        .enb   (web),        
        .web   (web),        
        .dob (mem_spm_rd_data) 
    );
  
endmodule
