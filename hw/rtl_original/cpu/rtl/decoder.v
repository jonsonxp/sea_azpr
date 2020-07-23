/*
 -- ============================================================================
 -- FILE NAME	: decoder.v
 -- DESCRIPTION : Instruction decoder
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

/********** Module **********/
module decoder (
	/********** IF/ID pipeline register **********/
	input  wire [`WordAddrBus]	 if_pc,			 // Program counter
	input  wire [`WordDataBus]	 if_insn,		 // Instruction
	input  wire					 if_en,			 // Enable pipeline data
	/********** GPR interface **********/
	input  wire [`WordDataBus]	 gpr_rd_data_0, // Read data 0
	input  wire [`WordDataBus]	 gpr_rd_data_1, // Read data 1
	output wire [`RegAddrBus]	 gpr_rd_addr_0, // Read address 0
	output wire [`RegAddrBus]	 gpr_rd_addr_1, // Read address 1
	/********** Forwarding **********/
	// Forwarding form ID stage
	input  wire					 id_en,			// Enable pipeline data
	input  wire [`RegAddrBus]	 id_dst_addr,	// Write address
	input  wire					 id_gpr_we_,	// Write enable
	input  wire [`MemOpBus]		 id_mem_op,		// Memory operation
	// Forwarding form EX stage
	input  wire					 ex_en,			// Enable pipeline data
	input  wire [`RegAddrBus]	 ex_dst_addr,	// Write address
	input  wire					 ex_gpr_we_,	// Write enable
	input  wire [`WordDataBus]	 ex_fwd_data,	// Forwarding data
	// Forwarding form MEM stage
	input  wire [`WordDataBus]	 mem_fwd_data,	// Forwarding data
	/********** Control register interface **********/
	input  wire [`CpuExeModeBus] exe_mode,		// Execution mode
	input  wire [`WordDataBus]	 creg_rd_data,	// Read data
	output wire [`RegAddrBus]	 creg_rd_addr,	// Read address
	/********** Decode result **********/
	output reg	[`AluOpBus]		 alu_op,		// ALU operation
	output reg	[`WordDataBus]	 alu_in_0,		// ALU input 0
	output reg	[`WordDataBus]	 alu_in_1,		// ALU input 1
	output reg	[`WordAddrBus]	 br_addr,		// Branch address
	output reg					 br_taken,		// Branch taken
	output reg					 br_flag,		// Brach flag
	output reg	[`MemOpBus]		 mem_op,		// Memory operation
	output wire [`WordDataBus]	 mem_wr_data,	// Data to write to memory
	output reg	[`CtrlOpBus]	 ctrl_op,		// Control operation
	output reg	[`RegAddrBus]	 dst_addr,		// GPR write address
	output reg					 gpr_we_,		// GPR write enable
	output reg	[`IsaExpBus]	 exp_code,		// Exception code
	output reg					 ld_hazard		// Load hazard
);

	/********** Instruction field **********/
	wire [`IsaOpBus]	op		= if_insn[`IsaOpLoc];	  // Opcode
	wire [`RegAddrBus]	ra_addr = if_insn[`IsaRaAddrLoc]; // Ra address
	wire [`RegAddrBus]	rb_addr = if_insn[`IsaRbAddrLoc]; // Rb address
	wire [`RegAddrBus]	rc_addr = if_insn[`IsaRcAddrLoc]; // Rc address
	wire [`IsaImmBus]	imm		= if_insn[`IsaImmLoc];	  // Immediate
	/********** Immediate **********/
	// Sign extension
	wire [`WordDataBus] imm_s = {{`ISA_EXT_W{imm[`ISA_IMM_MSB]}}, imm};
	// Zero extension
	wire [`WordDataBus] imm_u = {{`ISA_EXT_W{1'b0}}, imm};
	/********** Register read address **********/
	assign gpr_rd_addr_0 = ra_addr; // GPR read address 0
	assign gpr_rd_addr_1 = rb_addr; // GPR read address 1
	assign creg_rd_addr	 = ra_addr; // Control register read address
	/********** Control register read data **********/
	reg			[`WordDataBus]	ra_data;						  // Unsigned Ra
	wire signed [`WordDataBus]	s_ra_data = $signed(ra_data);	  // Signed Ra
	reg			[`WordDataBus]	rb_data;						  // Unsigned Rb
	wire signed [`WordDataBus]	s_rb_data = $signed(rb_data);	  // Signed Rb
	assign mem_wr_data = rb_data; // Data to write to memory
	/********** Address **********/
	wire [`WordAddrBus] ret_addr  = if_pc + 1'b1;					 // Return address
	wire [`WordAddrBus] br_target = if_pc + imm_s[`WORD_ADDR_MSB:0]; // Branch address
	wire [`WordAddrBus] jr_target = ra_data[`WordAddrLoc];		   // Jump address

	/********** Forwarding **********/
	always @(*) begin
		/* Ra register */
		if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && 
			(id_dst_addr == ra_addr)) begin
			ra_data = ex_fwd_data;	 // Forwarding from EX stage
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && 
					 (ex_dst_addr == ra_addr)) begin
			ra_data = mem_fwd_data;	 // Forwarding from MEM stage
		end else begin
			ra_data = gpr_rd_data_0; // Read from register file
		end
		/* Rb register */
		if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && 
			(id_dst_addr == rb_addr)) begin
			rb_data = ex_fwd_data;	 // Forwarding from EX stage
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && 
					 (ex_dst_addr == rb_addr)) begin
			rb_data = mem_fwd_data;	 // Forwarding from MEM stage
		end else begin
			rb_data = gpr_rd_data_1; // Read from register file
		end
	end

	/********** Load hazard detection **********/
	always @(*) begin
		if ((id_en == `ENABLE) && (id_mem_op == `MEM_OP_LDW) &&
			((id_dst_addr == ra_addr) || (id_dst_addr == rb_addr))) begin
			ld_hazard = `ENABLE;  // Load hazard
		end else begin
			ld_hazard = `DISABLE; // No hazard
		end
	end

	/********** Decode instruction **********/
	always @(*) begin
		/* Default value */
		alu_op	 = `ALU_OP_NOP;
		alu_in_0 = ra_data;
		alu_in_1 = rb_data;
		br_taken = `DISABLE;
		br_flag	 = `DISABLE;
		br_addr	 = {`WORD_ADDR_W{1'b0}};
		mem_op	 = `MEM_OP_NOP;
		ctrl_op	 = `CTRL_OP_NOP;
		dst_addr = rb_addr;
		gpr_we_	 = `DISABLE_;
		exp_code = `ISA_EXP_NO_EXP;
		/* Opcode */
		if (if_en == `ENABLE) begin
			case (op)
				/* Logical operation */
				`ISA_OP_ANDR  : begin 
					alu_op	 = `ALU_OP_AND;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ANDI  : begin 
					alu_op	 = `ALU_OP_AND;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ORR	  : begin 
					alu_op	 = `ALU_OP_OR;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ORI	  : begin 
					alu_op	 = `ALU_OP_OR;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_XORR  : begin 
					alu_op	 = `ALU_OP_XOR;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_XORI  : begin 
					alu_op	 = `ALU_OP_XOR;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				/* Arithmetic operation */
				`ISA_OP_ADDSR : begin 
					alu_op	 = `ALU_OP_ADDS;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDSI : begin 
					alu_op	 = `ALU_OP_ADDS;
					alu_in_1 = imm_s;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDUR : begin 
					alu_op	 = `ALU_OP_ADDU;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDUI : begin 
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SUBSR : begin 
					alu_op	 = `ALU_OP_SUBS;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SUBUR : begin 
					alu_op	 = `ALU_OP_SUBU;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				/* Shift */
				`ISA_OP_SHRLR : begin 
					alu_op	 = `ALU_OP_SHRL;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHRLI : begin 
					alu_op	 = `ALU_OP_SHRL;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHLLR : begin 
					alu_op	 = `ALU_OP_SHLL;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHLLI : begin 
					alu_op	 = `ALU_OP_SHLL;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				/* Branch */
				`ISA_OP_BE	  : begin // Signed compare registers(Ra == Rb)
					br_addr	 = br_target;
					br_taken = (ra_data == rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BNE	  : begin // Signed compare registers(Ra != Rb)
					br_addr	 = br_target;
					br_taken = (ra_data != rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BSGT  : begin // Signed compare registers(Ra < Rb)
					br_addr	 = br_target;
					br_taken = (s_ra_data < s_rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BUGT  : begin // Unsigned compare registers(Ra < Rb)
					br_addr	 = br_target;
					br_taken = (ra_data < rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_JMP	  : begin // Jump
					br_addr	 = jr_target;
					br_taken = `ENABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_CALL  : begin // Call
					alu_in_0 = {ret_addr, {`BYTE_OFFSET_W{1'b0}}};
					br_addr	 = jr_target;
					br_taken = `ENABLE;
					br_flag	 = `ENABLE;
					dst_addr = `REG_ADDR_W'd31;
					gpr_we_	 = `ENABLE_;
				end
				/* Memory access */
				`ISA_OP_LDW	  : begin // Load word
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					mem_op	 = `MEM_OP_LDW;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_STW	  : begin // Store word
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					mem_op	 = `MEM_OP_STW;
				end
				/* System call */
				`ISA_OP_TRAP  : begin // Trap
					exp_code = `ISA_EXP_TRAP;
				end
				/* Privilege */
				`ISA_OP_RDCR  : begin // Read control register
					if (exe_mode == `CPU_KERNEL_MODE) begin
						alu_in_0 = creg_rd_data;
						gpr_we_	 = `ENABLE_;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				`ISA_OP_WRCR  : begin // Write control register
					if (exe_mode == `CPU_KERNEL_MODE) begin
						ctrl_op	 = `CTRL_OP_WRCR;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				`ISA_OP_EXRT  : begin // Restore from exception
					if (exe_mode == `CPU_KERNEL_MODE) begin
						ctrl_op	 = `CTRL_OP_EXRT;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				/* Other instructions */
				default		  : begin // Undefined instruction
					exp_code = `ISA_EXP_UNDEF_INSN;
				end
			endcase
		end
	end

endmodule
