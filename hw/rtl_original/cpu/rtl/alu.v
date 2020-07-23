/*
 -- ============================================================================
 -- FILE NAME	: alu.v
 -- DESCRIPTION : Arithmetic logic unit
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

/********** Module **********/
module alu (
	input  wire [`WordDataBus] in_0,  // Input 0
	input  wire [`WordDataBus] in_1,  // Input 1
	input  wire [`AluOpBus]	   op,	  // Operation
	output reg	[`WordDataBus] out,	  // Outpu
	output reg				   of	  // Overflow
);

	/********** Signed I/O signal **********/
	wire signed [`WordDataBus] s_in_0 = $signed(in_0); // Signed input 0
	wire signed [`WordDataBus] s_in_1 = $signed(in_1); // Signed input 1
	wire signed [`WordDataBus] s_out  = $signed(out);  // Signed output

	/********** Arithmetic logic operation **********/
	always @(*) begin
		case (op)
			`ALU_OP_AND	 : begin 
				out	  = in_0 & in_1;
			end
			`ALU_OP_OR	 : begin
				out	  = in_0 | in_1;
			end
			`ALU_OP_XOR	 : begin
				out	  = in_0 ^ in_1;
			end
			`ALU_OP_ADDS : begin
				out	  = in_0 + in_1;
			end
			`ALU_OP_ADDU : begin
				out	  = in_0 + in_1;
			end
			`ALU_OP_SUBS : begin
				out	  = in_0 - in_1;
			end
			`ALU_OP_SUBU : begin
				out	  = in_0 - in_1;
			end
			`ALU_OP_SHRL : begin
				out	  = in_0 >> in_1[`ShAmountLoc];
			end
			`ALU_OP_SHLL : begin
				out	  = in_0 << in_1[`ShAmountLoc];
			end
			default		 : begin // Default (No Operation)
				out	  = in_0;
			end
		endcase
	end

	/********** Overflow check **********/
	always @(*) begin
		case (op)
			`ALU_OP_ADDS : begin // ADD overflow check
				if (((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
					((s_in_0 < 0) && (s_in_1 < 0) && (s_out > 0))) begin
					of = `ENABLE;
				end else begin
					of = `DISABLE;
				end
			end
			`ALU_OP_SUBS : begin // SUB overflow check
				if (((s_in_0 < 0) && (s_in_1 > 0) && (s_out > 0)) ||
					((s_in_0 > 0) && (s_in_1 < 0) && (s_out < 0))) begin
					of = `ENABLE;
				end else begin
					of = `DISABLE;
				end
			end
			default		: begin // Default value
				of = `DISABLE;
			end
		endcase
	end

endmodule
