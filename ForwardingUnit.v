`timescale 1ns / 1ps
/*********************************************************
 * File Name: ForwardingUnit.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/23/2018
 *
 * Purpose: This module is used to implement forwarding for 
 *          a pipelined CPU architecture. It compares the 
 *          operand addresses of an instruction (instr) against
 *          the destination address of the two instructions before
 *          it. If any are equal, it will send a signal that will be
 *          used to forward the correct data back to the execution
 *          stage.
 *
 * Notes: Rev. 4/23/18  - updated header     
 *********************************************************/
module ForwardingUnit(IloRhi, isBranch, OUT_HI, SW_HI, 
                        RS, RT, RD_M1, RD_M2, FA, FB);
input IloRhi, SW_HI, isBranch, OUT_HI;
input [4:0] RS, RT, RD_M1, RD_M2;
output reg [1:0] FA, FB;

wire DH1RS, DH1RT, DH2RS, DH2RT;

//must make sure NOP (zeros) don't affect forwarding

//inst-1 destination is used in current RS
assign DH1RS = (RD_M1 == 5'h0)? 1'b0 :(RS == RD_M1); 
//inst-1 destination is used in current RT
assign DH1RT = (RD_M1 == 5'h0)? 1'b0 :(RT == RD_M1); 
//inst-2 destination is used in current RS
assign DH2RS = (RD_M2 == 5'h0)? 1'b0 :(RS == RD_M2); 
//inst-2 destination is used in current RT
assign DH2RT = (RD_M2 == 5'h0)? 1'b0 :(RT == RD_M2); 

//FA: forward mux select for RS
//FB: forward mux select for RT

//Select |  Source
//-----------------
//  00   |   ID_EX (No forwarding)
//  01   |   EX_MEM (forward from inst-1)
//  10   |   MEM_WB (forward from inst-2)

//inst-1 has priority in the case that 
//  inst-1 & inst-2 have same destination reg and need forwarding
always @(*)
  begin
  //SW/Branch/Output uses same forwarding as R-type
  // therefor use this casez if the instruction is either
  if (IloRhi | SW_HI | isBranch | OUT_HI) 
  casez ({DH1RS,DH1RT, DH2RS,DH2RT}) //R-type
                     // RS_RT
  4'b0000: {FA,FB} = 4'b00_00; //no forwarding
  4'b0001: {FA,FB} = 4'b00_10; //forward inst-2 result to RT
  4'b0010: {FA,FB} = 4'b10_00; //forward inst-2 result to RS
  4'b0011: {FA,FB} = 4'b10_10; //forward inst-2 result to RS & RT
  4'b0100: {FA,FB} = 4'b00_01; //forward inst-1 result to RT
  4'b0101: {FA,FB} = 4'b00_01; //forward inst-1 result to RT
  4'b0110: {FA,FB} = 4'b10_01; //forward inst-1 result to RT, inst-2 result to RS
  4'b0111: {FA,FB} = 4'b10_01; //forward inst-2 result to RS, inst-1 result to RT
  4'b1000: {FA,FB} = 4'b01_00; //forward inst-1 result to RS
  4'b1001: {FA,FB} = 4'b01_10; //forward inst-1 result to RS, inst-2 result to RT
  4'b1010: {FA,FB} = 4'b01_00; //forward inst-1 result to RS
  4'b1011: {FA,FB} = 4'b01_10; //forward inst-1 result to RS, inst-2 result to RT
  4'b1100: {FA,FB} = 4'b01_01; //forward inst-1 result to RS & RT
  4'b1101: {FA,FB} = 4'b01_01; //forward inst-1 result to RS & RT
  4'b1110: {FA,FB} = 4'b01_01; //forward inst-1 result to RS & RT
  4'b1111: {FA,FB} = 4'b01_01; //forward inst-1 result to RS & RT
  endcase
  
  else
  //I-type isntructions, besides SW/branches/Output, do not need
  // forwarding to RT.
  casez ({DH1RS,DH1RT, DH2RS,DH2RT}) //I-type 
                        // RS_RT
     4'b0000: {FA,FB} = 4'b00_00; //no forwarding
     4'b0001: {FA,FB} = 4'b00_00; //no forwarding
     4'b0010: {FA,FB} = 4'b10_00; //forward inst-2 result to RS
     4'b0011: {FA,FB} = 4'b10_00; //forward inst-2 result to RS 
     4'b0100: {FA,FB} = 4'b00_00; //no forwarding
     4'b0101: {FA,FB} = 4'b00_00; //no forwarding
     4'b0110: {FA,FB} = 4'b10_00; //forward  inst-2 result to RS
     4'b0111: {FA,FB} = 4'b10_00; //forward inst-2 result to RS,
     4'b1000: {FA,FB} = 4'b01_00; //forward inst-1 result to RS
     4'b1001: {FA,FB} = 4'b01_00; //forward inst-1 result to RS
     4'b1010: {FA,FB} = 4'b01_00; //forward inst-1 result to RS
     4'b1011: {FA,FB} = 4'b01_00; //forward inst-1 result to RS
     4'b1100: {FA,FB} = 4'b01_00; //forward inst-1 result to RS 
     4'b1101: {FA,FB} = 4'b01_00; //forward inst-1 result to RS 
     4'b1110: {FA,FB} = 4'b01_00; //forward inst-1 result to RS 
     4'b1111: {FA,FB} = 4'b01_00; //forward inst-1 result to RS
  endcase
   
   
   end

endmodule
