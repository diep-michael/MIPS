`timescale 1ns / 1ps
/*********************************************************
 * File Name: IO_Module.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/22/18
 *
 * Purpose: This module is used to represent an IO subsystem. 
 *          In this case, it simply contains a 8x4096 memory 
 *          module to represent IO memory, and an interrupt
 *          /interrupt acknowledge signal to be used in
 *          simulation.
 *          
 * Notes:  Rev. 4/22/18 - implemented, updated header
 *         
 *        
 *********************************************************/
module IO_Module(clk, rst, io_cs, io_rd, io_wr, inta, addr, din, intr, dout);
input clk, rst, io_cs, io_rd, io_wr, inta;
input [11:0] addr;
input [31:0] din;
output reg intr;
output [31:0] dout;

Data_Memory IOMEM (
      .clk(clk),
      .rst(rst),
      .dm_cs(io_cs),
      .dm_wr(io_wr),
      .dm_rd(io_rd),
      .addr(addr),
      .D_in(din),
      .D_out(dout)
      );
      
initial begin
    intr = 0;
    #350 intr = 1;
    @(posedge inta) intr =0;
    end

endmodule
