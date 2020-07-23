/*
 -- ============================================================================
 -- FILE NAME	: mem_ctrl.v
 -- DESCRIPTION : Memory access control unit
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
`include "isa.h"
`include "cpu.h"
`include "bus.h"

/********** Module **********/
module mem_ctrl (
	/********** EX/MEM pipeline register **********/
	input  wire				   ex_en,		   // Enable pipline ata
	input  wire [`MemOpBus]	   ex_mem_op,	   // Memory operation
	input  wire [`WordDataBus] ex_mem_wr_data, // Memory write data
	input  wire [`WordDataBus] ex_out,		   // Processing result
	/********** Memory access interface **********/
	input  wire [`WordDataBus] rd_data,		   // Read data
	output wire [`WordAddrBus] addr,		   // Address
	output reg				   as_,			   // Address enable
	output reg				   rw,			   // Read/Write
	output wire [`WordDataBus] wr_data,		   // Write data
	/********** Memory access result **********/
	output reg [`WordDataBus]  out	 ,		   // Memory access result
	output reg				   miss_align	   // Misalign
);

	/********** Internal signal **********/
	wire [`ByteOffsetBus]	 offset;		   // Offset

	/********** Assign output **********/
	assign wr_data = ex_mem_wr_data;		   // Write data
	assign addr	   = ex_out[`WordAddrLoc];	   // Address
	assign offset  = ex_out[`ByteOffsetLoc];   // Offset

	/********** Memory access control **********/
	always @(*) begin
		/* Default value */
		miss_align = `DISABLE;
		out		   = `WORD_DATA_W'h0;
		as_		   = `DISABLE_;
		rw		   = `READ;
		/* Memory access */
		if (ex_en == `ENABLE) begin
			case (ex_mem_op)
				`MEM_OP_LDW : begin // Read word
					/* Byte offset check */
					if (offset == `BYTE_OFFSET_WORD) begin // Align
						out			= rd_data;
						as_		   = `ENABLE_;
					end else begin						   // Misalign
						miss_align	= `ENABLE;
					end
				end
				`MEM_OP_STW : begin // Write word
					/* Byte offset check */
					if (offset == `BYTE_OFFSET_WORD) begin // Align
						rw			= `WRITE;
						as_		   = `ENABLE_;
					end else begin						   // Misalign
						miss_align	= `ENABLE;
					end
				end
				default		: begin // No memory access
					out			= ex_out;
				end
			endcase
		end
	end

endmodule
