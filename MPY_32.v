`timescale 1ns / 1ps
/*********************************************************
 * File Name: MPY_32.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 2/23/17
 *
 * Purpose: This module is used to do signed multiplication.
 *          It requires the 5-bit opcode, two 32-bit data
 *          inputs, and has two outputs. The result of the
 *          multiplication is output in the two 32-bit outputs
 *          to make up the 64-bit result of the multiply.
 *          S and T must be casted to integers, otherwise
 *          the values are treated as unsigned datatypes.
 *
 * Notes:   Rev Date 2/2/18  - updated comments and header
 *          Rev Data 2/23/18 - explained reason for typecast
 *********************************************************/
module MPY_32(FS, S, T, Y_hi, Y_lo);

 input [4:0] FS;
 input [31:0] S, T;

 output [31:0] Y_hi, Y_lo;
 
 integer S_int, T_int;

//Cast S & T to Integer//
//Signed mult. will not work correctly
//on default unsigned datatype
 always @ (*)
   begin
   S_int <= S;
   T_int <= T;
   end
    
  assign {Y_hi, Y_lo} = S_int * T_int;
 
endmodule
