`timescale 1ns / 1ps
/*********************************************************
 * File Name: Data_Memory.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/22/18
 *
 * Purpose: This is a 8 x 4096 byte addressable data memory 
 *          module that is used to interface with out Integer
 *          Datapath V2. This module has both read and write 
 *          features. The data in our memory is organized in
 *          big endian format. Meaning the MSB's of our output
 *          will recieve the lowest of the 4 bytes of the address.
 *          Anytime we want to access data in the memory, dm_cs,
 *          our chip select must be enabled.
 *          
 * Notes:  Rev. 3/4/18 - updated header and added comments
 *         Rev. 4/22/18 - updated header
 *        
 *********************************************************/
module Data_Memory(clk, rst, dm_cs, dm_wr, dm_rd, addr, D_in, D_out);

input clk, rst, dm_cs, dm_wr, dm_rd;
input [31:0] D_in;
input [11:0] addr;
output [31:0] D_out;

reg [7:0] mem_array [0:4095];

////////output assign//////////
//////with high Z when unused//
assign D_out = (dm_rd&&dm_cs)? {mem_array[addr],mem_array[addr+1],
                                mem_array[addr+2],mem_array[addr+3]}:
                                32'hZZZZ_ZZZZ; //else

always @(posedge clk, posedge rst)
   if (rst) ; else//////whatdohereallison///////
   if (dm_cs&&dm_wr) begin
         mem_array[addr] <= D_in [31:24];
         mem_array[addr+1] <= D_in [23:16];
         mem_array[addr+2] <= D_in [15:8];
         mem_array[addr+3] <= D_in [7:0]; end

endmodule
