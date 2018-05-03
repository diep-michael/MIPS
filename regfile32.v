`timescale 1ns / 1ps
/*********************************************************
 * File Name: regfile32.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/22/18
 *
 * Purpose: This module is used to instantiate a 32 wide
 *          x 32 deep register file. It requires a clock
 *          and reset. The S_addr and T_addr allow dual
 *          port readability. Outputting contents of the
 *          register file does not require a clock and
 *          is based on combinational logic. The D input
 *          is used for the data to be written to a reg.
 *          The D_en input needs to be high in order to 
 *          write to the reg. D_addr specifies which reg
 *          will be written to. S and T output the contents
 *          with respect to the S_addr and T_addr, respectively.
 *          *Reset is used to set Register0 (array[0] to 0.
 *
 * Notes:  Rev. 2/13/18 - updated header and added comments
 *         Rev. 2/23/18 - updated reset functionality & header
 *         Rev. 4/19/18 - R[29] now gets 3FC for pipelining.
 *         Rev. 4/22/18 - updated header to reflect write change
 *
 *         IMPORTANT: Register 0 (array[0]) cannot be written to;
 *         the contents will always remain 32 bits of 0.
 *         ALSO IMPORTANT: D is written to the Reg File on the
 *         NEGEDGE of clock. This allows for proper pipelining. 
 *********************************************************/
module regfile32(clk, rst, S_addr, T_addr, D, D_en, D_addr, S, T);

input clk, rst, D_en;
input [4:0] S_addr, T_addr, D_addr;
input [31:0] D;

output [31:0] S, T;

reg [31:0] array [0:31];

integer i;

assign S = array[S_addr];

assign T = array[T_addr];

always @(negedge clk, posedge rst) 
   if (rst) begin
   array[0] <= 32'h0; 
   array[29]<= 32'h_3FC; end else
   if (D_en) array[D_addr] <= (D_addr == 5'h0) ? 32'h0 : D;
  
endmodule
