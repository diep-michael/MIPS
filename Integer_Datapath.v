`timescale 1ns / 1ps
/*********************************************************
 * File Name: Integer_Datapath.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/22/18
 *
 * Purpose: This module is the integer datapath for the CPU.
 *          It is used to perform arithmetic operations and to
 *          operate the flow of data throughout itself.
 *       INPUTS:
 *          Clock(clk) - min/max clock speed unknown at this point
 *          Reset(rst) - resets registers
 *          FS         - opcode/Function Select
 *          S_addr     - S Address for reading from regfile
 *          T_addr     - T Address for reading from regfile
 *          D_addr0    - $rd Address for writing to regfile
 *          D_addr1    - $rt Address for writing to regfile
 *          D_en       - Write enable for writing to regfile
 *          D          - Data to be written to Register File
 *          DT         - Data line used for immediate values
 *          T_sel      - If 1, ALU T input gets DT, else regfile T output
 *          DY         - Used to load registers with data from memory
 *          PC_in      - Used to change program counter value i.e. jumps
 *          Y_sel      - ALU_OUT mux select (see Line 88)
 *          HILO_ld    - Used to load HI/LO registers during mult./div. ops
 *          shamt      - shift amount used in shift instructions
 *
 *          EX_MEM_FWD - Forwarded data from instruction - 1
 *          MEM_WB_FWD - Forwarded data from instruction - 2
 *          IO_IN      - Data from I/O Module
 *          FWDA_SEL   - Forwarded Data select for S
 *          FWDB_SEL   - Forwarded Data select for T
 *
 *       OUTPUTS:
 *          ALU_OUT    - ALU output (see Line 88)
 *          RT_OUT     - data to write to memory
 *          C,V,N,Z    - Carry, Overflow, Negative, Zero flags from ALU
 *          RSB        - Data going into ALU's S port
 *          RTB        - Data going into ALU's T port
 *          RFS2RS     - Data coming from Reg File's S outport
 *
 * Notes:  Rev. 2/23/18 - updated header and comments
 *         Rev. 3/4/18  - updated header to reflect Project 4
 *                      - added pipeline registers:
 *                        ALU_Out, D_in, RS, RT
 *         Rev. 4/22/18 - updated header to reflect Senior Design
 *********************************************************/
module Integer_Datapath(clk, rst, D, FS, shamt, S_addr, EX_MEM_FWD, MEM_WB_FWD,
                        T_addr, D_addr0, D_addr1, D_en, DT, FWDA_SEL, FWDB_SEL,
                        HILO_ld, T_sel, DY, PC_in, Y_sel, RSB, RTB, RFS2RS, 
                        D_sel, ALU_OUT, RTOUT, C, V, N, Z, IO_IN);
               
input clk, rst, D_en, T_sel, HILO_ld;
input [1:0] D_sel, FWDA_SEL, FWDB_SEL;
input [2:0] Y_sel;
input [4:0] FS, shamt, S_addr, T_addr, D_addr0, D_addr1;
input [31:0] DT, DY, PC_in, D, EX_MEM_FWD, MEM_WB_FWD, IO_IN;

output reg [31:0] RTOUT;
output [31:0] ALU_OUT, RSB, RTB, RFS2RS;
output C, V, N, Z;

reg [31:0] HI, LO, D_in, RS, RT, ALU_Out, IO_IN_REG;
wire [31:0] RFS2RS, RFT2RT, TMUXout, Y_hi, Y_lo, FWDA_MUX, FWDB_MUX;
wire [4:0] D_mux;
///////////////////////////////////////////////
///////////////Register File///////////////////
///////////////////////////////////////////////
regfile32 rf        (
                     .clk(clk),
                     .rst(rst),
                     .S_addr(S_addr),
                     .T_addr(T_addr),
                     .D(D), //changed to D from ALU_OUT 
                     .D_en(D_en),
                     .D_addr(D_mux),
                     .S(RFS2RS),
                     .T(RFT2RT)
                    );
                    
///////////////////////////////////////////////
////////////Arithmetic Logic Unit//////////////
///////////////////////////////////////////////
ALU_top alu32      ( 
                    .S(FWDA_MUX),
                    .T(TMUXout),
                    .FS(FS),
                    .shamt(shamt),
                    .Y_hi(Y_hi),
                    .Y_lo(Y_lo),
                    .C(C), .V(V),
                    .N(N), .Z(Z)
                   );
 
////////D_in, ALU_out, RS, RT Registers/////////
///No load signals, standard 32 bit registers/////added register to hold RT for SW
always@(posedge clk, posedge rst)
   if (rst) {D_in, ALU_Out, RS, RT, RTOUT, IO_IN_REG} <= 192'b0; else
            {D_in, ALU_Out, RS, RT, RTOUT, IO_IN_REG} <= 
                                 {DY, Y_lo, RFS2RS, RFT2RT, FWDB_MUX, IO_IN};
 
//////////////HI LO Registers///////////////////
////// Used for mult. and div. operations///////
always @(posedge clk, posedge rst)
   if (rst) {HI, LO} <= 64'h0; else
      if (HILO_ld) {HI,LO} <= {Y_hi, Y_lo};
                                    
/////////////////////T mux/////////////////////
//Determines if the T input to the ALU gets the
// DT input, or the T output of the regfile 
///////////////////////////////////////////////                               
assign TMUXout = (T_sel) ? DT : FWDB_MUX;

/////////////ALU mux///////////////////////////
//Determines if the ALU_OUT output of the IDP
// gets Y_lo, DY, PC_in, LO or HI.
///////////////////////////////////////////////
assign ALU_OUT = (Y_sel==3'h0) ? ALU_Out: 
                 (Y_sel==3'h1) ? D_in :
                 (Y_sel==3'h2) ? PC_in :
                 (Y_sel==3'h3) ? LO :
                 (Y_sel==3'h4) ? HI : 
                 (Y_sel==3'h5) ? IO_IN_REG: ALU_Out;

/////D_MUX to determine D_addr///////////////
assign D_mux = (D_sel == 2'b00)? D_addr0 :
               (D_sel == 2'b01)? D_addr1 :
               (D_sel == 2'b10)? 5'd31   :
                                 5'd29;

/////////RS and RT outputs for branch checks///
assign RSB = FWDA_MUX;
assign RTB = FWDB_MUX;

///////Forwarding mux A///////////
assign FWDA_MUX = (FWDA_SEL == 2'b00)? RS : 
                  (FWDA_SEL == 2'b01)? EX_MEM_FWD :
                  (FWDA_SEL == 2'b10)? MEM_WB_FWD :
                                       RS; 
                                       
///////Forwarding mux B///////////
assign FWDB_MUX = (FWDB_SEL == 2'b00)? RT : 
                  (FWDB_SEL == 2'b01)? EX_MEM_FWD :
                  (FWDB_SEL == 2'b10)? MEM_WB_FWD :
                                       RT;                                        
                                 
endmodule
