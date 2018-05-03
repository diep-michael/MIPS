`timescale 1ns / 1ps
/*********************************************************
 * File Name: Instruction_Unit.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/23/18
 *
 * Purpose: This module is the instruction unit for the CPU.
 *          It is used to fetch the instruction at the current PC
 *          from the instruction memory and sign extends any
 *          immediate values. 
 *       INPUTS:
 *          Clock(clk) - min/max clock speed unknown at this point
 *          Reset(rst) - resets registers
 *          im_cs      - instruction memory chip select
 *          im_wr      - instruction memory write enable
 *          im_rd      - instruction memory read enable
 *          pc_sel     - pc input select
 *          RSB        - rs output from regfile
 *          nop        - load IR with 32 0's
 *          ID_EX_SE_16- pipelined SE_16
 *          pc_ld      - load the pc
 *          ir_ld      - load the ir
 *          PC_in      - data from memory or ALU
 *
 *
 *       OUTPUTS:
 *          PC_out     - current pc
 *          IR_out     - current IR contents
 *          SE_16      - sign extended immediate value
 *          
 *
 * Notes:  Rev. 2/23/18 - updated header and comments
 *         Rev. 4/22/18 - added nop function signal
 *         Rev. 4/23/18 - added pipeline functionality and
 *                         updated header
 *********************************************************/
module Instruction_Unit(clk, rst, im_cs, im_wr, im_rd, pc_sel, RSB, nop, ID_EX_SE_16,
                        pc_ld, pc_inc, ir_ld, PC_in, PC_out, IR_out, SE_16);

input clk, rst, im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld, nop;
input [1:0] pc_sel;
input [31:0] PC_in, RSB, ID_EX_SE_16;
output [31:0] PC_out, IR_out, SE_16;

wire [31:0] IM_D_out, PC_mux;


///PC Mux
assign PC_mux = (pc_sel == 2'b00)? PC_out + {ID_EX_SE_16[29:0],2'b00}: //jumps
                (pc_sel == 2'b01)? {PC_out[31:28],IR_out[25:0],2'b00}: //branches
                (pc_sel == 2'b10)? PC_in : //loading pc w/ data from memory or ALU
                (pc_sel == 2'b11)? RSB : 32'h0; //JR
                
///Sign Extend immediate
assign SE_16 = { {16{IR_out[15]}}, IR_out[15:0]};

///////Program Counter
Load_Reg_32 PC (
                .clk(clk),
                .rst(rst),
                .nop(1'b0),
                .d(PC_mux),
                .load(pc_ld),
                .inc(pc_inc),
                .q(PC_out)
                );

///////Instruction Memory

Data_Memory IM (
                .clk(clk),
                .rst(rst),
                .dm_cs(im_cs),
                .dm_wr(im_wr),
                .dm_rd(im_rd),
                .addr(PC_out[11:0]),
                .D_in(32'h0),
                .D_out(IM_D_out)
                );
                
///////Instruction Register
Load_Reg_32 IR (
                .clk(clk),
                .rst(rst),
                .nop(nop),
                .d(IM_D_out),
                .load(ir_ld),
                .inc(1'b0),
                .q(IR_out)
                );

endmodule
