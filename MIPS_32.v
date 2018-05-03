`timescale 1ns / 1ps
/*********************************************************
 * File Name: MIPS_32.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/18/18
 *
 * Purpose: This module contains the majority of operations
 *          performed by this ALU. It requires the same 
 *          inputs as the top level. The outputs are the 
 *          same except it does not output the N&Z flags.
 *          This module is combinational logic, the output
 *          will change when any input is changed (FS, S, T).
 *          Operations performed by this module can be 
 *          found in the parameter list or the case logic.
 *
 * Notes:   Rev. 2/2/18  - removed N Z flag output logic. 
 *                             fixed V C flag output logic.
 *          Rev. 2/23/18 - updated header
 *          Rev. 4/12/18 - added shamt for shift instructions 
 *          Rev. 4/18/18 - updated header and comments
 *********************************************************/
module MIPS_32(FS, shamt, S, T, V, C, Y_hi, Y_lo);
 input [4:0] FS, shamt;
 input [31:0] S, T;
 output reg V, C;
 output reg [31:0] Y_hi, Y_lo;
 
 integer S_int, T_int;
   
  localparam PASS_S = 5'h00, PASS_T = 5'h01, ADD = 5'h02,
             SUB = 5'h03,    ADDU = 5'h04,   SUBU = 5'h05,   SLT = 5'h06,
             SLTU = 5'h07,   AND = 5'h08,    OR = 5'h09,     XOR = 5'h0A,
             NOR = 5'h0B,    SLL = 5'h0C,    SRL = 5'h0D,    SRA = 5'h0E,
             INC = 5'h0F,    DEC = 5'h10,    INC4 = 5'h11,   DEC4 = 5'h12,
             ZEROS = 5'h13,  ONES = 5'h14,   SP_INIT = 5'h15,
             ANDI = 5'h16,   ORI = 5'h17,    LUI = 5'h18,   XORI = 5'h19,
             MUL = 5'h1E,    DIV = 5'h1F;
   
   always @(*)
      begin   
      Y_hi = 32'h0;
      casex (FS)
      
         //PASS_S
         PASS_S : begin
               Y_lo = S;
               {V,C} = 2'dx;
                 end
                 
         //PASS_T
         PASS_T : begin
               Y_lo = T;              
               {V,C} = 2'dx;
                 end
         
         //ADD
         ADD : begin        
               {C, Y_lo} = S + T;
              //V=1 iff pos + pos = neg || neg + neg = pos
               V = ((S[31] && T[31] && ~Y_lo[31])
                 | (~S[31] && ~T[31] && Y_lo[31]));
                 end
         
         //SUB
         SUB : begin
               {C,Y_lo} = S - T;  
               //V=1 iff pos - neg = neg || neg - pos = pos
               V = ((S[31] && ~T[31] && ~Y_lo[31])
                  | (~S[31] && T[31] && Y_lo[31]));
                 end
         
         //ADDU
         ADDU : begin
               {C, Y_lo} = S + T;
               V = C;
                 end
         
         //SUBU
         SUBU : begin
               {C, Y_lo} = S - T;
               V = C;
               end
               
         //SLT
         SLT : begin
               //cast to int for signed comparison (default datatype is unsigned)
               S_int = S;
               T_int = T;  
               
               if (S_int < T_int) Y_lo = 1; else Y_lo = 0;              
               {C,V} = 2'dx;
               end
               
         //SLTU
         SLTU : begin
               if (S < T) Y_lo = 1; else Y_lo = 0;
               {C,V} = 2'dx;
               end
               
         //AND
         AND : begin
               Y_lo = S & T;
               {V,C} = 2'dx;               
               end
               
         //OR
         OR : begin
               Y_lo = S | T;
               {V,C} = 2'dx;
               end
               
         //XOR
         XOR : begin
               Y_lo = S ^ T;
               {V,C} = 2'dx;
               end
               
         //NOR
         NOR : begin
               Y_lo = ~(S | T);
               {V,C} = 2'dx;
               end
               
         //SLL
         SLL : begin
               case(shamt)
                     5'h00:{C, Y_lo} = {1'b0,  T[31:0]       };
                     5'h01:{C, Y_lo} = {T[31], T[30:0],  1'b0};
                     5'h02:{C, Y_lo} = {T[30], T[29:0],  2'b0};
                     5'h03:{C, Y_lo} = {T[29], T[28:0],  3'b0};
                     5'h04:{C, Y_lo} = {T[28], T[27:0],  4'b0};
                     5'h05:{C, Y_lo} = {T[27], T[26:0],  5'b0};
                     5'h06:{C, Y_lo} = {T[26], T[25:0],  6'b0};
                     5'h07:{C, Y_lo} = {T[25], T[24:0],  7'b0};
                     5'h08:{C, Y_lo} = {T[24], T[23:0],  8'b0};
                     5'h09:{C, Y_lo} = {T[23], T[22:0],  9'b0};
                     5'h0A:{C, Y_lo} = {T[22], T[21:0], 10'b0};
                     5'h0B:{C, Y_lo} = {T[21], T[20:0], 11'b0};
                     5'h0C:{C, Y_lo} = {T[20], T[19:0], 12'b0};
                     5'h0D:{C, Y_lo} = {T[19], T[18:0], 13'b0};
                     5'h0E:{C, Y_lo} = {T[18], T[17:0], 14'b0};
                     5'h0F:{C, Y_lo} = {T[17], T[16:0], 15'b0};
                     5'h10:{C, Y_lo} = {T[16], T[15:0], 16'b0};
                     5'h11:{C, Y_lo} = {T[15], T[14:0], 17'b0};
                     5'h12:{C, Y_lo} = {T[14], T[13:0], 18'b0};
                     5'h13:{C, Y_lo} = {T[13], T[12:0], 19'b0};
                     5'h14:{C, Y_lo} = {T[12], T[11:0], 20'b0};
                     5'h15:{C, Y_lo} = {T[11], T[10:0], 21'b0};
                     5'h16:{C, Y_lo} = {T[10],  T[9:0], 22'b0};
                     5'h17:{C, Y_lo} = { T[9],  T[8:0], 23'b0};
                     5'h18:{C, Y_lo} = { T[8],  T[7:0], 24'b0};
                     5'h19:{C, Y_lo} = { T[7],  T[6:0], 25'b0};
                     5'h1A:{C, Y_lo} = { T[6],  T[5:0], 26'b0};
                     5'h1B:{C, Y_lo} = { T[5],  T[4:0], 27'b0};
                     5'h1C:{C, Y_lo} = { T[4],  T[3:0], 28'b0};
                     5'h1D:{C, Y_lo} = { T[3],  T[2:0], 29'b0};
                     5'h1E:{C, Y_lo} = { T[2],  T[1:0], 30'b0};
                     5'h1F:{C, Y_lo} = { T[1],    T[0], 31'b0};
                   default:{C, Y_lo} = {1'b0,  T[31:0]       };
                  endcase     
               V = 1'dx;
               end
               
         //SRL
         SRL : begin
               case(shamt)
                     5'h00:{C, Y_lo} = { 1'b0,         T[31: 0]};
                     5'h01:{C, Y_lo} = { T[0],  1'b0,  T[31: 1]};
                     5'h02:{C, Y_lo} = { T[1],  2'b0,  T[31: 2]};
                     5'h03:{C, Y_lo} = { T[2],  3'b0,  T[31: 3]};
                     5'h04:{C, Y_lo} = { T[3],  4'b0,  T[31: 4]};
                     5'h05:{C, Y_lo} = { T[4],  5'b0,  T[31: 5]};
                     5'h06:{C, Y_lo} = { T[5],  6'b0,  T[31: 6]};
                     5'h07:{C, Y_lo} = { T[6],  7'b0,  T[31: 7]};
                     5'h08:{C, Y_lo} = { T[7],  8'b0,  T[31: 8]};
                     5'h09:{C, Y_lo} = { T[8],  9'b0,  T[31: 9]};
                     5'h0A:{C, Y_lo} = { T[9], 10'b0,  T[31:10]};
                     5'h0B:{C, Y_lo} = {T[10], 11'b0,  T[31:11]};
                     5'h0C:{C, Y_lo} = {T[11], 12'b0,  T[31:12]};
                     5'h0D:{C, Y_lo} = {T[12], 13'b0,  T[31:13]};
                     5'h0E:{C, Y_lo} = {T[13], 14'b0,  T[31:14]};
                     5'h0F:{C, Y_lo} = {T[14], 15'b0,  T[31:15]};
                     5'h10:{C, Y_lo} = {T[15], 16'b0,  T[31:16]};
                     5'h11:{C, Y_lo} = {T[16], 17'b0,  T[31:17]};
                     5'h12:{C, Y_lo} = {T[17], 18'b0,  T[31:18]};
                     5'h13:{C, Y_lo} = {T[18], 19'b0,  T[31:19]};
                     5'h14:{C, Y_lo} = {T[19], 20'b0,  T[31:20]};
                     5'h15:{C, Y_lo} = {T[20], 21'b0,  T[31:21]};
                     5'h16:{C, Y_lo} = {T[21], 22'b0,  T[31:22]};
                     5'h17:{C, Y_lo} = {T[22], 23'b0,  T[31:23]};
                     5'h18:{C, Y_lo} = {T[23], 24'b0,  T[31:24]};
                     5'h19:{C, Y_lo} = {T[24], 25'b0,  T[31:25]};
                     5'h1A:{C, Y_lo} = {T[25], 26'b0,  T[31:26]};
                     5'h1B:{C, Y_lo} = {T[26], 27'b0,  T[31:27]};
                     5'h1C:{C, Y_lo} = {T[27], 28'b0,  T[31:28]};
                     5'h1D:{C, Y_lo} = {T[28], 29'b0,  T[31:29]};
                     5'h1E:{C, Y_lo} = {T[29], 30'b0,  T[31:30]};
                     5'h1F:{C, Y_lo} = {T[30], 31'b0,     T[31]};
                   default:{C, Y_lo} = { 1'b0,         T[31: 0]};
                  endcase     
               V = 1'dx;
               end   
               
         //SRA
         SRA : begin
               case(shamt)
                     5'h00:{C, Y_lo} = { 1'b0,               T[31: 0]};
                     5'h01:{C, Y_lo} = { T[0],  {1{T[31]}},  T[31: 1]};
                     5'h02:{C, Y_lo} = { T[1],  {2{T[31]}},  T[31: 2]};
                     5'h03:{C, Y_lo} = { T[2],  {3{T[31]}},  T[31: 3]};
                     5'h04:{C, Y_lo} = { T[3],  {4{T[31]}},  T[31: 4]};
                     5'h05:{C, Y_lo} = { T[4],  {5{T[31]}},  T[31: 5]};
                     5'h06:{C, Y_lo} = { T[5],  {6{T[31]}},  T[31: 6]};
                     5'h07:{C, Y_lo} = { T[6],  {7{T[31]}},  T[31: 7]};
                     5'h08:{C, Y_lo} = { T[7],  {8{T[31]}},  T[31: 8]};
                     5'h09:{C, Y_lo} = { T[8],  {9{T[31]}},  T[31: 9]};
                     5'h0A:{C, Y_lo} = { T[9], {10{T[31]}},  T[31:10]};
                     5'h0B:{C, Y_lo} = {T[10], {11{T[31]}},  T[31:11]};
                     5'h0C:{C, Y_lo} = {T[11], {12{T[31]}},  T[31:12]};
                     5'h0D:{C, Y_lo} = {T[12], {13{T[31]}},  T[31:13]};
                     5'h0E:{C, Y_lo} = {T[13], {14{T[31]}},  T[31:14]};
                     5'h0F:{C, Y_lo} = {T[14], {15{T[31]}},  T[31:15]};
                     5'h10:{C, Y_lo} = {T[15], {16{T[31]}},  T[31:16]};
                     5'h11:{C, Y_lo} = {T[16], {17{T[31]}},  T[31:17]};
                     5'h12:{C, Y_lo} = {T[17], {18{T[31]}},  T[31:18]};
                     5'h13:{C, Y_lo} = {T[18], {19{T[31]}},  T[31:19]};
                     5'h14:{C, Y_lo} = {T[19], {20{T[31]}},  T[31:20]};
                     5'h15:{C, Y_lo} = {T[20], {21{T[31]}},  T[31:21]};
                     5'h16:{C, Y_lo} = {T[21], {22{T[31]}},  T[31:22]};
                     5'h17:{C, Y_lo} = {T[22], {23{T[31]}},  T[31:23]};
                     5'h18:{C, Y_lo} = {T[23], {24{T[31]}},  T[31:24]};
                     5'h19:{C, Y_lo} = {T[24], {25{T[31]}},  T[31:25]};
                     5'h1A:{C, Y_lo} = {T[25], {26{T[31]}},  T[31:26]};
                     5'h1B:{C, Y_lo} = {T[26], {27{T[31]}},  T[31:27]};
                     5'h1C:{C, Y_lo} = {T[27], {28{T[31]}},  T[31:28]};
                     5'h1D:{C, Y_lo} = {T[28], {29{T[31]}},  T[31:29]};
                     5'h1E:{C, Y_lo} = {T[29], {30{T[31]}},  T[31:30]};
                     5'h1F:{C, Y_lo} = {T[30], {31{T[31]}},     T[31]};
                   default:{C, Y_lo} = { 1'b0,         T[31: 0]};
                  endcase
               V = 1'dx;
               end
               
         //INC
         INC : begin
               {C, Y_lo} = S + 1 ;
               //V=1 iff S == 0x7fff_ffff
               V = (S == 32'h_7fff_ffff);
               end
               
         //DEC
         DEC : begin
               {C, Y_lo} = S - 1 ;
               //V=1 iff S == 0x8000_0000
               V = (S == 32'h_8000_0000);
               end
               
         //INC4
         INC4 : begin
               {C, Y_lo} = S + 4 ;
               //V=1 iff sign bit changes
               V = (S[31] && ~Y_lo[31]) | (~S[31] && Y_lo[31]);      
               end
               
         //DEC4
         DEC4 : begin
               {C, Y_lo} = S - 4 ;
               //V=1 iff sign bit changes
               V = (S[31] && ~Y_lo[31]) | (~S[31] && Y_lo[31]);                     
               end
         
         //ZEROS
         ZEROS : begin
               Y_lo = 32'h0;
               {V,C} = 2'dx;
               end
         
         //ONES
         ONES : begin
               Y_lo = 32'hFFFFFFFF;
               {V,C} = 2'dx;
               end
         
         //SP_INIT
         SP_INIT : begin
               Y_lo = 32'h3FC;
               {V,C} = 2'dx;
               end
         
         //ANDI
         ANDI : begin
               Y_lo = (S & {16'h0 , T[15:0]});
               {V,C} = 2'dx;
               end
               
         //ORI
         ORI : begin
               Y_lo = (S | {16'h0 , T[15:0]});
               {V,C} = 2'dx;
               end
               
         //LUI
         LUI : begin
               Y_lo = {T[15:0], 16'h0};
               {V,C} = 2'dx;
               end
               
         //XORI
         XORI : begin
               Y_lo = (S ^ {16'h0 , T[15:0]});
               {V,C} = 2'dx;
               end
         endcase
      end
endmodule
