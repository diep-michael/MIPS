`timescale 1ns / 1ps
/*********************************************************
 * File Name: Load_Reg_32.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/22/18
 *
 * Purpose: This module is a 32-bit loadable register with
 *          increment capabilites. Because we are using this module
 *          with our Program Counter, the increment will add 4 to
 *          the input value, instead of 1. A nop will load the 
 *          register with 0's. 
 *          
 * Notes:  Rev. 3/20/18 - updated header and added comments
 *         Rev. 4/22/18 - updated header for nop
 *        
 *********************************************************/
module Load_Reg_32(clk, rst, load, inc, nop, d, q);
input clk, rst, load, inc, nop;
input [31:0] d;
output reg [31:0] q;

always @(posedge clk, posedge rst)
   if (rst)  q <= 32'h0; else
   if (inc)  q <= q + 32'h4; else
   if (load) q <= d; else
   if (nop)  q <= 32'h0;

endmodule
