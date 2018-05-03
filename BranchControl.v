`timescale 1ns / 1ps
/*********************************************************
 * File Name: BranchControl.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/22/18
 *
 * Purpose: This module is used to test branch conditions 
 *          and alert the processor if a branch is being 
 *          considered. If a branch is to be succesfully
 *          tested, "Branch" will be '1'.
 *          
 * Notes:  Rev. 4/22/18 - implemented, updated header
 *         
 *        
 *********************************************************/
module BranchControl(IRF, IREX, RS, RT, isBranch, doBranch);
input [31:0] IRF, IREX, RS, RT; 
output isBranch, doBranch;

reg Branch;

parameter    
   BEQ = 6'h04, 
   BNE = 6'h05,
   BLEZ= 6'h06,
   BGTZ= 6'h07;
   
//condition & opcode is branch//
assign doBranch = (Branch & isBranch);

//branch is in progress
assign isBranch = ((IRF[31:26] == BEQ) | (IRF[31:26] == BNE) |
                   (IRF[31:26] == BLEZ)|(IRF[31:26] == BGTZ))|
                   ((IREX[31:26] == BEQ) | (IREX[31:26] == BNE)|
                   (IREX[31:26] == BLEZ)|(IREX[31:26] == BGTZ));

always @(*) 
   //determine branch conditions
   casez (IREX[31:26])
      BEQ:  
            Branch = (RS == RT);
            
      BNE:  
            Branch = (RS != RT);
            
      BLEZ: 
            Branch = (RS[31] | (RS == 32'h0));
            
      BGTZ: 
            Branch = (~RS[31]);
            
      default: Branch = 1'b0;
   endcase

   
endmodule
