/*
 -- ============================================================================
 -- FILE NAME	: x_s3e_dpram.v
 -- DESCRIPTION : Xilinx Spartan-3E Dual Port RAM psuedo module
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- 2.0.0	  2020/07/03  Qian Zhao		 Modified for Vivado 2018.2
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** Local header **********/
`include "spm.h"

/********** Module **********/
module x_s3e_dpram (
	/********** Port A **********/
	input  wire				   clka, 
	input  wire [`SpmAddrBus]  addra, 
	input  wire [`WordDataBus] dia, 
	input  wire				   ena,	 
	input  wire				   wea,	 
	output reg	[`WordDataBus] doa, 
	/********** Port B **********/
	input  wire				   clkb,
	input  wire [`SpmAddrBus]  addrb,
	input  wire [`WordDataBus] dib,
	input  wire				   enb,
	input  wire				   web,
	output reg	[`WordDataBus] dob 
);

	/********** Memory **********/
	reg [`WordDataBus] ram [0:`SPM_DEPTH-1];
	reg [`WordDataBus] doa, dob;

	/********** Memory access Port A **********/
	always @(posedge clka) begin
		if(ena)
		begin
            if (wea) begin
                ram[addra]<= #1 dia;
            end
            doa <= ram[addra];
		end
	end

	/********** Memory access (Port B) **********/
	always @(posedge clkb) begin
		if(enb)
		begin
            if (web) begin
                ram[addrb]<= #1 dib;
            end
            dob <= ram[addrb];
		end
	end

endmodule
