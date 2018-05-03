`timescale 1ns / 1ps
/*********************************************************
 * File Name: ALU_32.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 2/23/18
 *
 * Purpose: This module is used to instantiate a 32-bit
 *          MIPS ALU. It has two 32-bit data inputs (S T),
 *          5-bit Opcode input (FS), two 32-bit outputs
 *          (Y-hi, Y_lo), four status flags (Carry(C) 
 *          Overflow(V) Negative(N) Zero(Z). It can 
 *          perform signed multiplication and division,
 *          as well as the operations found in the MIPS_32
 *          module. The multiplation and division have
 *          64-bit outputs and utilize both Y_hi and Y_lo.
 *          The operation in the MIPS module only use Y_lo.
 *
 * Notes:   Rev Date 2/2/18  - updated N Z flag output mux. 
 *                             added V C flag output mux.
 *          Rev Date 2/23/18 - updated header
 *********************************************************/
module ALU_top(S, T, FS, shamt, Y_hi, Y_lo, C, V, N, Z);
   input [4:0] FS, shamt;
   input [31:0] S, T;
   
   output [31:0] Y_hi, Y_lo;
   output N, Z, V, C;
   
   wire [31:0] mips_hi, mips_lo, quot, rem, mpy_hi, mpy_lo;
   wire V_mips, C_mips;
   
   localparam MUL = 5'h1E, DIV = 5'h1F, ADDU = 5'h04, SUBU = 5'h05;
             
////////////////////////////////////////
///////////////MIPS_32//////////////////
////////////////////////////////////////
MIPS_32 MIPS  ( .FS(FS),
                .shamt(shamt),
                .S(S),
                .T(T),
                .V(V_mips),
                .C(C_mips),
                .Y_hi(mips_hi),
                .Y_lo(mips_lo)
                );
                
////////////////////////////////////////
///////////////DIV_32///////////////////
////////////////////////////////////////
DIV_32 DIV_32   ( .FS(FS),
               .S(S),
               .T(T),
               .quot(quot),
               .rem(rem)
               );
               
////////////////////////////////////////
///////////////MPY_32///////////////////
////////////////////////////////////////
MPY_32 MPY   ( .FS(FS),
               .S(S),
               .T(T),
               .Y_hi(mpy_hi),
               .Y_lo(mpy_lo)
               );

///////////Y output mux/////////////////
assign {Y_hi, Y_lo} = (FS == MUL) ? {mpy_hi, mpy_lo} : 
                      (FS == DIV) ? {rem   , quot  } :
                                    {mips_hi, mips_lo};
                           
///////////N Z Output mux///////////////                       
assign {N, Z} = (FS == MUL) ? {mpy_hi[31],  ~| {mpy_hi, mpy_lo}} :
                (FS == DIV) ? {quot[31]  ,  ~| quot} :
                (FS == ADDU)? {1'b0       , ~| mips_lo} :
                (FS == SUBU)? {1'b0       , ~| mips_lo} :
                              {mips_lo[31], ~| mips_lo};
                              
///////////V C output mux///////////////                             
assign {V, C} = ((FS == MUL) || (FS == DIV)) ? 2'bxx : {V_mips, C_mips};

endmodule
