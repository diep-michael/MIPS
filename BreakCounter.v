`timescale 1ns / 1ps
/*********************************************************
 * File Name: BreakCounter.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/23/2018
 *
 * Purpose: This module is used to generate a signal to end 
 *          simulation after a break instruction is reached.
 *          It is designed to allow any prior instructions to
 *          finish executing before sending the break signal.
 *
 * Notes: Rev. 4/23/18  - updated header    
 *********************************************************/
module BreakCounter(clk, rst, IR, done);
input clk, rst;
input [31:0] IR;

output done;

reg start;
reg [2:0] count;

assign done = (count == 3'h4);
assign s = (IR==32'h00_00_00_0D);

//SR flop to start counter once we see BREAK
always @(posedge clk or posedge rst)
   if (rst) start = 1'b0; else
   if (s)   start = 1'b1; else
            start = start;

//count to 4, waiting for all prior instructions to finish
always @(posedge clk or posedge rst)
   if (rst) count <= 3'h0; else
   if (start) count <= count + 3'b1; else
            count <= count;

endmodule
