`timescale 1ns / 1ps
/*********************************************************
 * File Name: DIV_32.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 2/23/17
 *
 * Purpose: This module is used to perform signed division.
 *          It requires the 5-bit opcode, two 32-bit data
 *          inputs, and has two outputs.
 *          The quotient is stored in the lower bits (Y_lo).
 *          The remainder is stored in the upper bits (Y_hi).
 *          S and T must be casted to integers, otherwise
 *          the values are treated as unsigned datatypes.
 *
 * Notes:   Rev Date 2/2 - updated comments and header
 *          Rev Data 2/23/18 - explained reason for typecast
 *********************************************************/
module DIV_32(FS, S, T, quot, rem);

 input [4:0] FS;
 input [31:0] S, T;

 output [31:0] quot, rem;
 
 integer S_int, T_int;
 
//Cast S & T to Integer//
//Signed div. will not work correctly
//on default unsigned datatype
 always @ (*)
   begin
   S_int <= S;
   T_int <= T;
   end
     
  assign quot = S_int / T_int;
  assign rem  = S_int % T_int;
  
endmodule
